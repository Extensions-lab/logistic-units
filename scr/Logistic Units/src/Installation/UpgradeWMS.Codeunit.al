codeunit 71628587 "TMAC Upgrade WMS"
{

    internal procedure UpgradeFromVersion(InstalledVersion: Version)
    begin
        if (InstalledVersion = Version.Create(0, 0, 0, 0)) or
           (InstalledVersion = Version.Create(22, 0, 0, 0)) or
           (InstalledVersion = Version.Create(22, 3, 0, 0))
        then
            UpgradeTo_22_3_1_0();

        if (InstalledVersion < Version.Create(24, 4, 1, 0))
        then
            UpgradeTo_24_4_1_0();


    end;

    local procedure UpgradeTo_22_3_1_0()
    var
        TrackingSetup: Record "TMAC Tracking Setup";
        Defaults: Codeunit "TMAC Defaults";
    begin
        if not TrackingSetup.get() then begin
            TrackingSetup.Init();
            TrackingSetup."AfterShip All Courier URL" := 'https://api.aftership.com/v4/couriers/all';
            TrackingSetup."Aftership Active Couriers URL" := 'https://api.aftership.com/v4/couriers';
            TrackingSetup."AfterShip GetTracking URL" := 'https://api.aftership.com/v4/trackings';
            TrackingSetup.Insert();
        end;

        TrackingSetup."Trackingmore All Courier URL" := 'https://api.trackingmore.com/v2/carriers/';
        TrackingSetup."Trackingmore AirCargo URL" := 'https://api.trackingmore.com/v2/trackings/aircargo';
        TrackingSetup."Trackingmore Ger User Info URL" := 'https://api.trackingmore.com/v2/trackings/getuserinfo';
        TrackingSetup."Trackingmore Create Tracking" := 'https://api.trackingmore.com/v2/trackings/post';
        TrackingSetup."Trackingmore Delete Tracking" := 'https://api.trackingmore.com/v2/trackings';
        TrackingSetup.Modify();

        Defaults.SetTrackingmoreSetupWizardPicture(TrackingSetup);
    end;

    local procedure UpgradeTo_24_4_1_0()
    begin
    end;

}