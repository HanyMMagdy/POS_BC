table 50222 "Delivery Driver"
{
    Caption = 'Delivery Driver';
    DataClassification = CustomerContent;
    LookupPageId = "Delivery Drivers";
    DrillDownPageId = "Delivery Drivers";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
        }
        field(3; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            ExtendedDatatype = PhoneNo;
        }
        field(4; Vehicle; Text[50])
        {
            Caption = 'Vehicle';
            ToolTip = 'The vehicle or plate number the driver uses.';
        }
        field(5; "Store No."; Code[20])
        {
            Caption = 'Store No.';
            TableRelation = "POS Store";
            ToolTip = 'The store the driver works for. The driver can only be given orders of this store. Leave blank for every store.';
        }
        field(6; "User ID"; Code[50])
        {
            Caption = 'User ID';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            ToolTip = 'The Business Central user of the driver. The My Deliveries page shows this user''s orders.';
        }
        field(7; Status; Enum "Delivery Driver Status")
        {
            Caption = 'Status';
            ToolTip = 'Changes by itself when the driver leaves with an order and when the orders are completed. Set Off Duty when the driver is not working.';
        }
        field(8; Blocked; Boolean)
        {
            Caption = 'Blocked';
        }
        field(20; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(21; "Open Deliveries"; Integer)
        {
            Caption = 'Open Deliveries';
            FieldClass = FlowField;
            CalcFormula = count("Delivery Order" where("Driver No." = field("No."), Status = filter(Assigned | "Out for Delivery")));
            Editable = false;
        }
        field(22; "Delivered Orders"; Integer)
        {
            Caption = 'Delivered';
            FieldClass = FlowField;
            CalcFormula = count("Delivery Order" where("Driver No." = field("No."), Status = const(Delivered), "Completed Date" = field("Date Filter")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(ByUser; "User ID")
        {
        }
    }

    trigger OnDelete()
    var
        DeliveryOrder: Record "Delivery Order";
    begin
        DeliveryOrder.SetRange("Driver No.", "No.");
        if not DeliveryOrder.IsEmpty() then
            Error(DriverInUseErr, "No.");
    end;

    var
        DriverInUseErr: Label 'Driver %1 has delivery orders and cannot be deleted. Block the driver instead.', Comment = '%1 = driver no.';
}
