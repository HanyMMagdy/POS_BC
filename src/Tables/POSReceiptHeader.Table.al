table 50202 "POS Receipt Header"
{
    Caption = 'POS Receipt Header';
    DataClassification = CustomerContent;
    LookupPageId = "POS Receipts";
    DrillDownPageId = "POS Receipts";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            Editable = false;
        }
        field(2; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            Editable = false;
        }
        field(3; "Created At"; DateTime)
        {
            Caption = 'Created At';
            Editable = false;
        }
        field(4; "Cashier ID"; Code[50])
        {
            Caption = 'Cashier ID';
            Editable = false;
            TableRelation = "POS User";
            ValidateTableRelation = false;
        }
        field(5; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;

            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                "Customer Name" := '';
                if "Customer No." <> '' then
                    if Customer.Get("Customer No.") then
                        "Customer Name" := Customer.Name;
            end;
        }
        field(6; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            Editable = false;
        }
        field(7; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(8; Status; Enum "POS Receipt Status")
        {
            Caption = 'Status';
            Editable = false;
        }
        field(9; "On Hold"; Boolean)
        {
            Caption = 'On Hold';
            Editable = false;
        }
        field(20; Subtotal; Decimal)
        {
            Caption = 'Subtotal (excl. VAT)';
            Editable = false;
            AutoFormatType = 1;
        }
        field(21; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            Editable = false;
            AutoFormatType = 1;
        }
        field(22; "VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
            Editable = false;
            AutoFormatType = 1;
        }
        field(23; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
            Editable = false;
            AutoFormatType = 1;
        }
        field(24; "Amount Tendered"; Decimal)
        {
            Caption = 'Amount Tendered';
            Editable = false;
            AutoFormatType = 1;
        }
        field(25; "Change Amount"; Decimal)
        {
            Caption = 'Change Amount';
            Editable = false;
            AutoFormatType = 1;
        }
        field(26; "Recalled From"; Code[50])
        {
            Caption = 'Taken Over From';
            Editable = false;
            ToolTip = 'The cashier who put this sale on hold, when an administrator took it over.';
        }
        field(30; "Posted Sales Invoice No."; Code[20])
        {
            Caption = 'Posted Sales Invoice No.';
            Editable = false;
            TableRelation = "Sales Invoice Header";
        }
        field(31; "Posted At"; DateTime)
        {
            Caption = 'Posted At';
            Editable = false;
        }
        field(40; "Line Count"; Integer)
        {
            Caption = 'Line Count';
            FieldClass = FlowField;
            CalcFormula = count("POS Receipt Line" where("Receipt No." = field("No.")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(Cashier; "Cashier ID", Status, "On Hold")
        {
        }
        key(ByStatus; Status, "Posting Date")
        {
            SumIndexFields = "Total Amount";
        }
    }

    trigger OnInsert()
    var
        POSSetup: Record "POS Setup";
        NoSeries: Codeunit "No. Series";
        POSSession: Codeunit "POS Session";
    begin
        POSSetup.GetSetup();
        if "No." = '' then begin
            POSSetup.TestField("Receipt Nos.");
            "No." := NoSeries.GetNextNo(POSSetup."Receipt Nos.", WorkDate());
        end;
        "Posting Date" := WorkDate();
        "Created At" := CurrentDateTime();
        "Cashier ID" := POSSession.GetCashierId();
        if "Customer No." = '' then
            Validate("Customer No.", POSSetup."Default Customer No.");
        if "Location Code" = '' then
            "Location Code" := POSSetup."Default Location Code";
    end;

    trigger OnDelete()
    var
        ReceiptLine: Record "POS Receipt Line";
        ReceiptPayment: Record "POS Receipt Payment";
    begin
        if Status = Status::Posted then
            Error(CannotDeletePostedErr);
        ReceiptLine.SetRange("Receipt No.", "No.");
        ReceiptLine.DeleteAll();
        ReceiptPayment.SetRange("Receipt No.", "No.");
        ReceiptPayment.DeleteAll();
    end;

    var
        CannotDeletePostedErr: Label 'A posted receipt cannot be deleted.';
}
