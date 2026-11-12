/// <summary>
/// A role center that holds nothing but the register screen. For cashiers: they sign in to the register
/// and have no other menu, list or setup page in front of them.
/// </summary>
page 50217 "POS Cashier Role Center"
{
    Caption = 'POS Register';
    PageType = RoleCenter;

    layout
    {
        area(RoleCenter)
        {
            part(Register; "POS Register Part")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Embedding)
        {
            // Only needed if the register part feels too small on a screen; it opens the same register full size.
            action(FullScreen)
            {
                ApplicationArea = All;
                Caption = 'Full Screen Register';
                RunObject = page "POS Register";
                ToolTip = 'Opens the register on a full page.';
            }
        }
    }
}
