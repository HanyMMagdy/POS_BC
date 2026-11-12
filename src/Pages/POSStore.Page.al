page 50219 "POS Store List"
{
    Caption = 'POS Stores';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "POS Store";
    
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
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the value of the Name field.', Comment = '%';
                }
                field("Name 2"; Rec."Name 2")
                {
                    ToolTip = 'Specifies the value of the Name 2 field.', Comment = '%';
                }
                field(Address; Rec.Address)
                {
                    ToolTip = 'Specifies the value of the Address field.', Comment = '%';
                }
                field("Address 2"; Rec."Address 2")
                {
                    ToolTip = 'Specifies the value of the Address 2 field.', Comment = '%';
                }
                field(City; Rec.City)
                {
                    ToolTip = 'Specifies the value of the City field.', Comment = '%';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the value of the Currency Code field.', Comment = '%';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ToolTip = 'Specifies the value of the Country/Region Code field.', Comment = '%';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ToolTip = 'The stock location the store sells from. Sales of its terminals are posted from this location.';
                }
                field(Active; Rec.Active)
                {
                    ToolTip = 'Only active stores can be used on the register.';
                }
                field(ReceiptsToday; Rec.Receipts)
                {
                    Caption = 'Receipts Today';
                    ToolTip = 'Specifies how many sales were completed in this store today.';
                }
                field(SalesToday; Rec."Sales (incl. VAT)")
                {
                    Caption = 'Sales Today';
                    ToolTip = 'Specifies the value of today''s sales in this store including VAT.';
                }
                field("Closing Method"; Rec."Closing Method")
                {
                    ToolTip = 'Specifies the value of the Closing Method field.', Comment = '%';
                }
                field("Default Customer No."; Rec."Default Customer No.")
                {
                    ToolTip = 'Specifies the value of the Default Customer No. field.', Comment = '%';
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field.', Comment = '%';
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field.', Comment = '%';
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ToolTip = 'Specifies the value of the Phone No. field.', Comment = '%';
                }
                field("Statement Nos."; Rec."Statement Nos.")
                {
                    ToolTip = 'Specifies the value of the Statement Nos. field.', Comment = '%';
                }
                field("Store Manager ID"; Rec."Store Manager ID")
                {
                    ToolTip = 'Specifies the value of the Store Manager ID field.', Comment = '%';
                }
                field("Store Type"; Rec."Store Type")
                {
                    ToolTip = 'Specifies the value of the Store Type field.', Comment = '%';
                }
                field("Tax Registration No."; Rec."Tax Registration No.")
                {
                    ToolTip = 'Specifies the value of the Tax Registration No. field.', Comment = '%';
                }
            }
        }
        area(Factboxes)
        {
            
        }
    }
    

    actions
    {
        area(Navigation)
        {
            action(Terminals)
            {
                Caption = 'Terminals';
                ApplicationArea = All;
                Image = Register;
                RunObject = page "POS Terminal List";
                RunPageLink = "Store No." = field("No.");
                ToolTip = 'Show the terminals of this store.';
            }
            action(Users)
            {
                Caption = 'Users';
                ApplicationArea = All;
                Image = Users;
                RunObject = page "POS Users";
                RunPageLink = "Store No." = field("No.");
                ToolTip = 'Show the users who work in this store.';
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetRange("Date Filter", WorkDate());
    end;
}