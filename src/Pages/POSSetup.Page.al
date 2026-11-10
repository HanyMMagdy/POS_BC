page 50201 "POS Setup"
{
    Caption = 'POS Setup';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "POS Setup";
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Default Customer No."; Rec."Default Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The customer that cash sales are posted to when the cashier does not pick another one. Use a customer with immediate payment terms.';
                }
                field("Default Location Code"; Rec."Default Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'The store location. Stock shown on the register and the posted sales use this location.';
                }
                field("Receipt Nos."; Rec."Receipt Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Number series for POS receipts.';
                }
            }
            group(Register)
            {
                Caption = 'Register';
                field("Max Line Discount %"; Rec."Max Line Discount %")
                {
                    ApplicationArea = All;
                }
                field("Product Tiles"; Rec."Product Tiles")
                {
                    ApplicationArea = All;
                }
                field("Auto Sign-out (minutes)"; Rec."Auto Sign-out (minutes)")
                {
                    ApplicationArea = All;
                }
                field("Default Theme Code"; Rec."Default Theme Code")
                {
                    ApplicationArea = All;
                }
            }
            group(ReceiptPrinting)
            {
                Caption = 'Receipt';
                field("Receipt Header Text"; Rec."Receipt Header Text")
                {
                    ApplicationArea = All;
                }
                field("Receipt Footer Text"; Rec."Receipt Footer Text")
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
            action(PaymentMethods)
            {
                Caption = 'Payment Methods';
                ApplicationArea = All;
                Image = Payment;
                RunObject = page "POS Payment Methods";
            }
            action(Users)
            {
                Caption = 'POS Users';
                ApplicationArea = All;
                Image = Users;
                RunObject = page "POS Users";
                ToolTip = 'Create the users who can sign in to the register and choose who is an administrator.';
            }
            action(Themes)
            {
                Caption = 'Themes';
                ApplicationArea = All;
                Image = Setup;
                RunObject = page "POS Themes";
                ToolTip = 'Create and edit the colour themes of the register screen.';
            }
        }
        area(Promoted)
        {
            actionref(PaymentMethods_Promoted; PaymentMethods)
            {
            }
            actionref(Themes_Promoted; Themes)
            {
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetSetup();
    end;
}
