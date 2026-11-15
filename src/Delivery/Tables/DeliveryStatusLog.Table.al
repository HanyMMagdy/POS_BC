table 50224 "Delivery Status Log"
{
    Caption = 'Delivery Status Log';
    DataClassification = CustomerContent;
    LookupPageId = "Delivery Status Log";
    DrillDownPageId = "Delivery Status Log";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Delivery No."; Code[20])
        {
            Caption = 'Delivery No.';
            TableRelation = "Delivery Order";
        }
        field(3; "Date Time"; DateTime)
        {
            Caption = 'Date Time';
        }
        field(4; Status; Enum "Delivery Status")
        {
            Caption = 'Status';
        }
        field(5; "User ID"; Code[50])
        {
            Caption = 'User ID';
        }
        field(6; Description; Text[250])
        {
            Caption = 'Description';
        }
        field(7; "Driver No."; Code[20])
        {
            Caption = 'Driver No.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(ByDelivery; "Delivery No.", "Entry No.")
        {
        }
    }
}
