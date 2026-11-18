/// <summary>
/// The delivery workflow: creating orders from a POS receipt or a posted sales invoice, assigning a driver,
/// sending the order out, and finishing it as delivered, failed or cancelled. Every status change is logged.
/// The pages only call this codeunit; the rules live here.
/// </summary>
codeunit 50207 "Delivery Management"
{
    var
        ReceiptNotPostedErr: Label 'Receipt %1 is not completed yet. A delivery can only be created for a completed sale.', Comment = '%1 = receipt no.';
        AlreadyExistsErr: Label 'Delivery order %1 already exists for %2. Open it or cancel it first.', Comment = '%1 = delivery order no., %2 = receipt or invoice no.';
        WrongStatusErr: Label 'Delivery order %1 is %2, so this action is not possible.', Comment = '%1 = order no., %2 = status';
        DriverBlockedErr: Label 'Driver %1 is blocked.', Comment = '%1 = driver no.';
        DriverOffDutyErr: Label 'Driver %1 is off duty.', Comment = '%1 = driver no.';
        DriverStoreErr: Label 'Driver %1 works for store %2 and cannot deliver orders of store %3.', Comment = '%1 = driver, %2 = driver store, %3 = order store';
        AddressMissingErr: Label 'Enter the delivery address of order %1 first.', Comment = '%1 = order no.';
        CollectedAmountErr: Label 'The cash to collect on delivery is %1. Enter exactly that amount.', Comment = '%1 = amount';
        NothingToCollectErr: Label 'Nothing is to be collected on this delivery. Leave the collected amount at 0.';
        ReasonRequiredErr: Label 'Enter the reason why the delivery failed.';
        MaxAttemptsErr: Label 'Order %1 already left %2 times, which is the maximum in Delivery Setup. Create a new order or raise the limit.', Comment = '%1 = order no., %2 = attempts';
        CreatedFromReceiptTxt: Label 'Created from POS receipt %1.', Comment = '%1 = receipt no.';
        CreatedFromInvoiceTxt: Label 'Created from posted sales invoice %1.', Comment = '%1 = invoice no.';
        AssignedTxt: Label 'Assigned to driver %1.', Comment = '%1 = driver no.';
        UnassignedTxt: Label 'Driver removed.';
        OutTxt: Label 'Left for delivery (attempt %1).', Comment = '%1 = attempt number';
        DeliveredTxt: Label 'Delivered. Received by %1.', Comment = '%1 = name';
        CollectedTxt: Label 'Cash collected %1, payment %2 posted.', Comment = '%1 = amount, %2 = document no.';
        FailedTxt: Label 'Delivery failed: %1', Comment = '%1 = reason';
        CancelledTxt: Label 'Cancelled.';
        ReopenedTxt: Label 'Reopened.';

    // -------------------------------------------------------------- creating orders

    /// <summary>Creates a delivery order for a completed POS receipt. Returns the order number.</summary>
    procedure CreateFromReceipt(Receipt: Record "POS Receipt Header"): Code[20]
    var
        Order: Record "Delivery Order";
    begin
        if Receipt.Status <> Receipt.Status::Posted then
            Error(ReceiptNotPostedErr, Receipt."No.");
        CheckNoActiveOrder(Receipt."No.", Receipt."Posted Sales Invoice No.");

        Order.Init();
        Order."Receipt No." := Receipt."No.";
        Order."Posted Sales Invoice No." := Receipt."Posted Sales Invoice No.";
        Order."Store No." := Receipt."Store No.";
        Order."Order Amount" := Receipt."Total Amount";
        // A delivery store receipt carries the delivery client chosen on the register; any other receipt keeps the old behaviour.
        if Receipt."Delivery Client No." <> '' then
            Order."Customer No." := Receipt."Delivery Client No."
        else
            Order."Customer No." := Receipt."Customer No.";
        Order.Insert(true);
        Order.FillFromCustomer();
        FillZoneFromClient(Order);
        SetPaymentFromInvoice(Order);
        Order.Modify(true);
        Log(Order, StrSubstNo(CreatedFromReceiptTxt, Receipt."No."));
        AssignChosenDriver(Order, Receipt."Delivery Driver No.");
        exit(Order."No.");
    end;

    /// <summary>Creates a delivery order for any posted sales invoice, for example one from the normal sales process.</summary>
    procedure CreateFromInvoice(InvoiceNo: Code[20]): Code[20]
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Receipt: Record "POS Receipt Header";
        Order: Record "Delivery Order";
    begin
        SalesInvoiceHeader.Get(InvoiceNo);
        SalesInvoiceHeader.CalcFields("Amount Including VAT");

        // An invoice that came from the register is linked to its receipt, so both ways of creating an order see each other.
        Receipt.SetRange("Posted Sales Invoice No.", InvoiceNo);
        if Receipt.FindFirst() then
            CheckNoActiveOrder(Receipt."No.", InvoiceNo)
        else
            CheckNoActiveOrder('', InvoiceNo);

        Order.Init();
        Order."Posted Sales Invoice No." := InvoiceNo;
        Order."Order Amount" := SalesInvoiceHeader."Amount Including VAT";
        Order."Customer No." := SalesInvoiceHeader."Sell-to Customer No.";
        if Receipt."No." <> '' then begin
            Order."Receipt No." := Receipt."No.";
            Order."Store No." := Receipt."Store No.";
        end;
        Order.Insert(true);
        Order.FillFromCustomer();
        if SalesInvoiceHeader."Ship-to Address" <> '' then begin
            Order.Address := SalesInvoiceHeader."Ship-to Address";
            Order."Address 2" := SalesInvoiceHeader."Ship-to Address 2";
            Order.City := SalesInvoiceHeader."Ship-to City";
            Order."Post Code" := SalesInvoiceHeader."Ship-to Post Code";
        end;
        if SalesInvoiceHeader."Ship-to Contact" <> '' then
            Order."Contact Name" := SalesInvoiceHeader."Ship-to Contact";
        SetPaymentFromInvoice(Order);
        Order.Modify(true);
        Log(Order, StrSubstNo(CreatedFromInvoiceTxt, InvoiceNo));
        exit(Order."No.");
    end;

    local procedure FillZoneFromClient(var Order: Record "Delivery Order")
    var
        Client: Record "Delivery Client";
    begin
        if not Client.Get(Order."Customer No.") then
            exit;
        if Client."Delivery Zone Code" <> '' then
            Order.Validate("Zone Code", Client."Delivery Zone Code");
    end;

    /// <summary>
    /// The driver chosen at the register is assigned to the new order. If that driver cannot take it any more
    /// (blocked, off duty, another store), the order is simply left unassigned for the dispatcher.
    /// </summary>
    local procedure AssignChosenDriver(var Order: Record "Delivery Order"; DriverNo: Code[20])
    var
        Driver: Record "Delivery Driver";
    begin
        if DriverNo = '' then
            exit;
        if not Driver.Get(DriverNo) then
            exit;
        if Driver.Blocked or (Driver.Status = Driver.Status::"Off Duty") then
            exit;
        if (Driver."Store No." <> '') and (Order."Store No." <> '') and (Driver."Store No." <> Order."Store No.") then
            exit;
        AssignDriver(Order, DriverNo);
    end;

    local procedure CheckNoActiveOrder(ReceiptNo: Code[20]; InvoiceNo: Code[20])
    var
        Order: Record "Delivery Order";
    begin
        Order.SetFilter(Status, '<>%1', Order.Status::Cancelled);
        if ReceiptNo <> '' then begin
            Order.SetRange("Receipt No.", ReceiptNo);
            if Order.FindFirst() then
                Error(AlreadyExistsErr, Order."No.", ReceiptNo);
            Order.SetRange("Receipt No.");
        end;
        if InvoiceNo <> '' then begin
            Order.SetRange("Posted Sales Invoice No.", InvoiceNo);
            if Order.FindFirst() then
                Error(AlreadyExistsErr, Order."No.", InvoiceNo);
        end;
    end;

    /// <summary>An invoice with an open balance is cash on delivery for that balance; a paid invoice is prepaid.</summary>
    local procedure SetPaymentFromInvoice(var Order: Record "Delivery Order")
    var
        OpenAmount: Decimal;
    begin
        OpenAmount := GetOpenInvoiceAmount(Order."Posted Sales Invoice No.");
        if OpenAmount > 0 then begin
            Order."Payment Mode" := Order."Payment Mode"::"Cash on Delivery";
            Order."Amount to Collect" := OpenAmount;
        end else begin
            Order."Payment Mode" := Order."Payment Mode"::Prepaid;
            Order."Amount to Collect" := 0;
        end;
    end;

    /// <summary>What the customer still owes on the invoice, in local currency. 0 when the invoice is paid or there is none.</summary>
    procedure GetOpenInvoiceAmount(InvoiceNo: Code[20]): Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if InvoiceNo = '' then
            exit(0);
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange("Document No.", InvoiceNo);
        CustLedgerEntry.SetRange(Open, true);
        if CustLedgerEntry.FindFirst() then begin
            CustLedgerEntry.CalcFields("Remaining Amt. (LCY)");
            exit(CustLedgerEntry."Remaining Amt. (LCY)");
        end;
        exit(0);
    end;

    /// <summary>The cash the driver must collect now. For an invoice it is the balance at this moment; otherwise the amount on the order.</summary>
    procedure GetAmountToCollect(Order: Record "Delivery Order"): Decimal
    begin
        if Order."Payment Mode" = Order."Payment Mode"::Prepaid then
            exit(0);
        if Order."Posted Sales Invoice No." <> '' then
            exit(GetOpenInvoiceAmount(Order."Posted Sales Invoice No."));
        exit(Order."Amount to Collect");
    end;

    // -------------------------------------------------------------- driver

    procedure AssignDriver(var Order: Record "Delivery Order"; DriverNo: Code[20])
    var
        Driver: Record "Delivery Driver";
    begin
        TestStatus(Order, Order.Status::New, Order.Status::Assigned);
        Driver.Get(DriverNo);
        if Driver.Blocked then
            Error(DriverBlockedErr, DriverNo);
        if Driver.Status = Driver.Status::"Off Duty" then
            Error(DriverOffDutyErr, DriverNo);
        if (Driver."Store No." <> '') and (Order."Store No." <> '') and (Driver."Store No." <> Order."Store No.") then
            Error(DriverStoreErr, DriverNo, Driver."Store No.", Order."Store No.");

        Order."Driver No." := DriverNo;
        Order.Status := Order.Status::Assigned;
        Order."Assigned At" := CurrentDateTime();
        Order.Modify(true);
        Log(Order, StrSubstNo(AssignedTxt, DriverNo));
    end;

    procedure UnassignDriver(var Order: Record "Delivery Order")
    begin
        TestStatus(Order, Order.Status::Assigned, Order.Status::Assigned);
        Order."Driver No." := '';
        Order.Status := Order.Status::New;
        Order."Assigned At" := 0DT;
        Order.Modify(true);
        Log(Order, UnassignedTxt);
    end;

    // -------------------------------------------------------------- on the road

    /// <summary>The driver leaves with the order.</summary>
    procedure Dispatch(var Order: Record "Delivery Order")
    begin
        TestStatus(Order, Order.Status::Assigned, Order.Status::Assigned);
        Order.TestField("Driver No.");
        if Order.Address = '' then
            Error(AddressMissingErr, Order."No.");

        Order.Status := Order.Status::"Out for Delivery";
        Order."Dispatched At" := CurrentDateTime();
        Order.Attempts += 1;
        Order.Modify(true);
        UpdateDriverStatus(Order."Driver No.");
        Log(Order, StrSubstNo(OutTxt, Order.Attempts));
    end;

    /// <summary>
    /// The goods arrived. On cash on delivery the cash collected must equal what is due, and it is posted as a
    /// customer payment applied to the invoice. If anything fails nothing is saved.
    /// </summary>
    procedure CompleteDelivery(var Order: Record "Delivery Order"; ReceivedBy: Text[100]; CollectedAmount: Decimal)
    var
        DeliveryPostCollection: Codeunit "Delivery Post Collection";
        ToCollect: Decimal;
        PaymentDocNo: Code[20];
        
    begin
        TestStatus(Order, Order.Status::"Out for Delivery", Order.Status::"Out for Delivery");

        ToCollect := GetAmountToCollect(Order);
        if ToCollect > 0 then begin
            if CollectedAmount <> ToCollect then
                Error(CollectedAmountErr, ToCollect);
            PaymentDocNo := DeliveryPostCollection.PostCollection(Order, CollectedAmount);
            Order."Amount to Collect" := ToCollect;
            Order."Collected Amount" := CollectedAmount;
            Order."Collection Document No." := PaymentDocNo;
        end else
            if CollectedAmount <> 0 then
                Error(NothingToCollectErr);

        Order.Status := Order.Status::Delivered;
        Order."Delivered At" := CurrentDateTime();
        Order."Completed Date" := WorkDate();
        Order."Received By" := ReceivedBy;
        Order.Modify(true);
        UpdateReceiptHeader(Order."Receipt No.", Order.Status);

        UpdateDriverStatus(Order."Driver No.");
        Log(Order, StrSubstNo(DeliveredTxt, ReceivedBy));
        if PaymentDocNo <> '' then
            Log(Order, StrSubstNo(CollectedTxt, CollectedAmount, PaymentDocNo));
    end;

    /// <summary>
    /// UpdateReceiptHeader.
    /// </summary>
    /// <param name="Receipt No.">Code[20].</param>
    /// <param name="DeliveryStatus">Enum "Delivery Status".</param>
    procedure UpdateReceiptHeader("Receipt No.":Code[20]; DeliveryStatus: Enum "Delivery Status")
    var
        POSHeader: Record "POS Receipt Header";
    begin
        POSHeader.SetRange("No.", "Receipt No.");
        if POSHeader.FindFirst() then begin
            POSHeader."Delivery Status" := DeliveryStatus;
            POSHeader.Modify();
        end;
    end;

    procedure FailDelivery(var Order: Record "Delivery Order"; Reason: Text[100])
    begin
        TestStatus(Order, Order.Status::"Out for Delivery", Order.Status::"Out for Delivery");
        if Reason = '' then
            Error(ReasonRequiredErr);

        Order.Status := Order.Status::Failed;
        Order."Failure Reason" := Reason;
        Order."Completed Date" := WorkDate();
        Order.Modify(true);
        UpdateReceiptHeader(Order."Receipt No.", Order.Status);
        UpdateDriverStatus(Order."Driver No.");
        Log(Order, StrSubstNo(FailedTxt, Reason));
    end;

    // -------------------------------------------------------------- cancel and reopen

    procedure Cancel(var Order: Record "Delivery Order")
    begin
        TestStatus(Order, Order.Status::New, Order.Status::Assigned);
        Order.Status := Order.Status::Cancelled;
        Order."Completed Date" := WorkDate();
        Order.Modify(true);
        UpdateReceiptHeader(Order."Receipt No.", Order.Status);
        Log(Order, CancelledTxt);
    end;

    /// <summary>Puts a failed or cancelled order back to New so it can be sent again.</summary>
    procedure Reopen(var Order: Record "Delivery Order")
    var
        DeliverySetup: Record "Delivery Setup";
    begin
        TestStatus(Order, Order.Status::Failed, Order.Status::Cancelled);
        DeliverySetup.GetSetup();
        if (Order.Status = Order.Status::Failed) and (Order.Attempts >= DeliverySetup."Max Delivery Attempts") then
            Error(MaxAttemptsErr, Order."No.", Order.Attempts);

        Order.Status := Order.Status::New;
        Order."Driver No." := '';
        Order."Assigned At" := 0DT;
        Order."Dispatched At" := 0DT;
        Order."Failure Reason" := '';
        Order."Completed Date" := 0D;
        Order.Modify(true);
        UpdateReceiptHeader(Order."Receipt No.", Order.Status);
        Log(Order, ReopenedTxt);
    end;

    // -------------------------------------------------------------- helpers

    local procedure TestStatus(Order: Record "Delivery Order"; Allowed1: Enum "Delivery Status"; Allowed2: Enum "Delivery Status")
    begin
        if (Order.Status <> Allowed1) and (Order.Status <> Allowed2) then
            Error(WrongStatusErr, Order."No.", Order.Status);
    end;

    /// <summary>A driver with an order on the road is On Delivery; otherwise Available. Off Duty is never changed by itself.</summary>
    local procedure UpdateDriverStatus(DriverNo: Code[20])
    var
        Driver: Record "Delivery Driver";
        Order: Record "Delivery Order";
    begin
        if DriverNo = '' then
            exit;
        if not Driver.Get(DriverNo) then
            exit;
        if Driver.Status = Driver.Status::"Off Duty" then
            exit;
        Order.SetRange("Driver No.", DriverNo);
        Order.SetRange(Status, Order.Status::"Out for Delivery");
        if Order.IsEmpty() then
            Driver.Status := Driver.Status::Available
        else
            Driver.Status := Driver.Status::"On Delivery";
        Driver.Modify();
    end;

    local procedure Log(Order: Record "Delivery Order"; Description: Text)
    var
        StatusLog: Record "Delivery Status Log";
    begin
        StatusLog.Init();
        StatusLog."Delivery No." := Order."No.";
        StatusLog."Date Time" := CurrentDateTime();
        StatusLog.Status := Order.Status;
        StatusLog."User ID" := CopyStr(UserId(), 1, MaxStrLen(StatusLog."User ID"));
        StatusLog."Driver No." := Order."Driver No.";
        StatusLog.Description := CopyStr(Description, 1, MaxStrLen(StatusLog.Description));
        StatusLog.Insert();
    end;
}
