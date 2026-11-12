page 50200 "POS Register"
{
    Caption = 'POS Register';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;
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
                    // Opening the register always starts at the login screen.
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

    actions
    {
        area(Navigation)
        {
            action(Receipts)
            {
                Caption = 'Receipts';
                ApplicationArea = All;
                Image = Document;
                RunObject = page "POS Receipts";
                visible = false;
            }
            action(Setup)
            {
                Caption = 'POS Setup';
                ApplicationArea = All;
                Image = Setup;
                RunObject = page "POS Setup";
                visible = false;
            }
            action(Users)
            {
                Caption = 'POS Users';
                ApplicationArea = All;
                Image = Users;
                RunObject = page "POS Users";
                visible = false;
            }
            action(PaymentMethods)
            {
                Caption = 'Payment Methods';
                ApplicationArea = All;
                Image = Payment;
                RunObject = page "POS Payment Methods";
                visible = false;
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
