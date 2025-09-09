page 71628595 "TMAC Unit Locations"
{
    ApplicationArea = All;
    Caption = 'Logistic Units Locations';
    PageType = List;
    SourceTable = "TMAC Unit Location";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Inbound Logistics Enabled"; Rec."Inbound Logistics Enabled")
                {
                    ApplicationArea = All;
                }
                field("Outbound Logistics Enabled"; Rec."Outbound Logistics Enabled")
                {
                    ApplicationArea = All;
                }
                field("Default Shipment Location"; Rec."Default Shipment Location")
                {
                    ApplicationArea = All;
                }
                field("Default Receipt Location"; Rec."Default Receipt Location")
                {
                    ApplicationArea = All;
                }
                field("Default Creation Location"; Rec."Default Creation Location")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
