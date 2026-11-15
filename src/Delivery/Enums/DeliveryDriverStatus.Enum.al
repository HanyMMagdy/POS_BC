enum 50204 "Delivery Driver Status"
{
    Extensible = true;
    Caption = 'Delivery Driver Status';

    value(0; Available)
    {
        Caption = 'Available';
    }
    value(1; "On Delivery")
    {
        Caption = 'On Delivery';
    }
    value(2; "Off Duty")
    {
        Caption = 'Off Duty';
    }
}
