page 50210 "POS Receipt Payments Subform"
{
    Caption = 'Payments';
    PageType = ListPart;
    SourceTable = "POS Receipt Payment";
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = All;
                }
                field("Payment Type"; Rec."Payment Type")
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
                field("Applied Amount"; Rec."Applied Amount")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
