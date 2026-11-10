page 50208 "POS Sales Lines"
{
    Caption = 'POS Items Sold';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "POS Receipt Line";
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
                field("Receipt Status"; Rec."Receipt Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Only lines of posted receipts are real sales. Filter this column to Posted.';
                }
                field("Cashier ID"; Rec."Cashier ID")
                {
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Line Discount %"; Rec."Line Discount %")
                {
                    ApplicationArea = All;
                }
                field("Line Amount"; Rec."Line Amount")
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
            action(OpenReceipt)
            {
                ApplicationArea = All;
                Caption = 'Open Receipt';
                Image = Document;
                ToolTip = 'Open the receipt this line belongs to.';

                trigger OnAction()
                var
                    Receipt: Record "POS Receipt Header";
                begin
                    if Receipt.Get(Rec."Receipt No.") then
                        Page.Run(Page::"POS Receipt Card", Receipt);
                end;
            }
        }
        area(Promoted)
        {
            actionref(OpenReceipt_Promoted; OpenReceipt)
            {
            }
        }
    }
}
