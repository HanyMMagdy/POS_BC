/// <summary>
/// The register screen as a part, so a role center can show it directly. It works exactly like the POS Register page.
/// </summary>
page 50216 "POS Register Part"
{
    Caption = 'POS Register';
    PageType = CardPart;
    Editable = false;

    layout
    {
        area(Content)
        {
            usercontrol(POS; "POS Control")
            {
                ApplicationArea = All;

                trigger ControlReady()
                var
                    JsonBuilder: Codeunit "POS Json Builder";
                    POSSession: Codeunit "POS Session";
                    Config: JsonObject;
                    ConfigText: Text;
                begin
                    // The register always starts at the login screen.
                    POSSession.Logout();
                    Config := JsonBuilder.BuildConfig();
                    Config.WriteTo(ConfigText);
                    CurrPage.POS.Initialize(ConfigText);
                    RunAction('session', '');
                end;

                trigger ActionRequested(ActionName: Text; Payload: Text)
                begin
                    RunAction(ActionName, Payload);
                end;
            }
        }
    }

    local procedure RunAction(ActionName: Text; Payload: Text)
    var
        Handler: Codeunit "POS Action Handler";
        ResponseText: Text;
    begin
        Handler.SetRequest(ActionName, Payload);
        // Codeunit.Run needs a clean transaction. If the action fails, everything it wrote is rolled back.
        Commit();
        if Handler.Run() then
            ResponseText := Handler.GetResponseText()
        else
            ResponseText := Handler.BuildErrorResponse(GetLastErrorText());
        CurrPage.POS.Apply(ResponseText);
    end;
}
