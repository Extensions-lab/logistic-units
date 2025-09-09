pageextension 71628600 "TMAC Purchase Order Subform" extends "Purchase Order Subform"
{
    layout
    {
        addbefore("Direct Unit Cost")
        {
            field("TMAC Logistic Units"; LogisticUnits)
            {
                Caption = 'Logistic Units';
                Editable = false;
                ApplicationArea = all;
                ToolTip = 'Specifies the logistic units linked to current focument line.';
                trigger OnDrillDown()
                begin
                    UnitLinkManagement.ShowLogisticUnitsList(Database::"Purchase Line", Rec."Document Type".AsInteger(), Rec."Document No.", Rec."Line No.", false);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        LogisticUnits := UnitLinkManagement.GetLogisticUnitsInText(Database::"Purchase Line", Rec."Document Type".AsInteger(), Rec."Document No.", Rec."Line No.");
    end;

    internal procedure GetSelectedLineLinks(var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        CurrPage.SetSelectionFilter(PurchaseLine);
        PurchaseLine.MarkedOnly(true);
        if PurchaseLine.Count <= 1 then begin
            PurchaseLine.Reset();
            PurchaseLine.SetRange("Document Type", Rec."Document Type");
            PurchaseLine.SetRange("Document No.", Rec."Document No.");
        end;
        if PurchaseLine.IsEmpty then
            exit;
        if PurchaseLine.Findset() then
            repeat
                UnitLinkManagement.CreateFrom_PurchLine(SourceDocumentLink, PurchaseLine, 0, 0);
            until PurchaseLine.Next() = 0;
    end;

    /// <summary>
    /// For TMS
    /// </summary>
    procedure "TMAC Get Selected Lines Links"(var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        CurrPage.SetSelectionFilter(PurchaseLine);
        PurchaseLine.MarkedOnly(true);
        if PurchaseLine.Count <= 1 then begin
            PurchaseLine.Reset();
            PurchaseLine.SetRange("Document Type", Rec."Document Type");
            PurchaseLine.SetRange("Document No.", Rec."Document No.");
        end;
        if PurchaseLine.IsEmpty then
            exit;
        if PurchaseLine.Findset() then
            repeat
                // No need to break it down by lots, as at the time of planning the shipment we still don't know which batches of goods we'll be transporting.
                SourceDocumentLink.Init();
                SourceDocumentLink.Clear();
                SourceDocumentLink."Source Type" := Database::"Purchase Line";
                SourceDocumentLink."Source Subtype" := PurchaseLine."Document Type".AsInteger();
                SourceDocumentLink."Source ID" := PurchaseLine."Document No.";
                SourceDocumentLink."Source Ref. No." := PurchaseLine."Line No.";
                SourceDocumentLink.Insert(false);
            until PurchaseLine.Next() = 0;
    end;

    var
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
        LogisticUnits: Code[20];



}
