/// <summary>
/// Single entry point for everything the JavaScript UI asks for. The page runs this codeunit with
/// Codeunit.Run, so a failed action (for example a posting error) rolls back every change it made
/// and the error text is sent back to the UI instead of a modal error dialog.
/// </summary>
codeunit 50202 "POS Action Handler"
{
    trigger OnRun()
    begin
        ProcessRequest();
    end;

    var
        POSMgt: Codeunit "POS Management";
        JsonBuilder: Codeunit "POS Json Builder";
        ThemeMgt: Codeunit "POS Theme Management";
        POSSession: Codeunit "POS Session";
        LoginError: Text;
        PayloadObj: JsonObject;
        Response: JsonObject;
        RequestAction: Text;
        RequestPayload: Text;
        ResponseText: Text;
        InvalidPayloadErr: Label 'The request from the POS screen could not be read.';
        UnknownActionErr: Label 'Unknown POS action %1.', Comment = '%1 = action name';
        NoPaymentsErr: Label 'Add at least one payment before completing the sale.';
        EmptySaleErr: Label 'Add at least one item before taking payment.';
        NoLastReceiptErr: Label 'There is no previous receipt for this cashier.';
        NoExactMatchMsg: Label 'No item matches "%1". Showing similar items.', Comment = '%1 = scanned text';
        SaleCompletedMsg: Label 'Sale %1 completed. Invoice %2 posted.', Comment = '%1 = receipt no., %2 = posted sales invoice no.';
        HeldMsg: Label 'Receipt %1 is on hold.', Comment = '%1 = receipt no.';
        RecalledMsg: Label 'Receipt %1 recalled.', Comment = '%1 = receipt no.';
        TakenOverMsg: Label 'Receipt %1 taken over from %2.', Comment = '%1 = receipt no., %2 = cashier who held it';
        VoidedMsg: Label 'Sale cancelled.';
        EnterCredentialsErr: Label 'Enter your user name and password.';

    procedure SetRequest(NewAction: Text; NewPayload: Text)
    begin
        RequestAction := NewAction;
        RequestPayload := NewPayload;
        ResponseText := '';
    end;

    procedure GetResponseText(): Text
    begin
        exit(ResponseText);
    end;

    /// <summary>Used by the page after a failed run, so the UI always receives the current receipt back.</summary>
    procedure BuildErrorResponse(ErrorText: Text): Text
    var
        Header: Record "POS Receipt Header";
        Obj: JsonObject;
        MsgObj: JsonObject;
        Result: Text;
    begin
        MsgObj.Add('type', 'error');
        MsgObj.Add('text', ErrorText);
        Obj.Add('message', MsgObj);
        if POSSession.IsActive() then begin
            if POSMgt.FindCurrentReceipt(Header) then
                Obj.Add('receipt', JsonBuilder.ReceiptToJson(Header));
            Obj.Add('heldCount', POSMgt.CountHeld());
        end;
        Obj.Add('session', BuildSession());
        Obj.WriteTo(Result);
        exit(Result);
    end;

    local procedure ProcessRequest()
    var
        Header: Record "POS Receipt Header";
    begin
        Clear(Response);
        Clear(PayloadObj);
        if RequestPayload <> '' then
            if not PayloadObj.ReadFrom(RequestPayload) then
                Error(InvalidPayloadErr);

        // Session actions work without a signed-in user. Everything else needs one.
        case RequestAction of
            'session':
                begin
                    FinishResponse();
                    exit;
                end;
            'logout':
                begin
                    POSSession.Logout();
                    FinishResponse();
                    exit;
                end;
            'login':
                begin
                    if not HandleLogin() then begin
                        FinishResponse();
                        exit;
                    end;
                    RequestAction := 'init';
                end;
        end;
        POSSession.RequireLogin();

        if not POSMgt.FindCurrentReceipt(Header) then
            POSMgt.CreateReceipt(Header);

        case RequestAction of
            'init':
                begin
                    AddProducts('', '');
                    AddHeld();
                end;
            'search-products':
                AddProducts(GetText('text'), CopyStr(GetText('category'), 1, 20));
            'scan':
                HandleScan(Header);
            'add-item':
                POSMgt.AddItem(Header, CopyStr(GetText('itemNo'), 1, 20), GetDecimal('qty', 1));
            'set-qty':
                POSMgt.SetLineQuantity(Header, GetInteger('lineNo'), GetDecimal('qty', 0));
            'set-discount':
                POSMgt.SetLineDiscount(Header, GetInteger('lineNo'), GetDecimal('pct', 0));
            'remove-line':
                POSMgt.RemoveLine(Header, GetInteger('lineNo'));
            'search-customers':
                Response.Add('customers', JsonBuilder.BuildCustomers(GetText('text')));
            'set-customer':
                POSMgt.SetCustomer(Header, CopyStr(GetText('customerNo'), 1, 20));
            'hold':
                begin
                    POSMgt.HoldReceipt(Header);
                    AddMessage('info', StrSubstNo(HeldMsg, Header."No."));
                end;
            'list-held':
                begin
                    AddHeld();
                    Response.Add('openPanel', 'held');
                end;
            'recall':
                HandleRecall();
            'discard-held':
                begin
                    POSSession.RequireAdmin();
                    DiscardHeld(CopyStr(GetText('receiptNo'), 1, 20));
                    AddHeld();
                    Response.Add('openPanel', 'held');
                end;
            'clear':
                begin
                    POSSession.RequireAdmin();
                    POSMgt.VoidReceipt(Header);
                    AddMessage('info', VoidedMsg);
                end;
            'checkout':
                HandleCheckout(Header);
            'reprint-last':
                HandleReprintLast();
            'set-theme':
                ThemeMgt.SetUserTheme(CopyStr(GetText('code'), 1, 10));
            else
                Error(UnknownActionErr, RequestAction);
        end;

        // Hold, recall, void and checkout change which receipt is current.
        if not POSMgt.FindCurrentReceipt(Header) then
            POSMgt.CreateReceipt(Header);
        Response.Add('receipt', JsonBuilder.ReceiptToJson(Header));
        Response.Add('heldCount', POSMgt.CountHeld());
        FinishResponse();
    end;

    local procedure HandleLogin(): Boolean
    var
        UserName: Text;
        Password: Text;
    begin
        UserName := GetText('userName');
        Password := GetText('password');
        if (DelChr(UserName, '<>', ' ') = '') or (Password = '') then begin
            LoginError := EnterCredentialsErr;
            exit(false);
        end;
        exit(POSSession.TryLogin(UserName, Password, GetText('terminalNo'), LoginError));
    end;

    /// <summary>Every response carries the session, so the UI always knows whether it is signed in and as whom.</summary>
    local procedure FinishResponse()
    begin
        Response.Add('session', BuildSession());
        Response.WriteTo(ResponseText);
    end;

    local procedure BuildSession(): JsonObject
    var
        POSUser: Record "POS User";
        POSSetup: Record "POS Setup";
        TerminalObj: JsonObject;
        Obj: JsonObject;
    begin
        POSSetup.GetSetup();
        Obj.Add('loggedIn', POSSession.IsActive());
        Obj.Add('userName', POSSession.GetUserName());
        Obj.Add('isAdmin', POSSession.IsAdmin());
        Obj.Add('hasUsers', not POSUser.IsEmpty());
        Obj.Add('themeCode', ThemeMgt.GetUserThemeCode());
        Obj.Add('idleMinutes', POSSession.GetAutoLogoffMinutes(POSSetup."Auto Sign-out (minutes)"));
        if POSSession.IsActive() then begin
            TerminalObj.Add('no', POSSession.GetTerminalNo());
            TerminalObj.Add('description', POSSession.GetTerminalDescription());
            TerminalObj.Add('storeNo', POSSession.GetStoreNo());
            TerminalObj.Add('storeName', POSSession.GetStoreName());
            Obj.Add('terminal', TerminalObj);
        end else
            Obj.Add('terminals', JsonBuilder.BuildTerminals());
        if LoginError <> '' then
            Obj.Add('error', LoginError);
        exit(Obj);
    end;

    local procedure HandleScan(var Header: Record "POS Receipt Header")
    var
        Item: Record Item;
        ScannedCode: Text;
        Qty: Decimal;
    begin
        ScannedCode := GetText('code');
        Qty := 1;
        ParseQuantityPrefix(ScannedCode, Qty);

        if POSMgt.FindItemByCode(ScannedCode, Item) then
            POSMgt.AddItem(Header, Item."No.", Qty)
        else begin
            AddProducts(ScannedCode, '');
            AddMessage('info', StrSubstNo(NoExactMatchMsg, ScannedCode));
        end;
    end;

    /// <summary>"3*5449000000996" means quantity 3 of that bar code.</summary>
    local procedure ParseQuantityPrefix(var ScannedCode: Text; var Qty: Decimal)
    var
        StarPos: Integer;
        ParsedQty: Decimal;
    begin
        StarPos := StrPos(ScannedCode, '*');
        if StarPos > 1 then
            if Evaluate(ParsedQty, CopyStr(ScannedCode, 1, StarPos - 1)) then
                if ParsedQty > 0 then begin
                    Qty := ParsedQty;
                    ScannedCode := CopyStr(ScannedCode, StarPos + 1);
                end;
    end;

    local procedure HandleCheckout(var Header: Record "POS Receipt Header")
    var
        PostReceipt: Codeunit "POS Post Receipt";
        PaymentsToken: JsonToken;
        PaymentToken: JsonToken;
        PaymentObj: JsonObject;
        ValueToken: JsonToken;
        MethodCode: Code[10];
        Amount: Decimal;
    begin
        if not POSMgt.HasLines(Header) then
            Error(EmptySaleErr);
        if not PayloadObj.Get('payments', PaymentsToken) then
            Error(NoPaymentsErr);

        POSMgt.ClearPayments(Header);
        foreach PaymentToken in PaymentsToken.AsArray() do begin
            PaymentObj := PaymentToken.AsObject();
            MethodCode := '';
            Amount := 0;
            if PaymentObj.Get('method', ValueToken) then
                MethodCode := CopyStr(ValueToken.AsValue().AsText(), 1, MaxStrLen(MethodCode));
            if PaymentObj.Get('amount', ValueToken) then
                Amount := ValueToken.AsValue().AsDecimal();
            POSMgt.AddPayment(Header, MethodCode, Amount);
        end;

        PostReceipt.Run(Header);

        Header.Get(Header."No.");
        Response.Add('receiptDone', JsonBuilder.ReceiptToJson(Header));
        AddMessage('success', StrSubstNo(SaleCompletedMsg, Header."No.", Header."Posted Sales Invoice No."));
    end;

    local procedure HandleRecall()
    var
        Held: Record "POS Receipt Header";
        ReceiptNo: Code[20];
        FromCashier: Code[50];
    begin
        ReceiptNo := CopyStr(GetText('receiptNo'), 1, MaxStrLen(ReceiptNo));
        if Held.Get(ReceiptNo) then
            FromCashier := Held."Cashier ID";
        POSMgt.RecallReceipt(ReceiptNo);
        if (FromCashier <> '') and (FromCashier <> POSSession.GetCashierId()) then
            AddMessage('info', StrSubstNo(TakenOverMsg, ReceiptNo, FromCashier))
        else
            AddMessage('info', StrSubstNo(RecalledMsg, ReceiptNo));
    end;

    local procedure HandleReprintLast()
    var
        Last: Record "POS Receipt Header";
    begin
        if not POSMgt.FindLastPosted(Last) then
            Error(NoLastReceiptErr);
        Response.Add('receiptDone', JsonBuilder.ReceiptToJson(Last));
    end;

    local procedure DiscardHeld(ReceiptNo: Code[20])
    var
        Held: Record "POS Receipt Header";
    begin
        if Held.Get(ReceiptNo) then
            if Held."On Hold" and (Held.Status = Held.Status::Open) then
                POSMgt.VoidReceipt(Held);
    end;

    // ------------------------------------------------------------------
    // Response helpers
    // ------------------------------------------------------------------

    local procedure AddProducts(SearchText: Text; CategoryCode: Code[20])
    begin
        Response.Add('products', JsonBuilder.BuildProducts(SearchText, CategoryCode));
    end;

    local procedure AddHeld()
    begin
        Response.Add('held', JsonBuilder.BuildHeldReceipts());
    end;

    local procedure AddMessage(MessageType: Text; MessageText: Text)
    var
        MsgObj: JsonObject;
    begin
        MsgObj.Add('type', MessageType);
        MsgObj.Add('text', MessageText);
        if Response.Contains('message') then
            Response.Replace('message', MsgObj)
        else
            Response.Add('message', MsgObj);
    end;

    // ------------------------------------------------------------------
    // Payload readers
    // ------------------------------------------------------------------

    local procedure GetText(KeyName: Text): Text
    var
        ValueToken: JsonToken;
    begin
        if PayloadObj.Get(KeyName, ValueToken) then
            if ValueToken.IsValue() then
                if not ValueToken.AsValue().IsNull() then
                    exit(ValueToken.AsValue().AsText());
        exit('');
    end;

    local procedure GetDecimal(KeyName: Text; DefaultValue: Decimal): Decimal
    var
        ValueToken: JsonToken;
    begin
        if PayloadObj.Get(KeyName, ValueToken) then
            if ValueToken.IsValue() then
                if not ValueToken.AsValue().IsNull() then
                    exit(ValueToken.AsValue().AsDecimal());
        exit(DefaultValue);
    end;

    local procedure GetInteger(KeyName: Text): Integer
    begin
        exit(Round(GetDecimal(KeyName, 0), 1));
    end;
}
