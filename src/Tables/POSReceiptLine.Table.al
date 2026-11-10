table 50203 "POS Receipt Line"
{
    Caption = 'POS Receipt Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
            TableRelation = "POS Receipt Header";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(5; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Unit of Measure";
        }
        field(6; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(7; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price (excl. VAT)';
            AutoFormatType = 2;
        }
        field(8; "Line Discount %"; Decimal)
        {
            Caption = 'Line Discount %';
            DecimalPlaces = 0 : 2;
            MinValue = 0;
            MaxValue = 100;
        }
        field(9; "Line Discount Amount"; Decimal)
        {
            Caption = 'Line Discount Amount';
            AutoFormatType = 1;
        }
        field(10; "Line Amount"; Decimal)
        {
            Caption = 'Line Amount (excl. VAT)';
            AutoFormatType = 1;
        }
        field(11; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
            DecimalPlaces = 0 : 2;
        }
        field(20; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            FieldClass = FlowField;
            CalcFormula = lookup("POS Receipt Header"."Posting Date" where("No." = field("Receipt No.")));
            Editable = false;
        }
        field(21; "Receipt Status"; Enum "POS Receipt Status")
        {
            Caption = 'Receipt Status';
            FieldClass = FlowField;
            CalcFormula = lookup("POS Receipt Header".Status where("No." = field("Receipt No.")));
            Editable = false;
        }
        field(22; "Cashier ID"; Code[50])
        {
            Caption = 'Cashier ID';
            FieldClass = FlowField;
            CalcFormula = lookup("POS Receipt Header"."Cashier ID" where("No." = field("Receipt No.")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Receipt No.", "Line No.")
        {
            Clustered = true;
        }
        key(Item; "Receipt No.", "Item No.")
        {
        }
    }
}
