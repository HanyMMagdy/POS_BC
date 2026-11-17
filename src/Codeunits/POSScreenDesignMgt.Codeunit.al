/// <summary>
/// Which register screen design a cashier gets. The order is: the one picked on the login form, then the one set on
/// the POS user, then the one set in POS Setup, then Classic. The JavaScript knows the designs by a short code.
/// </summary>
codeunit 50212 "POS Screen Design Mgt"
{
    procedure ToCode(Design: Enum "POS Screen Design"): Text
    begin
        case Design of
            Design::Touch:
                exit('touch');
            Design::"Fast Scan":
                exit('scan');
        end;
        exit('classic');
    end;

    /// <summary>False when the code is blank or not one of the known designs.</summary>
    procedure TryFromCode(DesignCode: Text; var Design: Enum "POS Screen Design"): Boolean
    begin
        case LowerCase(DelChr(DesignCode, '<>', ' ')) of
            'classic':
                Design := Design::Classic;
            'touch':
                Design := Design::Touch;
            'scan':
                Design := Design::"Fast Scan";
            else begin
                Design := Design::" ";
                exit(false);
            end;
        end;
        exit(true);
    end;

    /// <summary>The design to start a session with. ChosenCode is what the cashier picked on the login form (may be blank).</summary>
    procedure Resolve(ChosenCode: Text; UserName: Code[50]): Enum "POS Screen Design"
    var
        POSUser: Record "POS User";
        POSSetup: Record "POS Setup";
        Design: Enum "POS Screen Design";
    begin
        if TryFromCode(ChosenCode, Design) then
            exit(Design);
        if POSUser.Get(UserName) then
            if POSUser."Screen Design" <> POSUser."Screen Design"::" " then
                exit(POSUser."Screen Design");
        POSSetup.GetSetup();
        if POSSetup."Default Screen Design" <> POSSetup."Default Screen Design"::" " then
            exit(POSSetup."Default Screen Design");
        exit(Design::Classic);
    end;

    /// <summary>Keeps the design as the user's own default for the next sign-in.</summary>
    procedure SaveForUser(UserName: Code[50]; Design: Enum "POS Screen Design")
    var
        POSUser: Record "POS User";
    begin
        if not POSUser.Get(UserName) then
            exit;
        if POSUser."Screen Design" = Design then
            exit;
        POSUser."Screen Design" := Design;
        POSUser.Modify();
    end;
}
