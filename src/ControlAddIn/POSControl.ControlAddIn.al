/// <summary>
/// The register screen. All drawing is done in JavaScript (js/pos.js, css/pos.css).
/// AL only sends it JSON and answers its requests; the UI never touches data on its own.
/// </summary>
controladdin "POS Control"
{
    RequestedHeight = 780;
    MinimumHeight = 560;
    MinimumWidth = 900;
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = true;
    HorizontalShrink = true;

    Scripts = 'src/ControlAddIn/js/theme.js', 'src/ControlAddIn/js/pos.js';
    StartupScript = 'src/ControlAddIn/js/startup.js';
    StyleSheets = 'src/ControlAddIn/css/pos.css';

    /// <summary>Raised once the script has loaded and the screen can receive data.</summary>
    event ControlReady();

    /// <summary>Every user action: ActionName is the verb, Payload a JSON object with its arguments.</summary>
    event ActionRequested(ActionName: Text; Payload: Text);

    /// <summary>Sends static configuration (company, payment methods, categories, themes).</summary>
    procedure Initialize(ConfigJson: Text);

    /// <summary>Sends the result of an action: the current receipt and whatever else changed.</summary>
    procedure Apply(ResponseJson: Text);
}
