codeunit 50204 "POS Theme Management"
{
    var
        POSSession: Codeunit "POS Session";

    /// <summary>Creates the three themes that ship with the app. Existing themes are left alone.</summary>
    procedure InsertDefaultThemes()
    var
        POSSetup: Record "POS Setup";
    begin
        AddTheme('TEAL', 'Teal (light)', '#0B6B63', '#FFFFFF', '#EEF0F2', '#FFFFFF', '#1A1F26', '#667085', '#E3E6EA', '#B42318');
        AddTheme('MIDNIGHT', 'Midnight (dark)', '#2DD4BF', '#062A27', '#0F141A', '#1A222B', '#E7ECF2', '#98A2B3', '#2A3541', '#F97066');
        AddTheme('SUNSET', 'Sunset (warm)', '#C2410C', '#FFFFFF', '#FBF3EA', '#FFFFFF', '#2B1D14', '#7A6250', '#EADBC9', '#B42318');

        POSSetup.GetSetup();
        if POSSetup."Default Theme Code" = '' then begin
            POSSetup."Default Theme Code" := 'TEAL';
            POSSetup.Modify();
        end;
    end;

    local procedure AddTheme(ThemeCode: Code[10]; ThemeName: Text[50]; Accent: Text[7]; AccentText: Text[7]; Background: Text[7]; Panel: Text[7]; TextColor: Text[7]; Muted: Text[7]; Border: Text[7]; Danger: Text[7])
    var
        Theme: Record "POS Theme";
    begin
        if Theme.Get(ThemeCode) then
            exit;
        Theme.Init();
        Theme.Code := ThemeCode;
        Theme.Name := ThemeName;
        Theme."Accent Color" := Accent;
        Theme."Accent Text Color" := AccentText;
        Theme."Background Color" := Background;
        Theme."Panel Color" := Panel;
        Theme."Text Color" := TextColor;
        Theme."Muted Text Color" := Muted;
        Theme."Border Color" := Border;
        Theme."Danger Color" := Danger;
        Theme.Insert(true);
    end;

    /// <summary>The theme this cashier should see: own choice, else the setup default, else the first theme.</summary>
    procedure GetUserThemeCode(): Code[10]
    var
        UserSetup: Record "POS User Setup";
        POSSetup: Record "POS Setup";
        Theme: Record "POS Theme";
    begin
        if POSSession.IsActive() then
            if UserSetup.Get(POSSession.GetCashierId()) then
                if Theme.Get(UserSetup."Theme Code") then
                    exit(UserSetup."Theme Code");

        POSSetup.GetSetup();
        if Theme.Get(POSSetup."Default Theme Code") then
            exit(POSSetup."Default Theme Code");

        if Theme.FindFirst() then
            exit(Theme.Code);
        exit('');
    end;

    procedure SetUserTheme(ThemeCode: Code[10])
    var
        UserSetup: Record "POS User Setup";
        Theme: Record "POS Theme";
        CurrentUser: Code[50];
    begin
        Theme.Get(ThemeCode);
        POSSession.RequireLogin();
        CurrentUser := POSSession.GetCashierId();
        if UserSetup.Get(CurrentUser) then begin
            UserSetup."Theme Code" := ThemeCode;
            UserSetup.Modify();
        end else begin
            UserSetup.Init();
            UserSetup."User ID" := CurrentUser;
            UserSetup."Theme Code" := ThemeCode;
            UserSetup.Insert();
        end;
    end;
}
