page 50212 "POS Themes"
{
    Caption = 'POS Themes';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "POS Theme";
    CardPageId = "POS Theme Card";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field("Accent Color"; Rec."Accent Color")
                {
                    ApplicationArea = All;
                }
                field("Background Color"; Rec."Background Color")
                {
                    ApplicationArea = All;
                }
                field("Panel Color"; Rec."Panel Color")
                {
                    ApplicationArea = All;
                }
                field("Text Color"; Rec."Text Color")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateDefaults)
            {
                ApplicationArea = All;
                Caption = 'Create Default Themes';
                Image = Setup;
                ToolTip = 'Add the Teal, Midnight and Sunset themes that ship with the app. Themes that already exist are not changed.';

                trigger OnAction()
                var
                    ThemeMgt: Codeunit "POS Theme Management";
                begin
                    ThemeMgt.InsertDefaultThemes();
                    CurrPage.Update(false);
                end;
            }
            action(SetDefault)
            {
                ApplicationArea = All;
                Caption = 'Use as Default Theme';
                Image = Default;
                ToolTip = 'Make this the theme cashiers start with.';

                trigger OnAction()
                var
                    POSSetup: Record "POS Setup";
                begin
                    POSSetup.GetSetup();
                    POSSetup."Default Theme Code" := Rec.Code;
                    POSSetup.Modify();
                    Message(DefaultSetMsg, Rec.Code);
                end;
            }
        }
        area(Promoted)
        {
            actionref(SetDefault_Promoted; SetDefault)
            {
            }
            actionref(CreateDefaults_Promoted; CreateDefaults)
            {
            }
        }
    }

    var
        DefaultSetMsg: Label 'Theme %1 is now the default for cashiers who have not chosen their own.', Comment = '%1 = theme code';
}
