page 50222 "Delivery Drivers"
{
    Caption = 'Delivery Drivers';
    PageType = List;
    SourceTable = "Delivery Driver";
    ApplicationArea = All;
    UsageCategory = Lists;

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
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                }
                field(Vehicle; Rec.Vehicle)
                {
                    ApplicationArea = All;
                }
                field("Store No."; Rec."Store No.")
                {
                    ApplicationArea = All;
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyle;
                }
                field("Open Deliveries"; Rec."Open Deliveries")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    var
                        Order: Record "Delivery Order";
                    begin
                        Order.SetRange("Driver No.", Rec."No.");
                        Order.SetFilter(Status, '%1|%2', Order.Status::Assigned, Order.Status::"Out for Delivery");
                        Page.Run(Page::"Delivery Orders", Order);
                    end;
                }
                field("Delivered Orders"; Rec."Delivered Orders")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how many orders the driver delivered in the period of the date filter.';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    var
        StatusStyle: Text;

    trigger OnOpenPage()
    begin
        Rec.SetRange("Date Filter", WorkDate());
    end;

    trigger OnAfterGetRecord()
    begin
        case Rec.Status of
            Rec.Status::Available:
                StatusStyle := 'Favorable';
            Rec.Status::"On Delivery":
                StatusStyle := 'Attention';
            else
                StatusStyle := 'Subordinate';
        end;
    end;
}
