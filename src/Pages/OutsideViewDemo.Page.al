page 50220 "Outside View Demo"
{
    Caption = 'Outside View Demo';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            usercontrol(Outside; "Outside View")
            {
                ApplicationArea = All;

                trigger ControlReady()
                begin
                    // Open full screen straight away: CurrPage.Outside.EnterOutside();
                end;

                trigger OutsideChanged(IsOutside: Boolean)
                begin
                    // Nothing to do. Use this to refresh data when the view changes.
                end;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(FullScreen)
            {
                Caption = 'Full Screen';
                ApplicationArea = All;
                Image = View;

                trigger OnAction()
                begin
                    CurrPage.Outside.EnterOutside();
                end;
            }
            action(Back)
            {
                Caption = 'Back to Page';
                ApplicationArea = All;
                Image = Undo;

                trigger OnAction()
                begin
                    CurrPage.Outside.ExitOutside();
                end;
            }
        }
    }
}