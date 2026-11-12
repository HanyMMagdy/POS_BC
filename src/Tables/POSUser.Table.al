/// <summary>
/// People who may sign in to the register. The Password field never holds the password itself:
/// it holds "salt$hash" (random salt, PBKDF2-SHA256). Use SetPassword and VerifyPassword.
/// </summary>
table 50208 "POS User"
{
    Caption = 'POS User';
    DataClassification = EndUserIdentifiableInformation;
    LookupPageId = "POS Users";
    DrillDownPageId = "POS Users";

    fields
    {
        field(1; "User Name"; Code[50])
        {
            Caption = 'User Name';
            NotBlank = true;
        }
        field(2; Password; Text[250])
        {
            Caption = 'Password';
            Editable = false;
            DataClassification = EndUserPseudonymousIdentifiers;
        }
        field(3; "Is Admin"; Boolean)
        {
            Caption = 'Is Admin';
            ToolTip = 'Administrators can give discounts, cancel sales and discard held receipts on the register.';
        }
        field(4; "Store No."; Code[20])
        {
            Caption = 'Store No.';
            TableRelation = "POS Store";
            ToolTip = 'The store this user works in. The user can only sign in to terminals of this store. Leave blank to allow every store.';
        }
    }

    keys
    {
        key(PK; "User Name")
        {
            Clustered = true;
        }
    }

    trigger OnModify()
    begin
        if xRec."Is Admin" and (not "Is Admin") then
            EnsureAnotherAdmin();
    end;

    trigger OnDelete()
    begin
        if "Is Admin" then
            EnsureAnotherAdmin();
    end;

    trigger OnRename()
    begin
        Error(RenameErr);
    end;

    procedure SetPassword(PlainPassword: Text)
    var
        Salt: Text;
    begin
        if StrLen(PlainPassword) < 4 then
            Error(TooShortErr);
        Salt := DelChr(Format(CreateGuid()), '=', '{}-');
        Password := CopyStr(Salt + '$' + HashPassword(PlainPassword, Salt), 1, MaxStrLen(Password));
    end;

    procedure HasPassword(): Boolean
    begin
        exit(StrPos(Password, '$') > 1);
    end;

    procedure VerifyPassword(PlainPassword: Text): Boolean
    var
        Salt: Text;
        Expected: Text;
        SeparatorPos: Integer;
    begin
        SeparatorPos := StrPos(Password, '$');
        if SeparatorPos < 2 then
            exit(false);
        Salt := CopyStr(Password, 1, SeparatorPos - 1);
        Expected := CopyStr(Password, SeparatorPos + 1);
        exit(HashPassword(PlainPassword, Salt) = Expected);
    end;

    local procedure HashPassword(PlainPassword: Text; Salt: Text): Text
    var
        Rfc2898: Codeunit Rfc2898DeriveBytes;
        HashType: Option MD5,SHA1,SHA256,SHA384,SHA512;
    begin
        HashType := HashType::SHA256;
        exit(Rfc2898.HashRfc2898DeriveBytes(PlainPassword, Salt, 32, HashType));
    end;

    local procedure EnsureAnotherAdmin()
    var
        OtherAdmin: Record "POS User";
    begin
        OtherAdmin.SetFilter("User Name", '<>%1', "User Name");
        OtherAdmin.SetRange("Is Admin", true);
        if OtherAdmin.IsEmpty() then
            Error(LastAdminErr);
    end;

    var
        TooShortErr: Label 'The password must be at least 4 characters.';
        RenameErr: Label 'A user name cannot be changed because receipts refer to it. Create a new user instead.';
        LastAdminErr: Label 'There must be at least one administrator. Make another user an administrator first.';
}
