report 50200 "POS Receipt"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;
    
    dataset
    {
        dataitem("POS Receipt Header"; "POS Receipt Header")
        {

            column(AmountTendered_DataItemName; "Amount Tendered")
            {
            }
            column(CashierID_DataItemName; "Cashier ID")
            {
            }
            column(ChangeAmount_DataItemName; "Change Amount")
            {
            }
            column(CreatedAt_DataItemName; "Created At")
            {
            }
            column(CustomerName_DataItemName; "Customer Name")
            {
            }
            column(CustomerNo_DataItemName; "Customer No.")
            {
            }
            column(DiscountAmount_DataItemName; "Discount Amount")
            {
            }
            column(LineCount_DataItemName; "Line Count")
            {
            }
            column(LocationCode_DataItemName; "Location Code")
            {
            }
            column(No_DataItemName; "No.")
            {
            }
            column(OnHold_DataItemName; "On Hold")
            {
            }
            column(POSNo_DataItemName; "POS No.")
            {
            }
            column(PostedAt_DataItemName; "Posted At")
            {
            }
            column(PostedSalesInvoiceNo_DataItemName; "Posted Sales Invoice No.")
            {
            }
            column(PostingDate_DataItemName; "Posting Date")
            {
            }
            column(RecalledFrom_DataItemName; "Recalled From")
            {
            }
            column(Status_DataItemName; Status)
            {
            }
            column(StoreNo_DataItemName; "Store No.")
            {
            }
            column(Subtotal_DataItemName; Subtotal)
            {
            }
            column(TotalAmount_DataItemName; "Total Amount")
            {
            }
            column(VATAmount_DataItemName; "VAT Amount")
            {
            }
            column(SystemCreatedAt_DataItemName; SystemCreatedAt)
            {
            }
            column(SystemCreatedBy_DataItemName; SystemCreatedBy)
            {
            }
            column(SystemModifiedAt_DataItemName; SystemModifiedAt)
            {
            }
            column(SystemModifiedBy_DataItemName; SystemModifiedBy)
            {
            }
            column(SystemId_DataItemName; SystemId)
            {
            }
            dataitem("POS Receipt Line"; "POS Receipt Line")
            {
                DataItemLink = "Receipt No." = field("No.");
                column(CashierID_POSReceiptLine; "Cashier ID")
                {
                }
                column(Description_POSReceiptLine; Description)
                {
                }
                column(ItemNo_POSReceiptLine; "Item No.")
                {
                }
                column(LineAmount_POSReceiptLine; "Line Amount")
                {
                }
                column(LineDiscount_POSReceiptLine; "Line Discount %")
                {
                }
                column(LineDiscountAmount_POSReceiptLine; "Line Discount Amount")
                {
                }
                column(LineNo_POSReceiptLine; "Line No.")
                {
                }
                column(POSNo_POSReceiptLine; "POS No.")
                {
                }
                column(PostingDate_POSReceiptLine; "Posting Date")
                {
                }
                column(Quantity_POSReceiptLine; Quantity)
                {
                }
                column(ReceiptNo_POSReceiptLine; "Receipt No.")
                {
                }
                column(ReceiptStatus_POSReceiptLine; "Receipt Status")
                {
                }
                column(StoreNo_POSReceiptLine; "Store No.")
                {
                }
                column(SystemCreatedAt_POSReceiptLine; SystemCreatedAt)
                {
                }
                column(SystemCreatedBy_POSReceiptLine; SystemCreatedBy)
                {
                }
                column(SystemId_POSReceiptLine; SystemId)
                {
                }
                column(SystemModifiedAt_POSReceiptLine; SystemModifiedAt)
                {
                }
                column(SystemModifiedBy_POSReceiptLine; SystemModifiedBy)
                {
                }
                column(UnitofMeasureCode_POSReceiptLine; "Unit of Measure Code")
                {
                }
                column(UnitPrice_POSReceiptLine; "Unit Price")
                {
                }
                column(VAT_POSReceiptLine; "VAT %")
                {
                }
            }
            dataitem("POS Receipt Payment"; "POS Receipt Payment")
            {
                DataItemLink = "Receipt No." = field("No.");

                column(Amount_POSReceiptPayment; Amount)
                {
                }
                column(AppliedAmount_POSReceiptPayment; "Applied Amount")
                {
                }
                column(LineNo_POSReceiptPayment; "Line No.")
                {
                }
                column(PaymentMethodCode_POSReceiptPayment; "Payment Method Code")
                {
                }
                column(PaymentType_POSReceiptPayment; "Payment Type")
                {
                }
                column(POSNo_POSReceiptPayment; "POS No.")
                {
                }
                column(PostingDate_POSReceiptPayment; "Posting Date")
                {
                }
                column(ReceiptNo_POSReceiptPayment; "Receipt No.")
                {
                }
                column(StoreNo_POSReceiptPayment; "Store No.")
                {
                }
                column(SystemCreatedAt_POSReceiptPayment; SystemCreatedAt)
                {
                }
                column(SystemCreatedBy_POSReceiptPayment; SystemCreatedBy)
                {
                }
                column(SystemId_POSReceiptPayment; SystemId)
                {
                }
                column(SystemModifiedAt_POSReceiptPayment; SystemModifiedAt)
                {
                }
                column(SystemModifiedBy_POSReceiptPayment; SystemModifiedBy)
                {
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
            LayoutFile = 'src\Report\Layout\POSReceipt.rdl';
        }
    }
}