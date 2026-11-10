table 50201 "POS Payment Method"
{
    Caption = 'POS Payment Method';
    DataClassification = CustomerContent;
    LookupPageId = "POS Payment Methods";
    DrillDownPageId = "POS Payment Methods";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(3; Type; Enum "POS Payment Type")
        {
            Caption = 'Type';
            ToolTip = 'Only Cash payments can be overpaid. Change is given back from cash.';
        }
        field(4; "Balancing Account Type"; Enum "Gen. Journal Account Type")
        {
            Caption = 'Balancing Account Type';

            trigger OnValidate()
            begin
                if not ("Balancing Account Type" in ["Balancing Account Type"::"G/L Account", "Balancing Account Type"::"Bank Account"]) then
                    Error(AccountTypeErr);
                if xRec."Balancing Account Type" <> "Balancing Account Type" then
                    "Balancing Account No." := '';
            end;
        }
        field(5; "Balancing Account No."; Code[20])
        {
            Caption = 'Balancing Account No.';
            TableRelation = if ("Balancing Account Type" = const("G/L Account")) "G/L Account" where("Direct Posting" = const(true))
            else
            if ("Balancing Account Type" = const("Bank Account")) "Bank Account";
        }
        field(6; "Quick Amounts"; Text[100])
        {
            Caption = 'Quick Amounts';
            ToolTip = 'Comma separated amounts shown as shortcut buttons on the payment screen, for example 5,10,20,50,100.';
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    var
        AccountTypeErr: Label 'The balancing account must be a G/L Account or a Bank Account.';
}
