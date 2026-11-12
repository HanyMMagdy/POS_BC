page 50206 "POS Activities"
{
    Caption = 'Activities';
    PageType = CardPart;
    SourceTable = "POS Cue";
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            group(StoreSelection)
            {
                ShowCaption = false;

                field(StoreFilterField; StoreFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Store';
                    TableRelation = "POS Store"."No.";
                    ToolTip = 'Show the figures of one store. Leave blank to see all stores.';

                    trigger OnValidate()
                    begin
                        Rec.SetRange("Store Filter");
                        if StoreFilter <> '' then
                            Rec.SetRange("Store Filter", StoreFilter);
                        CurrPage.Update(false);
                    end;
                }
            }
            cuegroup(SalesToday)
            {
                Caption = 'Sales Today';

                field("Receipts Today"; Rec."Receipts Today")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how many sales were completed today. Choose to see them.';

                    trigger OnDrillDown()
                    begin
                        ShowReceipts(Enum::"POS Receipt Status"::Posted, false, true);
                    end;
                }
                field("Sales Today"; Rec."Sales Today")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total value of today''s sales including VAT.';

                    trigger OnDrillDown()
                    begin
                        ShowReceipts(Enum::"POS Receipt Status"::Posted, false, true);
                    end;
                }
                field("Voided Today"; Rec."Voided Today")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how many sales were cancelled today before payment.';

                    trigger OnDrillDown()
                    begin
                        ShowReceipts(Enum::"POS Receipt Status"::Voided, false, true);
                    end;
                }

                actions
                {
                    action(OpenRegister)
                    {
                        ApplicationArea = All;
                        Caption = 'Open Register';
                        RunObject = page "POS Register";
                        Image = TileNew;
                        ToolTip = 'Open the point of sale register to start a new sale.';
                    }
                }
            }
            cuegroup(PaymentsToday)
            {
                Caption = 'Payments Today';

                field("Cash Today"; Rec."Cash Today")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the cash received today, after change was given back.';

                    trigger OnDrillDown()
                    begin
                        ShowPayments(Enum::"POS Payment Type"::Cash);
                    end;
                }
                field("Card Today"; Rec."Card Today")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the card payments received today.';

                    trigger OnDrillDown()
                    begin
                        ShowPayments(Enum::"POS Payment Type"::Card);
                    end;
                }
                field("Other Today"; Rec."Other Today")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies other payments, for example vouchers, received today.';

                    trigger OnDrillDown()
                    begin
                        ShowPayments(Enum::"POS Payment Type"::Other);
                    end;
                }
            }
            cuegroup(Registers)
            {
                Caption = 'Registers';

                field("Receipts In Progress"; Rec."Receipts In Progress")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the sales that cashiers are working on right now.';

                    trigger OnDrillDown()
                    begin
                        ShowReceipts(Enum::"POS Receipt Status"::Open, false, false);
                    end;
                }
                field("Receipts On Hold"; Rec."Receipts On Hold")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the sales that are parked and can be recalled at a register.';
                    StyleExpr = HoldStyle;

                    trigger OnDrillDown()
                    begin
                        ShowReceipts(Enum::"POS Receipt Status"::Open, true, false);
                    end;
                }
            }
        }
    }

    var
        HoldStyle: Text;
        StoreFilter: Code[20];

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
        Rec.SetRange("Date Filter", WorkDate());
    end;

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Receipts On Hold");
        if Rec."Receipts On Hold" > 0 then
            HoldStyle := 'Attention'
        else
            HoldStyle := 'Favorable';
    end;

    local procedure ShowReceipts(ReceiptStatus: Enum "POS Receipt Status"; OnHold: Boolean; TodayOnly: Boolean)
    var
        Receipt: Record "POS Receipt Header";
    begin
        Receipt.SetRange(Status, ReceiptStatus);
        if ReceiptStatus = ReceiptStatus::Open then
            Receipt.SetRange("On Hold", OnHold);
        if StoreFilter <> '' then
            Receipt.SetRange("Store No.", StoreFilter);
        if TodayOnly then
            Receipt.SetRange("Posting Date", WorkDate());
        Page.Run(Page::"POS Receipts", Receipt);
    end;

    local procedure ShowPayments(PaymentType: Enum "POS Payment Type")
    var
        Payment: Record "POS Receipt Payment";
    begin
        Payment.SetRange("Payment Type", PaymentType);
        if StoreFilter <> '' then
            Payment.SetRange("Store No.", StoreFilter);
        Payment.SetRange("Posting Date", WorkDate());
        Page.Run(Page::"POS Payments", Payment);
    end;
}
