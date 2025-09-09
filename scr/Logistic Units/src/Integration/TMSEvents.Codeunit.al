/// <summary>
/// Events occurring in TMS.
/// Allows external systems, such as WMS, to subscribe.
/// </summary>
codeunit 71628600 "TMAC TMS Events"
{
    /// <summary>
    /// Function called from TMS at the moment of FWO creation from a sales order.
    /// Values that can be modified in the FWO.
    /// FWO Fields Values – values of certain fields that can be changed in the FWO.
    /// </summary>
    procedure AfterCreateForwardingOrderBySalesOrder(var SalesHeader: Record "Sales Header"; var FWOFieldsValues: Dictionary of [Integer, Text]; var IsHandled: Boolean)
    begin
        OnAfterCreateForwardingOrderBySalesOrder(SalesHeader, FWOFieldsValues, IsHandled);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateForwardingOrderBySalesOrder(var SalesHeader: Record "Sales Header"; var FWOFieldsValues: Dictionary of [Integer, Text]; var IsHandled: Boolean)
    begin
    end;
}
