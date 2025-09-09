
// Each extension version has a set of properties that contain information about the extension, including: AppVersion, DataVersion, Dependencies, 
//Id, Name, and Publisher. This information can be useful when upgrading. For more information, see JSON Files.

// The AppVersion is one of the available properties and its value differs depending on the context of the code being run:

// Normal operation: AppVersion represents the value of the currently installed extension.
// Installation code: AppVersion represents the version of the extension you're trying to install.
// Upgrade code: AppVersion represents the version of the extension that you're upgrading to (in other words, the 'newer' version).
// Another one of the more important properties is the DataVersion property, that represents the value of most recently 
// installed/uninstalled/upgraded version of the extension, meaning that it reflects the most recent version of the data on the system, 
// be that from the currently installed, or a previously uninstalled extension. The DataVersion property value differs depending on the 
// context of the code being run:

// Normal operation: 
//DataVersion represents the version of the currently installed extension, in which case it's identical to the AppVersion property.
// Installation code:
// Reinstallation (applying the same version): DataVersion represents the version of the extension you're trying to install 
// (identical to the AppVersion property).
// New installation: DataVersion represents the value of '0.0.0.0' that's used to indicate there's no data.
// Upgrade code:
// The version of the extension you're upgrading from. Either what was last uninstalled, or what is currently installed.
// All these properties are encapsulated in a ModuleInfo data type. You can access these properties through the NAVApp.GetCurrentModuleInfo()
// and NAVApp.GetModuleInfo() methods.

codeunit 71628586 "TMAC Upgrade"
{
    Subtype = Upgrade;

    trigger OnCheckPreconditionsPerDatabase()
    begin
    end;

    trigger OnCheckPreconditionsPerCompany()
    begin
    end;

    trigger OnUpgradePerDatabase()
    begin
    end;

    trigger OnUpgradePerCompany()
    begin
    end;

    trigger OnValidateUpgradePerDatabase()
    begin
    end;

    trigger OnValidateUpgradePerCompany()
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        UpgradeWMS.UpgradeFromVersion(AppInfo.DataVersion());
    end;

    var
        UpgradeWMS: Codeunit "TMAC Upgrade WMS";
}