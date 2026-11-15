table 50221 "Delivery Zone"
{
    Caption = 'Delivery Zone';
    DataClassification = CustomerContent;
    LookupPageId = "Delivery Zones";
    DrillDownPageId = "Delivery Zones";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Delivery Fee"; Decimal)
        {
            Caption = 'Delivery Fee';
            MinValue = 0;
            AutoFormatType = 1;
            ToolTip = 'The fee for delivering to this zone.';
        }
        field(4; "Free Delivery Above"; Decimal)
        {
            Caption = 'Free Delivery Above';
            MinValue = 0;
            AutoFormatType = 1;
            ToolTip = 'Orders of this amount or more are delivered free. Leave 0 to always charge the fee.';
        }
        field(5; "Est. Minutes"; Integer)
        {
            Caption = 'Est. Minutes';
            MinValue = 0;
            ToolTip = 'The usual delivery time to this zone, in minutes.';
        }
        field(6; "Store No."; Code[20])
        {
            Caption = 'Store No.';
            TableRelation = "POS Store";
            ToolTip = 'The store that delivers to this zone. Leave blank for every store.';
        }
        field(7; Blocked; Boolean)
        {
            Caption = 'Blocked';
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        DeliveryOrder: Record "Delivery Order";
    begin
        DeliveryOrder.SetRange("Zone Code", Code);
        if not DeliveryOrder.IsEmpty() then
            Error(ZoneInUseErr, Code);
    end;

    /// <summary>The fee for an order of the given amount: free above the free-delivery limit.</summary>
    procedure GetFee(OrderAmount: Decimal): Decimal
    begin
        if ("Free Delivery Above" > 0) and (OrderAmount >= "Free Delivery Above") then
            exit(0);
        exit("Delivery Fee");
    end;

    var
        ZoneInUseErr: Label 'Zone %1 is used by delivery orders and cannot be deleted. Block it instead.', Comment = '%1 = zone code';
}
