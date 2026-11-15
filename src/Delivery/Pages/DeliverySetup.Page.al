page 50232 "Delivery Setup"
{
    Caption = 'Delivery Setup';
    PageType = Card;
    SourceTable = "Delivery Setup";
    ApplicationArea = All;
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Delivery Client Nos."; Rec."Delivery Client Nos.")
                {
                    ToolTip = 'Specifies the value of the Delivery Client Nos. field.', Comment = '%';
                }
                field("Delivery Nos."; Rec."Delivery Nos.")
                {
                    ApplicationArea = All;
                }
                field("Max Delivery Attempts"; Rec."Max Delivery Attempts")
                {
                    ApplicationArea = All;
                }
                field("Default Delivery Store"; Rec."Default Delivery Store")
                {
                    ToolTip = 'Specifies the value of the Default Delivery Store field.', Comment = '%';
                }
                
            }
            group(CashOnDelivery)
            {
                Caption = 'Cash on Delivery';

                field("COD Payment Method"; Rec."COD Payment Method")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Zones)
            {
                ApplicationArea = All;
                Caption = 'Delivery Zones';
                Image = Areas;
                RunObject = page "Delivery Zones";
            }
            action(Drivers)
            {
                ApplicationArea = All;
                Caption = 'Delivery Drivers';
                Image = Resource;
                RunObject = page "Delivery Drivers";
            }
        }
        area(Promoted)
        {
            actionref(Zones_Promoted; Zones)
            {
            }
            actionref(Drivers_Promoted; Drivers)
            {
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetSetup();
    end;
}
