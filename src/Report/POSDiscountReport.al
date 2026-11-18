report 50205 "POS Discount Report"
{
    Caption = 'POS Discount Report';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;

    dataset
    {
        dataitem(POSReceiptLine; "POS Receipt Line")
        {
            RequestFilterFields = "Posting Date", "Store No.", "POS No.", "Cashier ID", "Item No.";
            DataItemTableView = sorting("Posting Date", "Receipt No.") where("Receipt Status" = const(Posted), "Line Discount Amount" = filter(<> 0));
            column(CompanyDisplayName; CompanyDisplayName)
            {
            }
            column(ReportFilters; ReportFilters)
            {
            }
            column(ReceiptNo; "Receipt No.")
            {
            }
            column(PostingDate; "Posting Date")
            {
            }
            column(CashierID; "Cashier ID")
            {
            }
            column(StoreNo; "Store No.")
            {
            }
            column(POSNo; "POS No.")
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
            column(UnitPrice; "Unit Price")
            {
            }
            column(LineDiscountPct; "Line Discount %")
            {
            }
            column(LineDiscountAmount; "Line Discount Amount")
            {
            }
            column(LineAmount; "Line Amount")
            {
            }
        }
    }

    rendering
    {
        layout(LayoutName)
        {
            Type = RDLC;
            LayoutFile = 'src\Report\Layout\POSDiscountReport.rdl';
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
