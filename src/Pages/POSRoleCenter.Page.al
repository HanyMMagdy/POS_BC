page 50209 "POS Role Center"
{
    Caption = 'Point of Sale';
    PageType = RoleCenter;

    layout
    {
        area(RoleCenter)
        {
            group(Left)
            {
                ShowCaption = false;

                part(Activities; "POS Activities")
                {
                    ApplicationArea = All;
                }
                part(RecentSales; "POS Recent Receipts")
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
        }

        area(Processing)
        {
            action(POSRUN)
            {
                ApplicationArea = All;
                Caption = 'POS RUN';
                Image = Form;
                RunObject = page "POS Register";
            }
            action(RecallHeld)
            {
                ApplicationArea = All;
                Caption = 'Receipts on Hold';
                Image = Reserve;
                RunObject = page "POS Receipts";
                RunPageView = where(Status = const(Open), "On Hold" = const(true));
                ToolTip = 'See the sales that are parked at the registers.';
            }
            action(SoldItems)
            {
                ApplicationArea = All;
                Caption = 'Items Sold';
                Image = Item;
                RunObject = page "POS Sales Lines";
                ToolTip = 'See every item line that was sold through the POS.';
            }
            action(Payments)
            {
                ApplicationArea = All;
                Caption = 'Payments';
                Image = Payment;
                RunObject = page "POS Payments";
                ToolTip = 'See every cash, card and other payment taken at the registers.';
            }
        }

        area(Embedding)
        {
            action(AllReceipts)
            {
                ApplicationArea = All;
                Caption = 'POS Receipts';
                RunObject = page "POS Receipts";
                ToolTip = 'See all sales, held sales and cancelled sales.';
            }
            action(PostedReceipts)
            {
                ApplicationArea = All;
                Caption = 'Completed Sales';
                RunObject = page "POS Receipts";
                RunPageView = where(Status = const(Posted));
                ToolTip = 'See completed and posted sales only.';
            }
            action(Customers)
            {
                ApplicationArea = All;
                Caption = 'Customers';
                RunObject = page "Customer List";
            }
            action(Items)
            {
                ApplicationArea = All;
                Caption = 'Items';
                RunObject = page "Item List";
            }
        }

        area(Sections)
        {
            group(PointOfSale)
            {
                Caption = 'Point of Sale';
                Image = Sales;

                action(SectionRegister)
                {
                    ApplicationArea = All;
                    Caption = 'POS Register';
                    RunObject = page "POS Register";
                }
                action(SectionReceipts)
                {
                    ApplicationArea = All;
                    Caption = 'Receipts';
                    RunObject = page "POS Receipts";
                }
                action(SectionHeld)
                {
                    ApplicationArea = All;
                    Caption = 'Receipts on Hold';
                    RunObject = page "POS Receipts";
                    RunPageView = where(Status = const(Open), "On Hold" = const(true));
                }
                action(SectionItemsSold)
                {
                    ApplicationArea = All;
                    Caption = 'Items Sold';
                    RunObject = page "POS Sales Lines";
                }
                action(SectionPayments)
                {
                    ApplicationArea = All;
                    Caption = 'Payments';
                    RunObject = page "POS Payments";
                }
                action(SectionStoreSales)
                {
                    ApplicationArea = All;
                    Caption = 'Sales by Store';
                    RunObject = page "POS Store List";
                    ToolTip = 'See today''s receipts and sales for every store.';
                }
                action(SectionTerminalSales)
                {
                    ApplicationArea = All;
                    Caption = 'Sales by Terminal';
                    RunObject = page "POS Terminal List";
                    ToolTip = 'See today''s receipts and sales for every terminal.';
                }
            }
            group(Catalog)
            {
                Caption = 'Catalog';
                Image = Item;

                action(SectionItems)
                {
                    ApplicationArea = All;
                    Caption = 'Items';
                    RunObject = page "Item List";
                }
                action(SectionCategories)
                {
                    ApplicationArea = All;
                    Caption = 'Item Categories';
                    RunObject = page "Item Categories";
                }
                action(SectionCustomers)
                {
                    ApplicationArea = All;
                    Caption = 'Customers';
                    RunObject = page "Customer List";
                }
            }
            group(Finance)
            {
                Caption = 'Finance and Stock';
                Image = ReferenceData;

                action(SectionInvoices)
                {
                    ApplicationArea = All;
                    Caption = 'Posted Sales Invoices';
                    RunObject = page "Posted Sales Invoices";
                }
                action(SectionCustLedger)
                {
                    ApplicationArea = All;
                    Caption = 'Customer Ledger Entries';
                    RunObject = page "Customer Ledger Entries";
                }
                action(SectionBanks)
                {
                    ApplicationArea = All;
                    Caption = 'Bank Accounts';
                    RunObject = page "Bank Account List";
                }
                action(SectionItemLedger)
                {
                    ApplicationArea = All;
                    Caption = 'Item Ledger Entries';
                    RunObject = page "Item Ledger Entries";
                }
                action(SectionChart)
                {
                    ApplicationArea = All;
                    Caption = 'Chart of Accounts';
                    RunObject = page "Chart of Accounts";
                }
            }
            group(Setup)
            {
                Caption = 'POS Setup';
                Image = Setup;

                action(SectionSetup)
                {
                    ApplicationArea = All;
                    Caption = 'POS Setup';
                    RunObject = page "POS Setup";
                }
                action(SectionUsers)
                {
                    ApplicationArea = All;
                    Caption = 'POS Users';
                    RunObject = page "POS Users";
                }
                action(SectionMethods)
                {
                    ApplicationArea = All;
                    Caption = 'Payment Methods';
                    RunObject = page "POS Payment Methods";
                }
                action(SectionThemes)
                {
                    ApplicationArea = All;
                    Caption = 'Themes';
                    RunObject = page "POS Themes";
                }
                action(SectionLocations)
                {
                    ApplicationArea = All;
                    Caption = 'Locations';
                    RunObject = page "Location List";
                }
                action(SectionNoSeries)
                {
                    ApplicationArea = All;
                    Caption = 'No. Series';
                    RunObject = page "No. Series";
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
                }
                //"POS Store List"
            }
        }

        area(Reporting)
        {
            group(POScashierstorereports)
            {
                Caption = 'POS (cashier and store reports)';
                Image = Report;
                action(POSDailySalesSummary)
                {
                    ApplicationArea = All;
                    Caption = 'POS Daily Sales Summary';
                    RunObject = report "POS Daily Sales Summary";
                }
                action(POSPaymentMethodSummary)
                {
                    ApplicationArea = All;
                    Caption = 'POS Payment Method Summary';
                    RunObject = report "POS Payment Method Summary";
                }
                action(POSCashierSales)
                {
                    ApplicationArea = All;
                    Caption = 'POS Cashier Sales';
                    RunObject = report "POS Cashier Sales";
                }
                action(POSItemSales)
                {
                    ApplicationArea = All;
                    Caption = 'POS Item Sales';
                    RunObject = report "POS Item Sales";
                }
                action(POSDiscountReport)
                {
                    ApplicationArea = All;
                    Caption = 'POS Discount Report';
                    RunObject = report "POS Discount Report";
                }
                action(POSVoidedReceipts)
                {
                    ApplicationArea = All;
                    Caption = 'POS Voided Receipts';
                    RunObject = report "POS Voided Receipts";
                }
            }
            group(POSManagementReports)
            {
                Caption = 'Management reports';
                Image = Report;
                action(POSSalesByStore)
                {
                    ApplicationArea = All;
                    Caption = 'POS Sales by Store';
                    RunObject = report "POS Sales by Store";
                }
                action(POSSalesByTerminal)
                {
                    ApplicationArea = All;
                    Caption = 'POS Sales by Terminal';
                    RunObject = report "POS Sales by Terminal";
                }
            }
        }
    }
}
