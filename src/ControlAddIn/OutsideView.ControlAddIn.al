/// <summary>
/// ControlAddIn Outside View.
/// </summary>
controladdin "Outside View"
{
    RequestedHeight = 400;
    MinimumHeight = 200;
    VerticalStretch = true;
    HorizontalStretch = true;
    StartupScript = 'js/outsideview.js';

    /// Lifts the add-in out of the page and over the whole browser window.
    procedure EnterOutside();
    /// Puts it back into the page.
    procedure ExitOutside();

    /// <summary>
    /// ControlReady.
    /// </summary>
    event ControlReady();
    /// <summary>
    /// OutsideChanged.
    /// </summary>
    /// <param name="IsOutside">Boolean.</param>
    /// IsOutside = true when the add-in now covers the whole window.
    event OutsideChanged(IsOutside: Boolean);
}