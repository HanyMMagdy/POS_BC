page 50215 "POS User Card"
{
    Caption = 'POS User';
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "POS User";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("User Name"; Rec."User Name")
                {
                    ApplicationArea = All;
                    Editable = NameEditable;
                    ToolTip = 'The name typed on the register login screen. It cannot be changed later.';
                }
                field("Is Admin"; Rec."Is Admin")
                {
                    ApplicationArea = All;
                }
                field("Store No."; Rec."Store No.")
                {
                    ApplicationArea = All;
                }
                field(PasswordStatus; PasswordStatusText)
                {
                    ApplicationArea = All;
                    Caption = 'Password';
                    Editable = false;
                }
            }
            group(ChangePassword)
            {
                Caption = 'Set or change password';

                field(NewPassword; NewPassword)
                {
                    ApplicationArea = All;
                    Caption = 'New password';
                    ExtendedDatatype = Masked;
                    ToolTip = 'At least 4 characters. It is stored only as a salted hash.';
                }
                field(ConfirmPassword; ConfirmPassword)
                {
                    ApplicationArea = All;
                    Caption = 'Confirm password';
                    ExtendedDatatype = Masked;

                    trigger OnValidate()
                    begin
                        if (NewPassword <> '') and (ConfirmPassword <> '') then
                            ApplyPassword();
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SetPassword)
            {
                Caption = 'Set Password';
                ApplicationArea = All;
                Image = EncryptionKeys;
                ToolTip = 'Saves the new password for this user.';

                trigger OnAction()
                begin
                    ApplyPassword();
                end;
            }
        }
        area(Promoted)
        {
            actionref(SetPassword_Promoted; SetPassword)
            {
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        NameEditable := Rec."User Name" = '';
        UpdateStatus();
    end;

    var
        NewPassword: Text[100];
        ConfirmPassword: Text[100];
        PasswordStatusText: Text;
        NameEditable: Boolean;
        PasswordSetTxt: Label 'Set';
        NoPasswordTxt: Label 'Not set - this user cannot sign in yet';
        MismatchErr: Label 'The two passwords are not the same.';
        EnterNameErr: Label 'Enter the user name first.';
        PasswordSavedMsg: Label 'The password was saved.';

    local procedure ApplyPassword()
    begin
        if Rec."User Name" = '' then
            Error(EnterNameErr);
        if NewPassword <> ConfirmPassword then
            Error(MismatchErr);
        Rec.SetPassword(NewPassword);
        if not Rec.Modify() then
            Rec.Insert();
        Clear(NewPassword);
        Clear(ConfirmPassword);
        UpdateStatus();
        Message(PasswordSavedMsg);
    end;

    local procedure UpdateStatus()
    begin
        if Rec.HasPassword() then
            PasswordStatusText := PasswordSetTxt
        else
            PasswordStatusText := NoPasswordTxt;
    end;
}
