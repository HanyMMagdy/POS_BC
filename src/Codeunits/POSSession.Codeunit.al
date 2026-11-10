/// <summary>
/// Who is signed in to the register. SingleInstance: lives for the Business Central session only, in server memory,
/// so the browser cannot claim to be signed in. Every register action except login checks it.
/// </summary>
codeunit 50206 "POS Session"
{
    SingleInstance = true;

    var
        CurrentUser: Code[50];
        CurrentIsAdmin: Boolean;
        Active: Boolean;
        FailedAttempts: Integer;
        LockedUntil: DateTime;
        InvalidLoginMsg: Label 'Wrong user name or password.';
        LockedMsg: Label 'Too many failed attempts. Try again in %1 seconds.', Comment = '%1 = seconds';
        NotSignedInErr: Label 'Please sign in to continue.';
        AdminOnlyErr: Label 'This action needs an administrator.';

    /// <summary>Checks the credentials. Returns false with a text instead of raising an error, so failures can be counted.</summary>
    procedure TryLogin(UserName: Text; Password: Text; var ErrorText: Text): Boolean
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
