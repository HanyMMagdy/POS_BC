table 50223 "Delivery Order"
{
    Caption = 'Delivery Order';
    DataClassification = CustomerContent;
    LookupPageId = "Delivery Orders";
    DrillDownPageId = "Delivery Orders";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            Editable = false;
        }
        field(2; Status; Enum "Delivery Status")
        {
            Caption = 'Status';
            Editable = false;
            ToolTip = 'Changes with the actions Assign Driver, Out for Delivery, Delivered, Failed, Cancel and Reopen.';
        }
        field(3; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
            Editable = false;
            TableRelation = "POS Receipt Header";
            ToolTip = 'The POS receipt this delivery belongs to.';
        }
        field(4; "Posted Sales Invoice No."; Code[20])
        {
            Caption = 'Posted Sales Invoice No.';
            Editable = false;
            TableRelation = "Sales Invoice Header";
            ToolTip = 'The posted sales invoice of the goods. Its open amount is what the driver collects on cash on delivery.';
        }
        field(5; "Customer No."; Code[20])
        {
            Caption = 'Client No.';
            TableRelation = "Delivery Client";

            trigger OnValidate()
            begin
                if "Customer No." <> xRec."Customer No." then
                    FillFromCustomer();
            end;
        }
        field(6; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Delivery Client".Name where("No." = field("Customer No.")));
            Editable = false;
        }
        field(7; "Contact Name"; Text[100])
        {
            Caption = 'Contact Name';
            ToolTip = 'The person who receives the delivery.';
        }
        field(8; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            ExtendedDatatype = PhoneNo;
        }
        field(9; Address; Text[100])
        {
            Caption = 'Address';
        }
        field(10; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
        }
        field(11; City; Text[30])
        {
            Caption = 'City';
        }
        field(12; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
        }
        field(13; "Zone Code"; Code[20])
        {
            Caption = 'Zone Code';
            TableRelation = "Delivery Zone" where(Blocked = const(false));

            trigger OnValidate()
            var
                DeliveryZone: Record "Delivery Zone";
            begin
                if "Zone Code" = '' then
                    exit;
                DeliveryZone.Get("Zone Code");
                "Delivery Fee" := DeliveryZone.GetFee("Order Amount");
            end;
        }
        field(14; "Delivery Fee"; Decimal)
        {
            Caption = 'Delivery Fee';
            MinValue = 0;
            AutoFormatType = 1;
            ToolTip = 'The fee for this delivery. It comes from the zone and can be changed. It is kept on the order and is not posted to the ledgers.';
        }
        field(15; "Driver No."; Code[20])
        {
            Caption = 'Driver No.';
            Editable = false;
            TableRelation = "Delivery Driver";
        }
        field(16; "Driver Name"; Text[100])
        {
            Caption = 'Driver Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Delivery Driver".Name where("No." = field("Driver No.")));
            Editable = false;
        }
        field(17; "Store No."; Code[20])
        {
            Caption = 'Store No.';
            TableRelation = "POS Store";
            ToolTip = 'The store that delivers the order.';
        }
        field(18; "Payment Mode"; Enum "Delivery Payment Mode")
        {
            Caption = 'Payment Mode';
            ToolTip = 'Prepaid: nothing to collect. Cash on Delivery: the driver collects the amount and it is posted as a customer payment when the order is delivered.';

            trigger OnValidate()
            begin
                if "Payment Mode" = "Payment Mode"::Prepaid then
                    "Amount to Collect" := 0;
            end;
        }
        field(19; "Order Amount"; Decimal)
        {
            Caption = 'Order Amount';
            Editable = false;
            AutoFormatType = 1;
            ToolTip = 'The value of the goods including VAT.';
        }
        field(20; "Amount to Collect"; Decimal)
        {
            Caption = 'Amount to Collect';
            MinValue = 0;
            AutoFormatType = 1;
            ToolTip = 'The cash the driver collects. For an invoice with an open balance it is that balance, checked again when the order is delivered.';

            trigger OnValidate()
            begin
                if ("Amount to Collect" > 0) and ("Payment Mode" = "Payment Mode"::Prepaid) then
                    "Payment Mode" := "Payment Mode"::"Cash on Delivery";
            end;
        }
        field(21; "Collected Amount"; Decimal)
        {
            Caption = 'Collected Amount';
            Editable = false;
            AutoFormatType = 1;
        }
        field(22; "Collection Document No."; Code[20])
        {
            Caption = 'Collection Document No.';
            Editable = false;
            ToolTip = 'The document number of the customer payment posted for the cash collected.';
        }
        field(23; "Requested Date"; Date)
        {
            Caption = 'Requested Date';
            ToolTip = 'The day the customer wants the delivery.';
        }
        field(24; "Requested Time"; Time)
        {
            Caption = 'Requested Time';
        }
        field(25; "Assigned At"; DateTime)
        {
            Caption = 'Assigned At';
            Editable = false;
        }
        field(26; "Dispatched At"; DateTime)
        {
            Caption = 'Dispatched At';
            Editable = false;
        }
        field(27; "Delivered At"; DateTime)
        {
            Caption = 'Delivered At';
            Editable = false;
        }
        field(28; "Completed Date"; Date)
        {
            Caption = 'Completed Date';
            Editable = false;
            ToolTip = 'The day the order was delivered, failed or cancelled.';
        }
        field(29; Attempts; Integer)
        {
            Caption = 'Attempts';
            Editable = false;
            ToolTip = 'How many times the order left for delivery.';
        }
        field(30; "Failure Reason"; Text[100])
        {
            Caption = 'Failure Reason';
            Editable = false;
        }
        field(31; Notes; Text[250])
        {
            Caption = 'Notes';
        }
        field(32; "Received By"; Text[100])
        {
            Caption = 'Received By';
            Editable = false;
            ToolTip = 'Who took the delivery, as entered by the driver.';
        }
        field(33; "Created By"; Code[50])
        {
            Caption = 'Created By';
            Editable = false;
        }
        field(34; "Created At"; DateTime)
        {
            Caption = 'Created At';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(ByStatus; Status, "Requested Date")
        {
        }
        key(ByDriver; "Driver No.", Status)
        {
        }
        key(ByStore; "Store No.", Status)
        {
        }
        key(ByReceipt; "Receipt No.")
        {
        }
        key(ByInvoice; "Posted Sales Invoice No.")
        {
        }
        key(ByCompleted; Status, "Completed Date")
        {
            SumIndexFields = "Collected Amount";
        }
    }

    trigger OnInsert()
    var
        DeliverySetup: Record "Delivery Setup";
    begin
        if "No." = '' then
            "No." := DeliverySetup.GetNextOrderNo();
        "Created By" := CopyStr(UserId(), 1, MaxStrLen("Created By"));
        "Created At" := CurrentDateTime();
        if "Requested Date" = 0D then
            "Requested Date" := WorkDate();
    end;

    trigger OnDelete()
    var
        StatusLog: Record "Delivery Status Log";
    begin
        if not (Status in [Status::New, Status::Cancelled]) then
            Error(CannotDeleteErr, "No.", Status);
        StatusLog.SetRange("Delivery No.", "No.");
        StatusLog.DeleteAll();
    end;

    /// <summary>Copies the contact, phone and address of the customer onto the order (the delivery address can be changed afterwards).</summary>
    procedure FillFromCustomer()
    var
        Customer: Record "Delivery Client";
    begin
        if not Customer.Get("Customer No.") then
            exit;
        "Contact Name" := CopyStr(Customer.Name, 1, MaxStrLen("Contact Name"));
        "Phone No." := CopyStr(Customer."Phone No.", 1, MaxStrLen("Phone No."));
        Address := CopyStr(Customer.Address, 1, MaxStrLen(Address));
        "Address 2" := CopyStr(Customer."Address 2", 1, MaxStrLen("Address 2"));
        City := CopyStr(Customer.City, 1, MaxStrLen(City));
        "Post Code" := CopyStr(Customer."Post Code", 1, MaxStrLen("Post Code"));
    end;

    /// <summary>True while the order can still be changed: before it leaves for delivery.</summary>
    procedure IsEditable(): Boolean
    begin
        exit(Status in [Status::New, Status::Assigned]);
    end;

    var
        CannotDeleteErr: Label 'Delivery order %1 is %2 and cannot be deleted. Only new or cancelled orders can be deleted.', Comment = '%1 = order no., %2 = status';
}
