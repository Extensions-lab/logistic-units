pageextension 71628616 "TMAC Posted Return Rcpt Sub." extends "Posted Return Receipt Subform"
{

    internal procedure GetSelectedLineLinks(var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        ReturnReceiptLine: Record "Return Receipt Line";
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
    begin
        CurrPage.SetSelectionFilter(ReturnReceiptLine);
        ReturnReceiptLine.MarkedOnly(true);
        if ReturnReceiptLine.Count <= 1 then begin
            ReturnReceiptLine.Reset();
            ReturnReceiptLine.SetRange("Document No.", Rec."Document No.");
        end;
        if ReturnReceiptLine.IsEmpty then
            exit;
        if ReturnReceiptLine.Findset() then
            repeat
                UnitLinkManagement.CreateFrom_ReturnReceiptLine(SourceDocumentLink, ReturnReceiptLine, 0, 0);
            until ReturnReceiptLine.Next() = 0;
    end;

    /// <summary>
    /// For TMS
    /// </summary>
    procedure "TMAC Get Selected Lines Links"(var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        ReturnReceiptLine: Record "Return Receipt Line";
    begin
        CurrPage.SetSelectionFilter(ReturnReceiptLine);
        ReturnReceiptLine.MarkedOnly(true);
        if ReturnReceiptLine.Count <= 1 then begin
            ReturnReceiptLine.Reset();
            ReturnReceiptLine.SetRange("Document No.", Rec."Document No.");
        end;
        if ReturnReceiptLine.IsEmpty then
            exit;
        if ReturnReceiptLine.Findset() then
            repeat
                SourceDocumentLink.Init();
                SourceDocumentLink.Clear();
                SourceDocumentLink."Source Type" := Database::"Return Receipt Line";
                SourceDocumentLink."Source Subtype" := 0;
                SourceDocumentLink."Source ID" := ReturnReceiptLine."Document No.";
                SourceDocumentLink."Source Ref. No." := ReturnReceiptLine."Line No.";
                SourceDocumentLink.Insert(false);
            until ReturnReceiptLine.Next() = 0;
    end;
}
