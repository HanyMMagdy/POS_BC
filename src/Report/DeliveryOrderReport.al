report 50209 "Delivery Order"
{
    Caption = 'Delivery Order';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;

    dataset
    {
        dataitem(DeliveryOrder; "Delivery Order")
        {
            RequestFilterFields = "No.", Status, "Driver No.", "Requested Date";
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
            column(StoreNo; "Store No.")
            {
            }
            column(RequestedDate; "Requested Date")
            {
            }
            column(RequestedTime; "Requested Time")
            {
            }
            column(CustomerName; "Customer Name")
            {
            }
            column(ContactName; "Contact Name")
            {
            }
            column(PhoneNo; "Phone No.")
            {
            }
            column(Address; Address)
            {
            }
            column(Address2; "Address 2")
            {
            }
            column(City; City)
            {
            }
            column(PostCode; "Post Code")
            {
            }
            column(ZoneCode; "Zone Code")
            {
            }
            column(DriverName; "Driver Name")
            {
            }
            column(PaymentMode; "Payment Mode")
            {
            }
            column(DeliveryFee; "Delivery Fee")
            {
            }
            column(AmountToCollect; "Amount to Collect")
            {
            }
            column(Notes; Notes)
            {
            }
            column(ReceiptNo; "Receipt No.")
            {
            }
            dataitem(POSReceiptLine; "POS Receipt Line")
            {
                DataItemLink = "Receipt No." = field("Receipt No.");
                column(LineItemNo; "Item No.")
                {
                }
                column(LineDescription; Description)
                {
                }
                column(LineQuantity; Quantity)
                {
                }
                column(LineUnitPrice; "Unit Price")
                {
                }
                column(LineAmount; "Line Amount")
                {
                }
            }
        }
    }

    rendering
    {
        layout(LayoutName)
        {
            Type = RDLC;
            LayoutFile = 'src\Report\Layout\DeliveryOrderReport.rdl';
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
