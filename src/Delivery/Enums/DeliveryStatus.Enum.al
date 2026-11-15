enum 50202 "Delivery Status"
{
    Extensible = true;
    Caption = 'Delivery Status';

    value(0; New)
    {
        Caption = 'New';
    }
    value(1; Assigned)
    {
        Caption = 'Assigned';
    }
    value(2; "Out for Delivery")
    {
        Caption = 'Out for Delivery';
    }
    value(3; Delivered)
    {
        Caption = 'Delivered';
    }
    value(4; Failed)
    {
        Caption = 'Failed';
    }
    value(5; Cancelled)
    {
        Caption = 'Cancelled';
    }
}
