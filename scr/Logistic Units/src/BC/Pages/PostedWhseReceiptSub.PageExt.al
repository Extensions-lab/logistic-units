pageextension 71628605 "TMAC Posted Whse. Receipt Sub" extends "Posted Whse. Receipt Subform"
{
    layout
    {
        addbefore(Quantity)
        {
            field("TMAC Logistic Units"; LogisticUnits)
            {
                Caption = 'Logistic Units';
                Editable = false;
                ApplicationArea = all;
                ToolTip = 'Specifies the logistic units linked to current focument line.';
                trigger OnDrillDown()
                begin
                    UnitLinkManagement.ShowLogisticUnitsList(Database::"Posted Whse. Receipt Line", 0, Rec."No.", Rec."Line No.", false);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        LogisticUnits := UnitLinkManagement.GetLogisticUnitsInText(Database::"Posted Whse. Receipt Line", 0, Rec."No.", Rec."Line No.");
    end;

    internal procedure GetSelectedLineLinks(var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        PostedWhseReceiptLine: Record "Posted Whse. Receipt Line";
    begin
        CurrPage.SetSelectionFilter(PostedWhseReceiptLine);
        PostedWhseReceiptLine.MarkedOnly(true);
        if PostedWhseReceiptLine.Count <= 1 then begin
            PostedWhseReceiptLine.Reset();
            PostedWhseReceiptLine.SetRange("No.", Rec."No.");
        end;
        if PostedWhseReceiptLine.IsEmpty then
            exit;
        if PostedWhseReceiptLine.Findset() then
            repeat
                UnitLinkManagement.CreateFrom_PostedWhsReceiptLine(SourceDocumentLink, PostedWhseReceiptLine, 0, 0);
            until PostedWhseReceiptLine.Next() = 0;
    end;

    /// <summary>
    /// For TMS
    /// </summary>
    procedure "TMAC Get Selected Lines Links"(var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        PostedWhseReceiptLine: Record "Posted Whse. Receipt Line";
    begin
        CurrPage.SetSelectionFilter(PostedWhseReceiptLine);
        PostedWhseReceiptLine.MarkedOnly(true);
        if PostedWhseReceiptLine.Count <= 1 then begin
            PostedWhseReceiptLine.Reset();
            PostedWhseReceiptLine.SetRange("No.", Rec."No.");
        end;
        if PostedWhseReceiptLine.IsEmpty then
            exit;
        if PostedWhseReceiptLine.Findset() then
            repeat
                SourceDocumentLink.Init();
                SourceDocumentLink.Clear();
                SourceDocumentLink."Source Type" := Database::"Posted Whse. Receipt Line";
                SourceDocumentLink."Source Subtype" := 0; 
                SourceDocumentLink."Source ID" := PostedWhseReceiptLine."No.";
                SourceDocumentLink."Source Ref. No." := PostedWhseReceiptLine."Line No.";
                SourceDocumentLink.Insert(false);
            until PostedWhseReceiptLine.Next() = 0;
    end;

    var
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
        LogisticUnits: Code[20];

}
