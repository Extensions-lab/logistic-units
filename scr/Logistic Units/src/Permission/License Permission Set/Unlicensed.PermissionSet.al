permissionset 71628577 "TMAC Unlicensed"
{
    Assignable = false;
    Access = Public;
    Caption = 'Logistic Units - Unlicensed', MaxLength = 30;
    IncludedPermissionSets = "TMAC Run All Objects";
    
    Permissions =

        // ==================================================
        // То что мы определяем как настройки
        // ==================================================

        tabledata "TMAC Tracking Setup" = R,
        tabledata "TMAC Logistic Units Setup" = R,
        tabledata "TMAC Unit Build Rule" = R,
        tabledata "TMAC Unit Type" = R,
        tabledata "TMAC Unit of Measure" = R,
        tabledata "TMAC Unit Action" = R,
        tabledata "TMAC Unit Location" = R,
        tabledata "TMAC Unit Worksheet Name" = R,
        tabledata "TMAC SSCC Default Identifier" = R,

        //====================================================
        // Для обычного пользователя
        //====================================================

        tabledata "TMAC Freight Class" = R,
        tabledata "TMAC SSCC" = R,
        tabledata "TMAC SSCC GS1 AI" = R,
        tabledata "TMAC SSCC Line" = R,
        tabledata "TMAC Unit Worksheet Line" = R,

        tabledata "TMAC Aftership Checkpoint" = R,
        tabledata "TMAC Aftership Courier" = R,
        tabledata "TMAC Aftership Tracking" = R,

        tabledata "TMAC Unit" = R,
        tabledata "TMAC Unit Line" = R,

        tabledata "TMAC Trackingmore Air Detail" = R,
        tabledata "TMAC Trackingmore Air Tracking" = R,
        tabledata "TMAC Trackingmore Carrier" = R,
        tabledata "TMAC Trackingmore Checkpoint" = R,
        tabledata "TMAC Trackingmore Tracking" = R,

        tabledata "TMAC Unit Entry" = RMID,
        tabledata "TMAC Unit Line Link" = RMID,
        tabledata "TMAC Unit Info" = RMID,
        tabledata "TMAC Unit Document Info" = RMID,
        tabledata "TMAC Units Location Analysis" = RMID,
        tabledata "TMAC Unit Load Details" = RMID,
        tabledata "TMAC Unit Select By Source" = RMID,
        tabledata "TMAC Posted Unit" = RMID,
        tabledata "TMAC Posted Unit Line" = RMID,
        tabledata "TMAC Posted Unit Entry" = RMID,
        tabledata "TMAC Posted Unit Line Link" = RMID,
        tabledata "TMAC Source Document Link" = RMID,
        tabledata "TMAC Buffer Unit Build" = RMID,
        tabledata "TMAC Scanned Value" = RIMD,
        
        tabledata "TMAC Estimated Unit Line" = R,
        tabledata "TMAC Estimated Unit" = R,

        page "TMAC Logistic Units Setup" = X,
        page "TMAC Assisted Setup" = X,
        page "TMAC Unit List FactBox" = X;
}
