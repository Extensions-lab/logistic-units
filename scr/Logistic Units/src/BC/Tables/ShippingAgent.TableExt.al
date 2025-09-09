tableextension 71628577 "TMAC Shipping Agent" extends "Shipping Agent"
{
    fields
    {
        field(71628575; "TMAC Tracking Provider"; Enum "TMAC Tracking Provider")
        {
            Caption = 'Tracking Provider';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the tracking provider that this shipping agent uses for shipment tracking, such as AfterShip.';
            trigger OnValidate()
            begin
                if "TMAC Tracking Provider" <> "TMAC Tracking Provider"::AfterShip then
                    "TMAC Tracking Courier Code" := '';
            end;
        }
        field(71628576; "TMAC Tracking Courier Code"; Text[100])
        {
            Caption = 'Tracking Service Carrier Code';
            DataClassification = CustomerContent;
            TableRelation =
                if ("TMAC Tracking Provider" = const(AfterShip)) "TMAC Aftership Courier".Slug where(Activated = const(true));
            ToolTip = 'Specifies the courier code from the selected tracking provider, used to track shipments for this shipping agent.';
        }
    }
}
