page 50223 "Delivery Orders"
{
    Caption = 'Delivery Orders';
    PageType = List;
    SourceTable = "Delivery Order";
    CardPageId = "Delivery Order";
    ApplicationArea = All;
    UsageCategory = Lists;
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
                    StyleExpr = StatusStyle;
                }
                field("Requested Date"; Rec."Requested Date")
                {
                    ApplicationArea = All;
                }
                field("Requested Time"; Rec."Requested Time")
                {
                    ApplicationArea = All;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Customer Name"; Rec."Customer Name")
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
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                }
                field("Zone Code"; Rec."Zone Code")
                {
                    ApplicationArea = All;
                }
                field("Driver No."; Rec."Driver No.")
                {
                    ApplicationArea = All;
                }
                field("Driver Name"; Rec."Driver Name")
                {
                    ApplicationArea = All;
                }
                field("Store No."; Rec."Store No.")
                {
                    ApplicationArea = All;
                }
                field("Payment Mode"; Rec."Payment Mode")
                {
                    ApplicationArea = All;
                }
                field("Order Amount"; Rec."Order Amount")
                {
                    ApplicationArea = All;
                }
                field("Amount to Collect"; Rec."Amount to Collect")
                {
                    ApplicationArea = All;
                }
                field("Collected Amount"; Rec."Collected Amount")
                {
                    ApplicationArea = All;
                }
                field("Receipt No."; Rec."Receipt No.")
                {
                    ApplicationArea = All;
                }
                field("Posted Sales Invoice No."; Rec."Posted Sales Invoice No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(Creation)
        {
            action(NewFromReceipt)
            {
                ApplicationArea = All;
                Caption = 'New from POS Receipt';
                Image = NewDocument;
                ToolTip = 'Choose a completed POS sale and create a delivery order for it.';

                trigger OnAction()
                var
                    DeliveryActions: Codeunit "Delivery Actions";
                begin
                    DeliveryActions.NewFromReceiptLookup();
                end;
            }
            action(NewFromInvoice)
            {
                ApplicationArea = All;
                Caption = 'New from Posted Invoice';
                Image = NewSalesInvoice;
                ToolTip = 'Choose a posted sales invoice and create a delivery order for it. An invoice with an open balance becomes cash on delivery.';

                trigger OnAction()
                var
                    DeliveryActions: Codeunit "Delivery Actions";
                begin
                    DeliveryActions.NewFromInvoiceLookup();
                end;
            }
        }
        area(Navigation)
        {
            action(StatusLog)
            {
                ApplicationArea = All;
                Caption = 'Status Log';
                Image = Log;
                RunObject = page "Delivery Status Log";
                RunPageLink = "Delivery No." = field("No.");
            }
        }
        area(Promoted)
        {
            actionref(NewFromReceipt_Promoted; NewFromReceipt)
            {
            }
            actionref(NewFromInvoice_Promoted; NewFromInvoice)
            {
            }
        }
    }

    var
        StatusStyle: Text;

    trigger OnAfterGetRecord()
    begin
        StatusStyle := GetStatusStyle(Rec.Status);
    end;

    local procedure GetStatusStyle(Status: Enum "Delivery Status"): Text
    begin
        case Status of
            Status::Delivered:
                exit('Favorable');
            Status::Failed:
                exit('Unfavorable');
            Status::"Out for Delivery":
                exit('Attention');
            Status::Cancelled:
                exit('Subordinate');
        end;
        exit('Standard');
    end;
}
