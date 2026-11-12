page 50203 "POS Receipts"
{
    Caption = 'POS Receipts';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "POS Receipt Header";
    CardPageId = "POS Receipt Card";
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    SourceTableView = sorting("No.") order(descending);

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
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Created At"; Rec."Created At")
                {
                    ApplicationArea = All;
                }
                field("Store No."; Rec."Store No.")
                {
                    ApplicationArea = All;
                }
                field("POS No."; Rec."POS No.")
                {
                    ApplicationArea = All;
                }
                field("Cashier ID"; Rec."Cashier ID")
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
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("On Hold"; Rec."On Hold")
                {
                    ApplicationArea = All;
                }
                field(Subtotal; Rec.Subtotal)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                }
                field("Amount Tendered"; Rec."Amount Tendered")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Change Amount"; Rec."Change Amount")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Posted Sales Invoice No."; Rec."Posted Sales Invoice No.")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(FactBoxes)
        {
            part(Lines; "POS Receipt Subform")
            {
                ApplicationArea = All;
                Caption = 'Lines';
                SubPageLink = "Receipt No." = field("No.");
            }
            part(Payments; "POS Receipt Payments Subform")
            {
                ApplicationArea = All;
                Caption = 'Payments';
                SubPageLink = "Receipt No." = field("No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenRegister)
            {
                ApplicationArea = All;
                Caption = 'Open Register';
                Image = NewSalesInvoice;
                RunObject = page "POS Register";
                ToolTip = 'Start a new sale at the register.';
            }
        }
        area(Navigation)
        {
            action(PostedInvoice)
            {
                ApplicationArea = All;
                Caption = 'Posted Sales Invoice';
                Image = PostedOrder;
                Enabled = Rec."Posted Sales Invoice No." <> '';
                ToolTip = 'Open the posted sales invoice created for this receipt.';

                trigger OnAction()
                var
                    SalesInvoiceHeader: Record "Sales Invoice Header";
                begin
                    if SalesInvoiceHeader.Get(Rec."Posted Sales Invoice No.") then
                        Page.Run(Page::"Posted Sales Invoice", SalesInvoiceHeader);
                end;
            }
            action(ItemsSold)
            {
                ApplicationArea = All;
                Caption = 'Items Sold';
                Image = Item;
                RunObject = page "POS Sales Lines";
                ToolTip = 'See every item line sold through the POS.';
            }
            action(AllPayments)
            {
                ApplicationArea = All;
                Caption = 'Payments';
                Image = Payment;
                RunObject = page "POS Payments";
                ToolTip = 'See every payment taken at the registers.';
            }
        }
        area(Promoted)
        {
            actionref(OpenRegister_Promoted; OpenRegister)
            {
            }
            actionref(PostedInvoice_Promoted; PostedInvoice)
            {
            }
        }
    }
}
