pageextension 71628603 "TMAC Sales Return Order Sub" extends "Sales Return Order Subform"
{
    layout
    {
        addbefore("Unit Price")
        {
            field("TMAC Logistic Units"; LogisticUnits)
            {
                Caption = 'Logistic Units';
                Editable = false;
                ApplicationArea = all;
                ToolTip = 'Specifies the logistic units linked to current focument line.';
                trigger OnDrillDown()
                begin
                    UnitLinkManagement.ShowLogisticUnitsList(Database::"Sales Line", Rec."Document Type".AsInteger(), Rec."Document No.", Rec."Line No.", false);
                end;
            }
        }
    }


    trigger OnAfterGetRecord()
    begin
        LogisticUnits := UnitLinkManagement.GetLogisticUnitsInText(Database::"Sales Line", Rec."Document Type".AsInteger(), Rec."Document No.", Rec."Line No.");
    end;

    internal procedure GetSelectedLineLinks(var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        SalesLine: Record "Sales Line";
    begin
        CurrPage.SetSelectionFilter(SalesLine);
        SalesLine.MarkedOnly(true);
        if SalesLine.Count <= 1 then begin
            SalesLine.Reset();
            SalesLine.SetRange("Document Type", Rec."Document Type");
            SalesLine.SetRange("Document No.", Rec."Document No.");
        end;
        if SalesLine.IsEmpty then
            exit;
        if SalesLine.Findset() then
            repeat
                UnitLinkManagement.CreateFrom_SalesLine(SourceDocumentLink, SalesLine, 0, 0);
            until SalesLine.Next() = 0;
    end;

    /// <summary>
    /// For TMS
    /// </summary>
    procedure "TMAC Get Selected Lines Links"(var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        SalesLine: Record "Sales Line";
    begin
        CurrPage.SetSelectionFilter(SalesLine);
        SalesLine.MarkedOnly(true);
        if SalesLine.Count <= 1 then begin
            SalesLine.Reset();
            SalesLine.SetRange("Document Type", Rec."Document Type");
            SalesLine.SetRange("Document No.", Rec."Document No.");
        end;
        if SalesLine.IsEmpty then
            exit;
        if SalesLine.Findset() then
            repeat
                SourceDocumentLink.Init();
                SourceDocumentLink.Clear();
                SourceDocumentLink."Source Type" := Database::"Sales Line";
                SourceDocumentLink."Source Subtype" := SalesLine."Document Type".AsInteger();
                SourceDocumentLink."Source ID" := SalesLine."Document No.";
                SourceDocumentLink."Source Ref. No." := SalesLine."Line No.";
                SourceDocumentLink.Insert(false);
            until SalesLine.Next() = 0;
    end;

    var
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
        LogisticUnits: Code[20];

}
