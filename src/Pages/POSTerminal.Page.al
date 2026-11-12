/// <summary>
/// Page POS Terminal List (ID 50218).
/// </summary>
page 50218 "POS Terminal List"
{
    Caption = 'POS Terminals';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "POS Terminal";
    
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field("Store No."; Rec."Store No.")
                {
                    ToolTip = 'Specifies the value of the Store No. field.', Comment = '%';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Only active terminals can be chosen on the register login screen.';
                }
                field("Manager Privileges Required"; Rec."Manager Privileges Required")
                {
                    ToolTip = 'When set, only administrators can sign in to this terminal.';
                }
                field("Auto Logoff After (Min.)"; Rec."Auto Logoff After (Min.)")
                {
                    ToolTip = 'Signs the cashier out of this terminal after this many idle minutes. Blank or 0 uses the value in POS Setup.';
                }
                field(ReceiptsToday; Rec.Receipts)
                {
                    Caption = 'Receipts Today';
                    ToolTip = 'Specifies how many sales were completed at this terminal today.';
                }
                field(SalesToday; Rec."Sales (incl. VAT)")
                {
                    Caption = 'Sales Today';
                    ToolTip = 'Specifies the value of today''s sales at this terminal including VAT.';
                }
                field("Terminal Type"; Rec."Terminal Type")
                {
                    ToolTip = 'Specifies the value of the Terminal Type field.', Comment = '%';
                }
                field("Receipt No. Series"; Rec."Receipt No. Series")
                {
                    ToolTip = 'Specifies the value of the Receipt No. Series field.', Comment = '%';
                }
                field("Receipt Barcode"; Rec."Receipt Barcode")
                {
                    ToolTip = 'Specifies the value of the Receipt Barcode field.', Comment = '%';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ToolTip = 'Specifies the value of the Location Code field.', Comment = '%';
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {
                    ToolTip = 'Specifies the value of the Last Date Modified field.', Comment = '%';
                }
                field("IP Address"; Rec."IP Address")
                {
                    ToolTip = 'Specifies the value of the IP Address field.', Comment = '%';
                }
                field("Default Sales Type"; Rec."Default Sales Type")
                {
                    ToolTip = 'Specifies the value of the Default Sales Type field.', Comment = '%';
                }
            }
        }
        area(Factboxes)
        {
            
        }
    }
    

    trigger OnOpenPage()
    begin
        Rec.SetRange("Date Filter", WorkDate());
    end;
}