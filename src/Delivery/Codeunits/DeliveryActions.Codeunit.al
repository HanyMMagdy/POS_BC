/// <summary>
/// The questions the delivery pages ask the user (choose a driver, who received the goods, why it failed, are you sure),
/// and then a call to Delivery Management. Kept apart from the rules so those can be reused without dialogs.
/// </summary>
codeunit 50209 "Delivery Actions"
{
    var
        DeliveryMgt: Codeunit "Delivery Management";
        CancelQst: Label 'Cancel delivery order %1?', Comment = '%1 = order no.';

    /// <summary>The action on a POS receipt: creates the order and opens it.</summary>
    procedure CreateFromReceipt(Receipt: Record "POS Receipt Header")
    begin
        OpenOrder(DeliveryMgt.CreateFromReceipt(Receipt));
    end;

    procedure NewFromReceiptLookup()
    var
        Receipt: Record "POS Receipt Header";
        ReceiptsPage: Page "POS Receipts";
        DeliverySetup: Record "Delivery Setup";
    begin
        if DeliverySetup.Get() then;
        DeliverySetup.TestField("Default Delivery Store");
        Receipt.SetRange("Store No.", DeliverySetup."Default Delivery Store");
        Receipt.SetRange(Status, Receipt.Status::Posted);
        Receipt.SetRange("Delivery Status", Receipt."Delivery Status"::New);
        ReceiptsPage.SetTableView(Receipt);
        ReceiptsPage.LookupMode(true);
        if ReceiptsPage.RunModal() <> Action::LookupOK then
            exit;
        ReceiptsPage.GetRecord(Receipt);
        OpenOrder(DeliveryMgt.CreateFromReceipt(Receipt));
    end;

    procedure NewFromInvoiceLookup()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        InvoicesPage: Page "Posted Sales Invoices";
    begin
        InvoicesPage.SetTableView(SalesInvoiceHeader);
        InvoicesPage.LookupMode(true);
        if InvoicesPage.RunModal() <> Action::LookupOK then
            exit;
        InvoicesPage.GetRecord(SalesInvoiceHeader);
        OpenOrder(DeliveryMgt.CreateFromInvoice(SalesInvoiceHeader."No."));
    end;

    /// <summary>Lets the user pick one of the drivers who can take the order (not blocked, not off duty, right store).</summary>
    procedure AssignDriver(var Order: Record "Delivery Order")
    var
        Driver: Record "Delivery Driver";
        DriversPage: Page "Delivery Drivers";
    begin
        Driver.SetRange(Blocked, false);
        Driver.SetFilter(Status, '<>%1', Driver.Status::"Off Duty");
        if Order."Store No." <> '' then
            Driver.SetFilter("Store No.", '%1|%2', Order."Store No.", '');
        DriversPage.SetTableView(Driver);
        DriversPage.LookupMode(true);
        if DriversPage.RunModal() <> Action::LookupOK then
            exit;
        DriversPage.GetRecord(Driver);
        DeliveryMgt.AssignDriver(Order, Driver."No.");
    end;

    /// <summary>Asks who received the goods and, on cash on delivery, how much was collected.</summary>
    procedure Complete(var Order: Record "Delivery Order")
    var
        CompleteDialog: Page "Delivery Complete Dialog";
        ReceivedBy: Text[100];
        Collected: Decimal;
    begin
        Order.CalcFields("Customer Name");
        CompleteDialog.SetContext(Order."No.", Order."Customer Name", Order."Contact Name", DeliveryMgt.GetAmountToCollect(Order));
        if CompleteDialog.RunModal() <> Action::OK then
            exit;
        CompleteDialog.GetResult(ReceivedBy, Collected);
        DeliveryMgt.CompleteDelivery(Order, ReceivedBy, Collected);
    end;

    /// <summary>Asks why the delivery failed.</summary>
    procedure Fail(var Order: Record "Delivery Order")
    var
        FailDialog: Page "Delivery Fail Dialog";
        Reason: Text[100];
    begin
        FailDialog.SetContext(Order."No.");
        if FailDialog.RunModal() <> Action::OK then
            exit;
        FailDialog.GetResult(Reason);
        DeliveryMgt.FailDelivery(Order, Reason);
    end;

    procedure Cancel(var Order: Record "Delivery Order")
    begin
        if not Confirm(CancelQst, false, Order."No.") then
            exit;
        DeliveryMgt.Cancel(Order);
    end;

    local procedure OpenOrder(DeliveryNo: Code[20])
    var
        Order: Record "Delivery Order";
    begin
        Order.Get(DeliveryNo);
        Page.Run(Page::"Delivery Order", Order);
    end;
}


codeunit 50210 "New From Receipt Lookup"
{
    trigger OnRun()
    begin
        DeliveryActions.NewFromReceiptLookup();
    end;
    
    var
        DeliveryActions: Codeunit "Delivery Actions";
}

codeunit 50211 "New From Invoice Lookup"
{
    trigger OnRun()
    begin
        DeliveryActions.NewFromInvoiceLookup();
    end;
    
    var
        DeliveryActions: Codeunit "Delivery Actions";
}