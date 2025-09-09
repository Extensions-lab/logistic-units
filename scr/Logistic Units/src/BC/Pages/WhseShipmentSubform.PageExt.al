pageextension 71628598 "TMAC Whse. Shipment Subform" extends "Whse. Shipment Subform"
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
                AccessByPermission = tabledata "TMAC Unit" = I;
                trigger OnDrillDown()
                begin
                    UnitLinkManagement.ShowLogisticUnitsList(Database::"Warehouse Shipment Line", 0, Rec."No.", Rec."Line No.", false);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        LogisticUnits := UnitLinkManagement.GetLogisticUnitsInText(Database::"Warehouse Shipment Line", 0, Rec."No.", Rec."Line No.");
    end;

    internal procedure GetSelectedLineLinks(var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
    begin
        CurrPage.SetSelectionFilter(WarehouseShipmentLine);
        WarehouseShipmentLine.MarkedOnly(true);
        if WarehouseShipmentLine.Count <= 1 then begin
            WarehouseShipmentLine.Reset();
            WarehouseShipmentLine.SetRange("No.", Rec."No.");
        end;
        if WarehouseShipmentLine.IsEmpty then
            exit;
        if WarehouseShipmentLine.Findset() then
            repeat
                UnitLinkManagement.CreateFrom_WarehouseShipmentLine(SourceDocumentLink, WarehouseShipmentLine, 0, 0);
            until WarehouseShipmentLine.Next() = 0;
    end;

    /// <summary>
    /// For TMS
    /// </summary>
    procedure "TMAC Get Selected Lines Links"(var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
    begin
        //собираем выбранные строки
        CurrPage.SetSelectionFilter(WarehouseShipmentLine);
        WarehouseShipmentLine.MarkedOnly(true);
        if WarehouseShipmentLine.Count <= 1 then begin
            WarehouseShipmentLine.Reset();
            WarehouseShipmentLine.SetRange("No.", Rec."No.");
        end;
        if WarehouseShipmentLine.IsEmpty then
            exit;
        if WarehouseShipmentLine.Findset() then
            repeat
                SourceDocumentLink.Init();
                SourceDocumentLink.Clear();
                SourceDocumentLink."Source Type" := Database::"Warehouse Shipment Line";
                SourceDocumentLink."Source Subtype" := 0;
                SourceDocumentLink."Source ID" := WarehouseShipmentLine."No.";
                SourceDocumentLink."Source Ref. No." := WarehouseShipmentLine."Line No.";
                SourceDocumentLink.Insert(false);
            until WarehouseShipmentLine.Next() = 0;
    end;

    var
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
        LogisticUnits: Code[20];

}
