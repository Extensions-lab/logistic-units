codeunit 71628593 "TMAC Tracking Management"
{

    internal procedure UpdateTrackingInformation(var Unit: Record "TMAC Unit")
    var
        ShippingAgent: Record "Shipping Agent";
    begin
        Unit.Testfield("Tracking No.");
        Unit.TestField("Shipping Agent Code");
        ShippingAgent.Get(Unit."Shipping Agent Code");
        Unit."Tracking Information" := UpdateTrackingInformation(Unit."Tracking No.", ShippingAgent."TMAC Tracking Provider", ShippingAgent."TMAC Tracking Courier Code");
    end;

    internal procedure OpenTrackingInformation(var Unit: Record "TMAC Unit")
    var
        ShippingAgent: Record "Shipping Agent";
    begin
        Unit.Testfield("Tracking No.");
        Unit.TestField("Shipping Agent Code");
        ShippingAgent.Get(Unit."Shipping Agent Code");
        OpenTrackingInformationCard(Unit."Tracking No.", ShippingAgent."TMAC Tracking Provider");
    end;

    local procedure UpdateTrackingInformation(TrackingNumber: Text; TrackingProvider: Enum "TMAC Tracking Provider"; CourierCode: Text) ReturnValue: Text[100]
    var
        AftershipTracking: Record "TMAC Aftership Tracking";
        TrackingmoreTracking: Record "TMAC Trackingmore Tracking";
        TrackingmoreAirTracking: record "TMAC Trackingmore Air Tracking";
    begin
        case TrackingProvider of
            "TMAC Tracking Provider"::AfterShip:
                if Track(TrackingNumber, TrackingProvider, CourierCode) = 0 then begin
                    AftershipTracking.Reset();
                    AftershipTracking.FilterGroup(2);
                    AftershipTracking.SetCurrentKey("Tracking Number", "Slug");
                    AftershipTracking.SetRange("Tracking Number", TrackingNumber);
                    AftershipTracking.FilterGroup(0);
                    if AftershipTracking.FindFirst() then
                        ReturnValue := AftershipTracking."Last Checkpoint Action";
                end;
            "TMAC Tracking Provider"::Trackingmore:
                if Track(TrackingNumber, TrackingProvider, CourierCode) = 0 then begin
                    TrackingmoreTracking.Reset();
                    TrackingmoreTracking.FilterGroup(2);
                    TrackingmoreTracking.SetCurrentKey("Tracking Number", "Carrier Code");
                    TrackingmoreTracking.SetRange("Tracking Number", TrackingNumber);
                    TrackingmoreTracking.SetRange("Carrier Code", CourierCode);
                    TrackingmoreTracking.FilterGroup(0);
                    if TrackingmoreTracking.FindFirst() then
                        ReturnValue := CopyStr(TrackingmoreTracking."Last Event", 1, 100);
                end;
            "TMAC Tracking Provider"::TrackingmoreAirCargo:
                if Track(TrackingNumber, TrackingProvider, CourierCode) = 0 then begin
                    TrackingmoreAirTracking.Reset();
                    TrackingmoreAirTracking.FilterGroup(2);
                    TrackingmoreAirTracking.SetRange("Tracking Number", TrackingNumber);
                    TrackingmoreAirTracking.FilterGroup(0);
                    if TrackingmoreAirTracking.FindFirst() then
                        returnvalue := CopyStr(TrackingmoreAirTracking."Last Event", 1, 100);
                end;
        end;
    end;

    local procedure OpenTrackingInformationCard(TrackingNumber: Text; TrackingProvider: Enum "TMAC Tracking Provider")
    var
        AftershipTracking: Record "TMAC Aftership Tracking";
        TrackingmoreTracking: Record "TMAC Trackingmore Tracking";
        TrackingmoreAirTracking: record "TMAC Trackingmore Air Tracking";
    begin
        case TrackingProvider of
            "TMAC Tracking Provider"::AfterShip:
                begin
                    AftershipTracking.Reset();
                    AftershipTracking.FilterGroup(2);
                    AftershipTracking.SetCurrentKey("Tracking Number", "Slug");
                    AftershipTracking.SetRange("Tracking Number", TrackingNumber);
                    AftershipTracking.FilterGroup(0);
                    if AftershipTracking.FindFirst() then
                        Page.Run(Page::"TMAC Aftership Trackings Card", AftershipTracking);
                end;
            "TMAC Tracking Provider"::Trackingmore:
                begin
                    TrackingmoreTracking.Reset();
                    TrackingmoreTracking.FilterGroup(2);
                    TrackingmoreTracking.SetCurrentKey("Tracking Number", "Carrier Code");
                    TrackingmoreTracking.SetRange("Tracking Number", TrackingNumber);
                    TrackingmoreTracking.FilterGroup(0);
                    if TrackingmoreTracking.FindFirst() then
                        Page.Run(Page::"TMAC Trackingmore Trackings", TrackingmoreTracking);
                end;
            "TMAC Tracking Provider"::TrackingmoreAirCargo:
                begin
                    TrackingmoreAirTracking.Reset();
                    TrackingmoreAirTracking.FilterGroup(2);
                    TrackingmoreAirTracking.SetRange("Tracking Number", TrackingNumber);
                    TrackingmoreAirTracking.FilterGroup(0);
                    if TrackingmoreAirTracking.FindFirst() then
                        Page.Run(Page::"TMAC Trackingmore Air Tracks", TrackingmoreAirTracking);
                end;
        end;
    end;

    local procedure Track(TrackingNumber: text; Provider: Enum "TMAC Tracking Provider"; CarrierCode: Text): Integer
    var
        TrackImpl: Interface "TMAC Tracking Provider Impl.";
    begin
        if Provider = "TMAC Tracking Provider"::None then
            exit(0);
        TrackImpl := Provider;
        exit(TrackImpl.Track(TrackingNumber, CarrierCode));
    end;
}