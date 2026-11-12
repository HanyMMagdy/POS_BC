table 50209 "POS Terminal"
{
    Caption = 'POS Terminal';
    DataClassification = CustomerContent;
    LookupPageId = "POS Terminal List";
    DrillDownPageId = "POS Terminal List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(2; "Store No."; Code[20])
        {
            Caption = 'Store No.';
            TableRelation = "POS Store"."No.";
            NotBlank = true;

            trigger OnValidate()
            var
                Store: Record "POS Store";
            begin
                if Store.Get("Store No.") then begin
                    if "Location Code" = '' then
                        "Location Code" := Store."Location Code";
                end;
            end;
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(4; "Terminal Type"; Option)
        {
            Caption = 'Terminal Type';
            OptionMembers = POS,"Mobile POS",Kiosk,"Self-Checkout",KDS;
            OptionCaption = 'POS,Mobile POS,Kiosk,Self-Checkout,KDS';
        }

        // --- Core LS Retail Profiles ---
        field(10; "Hardware Profile"; Code[20])
        {
            Caption = 'Hardware Profile';
            //TableRelation = "Custom POS Hardware Profile"."Profile ID";
        }
        field(11; "Interface Profile"; Code[20])
        {
            Caption = 'Interface Profile';
            // TableRelation = "POS Interface Profile"."Profile ID";
        }
        field(12; "Menu Profile"; Code[20])
        {
            Caption = 'Menu Profile';
            // TableRelation = "POS Menu Profile"."Profile ID";
        }
        field(13; "Functionality Profile"; Code[20])
        {
            Caption = 'Functionality Profile';
            // TableRelation = "POS Functionality Profile"."Profile ID";
        }
        field(14; "Style Profile"; Code[20])
        {
            Caption = 'Style Profile';
            // TableRelation = "POS Style Profile"."Profile ID";
        }

        // --- Security & Staff Access ---
        field(20; "Auto Logoff After (Min.)"; Integer)
        {
            Caption = 'Auto Logoff After (Min.)';
            MinValue = 0;
        }
        field(21; "Manager Privileges Required"; Boolean)
        {
            Caption = 'Manager Privileges Required';
        }
        field(22; "Default Staff ID"; Code[20])
        {
            Caption = 'Default Staff ID';
            // TableRelation = "Staff".ID;
        }

        // --- Printing & Receipt Numbering ---
        field(30; "Receipt No. Series"; Code[20])
        {
            Caption = 'Receipt No. Series';
            TableRelation = "No. Series";
        }
        field(31; "Print Receipt Logo"; Boolean)
        {
            Caption = 'Print Receipt Logo';
            InitValue = true;
        }
        field(32; "Print Two Receipts"; Boolean)
        {
            Caption = 'Print Two Receipts';
        }
        field(33; "Receipt Barcode"; Boolean)
        {
            Caption = 'Receipt Barcode';
            InitValue = true;
        }
        field(34; "Receipt Barcode ID"; Integer)
        {
            Caption = 'Receipt Barcode ID';
            InitValue = 101;
        }

        // --- EFT (Electronic Funds Transfer) ---
        field(40; "EFT Store No."; Code[20])
        {
            Caption = 'EFT Store No.';
        }
        field(41; "EFT POS Terminal No."; Code[20])
        {
            Caption = 'EFT POS Terminal No.';
        }
        field(42; "Tips Handling"; Option)
        {
            Caption = 'Tips Handling';
            OptionMembers = None,"Ask User","Always Include";
            OptionCaption = 'None,Ask User,Always Include';
        }
        field(43; "EFT X/Z Report Handling"; Option)
        {
            Caption = 'EFT X/Z Report Handling';
            OptionMembers = Never,"Ask User",Always;
            OptionCaption = 'Never,Ask User,Always';
            InitValue = "Ask User";
        }

        // --- Hospitality / Sales Type ---
        field(50; "Hospitality Type"; Code[20])
        {
            Caption = 'Hospitality Type';
        }
        field(51; "Sales Type Filter"; Text[100])
        {
            Caption = 'Sales Type Filter';
        }
        field(52; "Default Sales Type"; Code[20])
        {
            Caption = 'Default Sales Type';
        }

        // --- Hardware Station & Network Pairing ---
        field(60; "Hardware Station ID"; Code[50])
        {
            Caption = 'Hardware Station ID';
        }
        field(61; "IP Address"; Text[45])
        {
            Caption = 'IP Address';
        }
        field(62; "Computer Name"; Text[100])
        {
            Caption = 'Computer Name';
        }

        // --- Inventory & Status ---
        field(70; "Location Code"; Code[20])
        {
            Caption = 'Location Code';
            TableRelation = Location.Code;
        }
        field(71; Status; Option)
        {
            Caption = 'Status';
            OptionMembers = Active,Inactive,Maintenance;
            OptionCaption = 'Active,Inactive,Maintenance';
        }
        field(72; "Last Date Modified"; DateTime)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }

        // --- Sales figures (for the manager lists) ---
        field(80; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(81; "Receipts"; Integer)
        {
            Caption = 'Receipts';
            FieldClass = FlowField;
            CalcFormula = count("POS Receipt Header" where("POS No." = field("No."), Status = const(Posted), "Posting Date" = field("Date Filter")));
            Editable = false;
        }
        field(82; "Sales (incl. VAT)"; Decimal)
        {
            Caption = 'Sales (incl. VAT)';
            FieldClass = FlowField;
            CalcFormula = sum("POS Receipt Header"."Total Amount" where("POS No." = field("No."), Status = const(Posted), "Posting Date" = field("Date Filter")));
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
        key(StoreTerminal; "Store No.", "No.")
        {
        }
        key(HardwareProfile; "Hardware Profile")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", Description, "Store No.", "Terminal Type", Status)
        {
        }
        fieldgroup(Brick; "No.", Description, "Store No.", Status)
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
        Receipt: Record "POS Receipt Header";
    begin
        Receipt.SetRange("POS No.", "No.");
        if not Receipt.IsEmpty() then
            Error('Cannot delete terminal %1 because POS receipts refer to it. Set the status to Inactive instead.', "No.");
    end;
}

table 50211 "Custom POS Hardware Profile"
{
    Caption = 'POS Hardware Profile';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Profile ID"; Code[20])
        {
            Caption = 'Profile ID';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }

        // --- Receipt Printer ---
        field(10; "Printer Type"; Option)
        {
            Caption = 'Printer Type';
            OptionMembers = None,OPOS,Windows,"Hardware Station",Virtual;
            OptionCaption = 'None,OPOS,Windows,Hardware Station,Virtual';
            InitValue = OPOS;
        }
        field(11; "Printer Device Name"; Text[100])
        {
            Caption = 'Printer Device Name';
        }
        field(12; "Printer Columns"; Integer)
        {
            Caption = 'Printer Columns';
            InitValue = 42;
            MinValue = 20;
        }

        // --- Cash Drawer ---
        field(20; "Drawer Type"; Option)
        {
            Caption = 'Drawer Type';
            OptionMembers = None,OPOS,"Printer Driven","Hardware Station";
            OptionCaption = 'None,OPOS,Printer Driven,Hardware Station';
            InitValue = "Printer Driven";
        }
        field(21; "Drawer Device Name"; Text[100])
        {
            Caption = 'Drawer Device Name';
        }
        field(22; "Drawer Open Command"; Text[50])
        {
            Caption = 'Drawer Open Command';
        }

        // --- Barcode Scanner ---
        field(30; "Scanner Type"; Option)
        {
            Caption = 'Scanner Type';
            OptionMembers = None,OPOS,"Keyboard Wedge","Hardware Station";
            OptionCaption = 'None,OPOS,Keyboard Wedge,Hardware Station';
            InitValue = "Keyboard Wedge";
        }
        field(31; "Scanner Device Name"; Text[100])
        {
            Caption = 'Scanner Device Name';
        }

        // --- Customer Display ---
        field(40; "Display Type"; Option)
        {
            Caption = 'Display Type';
            OptionMembers = None,OPOS,"Dual Display","Hardware Station";
            OptionCaption = 'None,OPOS,Dual Display,Hardware Station';
        }
        field(41; "Display Device Name"; Text[100])
        {
            Caption = 'Display Device Name';
        }

        // --- Weighing Scale ---
        field(50; "Scale Type"; Option)
        {
            Caption = 'Scale Type';
            OptionMembers = None,OPOS,"Hardware Station";
            OptionCaption = 'None,OPOS,Hardware Station';
        }
        field(51; "Scale Device Name"; Text[100])
        {
            Caption = 'Scale Device Name';
        }

        // --- EFT / Card Terminal ---
        field(60; "EFT Type"; Option)
        {
            Caption = 'EFT Type';
            OptionMembers = None,OPOS,"LS Pay",External;
            OptionCaption = 'None,OPOS,LS Pay,External';
        }
        field(61; "EFT IP Address"; Text[45])
        {
            Caption = 'EFT IP Address';
        }
        field(62; "EFT Port"; Integer)
        {
            Caption = 'EFT Port';
        }
    }

    keys
    {
        key(PK; "Profile ID")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Profile ID", Description, "Printer Type", "EFT Type")
        {
        }
    }
}