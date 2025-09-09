/// <summary>
/// Events related to warehouse management
/// </summary>
codeunit 71628589 "TMAC Events WMS"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Sales Release", 'OnBeforeCreateWhseRequest', '', false, false)]
    local procedure OnBeforeCreateWhseRequestSale(var WhseRqst: Record "Warehouse Request"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; WhseType: Option Inbound,Outbound)
    var
        ShipToAddress: Record "Ship-to Address";
        SalesLine1: Record "Sales Line";
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
    begin
        WhseRqst."TMAC Source Name" := SalesHeader."Sell-to Customer Name" + SalesHeader."Sell-to Customer Name 2";

        if ShipToAddress.Get(SalesHeader."Sell-to Customer No.", SalesHeader."Ship-to Code") then begin
            WhseRqst."TMAC Source Country Code" := ShiptoAddress."Country/Region Code";
            WhseRqst."TMAC Source City" := ShiptoAddress."City";
            WhseRqst."TMAC Source Post Code" := ShiptoAddress."Post Code";
            WhseRqst."TMAC Source Address" := ShiptoAddress.Address + ShiptoAddress."Address 2";
            WhseRqst."TMAC Source County" := ShiptoAddress.County;
        end else begin
            WhseRqst."TMAC Source Country Code" := SalesHeader."Sell-to Country/Region Code";
            WhseRqst."TMAC Source City" := SalesHeader."Sell-to City";
            WhseRqst."TMAC Source Post Code" := SalesHeader."Sell-to Post Code";
            WhseRqst."TMAC Source Address" := SalesHeader."Sell-to Address" + SalesHeader."Sell-to Address 2";
            WhseRqst."TMAC Source County" := SalesHeader."Sell-to County"
        end;

        WhseRqst."TMAC Weight" := 0;
        WhseRqst."TMAC Volume" := 0;

        SalesLine1.Setrange("Document Type", SalesHeader."Document Type");
        SalesLine1.Setrange("Document No.", SalesHeader."No.");
        SalesLine1.Setrange(Type, "Sales Line Type"::Item);
        SalesLine1.SetLoadFields("No.", Quantity, "Gross Weight", "Unit Volume", "Unit of Measure Code");
        if SalesLine1.findset(false) then
            repeat
                WhseRqst."TMAC Weight" += SalesLine1.Quantity * UnitLinkManagement.GetWeight(SalesLine1."Gross Weight", SalesLine1."No.", SalesLine1."Unit of Measure Code");
                WhseRqst."TMAC Volume" += SalesLine1.Quantity * UnitLinkManagement.GetVolume(SalesLine1."Unit Volume", SalesLine1."No.", SalesLine1."Unit of Measure Code");
            until SalesLine1.next() = 0; 
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Purch. Release", 'OnBeforeCreateWhseRequest', '', false, false)]

    local procedure OnBeforeCreateWhseRequestPurchase(var WhseRqst: Record "Warehouse Request"; var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line"; WhseType: Option Inbound,Outbound)
    var
        OrderAddress: Record "Order Address";
        PurchLine1: Record "Purchase Line";
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
    begin
        WhseRqst."TMAC Source Name" := PurchHeader."Buy-from Vendor Name" + PurchHeader."Buy-from Vendor Name 2";

        if OrderAddress.Get(PurchHeader."Sell-to Customer No.", PurchHeader."Ship-to Code") then begin
            WhseRqst."TMAC Source Country Code" := OrderAddress."Country/Region Code";
            WhseRqst."TMAC Source City" := OrderAddress."City";
            WhseRqst."TMAC Source Post Code" := OrderAddress."Post Code";
            WhseRqst."TMAC Source Address" := OrderAddress.Address + OrderAddress."Address 2";
            WhseRqst."TMAC Source County" := OrderAddress.County;
        end else begin
            WhseRqst."TMAC Source Country Code" := PurchHeader."Buy-from Country/Region Code";
            WhseRqst."TMAC Source City" := PurchHeader."Buy-from City";
            WhseRqst."TMAC Source Post Code" := PurchHeader."Buy-from Post Code";
            WhseRqst."TMAC Source Address" := PurchHeader."Buy-from Address" + PurchHeader."Buy-from Address 2";
            WhseRqst."TMAC Source County" := PurchHeader."Buy-from County";
        end;

        WhseRqst."TMAC Weight" := 0;
        WhseRqst."TMAC Volume" := 0;

        PurchLine1.Setrange("Document Type", PurchHeader."Document Type");
        PurchLine1.Setrange("Document No.", PurchHeader."No.");
        PurchLine1.Setrange(Type, "Purchase Line Type"::Item);
        PurchLine1.SetLoadFields("No.", Quantity, "Gross Weight", "Unit Volume", "Unit of Measure Code");
        if PurchLine1.findset(false) then
            repeat
                WhseRqst."TMAC Weight" += PurchLine1.Quantity * UnitLinkManagement.GetWeight(PurchLine1."Gross Weight", PurchLine1."No.", PurchLine1."Unit of Measure Code");
                WhseRqst."TMAC Volume" += PurchLine1.Quantity * UnitLinkManagement.GetVolume(PurchLine1."Unit Volume", PurchLine1."No.", PurchLine1."Unit of Measure Code");
            until PurchLine1.next() = 0;
    end;
}
