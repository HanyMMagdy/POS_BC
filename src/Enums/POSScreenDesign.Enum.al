/// <summary>
/// The layouts of the register screen. The register is drawn by JavaScript; each value here matches one design there
/// (see DESIGNS in pos.js and the design-... rules in pos.css). The blank value means "not chosen".
/// </summary>
enum 50205 "POS Screen Design"
{
    Extensible = true;
    Caption = 'POS Screen Design';

    value(0; " ")
    {
        Caption = 'Default';
    }
    value(1; Classic)
    {
        Caption = 'Classic';
    }
    value(2; Touch)
    {
        Caption = 'Touch';
    }
    value(3; "Fast Scan")
    {
        Caption = 'Fast Scan';
    }
}