/// <summary>
/// Posts a POS receipt in one transaction:
///   1. creates a sales invoice for the receipt customer and posts it (inventory, G/L, VAT, customer ledger),
///   2. posts one customer payment per tender, applied to that invoice, against the cash / bank account of the payment method,
///   3. marks the receipt as posted.
/// Any error rolls everything back, so the receipt is either fully posted or untouched.
/// </summary>
codeunit 50203 "POS Post Receipt"
{
    TableNo = "POS Receipt Header";
    Permissions = tabledata "Sales Header" = rimd,
                  tabledata "Sales Line" = rimd,
                  tabledata "Sales Invoice Header" = rimd,
                  tabledata "Sales Invoice Line" = rimd;

    trigger OnRun()
    begin
        PostReceipt(Rec);
    end;

    var
        NotOpenErr: Label 'Receipt %1 is %2 and cannot be posted.', Comment = '%1 = receipt no., %2 = status';
        NoLinesErr: Label 'Receipt %1 has no lines.', Comment = '%1 = receipt no.';
        NoPaymentsErr: Label 'There are no payments on receipt %1.', Comment = '%1 = receipt no.';
        NonCashTooHighErr: Label 'Card and other non-cash payments (%1) cannot be more than the amount due (%2). Only cash can give change.', Comment = '%1 = non-cash total, %2 = total due';
        NotEnoughErr: Label 'The payments (%1) do not cover the amount due (%2).', Comment = '%1 = tendered, %2 = due';
        InvoiceTotalDiffersErr: Label 'The posted invoice total is %1 but the receipt total is %2. Nothing was posted; check the VAT setup of the customer and items.', Comment = '%1 = invoice total, %2 = receipt total';
        InvoiceNotFoundErr: Label 'The posted sales invoice for receipt %1 could not be found.', Comment = '%1 = receipt no.';

    procedure PostReceipt(var Header: Record "POS Receipt Header")
    var
        PostedInvoiceNo: Code[20];
        InvoiceTotal: Decimal;
    begin
        CheckReceipt(Header);
        PostedInvoiceNo := PostSalesInvoice(Header, InvoiceTotal);

        // The sales document is the source of truth for VAT. If it disagrees with the screen, stop and roll back.
        if InvoiceTotal <> Header."Total Amount" then
            Error(InvoiceTotalDiffersErr, InvoiceTotal, Header."Total Amount");

        PostPayments(Header, PostedInvoiceNo);

        Header.Status := Header.Status::Posted;
        Header."On Hold" := false;
        Header."Posted Sales Invoice No." := PostedInvoiceNo;
        Header."Posted At" := CurrentDateTime();
        Header.Modify();
    end;

    local procedure CheckReceipt(Header: Record "POS Receipt Header")
    var
        Line: Record "POS Receipt Line";
        Payment: Record "POS Receipt Payment";
        NonCash: Decimal;
        Tendered: Decimal;
    begin
        if Header.Status <> Header.Status::Open then
            Error(NotOpenErr, Header."No.", Header.Status);

        Line.SetRange("Receipt No.", Header."No.");
        if Line.IsEmpty() then
            Error(NoLinesErr, Header."No.");

        Payment.SetRange("Receipt No.", Header."No.");
        if Payment.IsEmpty() then
            Error(NoPaymentsErr, Header."No.");

        Payment.CalcSums(Amount);
        Tendered := Payment.Amount;
        Payment.SetFilter("Payment Type", '<>%1', Payment."Payment Type"::Cash);
        Payment.CalcSums(Amount);
        NonCash := Payment.Amount;

        if NonCash > Header."Total Amount" then
            Error(NonCashTooHighErr, NonCash, Header."Total Amount");
        if Tendered < Header."Total Amount" then
            Error(NotEnoughErr, Tendered, Header."Total Amount");
    end;

    local procedure PostSalesInvoice(Header: Record "POS Receipt Header"; var InvoiceTotal: Decimal): Code[20]
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ReceiptLine: Record "POS Receipt Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesPost: Codeunit "Sales-Post";
        LineNo: Integer;
    begin
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", Header."Customer No.");
        SalesHeader.Validate("Currency Code", '');
        SalesHeader.Validate("Prices Including VAT", false);
        SalesHeader.Validate("Posting Date", Header."Posting Date");
        SalesHeader.Validate("Document Date", Header."Posting Date");
        if Header."Location Code" <> '' then
            SalesHeader.Validate("Location Code", Header."Location Code");
        SetStoreDimensions(Header."Store No.", SalesHeader);
        SalesHeader."External Document No." := Header."No.";
        SalesHeader."Posting Description" := CopyStr('POS ' + Header."No.", 1, MaxStrLen(SalesHeader."Posting Description"));
        SalesHeader.Modify(true);

        ReceiptLine.SetRange("Receipt No.", Header."No.");
        ReceiptLine.FindSet();
        repeat
            LineNo += 10000;
            SalesLine.Init();
            SalesLine."Document Type" := SalesHeader."Document Type";
            SalesLine."Document No." := SalesHeader."No.";
            SalesLine."Line No." := LineNo;
            SalesLine.Validate(Type, SalesLine.Type::Item);
            SalesLine.Validate("No.", ReceiptLine."Item No.");
            SalesLine.Insert(true);
            SalesLine.Validate("Unit of Measure Code", ReceiptLine."Unit of Measure Code");
            SalesLine.Validate(Quantity, ReceiptLine.Quantity);
            SalesLine.Validate("Unit Price", ReceiptLine."Unit Price");
            if ReceiptLine."Line Discount %" <> 0 then
                SalesLine.Validate("Line Discount %", ReceiptLine."Line Discount %");
            SalesLine.Modify(true);
        until ReceiptLine.Next() = 0;

        // Keep the commit out of the posting routine so a later failure (payments) rolls the invoice back too.
        SalesPost.SetSuppressCommit(true);
        SalesPost.Run(SalesHeader);

        SalesInvoiceHeader.SetRange("Pre-Assigned No.", SalesHeader."No.");
        if not SalesInvoiceHeader.FindLast() then
            Error(InvoiceNotFoundErr, Header."No.");
        SalesInvoiceHeader.CalcFields("Amount Including VAT");
        InvoiceTotal := SalesInvoiceHeader."Amount Including VAT";
        exit(SalesInvoiceHeader."No.");
    end;

    local procedure PostPayments(var Header: Record "POS Receipt Header"; PostedInvoiceNo: Code[20])
    var
        Payment: Record "POS Receipt Payment";
        Remaining: Decimal;
        Tendered: Decimal;
        Applied: Decimal;
    begin
        Remaining := Header."Total Amount";

        // Card and other payments are applied first; cash covers whatever is left, and cash is what gets change.
        Payment.SetRange("Receipt No.", Header."No.");
        Payment.SetFilter("Payment Type", '<>%1', Payment."Payment Type"::Cash);
        ApplyPayments(Payment, Header, PostedInvoiceNo, Remaining, Tendered);

        Payment.SetRange("Payment Type", Payment."Payment Type"::Cash);
        ApplyPayments(Payment, Header, PostedInvoiceNo, Remaining, Tendered);

        Applied := Header."Total Amount" - Remaining;
        Header."Amount Tendered" := Tendered;
        Header."Change Amount" := Tendered - Applied;
    end;

    local procedure ApplyPayments(var Payment: Record "POS Receipt Payment"; Header: Record "POS Receipt Header"; PostedInvoiceNo: Code[20]; var Remaining: Decimal; var Tendered: Decimal)
    var
        ApplyAmount: Decimal;
    begin
        if Payment.FindSet(true) then
            repeat
                Tendered += Payment.Amount;
                ApplyAmount := Payment.Amount;
                if ApplyAmount > Remaining then
                    ApplyAmount := Remaining;

                Payment."Applied Amount" := ApplyAmount;
                Payment.Modify();

                if ApplyAmount > 0 then begin
                    PostCustomerPayment(Header, Payment, PostedInvoiceNo, ApplyAmount);
                    Remaining -= ApplyAmount;
                end;
            until Payment.Next() = 0;
    end;

    local procedure PostCustomerPayment(Header: Record "POS Receipt Header"; Payment: Record "POS Receipt Payment"; PostedInvoiceNo: Code[20]; Amount: Decimal)
    var
        PaymentMethod: Record "POS Payment Method";
        GenJnlLine: Record "Gen. Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
        Store: Record "POS Store";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        PaymentMethod.Get(Payment."Payment Method Code");
        PaymentMethod.TestField("Balancing Account No.");
        SourceCodeSetup.Get();

        GenJnlLine.Init();
        GenJnlLine."Line No." := Payment."Line No.";
        GenJnlLine."Posting Date" := Header."Posting Date";
        GenJnlLine."Document Date" := Header."Posting Date";
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
        GenJnlLine."Document No." := Header."No.";
        GenJnlLine."External Document No." := Header."No.";
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
        GenJnlLine.Validate("Account No.", Header."Customer No.");
        GenJnlLine.Description := CopyStr('POS ' + Header."No." + ' ' + PaymentMethod.Description, 1, MaxStrLen(GenJnlLine.Description));
        GenJnlLine.Validate(Amount, -Amount);
        GenJnlLine."Bal. Account Type" := PaymentMethod."Balancing Account Type";
        GenJnlLine.Validate("Bal. Account No.", PaymentMethod."Balancing Account No.");
        GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Invoice;
        GenJnlLine."Applies-to Doc. No." := PostedInvoiceNo;
        GenJnlLine."Source Code" := SourceCodeSetup."Cash Receipt Journal";
        if Store.Get(Header."Store No.") then begin
            if Store."Global Dimension 1 Code" <> '' then
                GenJnlLine.Validate("Shortcut Dimension 1 Code", Store."Global Dimension 1 Code");
            if Store."Global Dimension 2 Code" <> '' then
                GenJnlLine.Validate("Shortcut Dimension 2 Code", Store."Global Dimension 2 Code");
        end;
        GenJnlPostLine.RunWithCheck(GenJnlLine);
    end;

    /// <summary>The store's global dimensions (for example department or branch) go onto the invoice and its G/L entries.</summary>
    local procedure SetStoreDimensions(StoreNo: Code[20]; var SalesHeader: Record "Sales Header")
    var
        Store: Record "POS Store";
    begin
        if StoreNo = '' then
            exit;
        if not Store.Get(StoreNo) then
            exit;
        if Store."Global Dimension 1 Code" <> '' then
            SalesHeader.Validate("Shortcut Dimension 1 Code", Store."Global Dimension 1 Code");
        if Store."Global Dimension 2 Code" <> '' then
            SalesHeader.Validate("Shortcut Dimension 2 Code", Store."Global Dimension 2 Code");
    end;
}
