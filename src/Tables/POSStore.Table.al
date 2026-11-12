table 50210 "POS Store"
{
    Caption = 'Store';
    DataClassification = CustomerContent;
    LookupPageId = "POS Store List";
    DrillDownPageId = "POS Store List";

    fields
    {
        // --- General & Identification ---
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
        }
        field(3; "Name 2"; Text[50])
        {
            Caption = 'Name 2';
        }
        field(4; Address; Text[100])
        {
            Caption = 'Address';
        }
        field(5; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
        }
        field(6; City; Text[30])
        {
            Caption = 'City';
        }
        field(7; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            TableRelation = "Post Code";
        }
        field(8; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(9; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            ExtendedDatatype = PhoneNo;
        }
        field(10; "E-Mail"; Text[80])
        {
            Caption = 'E-Mail';
            ExtendedDatatype = EMail;
        }
        field(11; "Store Type"; Option)
        {
            Caption = 'Store Type';
            OptionMembers = Retail,Hospitality,"Web Store",Warehouse;
            OptionCaption = 'Retail,Hospitality,Web Store,Warehouse';
        }

        // --- Inventory & Accounting Links ---
        field(20; "Location Code"; Code[20])
        {
            Caption = 'Location Code';
            TableRelation = Location.Code;
            NotBlank = true;
        }
        field(21; "Global Dimension 1 Code"; Code[20])
        {
            Caption = 'Global Dimension 1 Code';
            CaptionClass = '1,1,1';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1), Blocked = const(false));
        }
        field(22; "Global Dimension 2 Code"; Code[20])
        {
            Caption = 'Global Dimension 2 Code';
            CaptionClass = '1,1,2';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2), Blocked = const(false));
        }
        field(23; "Default Customer No."; Code[20])
        {
            Caption = 'Default Customer No.';
            TableRelation = Customer."No.";
        }
        field(24; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency.Code;
        }

        // --- Pricing & VAT / Tax ---
        field(30; "Price Includes VAT"; Boolean)
        {
            Caption = 'Price Includes VAT';
            InitValue = true;
        }
        field(31; "Store Price Group"; Code[10])
        {
            Caption = 'Store Price Group';
            TableRelation = "Customer Price Group".Code;
        }
        field(32; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group".Code;
        }
        field(33; "Tax Registration No."; Text[50])
        {
            Caption = 'Tax Registration No.';
        }

        // --- Store-Level Default POS Profiles ---
        field(40; "Interface Profile"; Code[20])
        {
            Caption = 'Interface Profile';
        }
        field(41; "Menu Profile"; Code[20])
        {
            Caption = 'Menu Profile';
        }
        field(42; "Functionality Profile"; Code[20])
        {
            Caption = 'Functionality Profile';
        }
        field(43; "Style Profile"; Code[20])
        {
            Caption = 'Style Profile';
        }

        // --- Statement Posting & Cash Management ---
        field(50; "Statement Method"; Option)
        {
            Caption = 'Statement Method';
            OptionMembers = "POS Terminal",Staff,"Total Store";
            OptionCaption = 'POS Terminal,Staff,Total Store';
        }
        field(51; "Closing Method"; Option)
        {
            Caption = 'Closing Method';
            OptionMembers = "Date & Time",Shift;
            OptionCaption = 'Date & Time,Shift';
        }
        field(52; "Max. Diff. to Allow Post"; Decimal)
        {
            Caption = 'Max. Diff. to Allow Post';
            DecimalPlaces = 2 : 2;
        }
        field(53; "Statement Nos."; Code[20])
        {
            Caption = 'Statement Nos.';
            TableRelation = "No. Series";
        }
        field(54; "Posted Statement Nos."; Code[20])
        {
            Caption = 'Posted Statement Nos.';
            TableRelation = "No. Series";
        }

        // --- Status & Audit ---
        field(60; "Store Manager ID"; Code[20])
        {
            Caption = 'Store Manager ID';
        }
        field(61; Active; Boolean)
        {
            Caption = 'Active';
            InitValue = true;
        }
        field(62; "Last Date Modified"; DateTime)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }

        // --- Sales figures (for the manager lists) ---
        field(70; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(71; "Receipts"; Integer)
        {
            Caption = 'Receipts';
            FieldClass = FlowField;
            CalcFormula = count("POS Receipt Header" where("Store No." = field("No."), Status = const(Posted), "Posting Date" = field("Date Filter")));
            Editable = false;
        }
        field(72; "Sales (incl. VAT)"; Decimal)
        {
            Caption = 'Sales (incl. VAT)';
            FieldClass = FlowField;
            CalcFormula = sum("POS Receipt Header"."Total Amount" where("Store No." = field("No."), Status = const(Posted), "Posting Date" = field("Date Filter")));
            Editable = false;
            AutoFormatType = 1;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(Location; "Location Code")
        {
        }
        key(Name; Name)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", Name, City, "Location Code", Active)
        {
        }
        fieldgroup(Brick; "No.", Name, "Location Code", "Phone No.")
        {
        }
    }

    trigger OnInsert()
    begin
        "Last Date Modified" := CurrentDateTime();
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := CurrentDateTime();
    end;

    trigger OnDelete()
    var
        POSTerminal: Record "POS Terminal";
        POSUser: Record "POS User";
        Receipt: Record "POS Receipt Header";
    begin
        POSTerminal.SetRange("Store No.", "No.");
        if not POSTerminal.IsEmpty() then
            Error('Cannot delete Store %1 because POS Terminals are still assigned to it.', "No.");
        POSUser.SetRange("Store No.", "No.");
        if not POSUser.IsEmpty() then
            Error('Cannot delete Store %1 because POS users are still assigned to it.', "No.");
        Receipt.SetRange("Store No.", "No.");
        if not Receipt.IsEmpty() then
            Error('Cannot delete Store %1 because POS receipts refer to it. Set Active to No instead.', "No.");
    end;
}