page 50231 "Delivery Active Orders"
{
    Caption = 'Orders to Deliver';
    PageType = ListPart;
    SourceTable = "Delivery Order";
    SourceTableView = where(Status = filter(New | Assigned | "Out for Delivery"));
    CardPageId = "Delivery Order";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Requested Date"; Rec."Requested Date")
                {
                    ApplicationArea = All;
                }
                field("Contact Name"; Rec."Contact Name")
                {
                    ApplicationArea = All;
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                }
                field("Driver Name"; Rec."Driver Name")
                {
                    ApplicationArea = All;
                }
                field("Amount to Collect"; Rec."Amount to Collect")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
