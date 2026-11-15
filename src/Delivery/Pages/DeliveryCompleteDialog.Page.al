page 50229 "Delivery Complete Dialog"
{
    Caption = 'Delivered';
    PageType = StandardDialog;

    layout
    {
        area(Content)
        {
            group(Info)
            {
                ShowCaption = false;

                field(OrderNoField; OrderNo)
                {
                    ApplicationArea = All;
                    Caption = 'Delivery Order';
                    Editable = false;
                }
                field(CustomerField; CustomerName)
                {
                    ApplicationArea = All;
                    Caption = 'Customer';
                    Editable = false;
                }
            }
            group(Receipt)
            {
                ShowCaption = false;

                field(ReceivedByField; ReceivedBy)
                {
                    ApplicationArea = All;
                    Caption = 'Received By';
                    ToolTip = 'Specifies who took the delivery.';
                    ShowMandatory = true;
                }
            }
            group(Cash)
            {
                Caption = 'Cash on Delivery';
                Visible = AmountToCollect > 0;

                field(DueField; AmountToCollect)
                {
                    ApplicationArea = All;
                    Caption = 'Amount to Collect';
                    Editable = false;
                    AutoFormatType = 1;
                }
                field(CollectedField; Collected)
                {
                    ApplicationArea = All;
                    Caption = 'Cash Collected';
                    ToolTip = 'Specifies the cash received from the customer. It must equal the amount to collect.';
                    AutoFormatType = 1;
                }
            }
        }
    }

    var
        OrderNo: Code[20];
        CustomerName: Text[100];
        ReceivedBy: Text[100];
        AmountToCollect: Decimal;
        Collected: Decimal;

    procedure SetContext(NewOrderNo: Code[20]; NewCustomerName: Text[100]; DefaultReceiver: Text[100]; NewAmountToCollect: Decimal)
    begin
        OrderNo := NewOrderNo;
        CustomerName := NewCustomerName;
        ReceivedBy := DefaultReceiver;
        AmountToCollect := NewAmountToCollect;
        Collected := NewAmountToCollect;
    end;

    procedure GetResult(var NewReceivedBy: Text[100]; var NewCollected: Decimal)
    begin
        NewReceivedBy := ReceivedBy;
        NewCollected := Collected;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = Action::OK then
            if ReceivedBy = '' then
                Error(ReceiverRequiredErr);
        exit(true);
    end;

    var
        ReceiverRequiredErr: Label 'Enter who received the delivery.';
}
