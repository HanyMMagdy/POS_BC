table 50204 "POS Receipt Payment"
{
    Caption = 'POS Receipt Payment';
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
        field(3; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            TableRelation = "POS Payment Method";
        }
        field(4; "Payment Type"; Enum "POS Payment Type")
        {
            Caption = 'Payment Type';
        }
        field(5; Amount; Decimal)
        {
            Caption = 'Amount Tendered';
            AutoFormatType = 1;
        }
        field(6; "Applied Amount"; Decimal)
        {
            Caption = 'Applied Amount';
            AutoFormatType = 1;
        }
        field(7; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(10; "POS No."; Code[20])
        {
            Caption = 'POS No.';
            TableRelation = "POS Terminal"."No.";
        }
        field(11; "Store No."; Code[20])
        {
            Caption = 'Store No.';
            TableRelation = "POS Store"."No.";
        }
    }

    keys
    {
        key(PK; "Receipt No.", "Line No.")
        {
            Clustered = true;
        }
        key(ByDate; "Payment Type", "Posting Date")
        {
            SumIndexFields = "Applied Amount";
        }
        key(ByStore; "Store No.", "Payment Type", "Posting Date")
        {
            SumIndexFields = "Applied Amount";
        }
    }
}
