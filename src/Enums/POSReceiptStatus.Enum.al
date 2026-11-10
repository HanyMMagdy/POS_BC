enum 50200 "POS Receipt Status"
{
    Extensible = true;
    Caption = 'POS Receipt Status';

    value(0; Open)
    {
        Caption = 'Open';
    }
    value(1; Posted)
    {
        Caption = 'Posted';
    }
    value(2; Voided)
    {
        Caption = 'Voided';
    }
}
