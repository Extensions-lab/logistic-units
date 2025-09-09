
/// <summary>
/// Installation-type codeunit that runs when the extension is installed in BC.
/// It can detect the type of installation and the version of the extension already installed (or if it's a fresh install),
/// and perform data upgrades to the new version (adjust data accordingly).
/// </summary>
codeunit 71628584 "TMAC Install"
{
    Subtype = Install;


    trigger OnInstallAppPerCompany();
    var
        myAppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(myAppInfo);
        if myAppInfo.DataVersion() = Version.Create(0, 0, 0, 0) then
            HandleFreshInstall(myAppInfo.DataVersion())
        else
            HandleReinstall();
    end;


    /// <summary>
    /// Do work needed the first time this extension is ever installed for this tenant.
    /// Some possible usages:
    /// - Service callback/telemetry indicating that extension was installed
    /// - Initial data setup for use
    /// Fresh install if there is no data or... the previous uninstall was done with data removal.
    /// </summary>
    /// <param name="InstalledVersion"></param>
    local procedure HandleFreshInstall(InstalledVersion: Version);
    var
        Vers: Version;
    begin
        Vers := InstalledVersion;
        Defaults.CreateUnitOfMeasure();
        Defaults.CreateStdUnitOfMeasures();
        Defaults.CreateFreightClasses();
        Defaults.Setup();
        Defaults.CreateDefaultUnitTypes();
        Defaults.CreateDefaultLogisticUnitActions();
        Defaults.CreateStandardGS1AI();
        Defaults.CreateDefaultSSCCLines();
        Defaults.CreateDefaultUnitWorksheets();
        Defaults.CreateDefaultUnitLocations();
    end;

    /// <summary>
    /// Do work needed when reinstalling the same version of this extension back on this tenant.
    /// Some possible usages:
    /// - Service callback/telemetry indicating that extension was reinstalled
    /// - Data 'patchup' work, for example, detecting if new 'base' records have been changed while you have been working 'offline'.
    /// - Setup 'welcome back' messaging for next user access.
    /// </summary>
    local procedure HandleReinstall();
    begin
        Defaults.CreateUnitOfMeasure();
        Defaults.CreateStdUnitOfMeasures();
        Defaults.CreateFreightClasses();
        Defaults.Setup();
        Defaults.CreateDefaultUnitTypes();
        Defaults.CreateDefaultLogisticUnitActions();
        Defaults.CreateStandardGS1AI();
        Defaults.CreateDefaultSSCCLines();
        Defaults.CreateDefaultUnitWorksheets();
        Defaults.CreateDefaultUnitLocations();
    end;

    var
        Defaults: Codeunit "TMAC Defaults";
}