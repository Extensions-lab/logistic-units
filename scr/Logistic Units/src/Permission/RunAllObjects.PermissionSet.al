/// <summary>
/// All permissions for running tables and codeunits have been moved here.
/// </summary>
permissionset 71628579 "TMAC Run All Objects"
{
    Caption = 'Run All Objects', MaxLength = 30;
    Assignable = false;

    Permissions =
        table "TMAC Logistic Units Setup" = X,
        table "TMAC Unit Build Rule" = X,
        table "TMAC Unit Type" = X,
        table "TMAC Unit of Measure" = X,
        table "TMAC Unit Action" = X,
        table "TMAC Unit Location" = X,
        table "TMAC Unit Worksheet Name" = X,
        table "TMAC SSCC Default Identifier" = X,
        table "TMAC Tracking Setup" = X,

        table "TMAC Freight Class" = X,
        table "TMAC SSCC" = X,
        table "TMAC SSCC GS1 AI" = X,
        table "TMAC SSCC Line" = X,
        table "TMAC Unit Worksheet Line" = X,

        table "TMAC Aftership Checkpoint" = X,
        table "TMAC Aftership Courier" = X,
        table "TMAC Aftership Tracking" = X,

        table "TMAC Unit" = X,
        table "TMAC Unit Line" = X,

        table "TMAC Trackingmore Air Detail" = X,
        table "TMAC Trackingmore Air Tracking" = X,
        table "TMAC Trackingmore Carrier" = X,
        table "TMAC Trackingmore Checkpoint" = X,
        table "TMAC Trackingmore Tracking" = X,

        table "TMAC Unit Entry" = X,
        table "TMAC Unit Line Link" = X,
        table "TMAC Unit Info" = X,
        table "TMAC Unit Document Info" = X,
        table "TMAC Units Location Analysis" = X,
        table "TMAC Unit Load Details" = X,
        table "TMAC Unit Select By Source" = X,
        table "TMAC Posted Unit" = X,
        table "TMAC Posted Unit Line" = X,
        table "TMAC Posted Unit Entry" = X,
        table "TMAC Posted Unit Line Link" = X,
        table "TMAC Source Document Link" = X,
        table "TMAC Buffer Unit Build" = X,
        table "TMAC Scanned Value" = X,
        
        table "TMAC Estimated Unit Line" = X,
        table "TMAC Estimated Unit" = X,

        codeunit "TMAC Unit Build Management" = X,
        codeunit "TMAC Null API" = X,
        codeunit "TMAC CaptionClass Mgt" = X,
        codeunit "TMAC Defaults" = X,
        codeunit "TMAC Demo Data" = X,
        codeunit "TMAC Extension Setup" = X,
        codeunit "TMAC Notifications" = X,
        codeunit "TMAC JSON Management" = X,
        codeunit "TMAC AfterShip API" = X,
        codeunit "TMAC Trackingmore Air API" = X,
        codeunit "TMAC Trackingmore API" = X,
        codeunit "TMAC Unit of Measure Mgmt." = X,
        codeunit "TMAC Install Management" = X,
        codeunit "TMAC Install" = X,
        codeunit "TMAC Pictures" = X,
        codeunit "TMAC Tracking Management" = X,
        codeunit "TMAC Unit Management" = X,
        codeunit "TMAC Unit Post" = X,
        codeunit "TMAC Events WMS" = X,
        codeunit "TMAC Events System" = X,
        codeunit "TMAC Upgrade" = X,
        codeunit "TMAC Upgrade WMS" = X,
        codeunit "TMAC Unit Link Management" = X,
        codeunit "TMAC SSCC Management" = X,
        codeunit "TMAC Entitlement Mgt." = X,
        codeunit "TMAC TMS Events" = X,

        query "TMAC Distinct Units" = X;
}
