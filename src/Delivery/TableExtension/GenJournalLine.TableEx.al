/// <summary>
/// TableExtension Gen. Journal Line Ex (ID 50200) extends Record Gen. Journal Line.
/// </summary>
tableextension 50200 "Gen. Journal Line Ex" extends "Gen. Journal Line"
{
    fields
    {
        // Add changes to table fields here
        field(50200; "Delivery Client"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Delivery Client"."No.";
        }
    }
    
    keys
    {
        // Add changes to keys here
    }
    
    fieldgroups
    {
        // Add changes to field groups here
    }
    
    var
        myInt: Integer;
}