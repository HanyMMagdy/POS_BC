page 50230 "Delivery Fail Dialog"
{
    Caption = 'Delivery Failed';
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
                field(ReasonField; Reason)
                {
                    ApplicationArea = All;
                    Caption = 'Reason';
                    ToolTip = 'Specifies why the delivery could not be made, for example the customer was not at home.';
                    ShowMandatory = true;
                }
            }
        }
    }

    var
        OrderNo: Code[20];
        Reason: Text[100];

    procedure SetContext(NewOrderNo: Code[20])
    begin
        OrderNo := NewOrderNo;
    end;

    procedure GetResult(var NewReason: Text[100])
    begin
        NewReason := Reason;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = Action::OK then
            if Reason = '' then
                Error(ReasonRequiredErr);
        exit(true);
    end;

    var
        ReasonRequiredErr: Label 'Enter the reason why the delivery failed.';
}
