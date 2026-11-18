report 50213 "Driver Cash Reconciliation"
{
    Caption = 'Driver Cash Reconciliation';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;

    dataset
    {
        dataitem(DeliveryOrder; "Delivery Order")
        {
            RequestFilterFields = "Requested Date", "Driver No.", "Store No.", Status;
            DataItemTableView = sorting("Driver No.", "No.") where("Payment Mode" = const("Cash on Delivery"), Status = const(Delivered));
            column(CompanyDisplayName; CompanyDisplayName)
            {
            }
            column(ReportFilters; ReportFilters)
            {
            }
            column(No; "No.")
            {
            }
            column(Status; Status)
            {
            }
            column(DriverNo; "Driver No.")
            {
            }
            column(DriverName; "Driver Name")
            {
            }
            column(ContactName; "Contact Name")
            {
            }
            column(CustomerName; "Customer Name")
            {
            }
            column(PhoneNo; "Phone No.")
            {
            }
            column(Address; Address)
            {
            }
            column(City; City)
            {
            }
            column(ZoneCode; "Zone Code")
            {
            }
            column(PaymentMode; "Payment Mode")
            {
            }
            column(RequestedDate; "Requested Date")
            {
            }
            column(OrderAmount; "Order Amount")
            {
            }
            column(DeliveryFee; "Delivery Fee")
            {
            }
            column(AmountToCollect; "Amount to Collect")
            {
            }
            column(CollectedAmount; "Collected Amount")
            {
            }
            column(CollectionDocNo; "Collection Document No.")
            {
            }
            column(CompletedDate; "Completed Date")
            {
            }
            column(StoreNo; "Store No.")
            {
            }
            column(Difference; Difference)
            {
            }
            column(NotPosted; NotPosted)
            {
            }

            trigger OnAfterGetRecord()
            begin
                Difference := "Collected Amount" - "Amount to Collect";
                if "Collection Document No." = '' then
                    NotPosted := 1
                else
                    NotPosted := 0;
            end;
        }
    }

    rendering
    {
        layout(LayoutName)
        {
            Type = RDLC;
            LayoutFile = 'src\Report\Layout\DriverCashReconciliation.rdl';
        }
    }

    trigger OnPreReport()
    begin
        CompanyDisplayName := CompanyProperty.DisplayName();
        ReportFilters := DeliveryOrder.GetFilters();
    end;

    var
        Difference: Decimal;
        NotPosted: Integer;
        CompanyDisplayName: Text;
        ReportFilters: Text;
}
