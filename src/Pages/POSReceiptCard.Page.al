page 50204 "POS Receipt Card"
{
    Caption = 'POS Receipt';
    PageType = Document;
    ApplicationArea = All;
    SourceTable = "POS Receipt Header";
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

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
                field("Posting Date"; Rec."Posting Date")
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
                field("Recalled From"; Rec."Recalled From")
                {
                    ApplicationArea = All;
                    Visible = Rec."Recalled From" <> '';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Posted Sales Invoice No."; Rec."Posted Sales Invoice No.")
                {
                    ApplicationArea = All;
                }
            }
            part(Lines; "POS Receipt Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Receipt No." = field("No.");
            }
            part(PaymentLines; "POS Receipt Payments Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Receipt No." = field("No.");
            }
            group(Totals)
            {
                Caption = 'Totals';
                field(Subtotal; Rec.Subtotal)
                {
                    ApplicationArea = All;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ApplicationArea = All;
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ApplicationArea = All;
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                }
                field("Amount Tendered"; Rec."Amount Tendered")
                {
                    ApplicationArea = All;
                }
                field("Change Amount"; Rec."Change Amount")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(PostedInvoice)
            {
                Caption = 'Posted Sales Invoice';
                ApplicationArea = All;
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
            action(PrintInvoice)
            {
                Caption = 'Print Payment';
                ApplicationArea = All;
                Image = Print;
                //Enabled = Rec."Posted Sales Invoice No." <> '';
                ToolTip = 'Open the posted sales invoice created for this receipt.';

                trigger OnAction()
                var
                    POSRectHdr: Record "POS Receipt Header";
                    POSRecpt: Report "POS Receipt";
                begin
                    POSRectHdr.Reset();
                    POSRectHdr.SetRange("No.", Rec."No.");
                    if POSRectHdr.FindFirst() then begin
                        POSRecpt.SetTableView(POSRectHdr);
                        POSRecpt.Run();
                    end;
                end;
            }
        }
        area(Promoted)
        {
            actionref(PostedInvoice_Promoted; PostedInvoice)
            {
            }
            actionref(PrintInvoice_Promoted; PrintInvoice)
            {
            }
        }
    }
}
