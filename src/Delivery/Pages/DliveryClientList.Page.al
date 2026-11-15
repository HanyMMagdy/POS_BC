page 50233 "Delivery Client List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Delivery Client";
    CardPageId = "Delivery Client Card";
    
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field.', Comment = '%';
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the value of the Name field.', Comment = '%';
                }
                field("Name 2"; Rec."Name 2")
                {
                    ToolTip = 'Specifies the value of the Name 2 field.', Comment = '%';
                }
                field(Address; Rec.Address)
                {
                    ToolTip = 'Specifies the value of the Address field.', Comment = '%';
                }
                field("Address 2"; Rec."Address 2")
                {
                    ToolTip = 'Specifies the value of the Address 2 field.', Comment = '%';
                }
                field(City; Rec.City)
                {
                    ToolTip = 'Specifies the value of the City field.', Comment = '%';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ToolTip = 'Specifies the value of the Country/Region Code field.', Comment = '%';
                }
                field(County; Rec.County)
                {
                    ToolTip = 'Specifies the value of the County / Governorate field.', Comment = '%';
                }
                field("Delivery Instructions"; Rec."Delivery Instructions")
                {
                    ToolTip = 'Specifies the value of the Delivery Instructions field.', Comment = '%';
                }
                field("Delivery Zone Code"; Rec."Delivery Zone Code")
                {
                    ToolTip = 'Specifies the value of the Delivery Zone Code field.', Comment = '%';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Linked Customer No. field.', Comment = '%';
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ToolTip = 'Specifies the value of the Email field.', Comment = '%';
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {
                    ToolTip = 'Specifies the value of the Last Date Modified field.', Comment = '%';
                }
                field(Latitude; Rec.Latitude)
                {
                    ToolTip = 'Specifies the value of the Latitude field.', Comment = '%';
                }
                field(Longitude; Rec.Longitude)
                {
                    ToolTip = 'Specifies the value of the Longitude field.', Comment = '%';
                }
                field("Mobile Phone No."; Rec."Mobile Phone No.")
                {
                    ToolTip = 'Specifies the value of the Mobile Phone No. field.', Comment = '%';
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ToolTip = 'Specifies the value of the Phone No. field.', Comment = '%';
                }
                field("Post Code"; Rec."Post Code")
                {
                    ToolTip = 'Specifies the value of the Post Code field.', Comment = '%';
                }
            }
        }
        area(Factboxes)
        {
            
        }
    }
    
    actions
    {
        area(Processing)
        {
        }
    }
}