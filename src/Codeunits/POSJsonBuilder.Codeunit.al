/// <summary>Turns Business Central records into the JSON the JavaScript UI renders.</summary>
codeunit 50201 "POS Json Builder"
{
    var
        POSMgt: Codeunit "POS Management";
        POSSession: Codeunit "POS Session";

    procedure BuildConfig(): JsonObject
    var
        POSSetup: Record "POS Setup";
        GLSetup: Record "General Ledger Setup";
        CompanyInfo: Record "Company Information";
        PaymentMethod: Record "POS Payment Method";
        ItemCategory: Record "Item Category";
        Theme: Record "POS Theme";
        ThemeMgt: Codeunit "POS Theme Management";
        Themes: JsonArray;
        Config: JsonObject;
        MethodObj: JsonObject;
        CategoryObj: JsonObject;
        Methods: JsonArray;
        Categories: JsonArray;
        IssuesArray: JsonArray;
        Issues: List of [Text];
        Issue: Text;
        HeaderText: Text;
        Currency: Text;
    begin
        POSSetup.GetSetup();
        GLSetup.Get();
        if CompanyInfo.Get() then;

        HeaderText := POSSetup."Receipt Header Text";
        if HeaderText = '' then
            HeaderText := CompanyInfo.Name;

        Currency := GLSetup."Local Currency Symbol";
        if Currency = '' then
            Currency := GLSetup."LCY Code";

        Config.Add('companyName', HeaderText);
        Config.Add('footer', POSSetup."Receipt Footer Text");
        Config.Add('currency', Currency);
        Config.Add('maxDiscount', POSSetup."Max Line Discount %");
        Config.Add('locationCode', POSSetup."Default Location Code");
        Config.Add('precision', POSMgt.GetRoundingPrecision());

        if PaymentMethod.FindSet() then
            repeat
                Clear(MethodObj);
                MethodObj.Add('code', PaymentMethod.Code);
                MethodObj.Add('description', PaymentMethod.Description);
                MethodObj.Add('type', Format(PaymentMethod.Type));
                MethodObj.Add('isCash', PaymentMethod.Type = PaymentMethod.Type::Cash);
                MethodObj.Add('quickAmounts', PaymentMethod."Quick Amounts");
                Methods.Add(MethodObj);
            until PaymentMethod.Next() = 0;
        Config.Add('paymentMethods', Methods);

        if ItemCategory.FindSet() then
            repeat
                if Categories.Count() < 12 then begin
                    Clear(CategoryObj);
                    CategoryObj.Add('code', ItemCategory.Code);
                    CategoryObj.Add('description', ItemCategory.Description);
                    Categories.Add(CategoryObj);
                end;
            until ItemCategory.Next() = 0;
        Config.Add('categories', Categories);

        POSMgt.GetSetupIssues(Issues);
        foreach Issue in Issues do
            IssuesArray.Add(Issue);
        Config.Add('setupIssues', IssuesArray);

        if Theme.IsEmpty() then
            ThemeMgt.InsertDefaultThemes();
        if Theme.FindSet() then
            repeat
                Themes.Add(ThemeToJson(Theme));
            until Theme.Next() = 0;
        Config.Add('themes', Themes);
        Config.Add('themeCode', ThemeMgt.GetUserThemeCode());
        Config.Add('idleMinutes', POSSetup."Auto Sign-out (minutes)");
        exit(Config);
    end;

    procedure ThemeToJson(Theme: Record "POS Theme"): JsonObject
    var
        Obj: JsonObject;
    begin
        Obj.Add('code', Theme.Code);
        Obj.Add('name', Theme.Name);
        Obj.Add('accent', Theme."Accent Color");
        Obj.Add('accentText', Theme."Accent Text Color");
        Obj.Add('background', Theme."Background Color");
        Obj.Add('panel', Theme."Panel Color");
        Obj.Add('text', Theme."Text Color");
        Obj.Add('muted', Theme."Muted Text Color");
        Obj.Add('border', Theme."Border Color");
        Obj.Add('danger', Theme."Danger Color");
        exit(Obj);
    end;

    procedure ReceiptToJson(Header: Record "POS Receipt Header"): JsonObject
    var
        Line: Record "POS Receipt Line";
        Payment: Record "POS Receipt Payment";
        PaymentMethod: Record "POS Payment Method";
        Obj: JsonObject;
        LineObj: JsonObject;
        PaymentObj: JsonObject;
        Lines: JsonArray;
        Payments: JsonArray;
        ItemCount: Decimal;
    begin
        Obj.Add('no', Header."No.");
        Obj.Add('status', Format(Header.Status));
        Obj.Add('onHold', Header."On Hold");
        Obj.Add('customerNo', Header."Customer No.");
        Obj.Add('customerName', Header."Customer Name");
        Obj.Add('locationCode', Header."Location Code");
        Obj.Add('cashier', Header."Cashier ID");
        Obj.Add('date', Format(Header."Posting Date", 0, '<Year4>-<Month,2>-<Day,2>'));
        if Header."Posted At" <> 0DT then
            Obj.Add('time', Format(Header."Posted At", 0, '<Hours24,2>:<Minutes,2>'))
        else
            Obj.Add('time', Format(Header."Created At", 0, '<Hours24,2>:<Minutes,2>'));
        Obj.Add('invoiceNo', Header."Posted Sales Invoice No.");

        Line.SetRange("Receipt No.", Header."No.");
        if Line.FindSet() then
            repeat
                Clear(LineObj);
                LineObj.Add('lineNo', Line."Line No.");
                LineObj.Add('itemNo', Line."Item No.");
                LineObj.Add('description', Line.Description);
                LineObj.Add('uom', Line."Unit of Measure Code");
                LineObj.Add('qty', Line.Quantity);
                LineObj.Add('unitPrice', Line."Unit Price");
                LineObj.Add('discountPct', Line."Line Discount %");
                LineObj.Add('discountAmount', Line."Line Discount Amount");
                LineObj.Add('lineAmount', Line."Line Amount");
                LineObj.Add('vatPct', Line."VAT %");
                Lines.Add(LineObj);
                ItemCount += Line.Quantity;
            until Line.Next() = 0;
        Obj.Add('lines', Lines);
        Obj.Add('itemCount', ItemCount);

        Obj.Add('subtotal', Header.Subtotal);
        Obj.Add('discount', Header."Discount Amount");
        Obj.Add('vat', Header."VAT Amount");
        Obj.Add('total', Header."Total Amount");
        Obj.Add('tendered', Header."Amount Tendered");
        Obj.Add('change', Header."Change Amount");

        Payment.SetRange("Receipt No.", Header."No.");
        if Payment.FindSet() then
            repeat
                Clear(PaymentObj);
                PaymentObj.Add('method', Payment."Payment Method Code");
                if PaymentMethod.Get(Payment."Payment Method Code") then
                    PaymentObj.Add('description', PaymentMethod.Description)
                else
                    PaymentObj.Add('description', Payment."Payment Method Code");
                PaymentObj.Add('amount', Payment.Amount);
                PaymentObj.Add('applied', Payment."Applied Amount");
                Payments.Add(PaymentObj);
            until Payment.Next() = 0;
        Obj.Add('payments', Payments);
        exit(Obj);
    end;

    procedure BuildProducts(SearchText: Text; CategoryCode: Code[20]): JsonArray
    var
        POSSetup: Record "POS Setup";
        Item: Record Item;
        Result: JsonArray;
        ItemObj: JsonObject;
        ItemNos: List of [Code[20]];
        ItemNo: Code[20];
        Limit: Integer;
    begin
        POSSetup.GetSetup();
        Limit := POSSetup."Product Tiles";
        if Limit <= 0 then
            Limit := 48;
        SearchText := SanitizeFilterText(SearchText);

        if SearchText = '' then
            CollectItems(Item, ItemNos, '', CategoryCode, Limit)
        else begin
            CollectItems(Item, ItemNos, 'DESC', CategoryCode, Limit, SearchText);
            CollectItems(Item, ItemNos, 'NO', CategoryCode, Limit, SearchText);
        end;

        foreach ItemNo in ItemNos do begin
            Item.Reset();
            if Item.Get(ItemNo) then begin
                if POSSetup."Default Location Code" <> '' then
                    Item.SetRange("Location Filter", POSSetup."Default Location Code");
                Item.CalcFields(Inventory);
                Clear(ItemObj);
                ItemObj.Add('no', Item."No.");
                ItemObj.Add('description', Item.Description);
                ItemObj.Add('price', POSMgt.GetUnitPrice(Item, ''));
                ItemObj.Add('uom', Item."Base Unit of Measure");
                ItemObj.Add('tracked', Item.Type = Item.Type::Inventory);
                ItemObj.Add('stock', Item.Inventory);
                ItemObj.Add('category', Item."Item Category Code");
                Result.Add(ItemObj);
            end;
        end;
        exit(Result);
    end;

    local procedure CollectItems(var Item: Record Item; var ItemNos: List of [Code[20]]; SearchMode: Text; CategoryCode: Code[20]; Limit: Integer; SearchText: Text)
    begin
        Item.Reset();
        Item.SetRange(Blocked, false);
        Item.SetRange("Sales Blocked", false);
        Item.SetFilter(Type, '%1|%2|%3', Item.Type::Inventory, Item.Type::Service, Item.Type::"Non-Inventory");
        if CategoryCode <> '' then
            Item.SetRange("Item Category Code", CategoryCode);

        case SearchMode of
            'DESC':
                Item.SetFilter("Search Description", '@*' + SearchText + '*');
            'NO':
                Item.SetFilter("No.", '@' + SearchText + '*');
        end;

        if Item.FindSet() then
            repeat
                if ItemNos.Count() >= Limit then
                    exit;
                if not ItemNos.Contains(Item."No.") then
                    ItemNos.Add(Item."No.");
            until Item.Next() = 0;
    end;

    local procedure CollectItems(var Item: Record Item; var ItemNos: List of [Code[20]]; SearchMode: Text; CategoryCode: Code[20]; Limit: Integer)
    begin
        CollectItems(Item, ItemNos, SearchMode, CategoryCode, Limit, '');
    end;

    procedure BuildCustomers(SearchText: Text): JsonArray
    var
        Customer: Record Customer;
        Result: JsonArray;
        CustomerObj: JsonObject;
        Seen: List of [Code[20]];
        Pass: Integer;
    begin
        SearchText := SanitizeFilterText(SearchText);
        for Pass := 1 to 2 do begin
            // Pass 1 searches by name, pass 2 by customer no. With no search text one pass lists the first customers.
            if (SearchText = '') and (Pass = 2) then
                break;

            Customer.Reset();
            Customer.SetRange(Blocked, Customer.Blocked::" ");
            if SearchText <> '' then begin
                if Pass = 1 then
                    Customer.SetFilter("Search Name", '@*' + SearchText + '*')
                else
                    Customer.SetFilter("No.", '@' + SearchText + '*');
            end;

            if Customer.FindSet() then
                repeat
                    if Seen.Count() >= 30 then
                        break;
                    if not Seen.Contains(Customer."No.") then begin
                        Seen.Add(Customer."No.");
                        Clear(CustomerObj);
                        CustomerObj.Add('no', Customer."No.");
                        CustomerObj.Add('name', Customer.Name);
                        CustomerObj.Add('phone', Customer."Phone No.");
                        CustomerObj.Add('city', Customer.City);
                        Result.Add(CustomerObj);
                    end;
                until Customer.Next() = 0;
        end;
        exit(Result);
    end;

    procedure BuildHeldReceipts(): JsonArray
    var
        Header: Record "POS Receipt Header";
        Line: Record "POS Receipt Line";
        Result: JsonArray;
        HeldObj: JsonObject;
        Lines: Decimal;
    begin
        Header.SetCurrentKey("Cashier ID", Status, "On Hold");
        if not POSSession.IsAdmin() then
            Header.SetRange("Cashier ID", POSSession.GetCashierId());
        Header.SetRange(Status, Header.Status::Open);
        Header.SetRange("On Hold", true);
        if Header.FindSet() then
            repeat
                Clear(HeldObj);
                Line.SetRange("Receipt No.", Header."No.");
                Line.CalcSums(Quantity);
                Lines := Line.Quantity;
                HeldObj.Add('no', Header."No.");
                HeldObj.Add('cashier', Header."Cashier ID");
                HeldObj.Add('mine', Header."Cashier ID" = POSSession.GetCashierId());
                HeldObj.Add('time', Format(Header."Created At", 0, '<Hours24,2>:<Minutes,2>'));
                HeldObj.Add('customerName', Header."Customer Name");
                HeldObj.Add('itemCount', Lines);
                HeldObj.Add('total', Header."Total Amount");
                Result.Add(HeldObj);
            until (Header.Next() = 0) or (Result.Count() >= 30);
        exit(Result);
    end;

    /// <summary>Filter operators typed by the cashier must not be interpreted as filter syntax.</summary>
    local procedure SanitizeFilterText(Value: Text): Text
    begin
        Value := DelChr(Value, '<>', ' ');
        Value := ConvertStr(Value, '&|()<>=''"@*?', '            ');
        exit(DelChr(Value, '<>', ' '));
    end;
}
