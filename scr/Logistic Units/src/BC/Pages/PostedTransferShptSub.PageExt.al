pageextension 71628620 "TMAC Posted Transfer Shpt. Sub" extends "Posted Transfer Shpt. Subform"
{
    internal procedure GetSelectedLineLinks(var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        TransferShipmentLine: Record "Transfer Shipment Line";
    begin
        CurrPage.SetSelectionFilter(TransferShipmentLine);
        TransferShipmentLine.MarkedOnly(true);
        if TransferShipmentLine.Count <= 1 then begin
            TransferShipmentLine.Reset();
            TransferShipmentLine.SetRange("Document No.", Rec."Document No.");
        end;
        if TransferShipmentLine.IsEmpty then
            exit;
        if TransferShipmentLine.Findset() then
            repeat
                // Down not work - Next Version
                // UnitLinkManagement.CreateFrom_TransferLine(SourceDocumentLink, TransferReceiptLine, 0, 0);
            until TransferShipmentLine.Next() = 0;
    end;

    /// <summary>
    /// For TMS
    /// </summary>
    procedure "TMAC Get Selected Lines Links"(var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        TransferShipmentLine: Record "Transfer Shipment Line";
    begin
        CurrPage.SetSelectionFilter(TransferShipmentLine);
        TransferShipmentLine.MarkedOnly(true);
        if TransferShipmentLine.Count <= 1 then begin
            TransferShipmentLine.Reset();
            TransferShipmentLine.SetRange("Document No.", Rec."Document No.");
        end;
        if TransferShipmentLine.IsEmpty then
            exit;
        if TransferShipmentLine.Findset() then
            repeat
                SourceDocumentLink.Init();
                SourceDocumentLink.Clear();
                SourceDocumentLink."Source Type" := Database::"Transfer Receipt Line";
                SourceDocumentLink."Source Subtype" := 0; ///????
                SourceDocumentLink."Source ID" := TransferShipmentLine."Document No.";
                SourceDocumentLink."Source Ref. No." := TransferShipmentLine."Line No.";
                SourceDocumentLink.Insert(false);
            until TransferShipmentLine.Next() = 0;
    end;

}
