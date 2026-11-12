page 50214 "POS Users"
{
    Caption = 'POS Users';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "POS User";
    CardPageId = "POS User Card";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("User Name"; Rec."User Name")
                {
                    ApplicationArea = All;
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
                    ToolTip = 'Shows whether a password has been set. Users without a password cannot sign in.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if Rec.HasPassword() then
            PasswordStatusText := PasswordSetTxt
        else
            PasswordStatusText := NoPasswordTxt;
    end;

    var
        PasswordStatusText: Text;
        PasswordSetTxt: Label 'Set';
        NoPasswordTxt: Label 'Not set';
}
