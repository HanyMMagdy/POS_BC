codeunit 50205 "POS Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        ThemeMgt: Codeunit "POS Theme Management";
    begin
        ThemeMgt.InsertDefaultThemes();
    end;
}
