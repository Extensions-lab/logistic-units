table 71628578 "TMAC Unit Location"
{
    Caption = 'Unit Location';
    DataClassification = CustomerContent;
    DrillDownPageId = "TMAC Unit Locations";
    LookupPageId = "TMAC Unit Locations";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the location''s unique code for identifying and referencing it in logistics operations.';
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the descriptive name or purpose of this location, aiding users in identifying it.';
        }
        field(3; "Inbound Logistics Enabled"; Boolean)
        {
            Caption = 'Inbound Logistics Enabled';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether this location is available for inbound logistics processes, like receiving goods.';
        }
        field(4; "Outbound Logistics Enabled"; Boolean)
        {
            Caption = 'Outbound Logistics Enabled';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether this location is available for outbound logistics processes, like shipping goods.';
        }
        field(5; "Default Shipment Location"; Boolean)
        {
            Caption = 'Default After Shipment Location';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies if this location is automatically set for a logistic unit after a shipment is posted.';
        }
        field(6; "Default Receipt Location"; Boolean)
        {
            Caption = 'Default After Receipt Location';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies if this location is automatically set for a logistic unit after a receipt is posted.';
        }
        field(7; "Default Creation Location"; Boolean)
        {
            Caption = 'Default Creation Location';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies if newly created logistic units default to this location before any movement.';
        }
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}
