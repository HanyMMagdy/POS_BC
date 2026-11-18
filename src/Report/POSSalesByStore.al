report 50207 "POS Sales by Store"
{
    Caption = 'POS Sales by Store';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;

    dataset
    {
        dataitem(POSReceiptHeader; "POS Receipt Header")
        {
            RequestFilterFields = "Posting Date", "Store No.", "POS No.", "Cashier ID";
            DataItemTableView = sorting("Store No.", "POS No.") where(Status = const(Posted), "On Hold" = const(false));
            column(CompanyDisplayName; CompanyDisplayName)
            {
            }
            column(ReportFilters; ReportFilters)
            {
            }
            column(No; "No.")
            {
            }
            column(StoreNo; "Store No.")
            {
            }
            column(POSNo; "POS No.")
            {
            }
            column(Subtotal; Subtotal)
            {
            }
            column(DiscountAmount; "Discount Amount")
            {
            }
            column(VATAmount; "VAT Amount")
            {
            }
            column(TotalAmount; "Total Amount")
            {
            }
            column(StoreName; StoreName)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if POSStore.Get("Store No.") then
                    StoreName := POSStore.Name
                else
                    StoreName := '';
            end;
        }
    }

    rendering
    {
        layout(LayoutName)
        {
            Type = RDLC;
            LayoutFile = 'src\Report\Layout\POSSalesByStore.rdl';
        }
    }

    trigger OnPreReport()
    begin
        CompanyDisplayName := CompanyProperty.DisplayName();
        ReportFilters := POSReceiptHeader.GetFilters();
    end;

    var
        POSStore: Record "POS Store";
        StoreName: Text[100];
        CompanyDisplayName: Text;
        ReportFilters: Text;
}
