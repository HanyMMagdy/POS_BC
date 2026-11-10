page 50213 "POS Theme Card"
{
    Caption = 'POS Theme';
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "POS Theme";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
            }
            group(Colors)
            {
                Caption = 'Colors';
                InstructionalText = 'Pick colors in the editor below, or type a hex value such as #0B6B63.';

                field("Accent Color"; Rec."Accent Color")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        PushTheme();
                    end;
                }
                field("Accent Text Color"; Rec."Accent Text Color")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        PushTheme();
                    end;
                }
                field("Background Color"; Rec."Background Color")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        PushTheme();
                    end;
                }
                field("Panel Color"; Rec."Panel Color")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        PushTheme();
                    end;
                }
                field("Text Color"; Rec."Text Color")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        PushTheme();
                    end;
                }
                field("Muted Text Color"; Rec."Muted Text Color")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        PushTheme();
                    end;
                }
                field("Border Color"; Rec."Border Color")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        PushTheme();
                    end;
                }
                field("Danger Color"; Rec."Danger Color")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        PushTheme();
                    end;
                }
            }
            group(PreviewGroup)
            {
                Caption = 'Live preview';

                usercontrol(Editor; "POS Theme Editor")
                {
                    ApplicationArea = All;

                    trigger ControlReady()
                    begin
                        EditorReady := true;
                        PushTheme();
                    end;

                    trigger ColorChanged(ColorKey: Text; ColorValue: Text)
                    begin
                        ApplyColor(ColorKey, ColorValue);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UseForMe)
            {
                ApplicationArea = All;
                Caption = 'Use for Me';
                Image = UserSetup;
                ToolTip = 'Switch your own register screen to this theme.';

                trigger OnAction()
                var
                    ThemeMgt: Codeunit "POS Theme Management";
                begin
                    Rec.TestField(Code);
                    ThemeMgt.SetUserTheme(Rec.Code);
                    Message(UsedMsg, Rec.Name);
                end;
            }
            action(UseAsDefault)
            {
                ApplicationArea = All;
                Caption = 'Use as Default Theme';
                Image = Default;
                ToolTip = 'Make this the theme cashiers start with.';

                trigger OnAction()
                var
                    POSSetup: Record "POS Setup";
                begin
                    Rec.TestField(Code);
                    POSSetup.GetSetup();
                    POSSetup."Default Theme Code" := Rec.Code;
                    POSSetup.Modify();
                    Message(DefaultMsg, Rec.Name);
                end;
            }
        }
        area(Promoted)
        {
            actionref(UseForMe_Promoted; UseForMe)
            {
            }
            actionref(UseAsDefault_Promoted; UseAsDefault)
            {
            }
        }
    }

    var
        EditorReady: Boolean;
        SkipPush: Boolean;
        CodeFirstErr: Label 'Enter a code for the theme before choosing colors.';
        UsedMsg: Label 'Open the register to see the %1 theme.', Comment = '%1 = theme name';
        DefaultMsg: Label '%1 is now the default theme.', Comment = '%1 = theme name';

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.ApplyDefaults();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        PushTheme();
    end;

    local procedure PushTheme()
    var
        JsonBuilder: Codeunit "POS Json Builder";
        ThemeObj: JsonObject;
        ThemeText: Text;
    begin
        if (not EditorReady) or SkipPush then
            exit;
        ThemeObj := JsonBuilder.ThemeToJson(Rec);
        ThemeObj.WriteTo(ThemeText);
        CurrPage.Editor.SetTheme(ThemeText);
    end;

    local procedure ApplyColor(ColorKey: Text; ColorValue: Text)
    begin
        if Rec.Code = '' then
            Error(CodeFirstErr);

        case ColorKey of
            'accent':
                Rec.Validate("Accent Color", CopyStr(ColorValue, 1, 7));
            'accentText':
                Rec.Validate("Accent Text Color", CopyStr(ColorValue, 1, 7));
            'background':
                Rec.Validate("Background Color", CopyStr(ColorValue, 1, 7));
            'panel':
                Rec.Validate("Panel Color", CopyStr(ColorValue, 1, 7));
            'text':
                Rec.Validate("Text Color", CopyStr(ColorValue, 1, 7));
            'muted':
                Rec.Validate("Muted Text Color", CopyStr(ColorValue, 1, 7));
            'border':
                Rec.Validate("Border Color", CopyStr(ColorValue, 1, 7));
            'danger':
                Rec.Validate("Danger Color", CopyStr(ColorValue, 1, 7));
        end;

        // The editor already shows this colour, so do not send it back while the picker may still be open.
        SkipPush := true;
        CurrPage.Update(true);
        SkipPush := false;
    end;
}
