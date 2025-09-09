pageextension 71628606 "TMAC Posted Purchase Rcpt. Sub" extends "Posted Purchase Rcpt. Subform"
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
                ToolTip = 'Specifies the logistic units linked to current document line.';
                trigger OnDrillDown()
                begin
                    UnitLinkManagement.ShowLogisticUnitsList(Database::"Purch. Rcpt. Line", 0, Rec."Document No.", Rec."Line No.", false);
                end;
            }
        }
    }

    internal procedure GetSelectedLineLinks(var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
    begin
        //собираем выбранные строки
        CurrPage.SetSelectionFilter(PurchRcptLine);
        PurchRcptLine.MarkedOnly(true);
        if PurchRcptLine.Count <= 1 then begin
            PurchRcptLine.Reset();
            PurchRcptLine.SetRange("Document No.", Rec."Document No.");
        end;
        if PurchRcptLine.IsEmpty then
            exit;
        if PurchRcptLine.Findset() then
            repeat
                UnitLinkManagement.CreateFrom_PurchRcptLine(SourceDocumentLink, PurchRcptLine, 0, 0);
            until PurchRcptLine.Next() = 0;
    end;

    /// <summary>
    /// For TMS
    /// </summary>
    procedure "TMAC Get Selected Lines Links"(var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
    begin
        CurrPage.SetSelectionFilter(PurchRcptLine);
        PurchRcptLine.MarkedOnly(true);
        if PurchRcptLine.Count <= 1 then begin
            PurchRcptLine.Reset();
            PurchRcptLine.SetRange("Document No.", Rec."Document No.");
        end;
        if PurchRcptLine.IsEmpty then
            exit;
        if PurchRcptLine.Findset() then
            repeat
                SourceDocumentLink.Init();
                SourceDocumentLink.Clear();
                SourceDocumentLink."Source Type" := Database::"Purch. Rcpt. Line";
                SourceDocumentLink."Source Subtype" := 0;
                SourceDocumentLink."Source ID" := PurchRcptLine."Document No.";
                SourceDocumentLink."Source Ref. No." := PurchRcptLine."Line No.";
                SourceDocumentLink.Insert(false);
            until PurchRcptLine.Next() = 0;
    end;

    trigger OnAfterGetRecord()
    begin
        LogisticUnits := UnitLinkManagement.GetLogisticUnitsInText(Database::"Purch. Rcpt. Line", 0, Rec."Document No.", Rec."Line No.");
    end;

    var
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
        LogisticUnits: Code[20];

}
