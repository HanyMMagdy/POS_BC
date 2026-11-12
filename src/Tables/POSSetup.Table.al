table 50200 "POS Setup"
{
    Caption = 'POS Setup';
    DataClassification = CustomerContent;
    LookupPageId = "POS Setup";
    DrillDownPageId = "POS Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(10; "Default Customer No."; Code[20])
        {
            Caption = 'Default Customer No.';
            TableRelation = Customer;
        }
        field(11; "Default Location Code"; Code[10])
        {
            Caption = 'Default Location Code';
            TableRelation = Location;
        }
        field(12; "Receipt Nos."; Code[20])
        {
            Caption = 'Receipt Nos.';
            TableRelation = "No. Series";
        }
        field(20; "Max Line Discount %"; Decimal)
        {
            Caption = 'Max Line Discount %';
            InitValue = 20;
            MinValue = 0;
            MaxValue = 100;
            DecimalPlaces = 0 : 2;
            ToolTip = 'The highest discount a cashier can give on one line. Set to 0 to disable discounts.';
        }
        field(21; "Product Tiles"; Integer)
        {
            Caption = 'Product Tiles';
            InitValue = 48;
            MinValue = 12;
            MaxValue = 200;
            ToolTip = 'How many items are shown on the register at once.';
        }
        field(23; "Auto Sign-out (minutes)"; Integer)
        {
            Caption = 'Auto Sign-out (minutes)';
            InitValue = 15;
            MinValue = 0;
            MaxValue = 240;
            ToolTip = 'Sign the cashier out of the register after this many minutes without activity. Set to 0 to turn it off.';
        }
        field(22; "Default Theme Code"; Code[10])
        {
            Caption = 'Default Theme Code';
            TableRelation = "POS Theme";
            ToolTip = 'The colour theme cashiers start with. Each cashier can switch theme on the register.';
        }
        field(30; "Receipt Header Text"; Text[100])
        {
            Caption = 'Receipt Header Text';
            ToolTip = 'Shown at the top of the printed receipt. Company name is used when empty.';
        }
        field(31; "Receipt Footer Text"; Text[250])
        {
            Caption = 'Receipt Footer Text';
        }
        field(32; "Receipt Header Picture"; Media)
        {
            Caption = 'Receipt Header Picture';
            ToolTip = 'A picture, for example the logo, printed at the top of every receipt.';
        }
        field(33; "Receipt Footer Picture"; Media)
        {
            Caption = 'Receipt Footer Picture';
            ToolTip = 'A picture, for example a promotion or a bar code, printed at the bottom of every receipt.';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure GetSetup()
    begin
        if not Get() then begin
            Init();
            Insert();
        end;
    end;
}
