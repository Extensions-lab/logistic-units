permissionset 71628575 "TMAC Admin"
{
    Caption = 'Logistic Units - Administrator';
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "TMAC Unlicensed";
    
    Permissions =
        tabledata "TMAC Logistic Units Setup" = RIMD,
        tabledata "TMAC Unit Type" = RIMD,
        tabledata "TMAC Unit Build Rule" = RIMD,
        tabledata "TMAC Unit of Measure" = RIMD,
        tabledata "TMAC Unit Action" = RIMD,
        tabledata "TMAC SSCC Default Identifier" = RIMD,
        tabledata "TMAC Unit Location" = RIMD,
        tabledata "TMAC Unit Worksheet Name" = RIMD,
        tabledata "TMAC Tracking Setup" = RIMD;
}