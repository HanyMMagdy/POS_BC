table 50220 "Delivery Setup"
{
    Caption = 'Delivery Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Delivery Nos."; Code[20])
        {
            Caption = 'Delivery Nos.';
            TableRelation = "No. Series";
            ToolTip = 'The number series of delivery orders. Leave blank to number them DEL000001, DEL000002 and so on.';
        }
        field(3; "COD Payment Method"; Code[10])
        {
            Caption = 'COD Payment Method';
            TableRelation = "POS Payment Method";
            ToolTip = 'The POS payment method whose balancing account receives the cash a driver collects on delivery.';
        }
        field(4; "Max Delivery Attempts"; Integer)
        {
            Caption = 'Max Delivery Attempts';
            InitValue = 3;
            MinValue = 1;
            ToolTip = 'A failed order that was already out for delivery this many times cannot be reopened.';
        }
        field(5; "Last Delivery No."; Integer)
        {
            Caption = 'Last Delivery No.';
            Editable = false;
        }
        field(6; "Delivery Client Nos."; Code[20])
        {
            Caption = 'Delivery Client Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(7; "Default Delivery Store"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "POS Store"."No." where("Store Type" = const(DeLivery));
            
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure GetSetup()
    begin
        if not Get() then begin
            Init();
            Insert();
        end;
    end;

    /// <summary>The next delivery order number: from the number series when one is set, else DEL plus a running number.</summary>
    procedure GetNextOrderNo(): Code[20]
    var
        NoSeries: Codeunit "No. Series";
    begin
        LockTable();
        GetSetup();
        if "Delivery Nos." <> '' then
            exit(NoSeries.GetNextNo("Delivery Nos.", WorkDate()));
        "Last Delivery No." += 1;
        Modify();
        exit('DEL' + Format("Last Delivery No.", 0, '<Integer,6><Filler Character,0>'));
    end;
}
