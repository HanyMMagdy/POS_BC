/// <summary>Colour pickers with a live miniature of the register. Used on the POS Theme card.</summary>
controladdin "POS Theme Editor"
{
    RequestedHeight = 560;
    MinimumHeight = 440;
    MinimumWidth = 640;
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = true;
    HorizontalShrink = true;

    Scripts = 'src/ControlAddIn/js/theme.js', 'src/ControlAddIn/js/themeeditor.js';
    StartupScript = 'src/ControlAddIn/js/themeeditor-start.js';
    StyleSheets = 'src/ControlAddIn/css/pos.css', 'src/ControlAddIn/css/themeeditor.css';

    /// <summary>Raised when the editor is ready to receive a theme.</summary>
    event ControlReady();

    /// <summary>Raised when the user finished choosing a colour. ColorKey: accent, accentText, background, panel, text, muted, border, danger.</summary>
    event ColorChanged(ColorKey: Text; ColorValue: Text);

    /// <summary>Shows a theme in the editor. ThemeJson comes from "POS Json Builder".ThemeToJson.</summary>
    procedure SetTheme(ThemeJson: Text);
}
