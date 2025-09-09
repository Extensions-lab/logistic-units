pageextension 71628618 "TMAC Transfer Order Subform" extends "Transfer Order Subform"
{
    internal procedure GetSelectedLineLinks(var SourceDocumentLink: Record "TMAC Source Document Link"; Positive: Boolean)
    var
        TransferLine: Record "Transfer Line";
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
    begin
        CurrPage.SetSelectionFilter(TransferLine);
        TransferLine.MarkedOnly(true);
        if TransferLine.Count <= 1 then begin
            TransferLine.Reset();
            TransferLine.SetRange("Document No.", Rec."Document No.");
        end;
        if TransferLine.IsEmpty then
            exit;
        if TransferLine.Findset() then
            repeat
                UnitLinkManagement.CreateFrom_TransferLine(SourceDocumentLink, TransferLine, 0, 0, Positive);
            until TransferLine.Next() = 0;
    end;

    /// <summary>
    /// For TMS
    /// </summary>
    procedure "TMAC Get Selected Lines Links"(var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        TransferLine: Record "Transfer Line";
    begin
        CurrPage.SetSelectionFilter(TransferLine);
        TransferLine.MarkedOnly(true);
        if TransferLine.Count <= 1 then begin
            TransferLine.Reset();
            TransferLine.SetRange("Document No.", Rec."Document No.");
            TransferLine.Setrange("Derived From Line No.", 0);
        end;
        if TransferLine.IsEmpty then
            exit;
        if TransferLine.Findset() then
            repeat
                SourceDocumentLink.Init();
                SourceDocumentLink.Clear();
                SourceDocumentLink."Source Type" := Database::"Transfer Line";
                SourceDocumentLink."Source Subtype" := 0;
                SourceDocumentLink."Source ID" := TransferLine."Document No.";
                SourceDocumentLink."Source Ref. No." := TransferLine."Line No.";
                SourceDocumentLink.Insert(false);
            until TransferLine.Next() = 0;
    end;
}
