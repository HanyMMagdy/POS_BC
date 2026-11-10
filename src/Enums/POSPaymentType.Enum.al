enum 50201 "POS Payment Type"
{
    Extensible = true;
    Caption = 'POS Payment Type';

    value(0; Cash)
    {
        Caption = 'Cash';
    }
    value(1; Card)
    {
        Caption = 'Card';
    }
    value(2; Other)
    {
        Caption = 'Other';
    }
}
