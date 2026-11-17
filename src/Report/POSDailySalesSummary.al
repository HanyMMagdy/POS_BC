report 50201 "POS Daily Sales Summary"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;
    
    dataset
    {
        dataitem("POS Receipt Header"; "POS Receipt Header")
        {
            RequestFilterFields = "Posting Date", "Store No.", "POS No.";
            DataItemTableView = where("On Hold" = const(false), Status = const(Posted), "Delivery Status" = const(New));
            column(No_POSReceiptHeader; "No.")
            {
            }
            column(AmountTendered_POSReceiptHeader; "Amount Tendered")
            {
            }
            column(ChangeAmount_POSReceiptHeader; "Change Amount")
            {
            }
            column(DiscountAmount_POSReceiptHeader; "Discount Amount")
            {
            }
            column(VATAmount_POSReceiptHeader; "VAT Amount")
            {
            }
            column(TotalAmount_POSReceiptHeader; "Total Amount")
            {
            }
            column(Subtotal_POSReceiptHeader; Subtotal)
            {
            }
            column(PostedAt_POSReceiptHeader; "Posted At")
            {
            }
            column(PostingDate_POSReceiptHeader; "Posting Date")
            {
            }
            column(Status_POSReceiptHeader; Status)
            {
            }
            column(StoreNo_POSReceiptHeader; "Store No.")
            {
            }
            column(CreatedAt_POSReceiptHeader; "Created At")
            {
            }
            column(DeliveryStatus_POSReceiptHeader; "Delivery Status")
            {
            }
            column(POSNo_POSReceiptHeader; "POS No.")
            {
            }

            trigger OnAfterGetRecord()
            begin
                if "POS Receipt Header"."Store No." = DeliveryStoreCode then begin
                    CurrReport.Skip();
                end;
            end;
        }
    }
    
    requestpage
    {
        AboutTitle = 'Teaching tip title';
        AboutText = 'Teaching tip content';
        layout
        {
            area(Content)
            {
                group(GroupName)
                {

                }
            }
        }
    
        actions
        {
            area(processing)
            {
                action(LayoutName)
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
            LayoutFile = 'src\Report\Layout\POSDailySalesSummary.rdl';
        }
    }

    trigger OnInitReport()
    begin
        if DeliverySetup.Get() then begin
            DeliverySetup.TestField("Default Delivery Store");
            DeliveryStoreCode := DeliverySetup."Default Delivery Store";
        end;
    end;


    
    var
        DeliverySetup: Record "Delivery Setup";
        DeliveryStoreCode: Code[20];
}