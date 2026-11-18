report 50211 "Delivery Status Summary"
{
    Caption = 'Delivery Status Summary';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;

    dataset
    {
        dataitem(DeliveryOrder; "Delivery Order")
        {
            RequestFilterFields = "Requested Date", "Driver No.", "Store No.", Status;
            DataItemTableView = sorting(Status, "No.");
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
        }
    }

    rendering
    {
        layout(LayoutName)
        {
            Type = RDLC;
            LayoutFile = 'src\Report\Layout\DeliveryStatusSummary.rdl';
        }
    }

    trigger OnPreReport()
    begin
        CompanyDisplayName := CompanyProperty.DisplayName();
        ReportFilters := DeliveryOrder.GetFilters();
    end;

    var
        CompanyDisplayName: Text;
        ReportFilters: Text;
}
