/// <summary>Per-user choices on the register. Today: the colour theme the cashier picked.</summary>
table 50207 "POS User Setup"
{
    Caption = 'POS User Setup';
    DataClassification = EndUserIdentifiableInformation;

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; "Theme Code"; Code[10])
        {
            Caption = 'Theme Code';
            TableRelation = "POS Theme";
        }
    }

    keys
    {
        key(PK; "User ID")
        {
            Clustered = true;
        }
    }
}
