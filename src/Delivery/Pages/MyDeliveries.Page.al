page 50228 "My Deliveries"
{
    Caption = 'My Deliveries';
    PageType = List;
    SourceTable = "Delivery Order";
    ApplicationArea = All;
    UsageCategory = Lists;
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
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Requested Time"; Rec."Requested Time")
                {
                    ApplicationArea = All;
                }
                field("Contact Name"; Rec."Contact Name")
                {
                    ApplicationArea = All;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                }
                field("Amount to Collect"; Rec."Amount to Collect")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the cash to collect from the customer. It is 0 for prepaid orders.';
                }
                field(Notes; Rec.Notes)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Dispatch)
            {
                ApplicationArea = All;
                Caption = 'Out for Delivery';
                Image = Shipment;
                Enabled = Rec.Status = Rec.Status::Assigned;

                trigger OnAction()
                var
                    DeliveryMgt: Codeunit "Delivery Management";
                begin
                    DeliveryMgt.Dispatch(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Complete)
            {
                ApplicationArea = All;
                Caption = 'Delivered';
                Image = Approve;
                Enabled = Rec.Status = Rec.Status::"Out for Delivery";

                trigger OnAction()
                var
                    DeliveryActions: Codeunit "Delivery Actions";
                begin
                    DeliveryActions.Complete(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Fail)
            {
                ApplicationArea = All;
                Caption = 'Delivery Failed';
                Image = Cancel;
                Enabled = Rec.Status = Rec.Status::"Out for Delivery";

                trigger OnAction()
                var
                    DeliveryActions: Codeunit "Delivery Actions";
                begin
                    DeliveryActions.Fail(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(OpenOrder)
            {
                ApplicationArea = All;
                Caption = 'Open Order';
                Image = Document;
                RunObject = page "Delivery Order";
                RunPageLink = "No." = field("No.");
            }
        }
        area(Promoted)
        {
            actionref(Dispatch_Promoted; Dispatch)
            {
            }
            actionref(Complete_Promoted; Complete)
            {
            }
            actionref(Fail_Promoted; Fail)
            {
            }
        }
    }

    trigger OnOpenPage()
    var
        Driver: Record "Delivery Driver";
        DriverNo: Code[20];
    begin
        // Only the orders of the driver who is signed in. With no driver linked to this user the list stays empty.
        Driver.SetRange("User ID", UserId());
        if Driver.FindFirst() then
            DriverNo := Driver."No.";
        Rec.FilterGroup(2);
        Rec.SetRange("Driver No.", DriverNo);
        Rec.SetFilter(Status, '%1|%2', Rec.Status::Assigned, Rec.Status::"Out for Delivery");
        Rec.FilterGroup(0);
    end;
}
