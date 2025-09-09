/// <summary>
/// License check and related functionality. Currently, none of the functions here are in use.
/// </summary>
codeunit 71628588 "TMAC Entitlement Mgt."
{
    internal procedure HasLicense(): Boolean
    begin
        if Navapp.IsEntitled(LogistisUnitsPlanID()) then
            exit(true);
    end;

    local procedure LogistisUnitsPlanID(): Text;
    begin
        exit('TMAC Standard Plan');
    end;
}
