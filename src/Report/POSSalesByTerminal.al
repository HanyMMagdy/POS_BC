report 50208 "POS Sales by Terminal"
{
    Caption = 'POS Sales by Terminal';
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
            column(TerminalDescription; TerminalDescription)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if POSTerminal.Get("POS No.") then
                    TerminalDescription := POSTerminal.Description
                else
                    TerminalDescription := '';
            end;
        }
    }

    rendering
    {
        layout(LayoutName)
        {
            Type = RDLC;
            LayoutFile = 'src\Report\Layout\POSSalesByTerminal.rdl';
        }
    }

    trigger OnPreReport()
    begin
        CompanyDisplayName := CompanyProperty.DisplayName();
        ReportFilters := POSReceiptHeader.GetFilters();
    end;

    var
        POSTerminal: Record "POS Terminal";
        TerminalDescription: Text[100];
        CompanyDisplayName: Text;
        ReportFilters: Text;
}
