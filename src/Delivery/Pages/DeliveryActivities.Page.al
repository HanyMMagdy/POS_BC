page 50226 "Delivery Activities"
{
    Caption = 'Delivery Activities';
    PageType = CardPart;
    SourceTable = "Delivery Cue";
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            cuegroup(OpenOrders)
            {
                Caption = 'Open Orders';

                field("New Orders"; Rec."New Orders")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the orders that have no driver yet.';

                    trigger OnDrillDown()
                    begin
                        ShowOrders(Enum::"Delivery Status"::New);
                    end;
                }
                field("Assigned Orders"; Rec."Assigned Orders")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the orders that have a driver but have not left yet.';

                    trigger OnDrillDown()
                    begin
                        ShowOrders(Enum::"Delivery Status"::Assigned);
                    end;
                }
                field("Out for Delivery"; Rec."Out for Delivery")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the orders that are on the road.';

                    trigger OnDrillDown()
                    begin
                        ShowOrders(Enum::"Delivery Status"::"Out for Delivery");
                    end;
                }

                actions
                {
                    action(NewFromReceipt)
                    {
                        ApplicationArea = All;
                        Caption = 'New from POS Receipt';
                        Image = TileNew;

                        trigger OnAction()
                        var
                            DeliveryActions: Codeunit "Delivery Actions";
                        begin
                            DeliveryActions.NewFromReceiptLookup();
                        end;
                    }
                }
            }
            cuegroup(Today)
            {
                Caption = 'Today';

                field("Delivered Today"; Rec."Delivered Today")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        ShowOrders(Enum::"Delivery Status"::Delivered);
                    end;
                }
                field("Failed Today"; Rec."Failed Today")
                {
                    ApplicationArea = All;
                    StyleExpr = FailedStyle;

                    trigger OnDrillDown()
                    begin
                        ShowOrders(Enum::"Delivery Status"::Failed);
                    end;
                }
            }
            cuegroup(CashOnDelivery)
            {
                Caption = 'Cash on Delivery';

                field("COD to Collect"; Rec."COD to Collect")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the cash still to be collected on open cash-on-delivery orders.';
                }
                field("COD Collected Today"; Rec."COD Collected Today")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the cash collected by drivers today.';
                }
            }
        }
    }

    var
        StoreFilter: Code[20];
        FailedStyle: Text;

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
        Rec.CalcFields("Failed Today");
        if Rec."Failed Today" > 0 then
            FailedStyle := 'Unfavorable'
        else
            FailedStyle := 'Standard';
    end;

    local procedure ShowOrders(Status: Enum "Delivery Status")
    var
        Order: Record "Delivery Order";
    begin
        Order.SetRange(Status, Status);
        if StoreFilter <> '' then
            Order.SetRange("Store No.", StoreFilter);
        if Status in [Status::Delivered, Status::Failed] then
            Order.SetRange("Completed Date", WorkDate());
        Page.Run(Page::"Delivery Orders", Order);
    end;
}
