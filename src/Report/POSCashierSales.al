report 50203 "POS Cashier Sales"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;

    dataset
    {
        dataitem(POSUser; "POS User")
        {
            RequestFilterFields = "User Name";
            column(UserName_POSUser; "User Name")
            {
            }
            column(IsAdmin_POSUser; "Is Admin")
            {
            }
            column(StoreNo_POSUser; "Store No.")
            {
            }
            dataitem("POS Receipt Header"; "POS Receipt Header")
            {
                DataItemLink = "Cashier ID" = field("User Name");
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
                dataitem("POS Receipt Payment"; "POS Receipt Payment")
                {
                    DataItemLink = "Receipt No." = field("No.");

                    column(PaymentType_POSReceiptPayment; "Payment Type")
                    {
                    }
                    column(PaymentMethodCode_POSReceiptPayment; "Payment Method Code")
                    {
                    }
                    column(Amount_POSReceiptPayment; Amount)
                    {
                    }
                    column(AppliedAmount_POSReceiptPayment; "Applied Amount")
                    {
                    }
                }
            }
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
            LayoutFile = 'src\Report\Layout\POSCashierSales.rdl';
        }
    }

    var
        myInt: Integer;
}