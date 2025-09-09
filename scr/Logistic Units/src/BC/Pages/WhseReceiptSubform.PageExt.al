pageextension 71628599 "TMAC Whse. Receipt Subform" extends "Whse. Receipt Subform"
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
                    UnitLinkManagement.ShowLogisticUnitsList(Database::"Warehouse Receipt Line", 0, Rec."No.", Rec."Line No.", false);
                end;
            }
        }
    }


    trigger OnAfterGetRecord()
    begin
        LogisticUnits := UnitLinkManagement.GetLogisticUnitsInText(Database::"Warehouse Receipt Line", 0, Rec."No.", Rec."Line No.");
    end;

    internal procedure GetSelectedLineLinks(var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
    begin
        CurrPage.SetSelectionFilter(WarehouseReceiptLine);
        WarehouseReceiptLine.MarkedOnly(true);
        if WarehouseReceiptLine.Count <= 1 then begin
            WarehouseReceiptLine.Reset();
            WarehouseReceiptLine.SetRange("No.", Rec."No.");
        end;
        if WarehouseReceiptLine.IsEmpty then
            exit;
        if WarehouseReceiptLine.Findset() then
            repeat
                UnitLinkManagement.CreateFrom_WarehouseReceiptLine(SourceDocumentLink, WarehouseReceiptLine, 0, 0);
            until WarehouseReceiptLine.Next() = 0;
    end;

    /// <summary>
    /// For TMS
    /// </summary>
    procedure "TMAC Get Selected Lines Links"(var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
    begin
        CurrPage.SetSelectionFilter(WarehouseReceiptLine);
        WarehouseReceiptLine.MarkedOnly(true);
        if WarehouseReceiptLine.Count <= 1 then begin
            WarehouseReceiptLine.Reset();
            WarehouseReceiptLine.SetRange("No.", Rec."No.");
        end;
        if WarehouseReceiptLine.IsEmpty then
            exit;
        if WarehouseReceiptLine.Findset() then
            repeat
                SourceDocumentLink.Init();
                SourceDocumentLink.Clear();
                SourceDocumentLink."Source Type" := Database::"Warehouse Receipt Line";
                SourceDocumentLink."Source Subtype" := 0;
                SourceDocumentLink."Source ID" := WarehouseReceiptLine."No.";
                SourceDocumentLink."Source Ref. No." := WarehouseReceiptLine."Line No.";
                SourceDocumentLink.Insert(false);
            until WarehouseReceiptLine.Next() = 0;
    end;

    var
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
        LogisticUnits: Code[20];

}
