table 50212 "Delivery Client"
{
    Caption = 'Delivery Client';
    DataClassification = CustomerContent;
    LookupPageId = "Delivery Client List";
    DrillDownPageId = "Delivery Client List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    DeliverySetup.Get();
                    NoSeries.TestManual(DeliverySetup."Delivery Client Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
            NotBlank = true;
        }
        field(3; "Name 2"; Text[50])
        {
            Caption = 'Name 2';
        }
        field(4; Address; Text[100])
        {
            Caption = 'Address';
        }
        field(5; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
        }
        field(6; City; Text[30])
        {
            Caption = 'City';
            TableRelation = if ("Country/Region Code" = const('')) "Post Code".City
            else if ("Country/Region Code" = filter(<> '')) "Post Code".City where("Country/Region Code" = field("Country/Region Code"));
            ValidateTableRelation = false;

            trigger OnLookup()
            begin
                PostCode.LookupPostCode(City, "Post Code", County, "Country/Region Code");
            end;

            trigger OnValidate()
            begin
                PostCode.ValidateCity(City, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(7; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            TableRelation = if ("Country/Region Code" = const('')) "Post Code"
            else if ("Country/Region Code" = filter(<> '')) "Post Code" where("Country/Region Code" = field("Country/Region Code"));
            ValidateTableRelation = false;

            trigger OnLookup()
            begin
                PostCode.LookupPostCode(City, "Post Code", County, "Country/Region Code");
            end;

            trigger OnValidate()
            begin
                PostCode.ValidatePostCode(City, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(8; County; Text[30])
        {
            Caption = 'County / Governorate';
        }
        field(9; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(10; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            ExtendedDatatype = PhoneNo;
        }
        field(11; "Mobile Phone No."; Text[30])
        {
            Caption = 'Mobile Phone No.';
            ExtendedDatatype = PhoneNo;
        }
        field(12; "E-Mail"; Text[80])
        {
            Caption = 'Email';
            ExtendedDatatype = EMail;
        }
        field(13; "Customer No."; Code[20])
        {
            Caption = 'Linked Customer No.';
            TableRelation = Customer."No.";
        }
        field(14; "Delivery Zone Code"; Code[20])
        {
            Caption = 'Delivery Zone Code';
            // Link to your custom Delivery Zone table if applicable
        }
        field(15; "Delivery Instructions"; Text[250])
        {
            Caption = 'Delivery Instructions';
        }
        field(16; Latitude; Decimal)
        {
            Caption = 'Latitude';
            DecimalPlaces = 6 : 8;
        }
        field(17; Longitude; Decimal)
        {
            Caption = 'Longitude';
            DecimalPlaces = 6 : 8;
        }
        field(18; Blocked; Boolean)
        {
            Caption = 'Blocked';
        }
        field(19; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
        field(20; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(SearchKey; Name, "Phone No.", "Mobile Phone No.")
        {
        }
        key(CustomerKey; "Customer No.")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", Name, "Phone No.", City, Address)
        {
        }
        fieldgroup(Brick; "No.", Name, "Mobile Phone No.", Address, City)
        {
        }
    }

    trigger OnInsert()
    begin
        if "No." = '' then begin
            DeliverySetup.Get();
            DeliverySetup.TestField("Delivery Client Nos.");
            "No. Series" := DeliverySetup."Delivery Client Nos.";
            if NoSeries.AreRelated(DeliverySetup."Delivery Client Nos.", xRec."No. Series") then
                "No. Series" := xRec."No. Series";
            "No." := NoSeries.GetNextNo("No. Series");
        end;

        "Last Date Modified" := Today();
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := Today();
    end;

    var
        DeliverySetup: Record "Delivery Setup";
        PostCode: Record "Post Code";
        NoSeries: Codeunit "No. Series";
}