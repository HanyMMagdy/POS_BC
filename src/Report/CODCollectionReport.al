report 50212 "COD Collection Report"
{
    Caption = 'COD Collection Report';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;

    dataset
    {
        dataitem(DeliveryOrder; "Delivery Order")
        {
            RequestFilterFields = "Requested Date", "Driver No.", "Store No.", Status;
            DataItemTableView = sorting(Status, "Completed Date", "No.") where("Payment Mode" = const("Cash on Delivery"));
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

            trigger OnAfterGetRecord()
            begin
                if Status in [Status::Cancelled, Status::New] then
                    CurrReport.Skip();
                Difference := "Collected Amount" - "Amount to Collect";
            end;
        }
    }

    rendering
    {
        layout(LayoutName)
        {
            Type = RDLC;
            LayoutFile = 'src\Report\Layout\CODCollectionReport.rdl';
        }
    }

    trigger OnPreReport()
    begin
        CompanyDisplayName := CompanyProperty.DisplayName();
        ReportFilters := DeliveryOrder.GetFilters();
    end;

    var
        Difference: Decimal;
        CompanyDisplayName: Text;
        ReportFilters: Text;
}
