/// <summary>
/// Who is signed in to the register. SingleInstance: lives for the Business Central session only, in server memory,
/// so the browser cannot claim to be signed in. Every register action except login checks it.
/// A session is also tied to one POS terminal (and so to one store), chosen on the login screen.
/// </summary>
codeunit 50206 "POS Session"
{
    SingleInstance = true;

    var
        CurrentUser: Code[50];
        CurrentIsAdmin: Boolean;
        CurrentTerminalNo: Code[20];
        CurrentTerminalDescription: Text[100];
        CurrentStoreNo: Code[20];
        CurrentStoreName: Text[100];
        CurrentLocationCode: Code[10];
        CurrentDefaultCustomerNo: Code[20];
        CurrentReceiptNos: Code[20];
        CurrentAutoLogoff: Integer;
        Active: Boolean;
        FailedAttempts: Integer;
        LockedUntil: DateTime;
        InvalidLoginMsg: Label 'Wrong user name or password.';
        LockedMsg: Label 'Too many failed attempts. Try again in %1 seconds.', Comment = '%1 = seconds';
        NotSignedInErr: Label 'Please sign in to continue.';
        AdminOnlyErr: Label 'This action needs an administrator.';
        ChooseTerminalErr: Label 'Choose the terminal you are working at.';
        UnknownTerminalErr: Label 'That terminal does not exist.';
        TerminalNotActiveErr: Label 'Terminal %1 is not active (status: %2).', Comment = '%1 = terminal no., %2 = status';
        StoreNotFoundErr: Label 'The store of terminal %1 is not set up.', Comment = '%1 = terminal no.';
        StoreNotActiveErr: Label 'Store %1 is not active.', Comment = '%1 = store no.';
        WrongStoreErr: Label 'User %1 works in store %2 and cannot sign in to terminal %3 of store %4.', Comment = '%1 = user, %2 = user store, %3 = terminal, %4 = terminal store';
        ManagerOnlyErr: Label 'Terminal %1 can only be used by an administrator.', Comment = '%1 = terminal no.';

    /// <summary>
    /// Checks the credentials and the terminal. Returns false with a text instead of raising an error, so failures can be counted.
    /// Only a wrong user name or password counts towards the lock-out; a wrong terminal does not.
    /// </summary>
    procedure TryLogin(UserName: Text; Password: Text; TerminalNo: Text; var ErrorText: Text): Boolean
    var
        POSUser: Record "POS User";
    begin
        Logout();

        if (LockedUntil <> 0DT) and (CurrentDateTime() < LockedUntil) then begin
            ErrorText := StrSubstNo(LockedMsg, Round((LockedUntil - CurrentDateTime()) / 1000, 1, '>'));
            exit(false);
        end;

        UserName := DelChr(UserName, '<>', ' ');
        if (UserName <> '') and (StrLen(UserName) <= MaxStrLen(POSUser."User Name")) then
            if POSUser.Get(CopyStr(UserName, 1, MaxStrLen(POSUser."User Name"))) then
                if POSUser.VerifyPassword(Password) then begin
                    FailedAttempts := 0;
                    LockedUntil := 0DT;
                    if not StartTerminal(POSUser, TerminalNo, ErrorText) then begin
                        Logout();
                        exit(false);
                    end;
                    CurrentUser := POSUser."User Name";
                    CurrentIsAdmin := POSUser."Is Admin";
                    Active := true;
                    exit(true);
                end;

        // Slow guessing down, and lock after five misses. The message never says which part was wrong.
        Sleep(700);
        FailedAttempts += 1;
        if FailedAttempts >= 5 then begin
            LockedUntil := CurrentDateTime() + 30000;
            FailedAttempts := 0;
            ErrorText := StrSubstNo(LockedMsg, 30);
        end else
            ErrorText := InvalidLoginMsg;
        exit(false);
    end;

    procedure Logout()
    begin
        Active := false;
        CurrentIsAdmin := false;
        CurrentUser := '';
        CurrentTerminalNo := '';
        CurrentTerminalDescription := '';
        CurrentStoreNo := '';
        CurrentStoreName := '';
        CurrentLocationCode := '';
        CurrentDefaultCustomerNo := '';
        CurrentReceiptNos := '';
        CurrentAutoLogoff := 0;
    end;

    /// <summary>
    /// Validates the chosen terminal for this user and remembers its store, location and settings.
    /// Until the first terminal is created the register still works without one (nothing is linked to a store).
    /// </summary>
    local procedure StartTerminal(POSUser: Record "POS User"; TerminalNo: Text; var ErrorText: Text): Boolean
    var
        Terminal: Record "POS Terminal";
        Store: Record "POS Store";
    begin
        if Terminal.IsEmpty() then
            exit(true);

        TerminalNo := DelChr(TerminalNo, '<>', ' ');
        if TerminalNo = '' then begin
            ErrorText := ChooseTerminalErr;
            exit(false);
        end;
        if StrLen(TerminalNo) > MaxStrLen(Terminal."No.") then begin
            ErrorText := UnknownTerminalErr;
            exit(false);
        end;
        if not Terminal.Get(CopyStr(TerminalNo, 1, MaxStrLen(Terminal."No."))) then begin
            ErrorText := UnknownTerminalErr;
            exit(false);
        end;
        if Terminal.Status <> Terminal.Status::Active then begin
            ErrorText := StrSubstNo(TerminalNotActiveErr, Terminal."No.", Terminal.Status);
            exit(false);
        end;
        if not Store.Get(Terminal."Store No.") then begin
            ErrorText := StrSubstNo(StoreNotFoundErr, Terminal."No.");
            exit(false);
        end;
        if not Store.Active then begin
            ErrorText := StrSubstNo(StoreNotActiveErr, Store."No.");
            exit(false);
        end;
        if (POSUser."Store No." <> '') and (POSUser."Store No." <> Store."No.") then begin
            ErrorText := StrSubstNo(WrongStoreErr, POSUser."User Name", POSUser."Store No.", Terminal."No.", Store."No.");
            exit(false);
        end;
        if Terminal."Manager Privileges Required" and (not POSUser."Is Admin") then begin
            ErrorText := StrSubstNo(ManagerOnlyErr, Terminal."No.");
            exit(false);
        end;

        CurrentTerminalNo := Terminal."No.";
        CurrentTerminalDescription := Terminal.Description;
        CurrentStoreNo := Store."No.";
        CurrentStoreName := Store.Name;
        if Terminal."Location Code" <> '' then
            CurrentLocationCode := CopyStr(Terminal."Location Code", 1, MaxStrLen(CurrentLocationCode))
        else
            CurrentLocationCode := CopyStr(Store."Location Code", 1, MaxStrLen(CurrentLocationCode));
        CurrentDefaultCustomerNo := Store."Default Customer No.";
        CurrentReceiptNos := Terminal."Receipt No. Series";
        CurrentAutoLogoff := Terminal."Auto Logoff After (Min.)";
        exit(true);
    end;

    procedure IsActive(): Boolean
    begin
        exit(Active);
    end;

    procedure IsAdmin(): Boolean
    begin
        exit(Active and CurrentIsAdmin);
    end;

    procedure GetUserName(): Code[50]
    begin
        exit(CurrentUser);
    end;

    /// <summary>The id stored as cashier on receipts: the POS user, or the Business Central user when nobody is signed in.</summary>
    procedure GetCashierId(): Code[50]
    begin
        if Active then
            exit(CurrentUser);
        exit(CopyStr(UserId(), 1, MaxStrLen(CurrentUser)));
    end;

    /// <summary>The terminal this session works at. Blank until terminals are set up, and when nobody is signed in.</summary>
    procedure GetTerminalNo(): Code[20]
    begin
        exit(CurrentTerminalNo);
    end;

    procedure GetTerminalDescription(): Text[100]
    begin
        exit(CurrentTerminalDescription);
    end;

    procedure GetStoreNo(): Code[20]
    begin
        exit(CurrentStoreNo);
    end;

    procedure GetStoreName(): Text[100]
    begin
        exit(CurrentStoreName);
    end;

    /// <summary>The stock location of the terminal (or its store). Falls back to the given default, normally POS Setup.</summary>
    procedure GetLocationCode(DefaultLocationCode: Code[10]): Code[10]
    begin
        if CurrentLocationCode <> '' then
            exit(CurrentLocationCode);
        exit(DefaultLocationCode);
    end;

    /// <summary>The store's own default customer, else the given default (POS Setup).</summary>
    procedure GetDefaultCustomerNo(DefaultCustomerNo: Code[20]): Code[20]
    begin
        if CurrentDefaultCustomerNo <> '' then
            exit(CurrentDefaultCustomerNo);
        exit(DefaultCustomerNo);
    end;

    /// <summary>The terminal's own receipt number series, else the given default (POS Setup).</summary>
    procedure GetReceiptNoSeries(DefaultSeries: Code[20]): Code[20]
    begin
        if CurrentReceiptNos <> '' then
            exit(CurrentReceiptNos);
        exit(DefaultSeries);
    end;

    /// <summary>Idle minutes before auto sign-out: the terminal's own value when set, else the given default (POS Setup).</summary>
    procedure GetAutoLogoffMinutes(DefaultMinutes: Integer): Integer
    begin
        if CurrentAutoLogoff > 0 then
            exit(CurrentAutoLogoff);
        exit(DefaultMinutes);
    end;

    procedure RequireLogin()
    begin
        if not Active then
            Error(NotSignedInErr);
    end;

    procedure RequireAdmin()
    begin
        RequireLogin();
        if not CurrentIsAdmin then
            Error(AdminOnlyErr);
    end;
}
