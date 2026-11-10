page 50202 "POS Payment Methods"
{
    Caption = 'POS Payment Methods';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "POS Payment Method";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field("Balancing Account Type"; Rec."Balancing Account Type")
                {
                    ApplicationArea = All;
                }
                field("Balancing Account No."; Rec."Balancing Account No.")
                {
                    ApplicationArea = All;
                }
                field("Quick Amounts"; Rec."Quick Amounts")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
