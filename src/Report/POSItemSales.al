report 50204 "POS Item Sales"
{
    Caption = 'POS Item Sales';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;

    dataset
    {
        dataitem(POSReceiptLine; "POS Receipt Line")
        {
            RequestFilterFields = "Posting Date", "Store No.", "POS No.", "Item No.", "Cashier ID";
            DataItemTableView = sorting("Item No.") where("Receipt Status" = const(Posted));
            column(CompanyDisplayName; CompanyDisplayName)
            {
            }
            column(ReportFilters; ReportFilters)
            {
            }
            column(ItemNo; "Item No.")
            {
            }
            column(ItemDescription; Description)
            {
            }
            column(Quantity; Quantity)
            {
            }
            column(LineDiscountAmount; "Line Discount Amount")
            {
            }
            column(LineAmount; "Line Amount")
            {
            }
            column(ReceiptNo; "Receipt No.")
            {
            }
        }
    }

    rendering
    {
        layout(LayoutName)
        {
            Type = RDLC;
            LayoutFile = 'src\Report\Layout\POSItemSales.rdl';
        }
    }

    trigger OnPreReport()
    begin
        CompanyDisplayName := CompanyProperty.DisplayName();
        ReportFilters := POSReceiptLine.GetFilters();
    end;

    var
        CompanyDisplayName: Text;
        ReportFilters: Text;
}
