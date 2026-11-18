report 50206 "POS Voided Receipts"
{
    Caption = 'POS Voided Receipts';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;

    dataset
    {
        dataitem(POSReceiptHeader; "POS Receipt Header")
        {
            RequestFilterFields = "Posting Date", "Store No.", "POS No.", "Cashier ID";
            DataItemTableView = sorting("Posting Date", "No.") where(Status = const(Voided));
            column(CompanyDisplayName; CompanyDisplayName)
            {
            }
            column(ReportFilters; ReportFilters)
            {
            }
            column(No; "No.")
            {
            }
            column(PostingDate; "Posting Date")
            {
            }
            column(CreatedAt; "Created At")
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
            column(CustomerName; "Customer Name")
            {
            }
            column(LineCount; "Line Count")
            {
            }
            column(TotalAmount; "Total Amount")
            {
            }
        }
    }

    rendering
    {
        layout(LayoutName)
        {
            Type = RDLC;
            LayoutFile = 'src\Report\Layout\POSVoidedReceipts.rdl';
        }
    }

    trigger OnPreReport()
    begin
        CompanyDisplayName := CompanyProperty.DisplayName();
        ReportFilters := POSReceiptHeader.GetFilters();
    end;

    var
        CompanyDisplayName: Text;
        ReportFilters: Text;
}
