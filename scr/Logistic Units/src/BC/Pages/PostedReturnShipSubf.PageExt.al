pageextension 71628617 "TMAC Posted Return Ship. Subf" extends "Posted Return Shipment Subform"
{
    internal procedure GetSelectedLineLinks(var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        ReturnShipmentLine: Record "Return Shipment Line";
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
    begin
        CurrPage.SetSelectionFilter(ReturnShipmentLine);
        ReturnShipmentLine.MarkedOnly(true);
        if ReturnShipmentLine.Count <= 1 then begin
            ReturnShipmentLine.Reset();
            ReturnShipmentLine.SetRange("Document No.", Rec."Document No.");
        end;
        if ReturnShipmentLine.IsEmpty then
            exit;
        if ReturnShipmentLine.Findset() then
            repeat
                UnitLinkManagement.CreateFrom_ReturnShipmentLine(SourceDocumentLink, ReturnShipmentLine, 0, 0);
            until ReturnShipmentLine.Next() = 0;
    end;

    /// <summary>
    /// For TMS
    /// </summary>
    procedure "TMAC Get Selected Lines Links"(var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        ReturnShipmentLine: Record "Return Shipment Line";
    begin
        CurrPage.SetSelectionFilter(ReturnShipmentLine);
        ReturnShipmentLine.MarkedOnly(true);
        if ReturnShipmentLine.Count <= 1 then begin
            ReturnShipmentLine.Reset();
            ReturnShipmentLine.SetRange("Document No.", Rec."Document No.");
        end;
        if ReturnShipmentLine.IsEmpty then
            exit;
        if ReturnShipmentLine.Findset() then
            repeat
                SourceDocumentLink.Init();
                SourceDocumentLink.Clear();
                SourceDocumentLink."Source Type" := Database::"Return Shipment Line";
                SourceDocumentLink."Source Subtype" := 0;
                SourceDocumentLink."Source ID" := ReturnShipmentLine."Document No.";
                SourceDocumentLink."Source Ref. No." := ReturnShipmentLine."Line No.";
                SourceDocumentLink.Insert(false);
            until ReturnShipmentLine.Next() = 0;
    end;

}
