/// <summary>One-record table behind the cues on the POS role center.</summary>
table 50205 "POS Cue"
{
    Caption = 'POS Cue';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Receipts Today"; Integer)
        {
            Caption = 'Receipts Today';
            FieldClass = FlowField;
            CalcFormula = count("POS Receipt Header" where(Status = const(Posted), "Posting Date" = field("Date Filter"), "Store No." = field("Store Filter")));
            Editable = false;
        }
        field(3; "Sales Today"; Decimal)
        {
            Caption = 'Sales Today (incl. VAT)';
            FieldClass = FlowField;
            CalcFormula = sum("POS Receipt Header"."Total Amount" where(Status = const(Posted), "Posting Date" = field("Date Filter"), "Store No." = field("Store Filter")));
            Editable = false;
            AutoFormatType = 1;
        }
        field(4; "Voided Today"; Integer)
        {
            Caption = 'Cancelled Today';
            FieldClass = FlowField;
            CalcFormula = count("POS Receipt Header" where(Status = const(Voided), "Posting Date" = field("Date Filter"), "Store No." = field("Store Filter")));
            Editable = false;
        }
        field(5; "Receipts On Hold"; Integer)
        {
            Caption = 'On Hold';
            FieldClass = FlowField;
            CalcFormula = count("POS Receipt Header" where(Status = const(Open), "On Hold" = const(true), "Store No." = field("Store Filter")));
            Editable = false;
        }
        field(6; "Receipts In Progress"; Integer)
        {
            Caption = 'In Progress at Registers';
            FieldClass = FlowField;
            CalcFormula = count("POS Receipt Header" where(Status = const(Open), "On Hold" = const(false), "Store No." = field("Store Filter")));
            Editable = false;
        }
        field(7; "Cash Today"; Decimal)
        {
            Caption = 'Cash Today';
            FieldClass = FlowField;
            CalcFormula = sum("POS Receipt Payment"."Applied Amount" where("Payment Type" = const(Cash), "Posting Date" = field("Date Filter"), "Store No." = field("Store Filter")));
            Editable = false;
            AutoFormatType = 1;
        }
        field(8; "Card Today"; Decimal)
        {
            Caption = 'Card Today';
            FieldClass = FlowField;
            CalcFormula = sum("POS Receipt Payment"."Applied Amount" where("Payment Type" = const(Card), "Posting Date" = field("Date Filter"), "Store No." = field("Store Filter")));
            Editable = false;
            AutoFormatType = 1;
        }
        field(9; "Other Today"; Decimal)
        {
            Caption = 'Other Payments Today';
            FieldClass = FlowField;
            CalcFormula = sum("POS Receipt Payment"."Applied Amount" where("Payment Type" = const(Other), "Posting Date" = field("Date Filter"), "Store No." = field("Store Filter")));
            Editable = false;
            AutoFormatType = 1;
        }
        field(20; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(21; "Store Filter"; Code[20])
        {
            Caption = 'Store Filter';
            FieldClass = FlowFilter;
            TableRelation = "POS Store"."No.";
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
