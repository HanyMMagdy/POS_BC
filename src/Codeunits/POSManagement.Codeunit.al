/// <summary>
/// Business rules of the register: finding items, building the receipt, totals, hold / recall / void.
/// Nothing in here knows about JSON or the browser.
/// </summary>
codeunit 50200 "POS Management"
{
    var
        POSSession: Codeunit "POS Session";
        QtyMustBePositiveErr: Label 'Quantity must be greater than zero.';
        NothingToHoldErr: Label 'There is nothing to hold. Add at least one item first.';
        DiscountNotAllowedErr: Label 'Discounts are disabled in POS Setup.';
        DiscountTooHighErr: Label 'The maximum line discount is %1%.', Comment = '%1 = percentage';
        CustomerBlockedErr: Label 'Customer %1 is blocked and cannot be used for a sale.', Comment = '%1 = customer no.';
        NotYourReceiptErr: Label 'Receipt %1 was put on hold by another cashier. Only an administrator can recall it.', Comment = '%1 = receipt no.';
        NotOnHoldErr: Label 'Receipt %1 is not on hold.', Comment = '%1 = receipt no.';
        UnknownPaymentMethodErr: Label 'Payment method %1 is not set up.', Comment = '%1 = payment method code';
        PaymentAmountErr: Label 'A payment amount must be greater than zero.';

    // ------------------------------------------------------------------
    // Receipt life cycle
    // ------------------------------------------------------------------

    /// <summary>Finds the receipt the cashier is working on right now (open and not on hold).</summary>
    procedure FindCurrentReceipt(var Header: Record "POS Receipt Header"): Boolean
    var
        Found: Boolean;
    begin
        Header.Reset();
        Header.SetCurrentKey("Cashier ID", Status, "On Hold");
        Header.SetRange("Cashier ID", POSSession.GetCashierId());
        Header.SetRange(Status, Header.Status::Open);
        Header.SetRange("On Hold", false);
        Found := Header.FindFirst();
        Header.Reset();
        exit(Found);
    end;

    procedure CreateReceipt(var Header: Record "POS Receipt Header")
    begin
        Header.Init();
        Header."No." := '';
        Header.Insert(true);
    end;

    procedure FindLastPosted(var Header: Record "POS Receipt Header"): Boolean
    begin
        Header.Reset();
        Header.SetCurrentKey("Cashier ID", Status, "On Hold");
        Header.SetRange("Cashier ID", POSSession.GetCashierId());
        Header.SetRange(Status, Header.Status::Posted);
        if Header.FindLast() then begin
            Header.Reset();
            exit(true);
        end;
        Header.Reset();
        exit(false);
    end;

    procedure HoldReceipt(var Header: Record "POS Receipt Header")
    begin
        if not HasLines(Header) then
            Error(NothingToHoldErr);
        Header."On Hold" := true;
        Header.Modify();
    end;

    procedure RecallReceipt(ReceiptNo: Code[20])
    var
        Current: Record "POS Receipt Header";
        Held: Record "POS Receipt Header";
    begin
        Held.Get(ReceiptNo);
        if (Held.Status <> Held.Status::Open) or (not Held."On Hold") then
            Error(NotOnHoldErr, ReceiptNo);

        // Cashiers recall their own sales. An administrator can also take over a sale held by another cashier;
        // it then belongs to the administrator and the receipt remembers who held it.
        if Held."Cashier ID" <> POSSession.GetCashierId() then begin
            if not POSSession.IsAdmin() then
                Error(NotYourReceiptErr, ReceiptNo);
            Held."Recalled From" := Held."Cashier ID";
            Held."Cashier ID" := POSSession.GetCashierId();
        end;

        if FindCurrentReceipt(Current) then
            if HasLines(Current) then begin
                Current."On Hold" := true;
                Current.Modify();
            end else
                Current.Delete(true);

        Held."On Hold" := false;
        Held.Modify();
    end;

    /// <summary>Empty receipts are deleted; receipts with lines are kept as Voided for the audit trail.</summary>
    procedure VoidReceipt(var Header: Record "POS Receipt Header")
    begin
        if HasLines(Header) then begin
            Header.Status := Header.Status::Voided;
            Header."On Hold" := false;
            Header.Modify();
        end else
            Header.Delete(true);
    end;

    procedure CountHeld(): Integer
    var
        Header: Record "POS Receipt Header";
    begin
        Header.SetCurrentKey("Cashier ID", Status, "On Hold");
        // Administrators see the held sales of every cashier; other users only their own.
        if not POSSession.IsAdmin() then
            Header.SetRange("Cashier ID", POSSession.GetCashierId());
        Header.SetRange(Status, Header.Status::Open);
        Header.SetRange("On Hold", true);
        exit(Header.Count());
    end;

    procedure HasLines(Header: Record "POS Receipt Header"): Boolean
    var
        Line: Record "POS Receipt Line";
    begin
        Line.SetRange("Receipt No.", Header."No.");
        exit(not Line.IsEmpty());
    end;

    // ------------------------------------------------------------------
    // Items
    // ------------------------------------------------------------------

    /// <summary>Resolves what the cashier scanned or typed: bar code reference, item no. or GTIN.</summary>
    procedure FindItemByCode(ScannedCode: Text; var Item: Record Item): Boolean
    var
        ItemReference: Record "Item Reference";
    begin
        ScannedCode := DelChr(ScannedCode, '<>', ' ');
        if ScannedCode = '' then
            exit(false);

        if StrLen(ScannedCode) <= MaxStrLen(ItemReference."Reference No.") then begin
            ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
            ItemReference.SetRange("Reference No.", CopyStr(ScannedCode, 1, MaxStrLen(ItemReference."Reference No.")));
            if ItemReference.FindFirst() then
                if Item.Get(ItemReference."Item No.") then
                    exit(true);
        end;

        if StrLen(ScannedCode) <= MaxStrLen(Item."No.") then
            if Item.Get(CopyStr(ScannedCode, 1, MaxStrLen(Item."No."))) then
                exit(true);

        if StrLen(ScannedCode) <= MaxStrLen(Item.GTIN) then begin
            Item.Reset();
            Item.SetRange(GTIN, CopyStr(ScannedCode, 1, MaxStrLen(Item.GTIN)));
            if Item.FindFirst() then begin
                Item.Reset();
                exit(true);
            end;
            Item.Reset();
        end;
        exit(false);
    end;

    local procedure TestItemSellable(Item: Record Item)
    begin
        Item.TestField(Blocked, false);
        Item.TestField("Sales Blocked", false);
    end;

    procedure GetUnitPrice(Item: Record Item; CustomerNo: Code[20]): Decimal
    var
        UnitPrice: Decimal;
    begin
        UnitPrice := Item."Unit Price";
        OnAfterGetUnitPrice(Item, CustomerNo, UnitPrice);
        exit(UnitPrice);
    end;

    procedure GetVATPct(CustomerNo: Code[20]; Item: Record Item): Decimal
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if Customer.Get(CustomerNo) then
            if VATPostingSetup.Get(Customer."VAT Bus. Posting Group", Item."VAT Prod. Posting Group") then
                if VATPostingSetup."VAT Calculation Type" = VATPostingSetup."VAT Calculation Type"::"Normal VAT" then
                    exit(VATPostingSetup."VAT %");
        exit(0);
    end;

    // ------------------------------------------------------------------
    // Receipt lines
    // ------------------------------------------------------------------

    procedure AddItem(var Header: Record "POS Receipt Header"; ItemNo: Code[20]; Qty: Decimal)
    var
        Item: Record Item;
        Line: Record "POS Receipt Line";
        NextLineNo: Integer;
    begin
        if Qty <= 0 then
            Error(QtyMustBePositiveErr);

        Item.Get(ItemNo);
        TestItemSellable(Item);

        // Same item without a discount: just raise the quantity.
        Line.SetRange("Receipt No.", Header."No.");
        Line.SetRange("Item No.", Item."No.");
        Line.SetRange("Line Discount %", 0);
        if Line.FindFirst() then begin
            Line.Quantity += Qty;
            CalcLine(Line);
            Line.Modify();
        end else begin
            Line.Reset();
            Line.SetRange("Receipt No.", Header."No.");
            if Line.FindLast() then
                NextLineNo := Line."Line No." + 10000
            else
                NextLineNo := 10000;

            Line.Init();
            Line."Receipt No." := Header."No.";
            Line."Line No." := NextLineNo;
            Line."Item No." := Item."No.";
            Line.Description := Item.Description;
            Line."Unit of Measure Code" := Item."Base Unit of Measure";
            Line.Quantity := Qty;
            Line."Unit Price" := GetUnitPrice(Item, Header."Customer No.");
            Line."VAT %" := GetVATPct(Header."Customer No.", Item);
            CalcLine(Line);
            Line.Insert();
        end;
        RecalculateReceipt(Header);
    end;

    procedure SetLineQuantity(var Header: Record "POS Receipt Header"; LineNo: Integer; Qty: Decimal)
    var
        Line: Record "POS Receipt Line";
    begin
        Line.Get(Header."No.", LineNo);
        if Qty <= 0 then begin
            POSSession.RequireAdmin();
            Line.Delete();
        end
        else begin
            Line.Quantity := Qty;
            CalcLine(Line);
            Line.Modify();
        end;
        RecalculateReceipt(Header);
    end;

    procedure SetLineDiscount(var Header: Record "POS Receipt Header"; LineNo: Integer; DiscountPct: Decimal)
    var
        POSSetup: Record "POS Setup";
        Line: Record "POS Receipt Line";
    begin
        POSSetup.GetSetup();
        if DiscountPct < 0 then
            DiscountPct := 0;
        if DiscountPct > 0 then begin
            POSSession.RequireAdmin();
            if POSSetup."Max Line Discount %" = 0 then
                Error(DiscountNotAllowedErr);
            if DiscountPct > POSSetup."Max Line Discount %" then
                Error(DiscountTooHighErr, POSSetup."Max Line Discount %");
        end;
        Line.Get(Header."No.", LineNo);
        Line."Line Discount %" := DiscountPct;
        CalcLine(Line);
        Line.Modify();
        RecalculateReceipt(Header);
    end;

    procedure RemoveLine(var Header: Record "POS Receipt Header"; LineNo: Integer)
    var
        Line: Record "POS Receipt Line";
    begin
        POSSession.RequireAdmin();
        if Line.Get(Header."No.", LineNo) then
            Line.Delete();
        RecalculateReceipt(Header);
    end;

    procedure SetCustomer(var Header: Record "POS Receipt Header"; CustomerNo: Code[20])
    var
        Customer: Record Customer;
        Item: Record Item;
        Line: Record "POS Receipt Line";
    begin
        Customer.Get(CustomerNo);
        if Customer.Blocked <> Customer.Blocked::" " then
            Error(CustomerBlockedErr, CustomerNo);

        Header.Validate("Customer No.", CustomerNo);
        Header.Modify();

        // The VAT business posting group belongs to the customer, so the VAT % can change.
        Line.SetRange("Receipt No.", Header."No.");
        if Line.FindSet(true) then
            repeat
                if Item.Get(Line."Item No.") then begin
                    Line."VAT %" := GetVATPct(CustomerNo, Item);
                    Line.Modify();
                end;
            until Line.Next() = 0;
        RecalculateReceipt(Header);
    end;

    local procedure CalcLine(var Line: Record "POS Receipt Line")
    var
        Precision: Decimal;
    begin
        Precision := GetRoundingPrecision();
        Line."Line Discount Amount" := Round(Line.Quantity * Line."Unit Price" * Line."Line Discount %" / 100, Precision);
        Line."Line Amount" := Round(Line.Quantity * Line."Unit Price", Precision) - Line."Line Discount Amount";
    end;

    /// <summary>
    /// VAT is calculated per VAT % on the summed base, then rounded - the same way the sales document does it,
    /// so the receipt total matches the invoice that will be posted.
    /// </summary>
    procedure RecalculateReceipt(var Header: Record "POS Receipt Header")
    var
        Line: Record "POS Receipt Line";
        VATBase: Dictionary of [Decimal, Decimal];
        VATPct: Decimal;
        Precision: Decimal;
        Subtotal: Decimal;
        Discount: Decimal;
        VATAmount: Decimal;
    begin
        Precision := GetRoundingPrecision();
        Line.SetRange("Receipt No.", Header."No.");
        if Line.FindSet() then
            repeat
                Subtotal += Line."Line Amount";
                Discount += Line."Line Discount Amount";
                if VATBase.ContainsKey(Line."VAT %") then
                    VATBase.Set(Line."VAT %", VATBase.Get(Line."VAT %") + Line."Line Amount")
                else
                    VATBase.Add(Line."VAT %", Line."Line Amount");
            until Line.Next() = 0;

        foreach VATPct in VATBase.Keys() do
            VATAmount += Round(VATBase.Get(VATPct) * VATPct / 100, Precision);

        Header.Subtotal := Subtotal;
        Header."Discount Amount" := Discount;
        Header."VAT Amount" := VATAmount;
        Header."Total Amount" := Subtotal + VATAmount;
        Header.Modify();
    end;

    // ------------------------------------------------------------------
    // Payments
    // ------------------------------------------------------------------

    procedure ClearPayments(Header: Record "POS Receipt Header")
    var
        Payment: Record "POS Receipt Payment";
    begin
        Payment.SetRange("Receipt No.", Header."No.");
        Payment.DeleteAll();
    end;

    procedure AddPayment(Header: Record "POS Receipt Header"; MethodCode: Code[10]; Amount: Decimal)
    var
        PaymentMethod: Record "POS Payment Method";
        Payment: Record "POS Receipt Payment";
        NextLineNo: Integer;
    begin
        if Amount <= 0 then
            Error(PaymentAmountErr);
        if not PaymentMethod.Get(MethodCode) then
            Error(UnknownPaymentMethodErr, MethodCode);

        Payment.SetRange("Receipt No.", Header."No.");
        if Payment.FindLast() then
            NextLineNo := Payment."Line No." + 10000
        else
            NextLineNo := 10000;

        Payment.Init();
        Payment."Receipt No." := Header."No.";
        Payment."Line No." := NextLineNo;
        Payment."Payment Method Code" := PaymentMethod.Code;
        Payment."Payment Type" := PaymentMethod.Type;
        Payment."Posting Date" := Header."Posting Date";
        Payment.Amount := Round(Amount, GetRoundingPrecision());
        Payment.Insert();
    end;

    // ------------------------------------------------------------------
    // Helpers
    // ------------------------------------------------------------------

    procedure GetRoundingPrecision(): Decimal
    var
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get();
        if GLSetup."Amount Rounding Precision" = 0 then
            exit(0.01);
        exit(GLSetup."Amount Rounding Precision");
    end;

    /// <summary>Returns a list of problems that stop the register from working. Empty when setup is fine.</summary>
    procedure GetSetupIssues(var Issues: List of [Text])
    var
        POSSetup: Record "POS Setup";
        PaymentMethod: Record "POS Payment Method";
        Customer: Record Customer;
    begin
        POSSetup.GetSetup();
        if POSSetup."Receipt Nos." = '' then
            Issues.Add('Receipt Nos. is missing in POS Setup.');
        if POSSetup."Default Customer No." = '' then
            Issues.Add('Default Customer No. is missing in POS Setup.')
        else
            if not Customer.Get(POSSetup."Default Customer No.") then
                Issues.Add('The default customer in POS Setup does not exist.');
        if PaymentMethod.IsEmpty() then
            Issues.Add('No POS payment methods are defined.');
        PaymentMethod.SetRange("Balancing Account No.", '');
        if not PaymentMethod.IsEmpty() then
            Issues.Add('Every payment method needs a balancing account.');
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetUnitPrice(Item: Record Item; CustomerNo: Code[20]; var UnitPrice: Decimal)
    begin
    end;
}
