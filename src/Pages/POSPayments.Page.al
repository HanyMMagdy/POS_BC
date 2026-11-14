page 50211 "POS Payments"
{
    Caption = 'POS Payments';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "POS Receipt Payment";
    SourceTableView = sorting("Receipt No.", "Line No.") order(descending);
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
                field("Receipt No."; Rec."Receipt No.")
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
                    ToolTip = 'The part of the tendered amount that paid the sale. The rest was given back as change.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(OpenReceipt)
            {
                ApplicationArea = All;
                Caption = 'Open Receipt';
                Image = Document;

                trigger OnAction()
                var
                    Receipt: Record "POS Receipt Header";
                begin
                    if Receipt.Get(Rec."Receipt No.") then
                        Page.Run(Page::"POS Receipt Card", Receipt);
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
                    POSRectHdr.SetRange("No.", Rec."Receipt No.");
                    if POSRectHdr.FindFirst() then begin
                        POSRecpt.SetTableView(POSRectHdr);
                        POSRecpt.Run();
                    end;
                end;
            }
        }
        area(Promoted)
        {
            actionref(OpenReceipt_Promoted; OpenReceipt)
            {
            }
            actionref(PrintInvoice_Promoted; PrintInvoice)
            {
            }
        }
    }
}
