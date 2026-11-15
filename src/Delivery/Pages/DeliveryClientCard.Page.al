/// <summary>
/// Page Delivery Client Card (ID 50234).
/// </summary>
page 50234 "Delivery Client Card"
{
    Caption = 'Delivery Client Card';
    PageType = Card;
    SourceTable = "Delivery Client";
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique number of the delivery client.';

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the delivery client.';
                }
                field("Name 2"; Rec."Name 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies an additional part of the client name.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the linked customer account used for financial postings.';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this delivery client is blocked from new orders.';
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the delivery client record was last updated.';
                }
            }

            group(AddressAndContact)
            {
                Caption = 'Address & Contact';

                group(AddressDetails)
                {
                    Caption = 'Address';

                    field(Address; Rec.Address)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the street address of the delivery client.';
                    }
                    field("Address 2"; Rec."Address 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies additional address details such as building, floor, or apartment.';
                    }
                    field(City; Rec.City)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the city of the delivery client.';
                    }
                    field(County; Rec.County)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the county or governorate.';
                    }
                    field("Post Code"; Rec."Post Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the postal code.';
                    }
                    field("Country/Region Code"; Rec."Country/Region Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the country or region code.';
                    }
                }

                group(ContactDetails)
                {
                    Caption = 'Contact';

                    field("Phone No."; Rec."Phone No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the primary telephone number.';
                    }
                    field("Mobile Phone No."; Rec."Mobile Phone No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the mobile phone number.';
                    }
                    field("E-Mail"; Rec."E-Mail")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the email address of the delivery client.';
                    }
                }
            }

            group(DeliveryDetails)
            {
                Caption = 'Delivery & Location';

                field("Delivery Zone Code"; Rec."Delivery Zone Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the delivery zone assigned to this client.';
                }
                field("Delivery Instructions"; Rec."Delivery Instructions")
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ToolTip = 'Specifies special notes or directions for the delivery driver.';
                }
                field(Latitude; Rec.Latitude)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the GPS latitude coordinate.';
                }
                field(Longitude; Rec.Longitude)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the GPS longitude coordinate.';
                }
            }
        }

        area(FactBoxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(OpenMap)
            {
                ApplicationArea = All;
                Caption = 'Show on Map';
                Image = Map;
                ToolTip = 'Opens the client coordinates in Google Maps.';

                trigger OnAction()
                begin
                    if (Rec.Latitude <> 0) and (Rec.Longitude <> 0) then
                        Hyperlink(StrSubstNo('https://www.google.com/maps/search/?api=1&query=%1,%2', Format(Rec.Latitude, 0, 9), Format(Rec.Longitude, 0, 9)))
                    else
                        Message('Latitude and Longitude are not set for this delivery client.');
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(OpenMap_Promoted; OpenMap)
                {
                }
            }
        }
    }

    local procedure AssistEdit(OldDeliveryClient: Record "Delivery Client"): Boolean
    var
        DeliverySetup: Record "Delivery Setup";
        NoSeries: Codeunit "No. Series";
    begin
        DeliverySetup.Get();
        DeliverySetup.TestField("Delivery Client Nos.");
        if NoSeries.LookupRelatedNoSeries(DeliverySetup."Delivery Client Nos.", OldDeliveryClient."No. Series", Rec."No. Series") then begin
            Rec."No." := NoSeries.GetNextNo(Rec."No. Series");
            exit(true);
        end;
    end;
}