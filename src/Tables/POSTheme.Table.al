/// <summary>A named colour scheme for the register screen. Colours are stored as #RRGGBB.</summary>
table 50206 "POS Theme"
{
    Caption = 'POS Theme';
    DataClassification = CustomerContent;
    LookupPageId = "POS Themes";
    DrillDownPageId = "POS Themes";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Name; Text[50])
        {
            Caption = 'Name';
        }
        field(10; "Accent Color"; Text[7])
        {
            Caption = 'Accent Color';
            ToolTip = 'Main buttons, selected items and highlights, for example #0B6B63.';

            trigger OnValidate()
            begin
                "Accent Color" := NormalizeColor("Accent Color");
            end;
        }
        field(11; "Accent Text Color"; Text[7])
        {
            Caption = 'Text on Accent';
            ToolTip = 'Text and icons drawn on top of the accent colour.';

            trigger OnValidate()
            begin
                "Accent Text Color" := NormalizeColor("Accent Text Color");
            end;
        }
        field(12; "Background Color"; Text[7])
        {
            Caption = 'Screen Background';

            trigger OnValidate()
            begin
                "Background Color" := NormalizeColor("Background Color");
            end;
        }
        field(13; "Panel Color"; Text[7])
        {
            Caption = 'Panels and Cards';
            ToolTip = 'The colour of the item tiles, the receipt panel, the top bar and dialogs.';

            trigger OnValidate()
            begin
                "Panel Color" := NormalizeColor("Panel Color");
            end;
        }
        field(14; "Text Color"; Text[7])
        {
            Caption = 'Main Text';

            trigger OnValidate()
            begin
                "Text Color" := NormalizeColor("Text Color");
            end;
        }
        field(15; "Muted Text Color"; Text[7])
        {
            Caption = 'Secondary Text';

            trigger OnValidate()
            begin
                "Muted Text Color" := NormalizeColor("Muted Text Color");
            end;
        }
        field(16; "Border Color"; Text[7])
        {
            Caption = 'Borders';

            trigger OnValidate()
            begin
                "Border Color" := NormalizeColor("Border Color");
            end;
        }
        field(17; "Danger Color"; Text[7])
        {
            Caption = 'Warnings and Delete';

            trigger OnValidate()
            begin
                "Danger Color" := NormalizeColor("Danger Color");
            end;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        ApplyDefaults();
    end;

    /// <summary>Fills every empty colour with the default Teal values, so a new theme is always usable.</summary>
    procedure ApplyDefaults()
    begin
        if "Accent Color" = '' then
            "Accent Color" := '#0B6B63';
        if "Accent Text Color" = '' then
            "Accent Text Color" := '#FFFFFF';
        if "Background Color" = '' then
            "Background Color" := '#EEF0F2';
        if "Panel Color" = '' then
            "Panel Color" := '#FFFFFF';
        if "Text Color" = '' then
            "Text Color" := '#1A1F26';
        if "Muted Text Color" = '' then
            "Muted Text Color" := '#667085';
        if "Border Color" = '' then
            "Border Color" := '#E3E6EA';
        if "Danger Color" = '' then
            "Danger Color" := '#B42318';
    end;

    /// <summary>Accepts #RGB, #RRGGBB or the same without #, and returns #RRGGBB in capitals.</summary>
    local procedure NormalizeColor(Value: Text): Text[7]
    var
        Hex: Text;
    begin
        Hex := UpperCase(DelChr(Value, '<>', ' '));
        if Hex = '' then
            exit('');
        if CopyStr(Hex, 1, 1) = '#' then
            Hex := CopyStr(Hex, 2);
        if StrLen(Hex) = 3 then
            Hex := CopyStr(Hex, 1, 1) + CopyStr(Hex, 1, 1) + CopyStr(Hex, 2, 1) + CopyStr(Hex, 2, 1) + CopyStr(Hex, 3, 1) + CopyStr(Hex, 3, 1);
        if (StrLen(Hex) <> 6) or (DelChr(Hex, '=', '0123456789ABCDEF') <> '') then
            Error(InvalidColorErr, Value);
        exit(CopyStr('#' + Hex, 1, 7));
    end;

    var
        InvalidColorErr: Label '"%1" is not a valid colour. Use a hex value such as #0B6B63.', Comment = '%1 = the text that was entered';
}
