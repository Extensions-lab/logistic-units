permissionset 71628576 "TMAC User"
{
    Caption = 'Logistic Units - User';
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "TMAC Unlicensed";

    Permissions =
        tabledata "TMAC Unit" = RIMD,
        tabledata "TMAC Unit Line" = RIMD,

        tabledata "TMAC Freight Class" = RIMD,
        tabledata "TMAC SSCC" = RIMD,
        tabledata "TMAC SSCC Default Identifier" = RIMD,
        tabledata "TMAC SSCC GS1 AI" = RIMD,
        tabledata "TMAC SSCC Line" = RIMD,
        tabledata "TMAC Unit Worksheet Line" = RIMD,

        tabledata "TMAC Aftership Checkpoint" = RIMD,
        tabledata "TMAC Aftership Courier" = RIMD,
        tabledata "TMAC Aftership Tracking" = RIMD,

        tabledata "TMAC Trackingmore Air Detail" = RIMD,
        tabledata "TMAC Trackingmore Air Tracking" = RIMD,
        tabledata "TMAC Trackingmore Carrier" = RIMD,
        tabledata "TMAC Trackingmore Checkpoint" = RIMD,
        tabledata "TMAC Trackingmore Tracking" = RIMD,
        tabledata "TMAC Scanned Value" = RIMD,

        tabledata "TMAC Estimated Unit Line" = RIMD,
        tabledata "TMAC Estimated Unit" = RIMD,

        page "TMAC Unit Card" = X,
        page "TMAC Unit Card Lines Subf." = X,
        page "TMAC Unit Card Docs Subf." = X,
        page "TMAC Unit Line Links" = X,
        page "TMAC Unit Lines Select" = X,
        page "TMAC Unit List" = X,
        page "TMAC Unit List FactBox" = X,
        page "TMAC Unit Selection" = X,
        page "TMAC Unit Selection Subf." = X,
        page "TMAC Units Of Measure" = X,
        page "TMAC Unit Actions" = X,
        page "TMAC Unit Locations" = X,
        page "TMAC Logistic Units Setup" = X,
        page "TMAC Units Location Analysis" = X,
        page "TMAC Unit Type Card" = X,
        page "TMAC Unit Type List" = X,
        page "TMAC Unit Type Picture" = X,
        page "TMAC Unit Load Details" = X,
        page "TMAC Unit Application" = X,
        page "TMAC Unit Entries" = X,
        page "TMAC Unit Worksheets" = X,
        page "TMAC Unit Worksheet Names List" = X,

        page "TMAC Add To Logistic Unit Sub2" = X,
        page "TMAC Add To Logistic Unit Wz." = X,
        page "TMAC New Logistic Unit Sub" = X,
        page "TMAC New Logistic Unit Wizard" = X,

        page "TMAC Posted Unit Card" = X,
        page "TMAC Posted Unit List" = X,
        page "TMAC Posted Unit Entries" = X,
        page "TMAC Posted Unit Card Line Sub" = X,
        page "TMAC Posted Unit Line Links" = X,

        page "TMAC SSCC Card" = X,
        page "TMAC SSCC Card Lines Subform" = X,
        page "TMAC SSCC GS1 AI List" = X,
        page "TMAC SSCC List" = X,
        page "TMAC SSCC Default Identifiers" = X,

        page "TMAC Aftership Checkpoints" = X,
        page "TMAC Aftership Couriers" = X,
        page "TMAC Aftership Setup Wizard" = X,
        page "TMAC Aftership Trackings" = X,
        page "TMAC Aftership Trackings Card" = X,

        page "TMAC Logistic Unit Builder" = X,
        page "TMAC Logistic Unit Build Units" = X,
        page "TMAC Logistic Unit Wizard" = X,
        page "TMAC Unit Build Rule List" = X,

        page "TMAC Freight Class List" = X,
        page "TMAC Add To Logistic Unit Sub1" = X,
        page "TMAC Scan Values" = X,
        page "TMAC Scan Values Details" = X,

        report "TMAC Get Logistic Units" = X,
        report "TMAC Packing List" = X,
        report "TMAC SSCC Label" = X,

        page "TMAC Trackingmore Air Details" = X,
        page "TMAC Trackingmore Air Tracks" = X,
        page "TMAC Trackingmore Carriers" = X,
        page "TMAC Trackingmore Checkpoints" = X,
        page "TMAC Trackingmore Setup Wizard" = X,
        page "TMAC Trackingmore Trackings" = X,

        page "TMAC Estimated Units" = X,
        page "TMAC Estimated Unit Lines" = X;
}