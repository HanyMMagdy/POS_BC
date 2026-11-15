page 50224 "Delivery Order"
{
    Caption = 'Delivery Order';
    PageType = Document;
    SourceTable = "Delivery Order";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyle;
                }
                field("Receipt No."; Rec."Receipt No.")
                {
                    ApplicationArea = All;
                }
                field("Posted Sales Invoice No."; Rec."Posted Sales Invoice No.")
                {
                    ApplicationArea = All;
                }
                field("Store No."; Rec."Store No.")
                {
                    ApplicationArea = All;
                    Editable = CanEdit;
                }
                field("Requested Date"; Rec."Requested Date")
                {
                    ApplicationArea = All;
                    Editable = CanEdit;
                }
                field("Requested Time"; Rec."Requested Time")
                {
                    ApplicationArea = All;
                    Editable = CanEdit;
                }
            }
            group(Customer)
            {
                Caption = 'Customer and Address';

                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    Editable = CanEdit;
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                }
                field("Contact Name"; Rec."Contact Name")
                {
                    ApplicationArea = All;
                    Editable = CanEdit;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                    Editable = CanEdit;
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                    Editable = CanEdit;
                    ShowMandatory = true;
                }
                field("Address 2"; Rec."Address 2")
                {
                    ApplicationArea = All;
                    Editable = CanEdit;
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                    Editable = CanEdit;
                }
                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = All;
                    Editable = CanEdit;
                }
                field("Zone Code"; Rec."Zone Code")
                {
                    ApplicationArea = All;
                    Editable = CanEdit;
                }
                field(Notes; Rec.Notes)
                {
                    ApplicationArea = All;
                    Editable = CanEdit;
                }
            }
            group(Dispatch_group)
            {
                Caption = 'Driver';

                field("Driver No."; Rec."Driver No.")
                {
                    ApplicationArea = All;
                }
                field("Driver Name"; Rec."Driver Name")
                {
                    ApplicationArea = All;
                }
                field("Assigned At"; Rec."Assigned At")
                {
                    ApplicationArea = All;
                }
                field("Dispatched At"; Rec."Dispatched At")
                {
                    ApplicationArea = All;
                }
                field("Delivered At"; Rec."Delivered At")
                {
                    ApplicationArea = All;
                }
                field(Attempts; Rec.Attempts)
                {
                    ApplicationArea = All;
                }
                field("Received By"; Rec."Received By")
                {
                    ApplicationArea = All;
                }
                field("Failure Reason"; Rec."Failure Reason")
                {
                    ApplicationArea = All;
                    StyleExpr = 'Unfavorable';
                }
            }
            group(Payment)
            {
                Caption = 'Payment';

                field("Payment Mode"; Rec."Payment Mode")
                {
                    ApplicationArea = All;
                    Editable = CanEdit;
                }
                field("Order Amount"; Rec."Order Amount")
                {
                    ApplicationArea = All;
                }
                field("Delivery Fee"; Rec."Delivery Fee")
                {
                    ApplicationArea = All;
                    Editable = CanEdit;
                }
                field("Amount to Collect"; Rec."Amount to Collect")
                {
                    ApplicationArea = All;
                    Editable = CanEdit;
                }
                field("Collected Amount"; Rec."Collected Amount")
                {
                    ApplicationArea = All;
                }
                field("Collection Document No."; Rec."Collection Document No.")
                {
                    ApplicationArea = All;
                }
            }
            part(Lines; "POS Receipt Subform")
            {
                ApplicationArea = All;
                Caption = 'Items';
                SubPageLink = "Receipt No." = field("Receipt No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(AssignDriver)
            {
                ApplicationArea = All;
                Caption = 'Assign Driver';
                Image = Resource;
                Enabled = CanEdit;
                ToolTip = 'Choose the driver who will take this order.';

                trigger OnAction()
                var
                    DeliveryActions: Codeunit "Delivery Actions";
                begin
                    CurrPage.SaveRecord();
                    DeliveryActions.AssignDriver(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Unassign)
            {
                ApplicationArea = All;
                Caption = 'Remove Driver';
                Image = RemoveLine;
                Enabled = Rec.Status = Rec.Status::Assigned;

                trigger OnAction()
                var
                    DeliveryMgt: Codeunit "Delivery Management";
                begin
                    DeliveryMgt.UnassignDriver(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Dispatch)
            {
                ApplicationArea = All;
                Caption = 'Out for Delivery';
                Image = Shipment;
                Enabled = Rec.Status = Rec.Status::Assigned;
                ToolTip = 'The driver leaves with the order.';

                trigger OnAction()
                var
                    DeliveryMgt: Codeunit "Delivery Management";
                begin
                    CurrPage.SaveRecord();
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
                ToolTip = 'The goods arrived. On cash on delivery the collected cash is posted as a customer payment against the invoice.';

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
            action(CancelOrder)
            {
                ApplicationArea = All;
                Caption = 'Cancel Order';
                Image = VoidCheck;
                Enabled = CanEdit;

                trigger OnAction()
                var
                    DeliveryActions: Codeunit "Delivery Actions";
                begin
                    DeliveryActions.Cancel(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Reopen)
            {
                ApplicationArea = All;
                Caption = 'Reopen';
                Image = ReOpen;
                Enabled = (Rec.Status = Rec.Status::Failed) or (Rec.Status = Rec.Status::Cancelled);
                ToolTip = 'Put a failed or cancelled order back to New so it can be sent again.';

                trigger OnAction()
                var
                    DeliveryMgt: Codeunit "Delivery Management";
                begin
                    DeliveryMgt.Reopen(Rec);
                    CurrPage.Update(false);
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
            action(ShowReceipt)
            {
                ApplicationArea = All;
                Caption = 'POS Receipt';
                Image = Document;
                Enabled = Rec."Receipt No." <> '';

                trigger OnAction()
                var
                    Receipt: Record "POS Receipt Header";
                begin
                    if Receipt.Get(Rec."Receipt No.") then
                        Page.Run(Page::"POS Receipt Card", Receipt);
                end;
            }
            action(ShowInvoice)
            {
                ApplicationArea = All;
                Caption = 'Posted Sales Invoice';
                Image = PostedOrder;
                Enabled = Rec."Posted Sales Invoice No." <> '';

                trigger OnAction()
                var
                    SalesInvoiceHeader: Record "Sales Invoice Header";
                begin
                    if SalesInvoiceHeader.Get(Rec."Posted Sales Invoice No.") then
                        Page.Run(Page::"Posted Sales Invoice", SalesInvoiceHeader);
                end;
            }
            action(ShowCustomer)
            {
                ApplicationArea = All;
                Caption = 'Customer';
                Image = Customer;
                RunObject = page "Customer Card";
                RunPageLink = "No." = field("Customer No.");
            }
        }
        area(Promoted)
        {
            actionref(AssignDriver_Promoted; AssignDriver)
            {
            }
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

    var
        CanEdit: Boolean;
        StatusStyle: Text;

    trigger OnAfterGetCurrRecord()
    begin
        CanEdit := Rec.IsEditable();
        case Rec.Status of
            Rec.Status::Delivered:
                StatusStyle := 'Favorable';
            Rec.Status::Failed:
                StatusStyle := 'Unfavorable';
            Rec.Status::"Out for Delivery":
                StatusStyle := 'Attention';
            Rec.Status::Cancelled:
                StatusStyle := 'Subordinate';
            else
                StatusStyle := 'Standard';
        end;
    end;
}
