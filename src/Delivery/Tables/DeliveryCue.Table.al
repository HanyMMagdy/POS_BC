table 50225 "Delivery Cue"
{
    Caption = 'Delivery Cue';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "New Orders"; Integer)
        {
            Caption = 'New Orders';
            FieldClass = FlowField;
            CalcFormula = count("Delivery Order" where(Status = const(New), "Store No." = field("Store Filter")));
            Editable = false;
        }
        field(3; "Assigned Orders"; Integer)
        {
            Caption = 'Assigned';
            FieldClass = FlowField;
            CalcFormula = count("Delivery Order" where(Status = const(Assigned), "Store No." = field("Store Filter")));
            Editable = false;
        }
        field(4; "Out for Delivery"; Integer)
        {
            Caption = 'Out for Delivery';
            FieldClass = FlowField;
            CalcFormula = count("Delivery Order" where(Status = const("Out for Delivery"), "Store No." = field("Store Filter")));
            Editable = false;
        }
        field(5; "Delivered Today"; Integer)
        {
            Caption = 'Delivered Today';
            FieldClass = FlowField;
            CalcFormula = count("Delivery Order" where(Status = const(Delivered), "Completed Date" = field("Date Filter"), "Store No." = field("Store Filter")));
            Editable = false;
        }
        field(6; "Failed Today"; Integer)
        {
            Caption = 'Failed Today';
            FieldClass = FlowField;
            CalcFormula = count("Delivery Order" where(Status = const(Failed), "Completed Date" = field("Date Filter"), "Store No." = field("Store Filter")));
            Editable = false;
        }
        field(7; "COD to Collect"; Decimal)
        {
            Caption = 'COD to Collect';
            FieldClass = FlowField;
            CalcFormula = sum("Delivery Order"."Amount to Collect" where("Payment Mode" = const("Cash on Delivery"), Status = filter(New | Assigned | "Out for Delivery"), "Store No." = field("Store Filter")));
            Editable = false;
            AutoFormatType = 1;
        }
        field(8; "COD Collected Today"; Decimal)
        {
            Caption = 'COD Collected Today';
            FieldClass = FlowField;
            CalcFormula = sum("Delivery Order"."Collected Amount" where(Status = const(Delivered), "Completed Date" = field("Date Filter"), "Store No." = field("Store Filter")));
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
