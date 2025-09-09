pageextension 71628619 "TMAC Posted Transfer Rcpt. Sub" extends "Posted Transfer Rcpt. Subform"
{
    internal procedure GetSelectedLineLinks(var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        TransferReceiptLine: Record "Transfer Receipt Line";
    begin
        CurrPage.SetSelectionFilter(TransferReceiptLine);
        TransferReceiptLine.MarkedOnly(true);
        if TransferReceiptLine.Count <= 1 then begin
            TransferReceiptLine.Reset();
            TransferReceiptLine.SetRange("Document No.", Rec."Document No.");
        end;
        if TransferReceiptLine.IsEmpty then
            exit;
        if TransferReceiptLine.Findset() then
            repeat
                // Does not work
                // UnitLinkManagement.CreateFrom_TransferLine(SourceDocumentLink, TransferReceiptLine, 0, 0);
            until TransferReceiptLine.Next() = 0;
    end;

    /// <summary>
    /// For TMS
    /// </summary>
    procedure "TMAC Get Selected Lines Links"(var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        TransferReceiptLine: Record "Transfer Receipt Line";
    begin
        CurrPage.SetSelectionFilter(TransferReceiptLine);
        TransferReceiptLine.MarkedOnly(true);
        if TransferReceiptLine.Count <= 1 then begin
            TransferReceiptLine.Reset();
            TransferReceiptLine.SetRange("Document No.", Rec."Document No.");
        end;
        if TransferReceiptLine.IsEmpty then
            exit;
        if TransferReceiptLine.Findset() then
            repeat
                SourceDocumentLink.Init();
                SourceDocumentLink.Clear();
                SourceDocumentLink."Source Type" := Database::"Transfer Receipt Line";
                SourceDocumentLink."Source Subtype" := 0; 
                SourceDocumentLink."Source ID" := TransferReceiptLine."Document No.";
                SourceDocumentLink."Source Ref. No." := TransferReceiptLine."Line No.";
                SourceDocumentLink.Insert(false);
            until TransferReceiptLine.Next() = 0;
    end;
}
