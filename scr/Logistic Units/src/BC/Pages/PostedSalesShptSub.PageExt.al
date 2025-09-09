pageextension 71628607 "TMAC Posted Sales Shpt. Sub" extends "Posted Sales Shpt. Subform"
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
                    UnitLinkManagement.ShowLogisticUnitsList(Database::"Sales Shipment Line", 0, Rec."Document No.", Rec."Line No.", false);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        LogisticUnits := UnitLinkManagement.GetLogisticUnitsInText(Database::"Sales Shipment Line", 0, Rec."Document No.", Rec."Line No.");
    end;

    internal procedure GetSelectedLineLinks(var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        SalesShipmentLine: Record "Sales Shipment Line";
    begin
        CurrPage.SetSelectionFilter(SalesShipmentLine);
        SalesShipmentLine.MarkedOnly(true);
        if SalesShipmentLine.Count <= 1 then begin
            SalesShipmentLine.Reset();
            SalesShipmentLine.SetRange("Document No.", Rec."Document No.");
        end;
        if SalesShipmentLine.IsEmpty then
            exit;
        if SalesShipmentLine.Findset() then
            repeat
                UnitLinkManagement.CreateFrom_SalesShipmentLine(SourceDocumentLink, SalesShipmentLine, 0, 0);
            until SalesShipmentLine.Next() = 0;
    end;

    /// <summary>
    /// For TMS
    /// </summary>
    procedure "TMAC Get Selected Lines Links"(var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        SalesShipmentLine: Record "Sales Shipment Line";
    begin
        CurrPage.SetSelectionFilter(SalesShipmentLine);
        SalesShipmentLine.MarkedOnly(true);
        if SalesShipmentLine.Count <= 1 then begin
            SalesShipmentLine.Reset();
            SalesShipmentLine.SetRange("Document No.", Rec."Document No.");
        end;
        if SalesShipmentLine.IsEmpty then
            exit;
        if SalesShipmentLine.Findset() then
            repeat
                SourceDocumentLink.Init();
                SourceDocumentLink.Clear();
                SourceDocumentLink."Source Type" := Database::"Sales Shipment Line";
                SourceDocumentLink."Source Subtype" := 0;
                SourceDocumentLink."Source ID" := SalesShipmentLine."Document No.";
                SourceDocumentLink."Source Ref. No." := SalesShipmentLine."Line No.";
                SourceDocumentLink.Insert(false);
            until SalesShipmentLine.Next() = 0;
    end;

    var
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
        LogisticUnits: Code[20];

}
