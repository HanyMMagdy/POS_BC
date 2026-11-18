page 50227 "Delivery Role Center"
{
    Caption = 'Deliveries';
    PageType = RoleCenter;

    layout
    {
        area(RoleCenter)
        {
            group(Left)
            {
                ShowCaption = false;

                part(Activities; "Delivery Activities")
                {
                    ApplicationArea = All;
                }
                part(ActiveOrders; "Delivery Active Orders")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Creation)
        {
            action(NewSale)
            {
                ApplicationArea = All;
                Caption = 'New Sale';
                Image = NewSalesInvoice;
                RunObject = page "POS Register";
                ToolTip = 'Open the register and start a new sale.';
            }
            action(NewFromReceipt)
            {
                ApplicationArea = All;
                Caption = 'New from POS Receipt';
                Image = NewDocument;
                RunObject = codeunit "New From Receipt Lookup";

                /*trigger OnAction()
                var
                    DeliveryActions: Codeunit "Delivery Actions";
                begin
                    DeliveryActions.NewFromReceiptLookup();
                end;*/
            }
            action(NewFromInvoice)
            {
                ApplicationArea = All;
                Caption = 'New from Posted Invoice';
                Image = NewSalesInvoice;
                RunObject = codeunit "New From Invoice Lookup";

                /*trigger OnAction()
                var
                    DeliveryActions: Codeunit "Delivery Actions";
                begin
                    DeliveryActions.NewFromInvoiceLookup();
                end;*/
            }
        }
        area(Embedding)
        {
            action(AllOrders)
            {
                ApplicationArea = All;
                Caption = 'Delivery Orders';
                RunObject = page "Delivery Orders";
            }
            action(NewOrders)
            {
                ApplicationArea = All;
                Caption = 'New Orders';
                RunObject = page "Delivery Orders";
                RunPageView = where(Status = const(New));
            }
            action(OnTheRoad)
            {
                ApplicationArea = All;
                Caption = 'Out for Delivery';
                RunObject = page "Delivery Orders";
                RunPageView = where(Status = const("Out for Delivery"));
            }
            action(FailedOrders)
            {
                ApplicationArea = All;
                Caption = 'Failed Deliveries';
                RunObject = page "Delivery Orders";
                RunPageView = where(Status = const(Failed));
            }
            action(Drivers)
            {
                ApplicationArea = All;
                Caption = 'Drivers';
                RunObject = page "Delivery Drivers";
            }
        }
        area(Sections)
        {
            group(DeliveryOrders)
            {
                Caption = 'Delivery';
                Image = Shipment;

                action(SectionOrders)
                {
                    ApplicationArea = All;
                    Caption = 'Delivery Orders';
                    RunObject = page "Delivery Orders";
                }
                action(SectionMine)
                {
                    ApplicationArea = All;
                    Caption = 'My Deliveries';
                    RunObject = page "My Deliveries";
                }
                action(SectionLog)
                {
                    ApplicationArea = All;
                    Caption = 'Status Log';
                    RunObject = page "Delivery Status Log";
                }
            }
            group(Related)
            {
                Caption = 'Related';
                Image = Sales;

                action(SectionReceipts)
                {
                    ApplicationArea = All;
                    Caption = 'POS Receipts';
                    RunObject = page "POS Receipts";
                    RunPageView = where(Status = const(Posted));
                }
                action(SectionInvoices)
                {
                    ApplicationArea = All;
                    Caption = 'Posted Sales Invoices';
                    RunObject = page "Posted Sales Invoices";
                }
                action(SectionCustomers)
                {
                    ApplicationArea = All;
                    Caption = 'Clients';
                    RunObject = page "Delivery Client List";
                }
            }
            group(Setup)
            {
                Caption = 'Delivery Setup';
                Image = Setup;

                action(SectionSetup)
                {
                    ApplicationArea = All;
                    Caption = 'Delivery Setup';
                    RunObject = page "Delivery Setup";
                }
                action(SectionZones)
                {
                    ApplicationArea = All;
                    Caption = 'Delivery Zones';
                    RunObject = page "Delivery Zones";
                }
                action(SectionDrivers)
                {
                    ApplicationArea = All;
                    Caption = 'Delivery Drivers';
                    RunObject = page "Delivery Drivers";
                }
                action(POSTerminal)
                {
                    ApplicationArea = All;
                    Caption = 'POS Terminal';
                    RunObject = page "POS Terminal List";
                }
                action(POSStore)
                {
                    ApplicationArea = All;
                    Caption = 'POS Store';
                    RunObject = page "POS Store List";
                    RunPageView = where("Store Type" = const(Delivery));
                }
                action(SectionUsers)
                {
                    ApplicationArea = All;
                    Caption = 'POS Users';
                    RunObject = page "POS Users";
                }
            }
        }

        area(Reporting)
        {
            group(DeliveryReports)
            {
                Caption = 'Delivery reports';
                Image = Report;
                action(RptDeliveryOrder)
                {
                    ApplicationArea = All;
                    Caption = 'Delivery Order';
                    RunObject = report "Delivery Order";
                }
                action(RptRunSheet)
                {
                    ApplicationArea = All;
                    Caption = 'Delivery Run Sheet';
                    RunObject = report "Delivery Run Sheet";
                }
                action(RptStatusSummary)
                {
                    ApplicationArea = All;
                    Caption = 'Delivery Status Summary';
                    RunObject = report "Delivery Status Summary";
                }
                action(RptCODCollection)
                {
                    ApplicationArea = All;
                    Caption = 'COD Collection Report';
                    RunObject = report "COD Collection Report";
                }
                action(RptDriverCash)
                {
                    ApplicationArea = All;
                    Caption = 'Driver Cash Reconciliation';
                    RunObject = report "Driver Cash Reconciliation";
                }
            }
        }
    }
}
