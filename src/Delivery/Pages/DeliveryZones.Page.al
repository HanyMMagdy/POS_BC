page 50221 "Delivery Zones"
{
    Caption = 'Delivery Zones';
    PageType = List;
    SourceTable = "Delivery Zone";
    ApplicationArea = All;
    UsageCategory = Lists;

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
                field("Delivery Fee"; Rec."Delivery Fee")
                {
                    ApplicationArea = All;
                }
                field("Free Delivery Above"; Rec."Free Delivery Above")
                {
                    ApplicationArea = All;
                }
                field("Est. Minutes"; Rec."Est. Minutes")
                {
                    ApplicationArea = All;
                }
                field("Store No."; Rec."Store No.")
                {
                    ApplicationArea = All;
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
