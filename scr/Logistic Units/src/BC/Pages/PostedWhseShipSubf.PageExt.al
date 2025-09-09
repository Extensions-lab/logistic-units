pageextension 71628604 "TMAC Posted Whse. Ship. Subf" extends "Posted Whse. Shipment Subform"
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
                    UnitLinkManagement.ShowLogisticUnitsList(Database::"Posted Whse. Shipment Line", 0, Rec."No.", Rec."Line No.", false);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        LogisticUnits := UnitLinkManagement.GetLogisticUnitsInText(Database::"Posted Whse. Shipment Line", 0, Rec."No.", Rec."Line No.");
    end;

    internal procedure GetSelectedLineLinks(var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        PostedWhseShipmentLine: Record "Posted Whse. Shipment Line";
    begin
        CurrPage.SetSelectionFilter(PostedWhseShipmentLine);
        PostedWhseShipmentLine.MarkedOnly(true);
        if PostedWhseShipmentLine.Count <= 1 then begin
            PostedWhseShipmentLine.Reset();
            PostedWhseShipmentLine.SetRange("No.", Rec."No.");
        end;
        if PostedWhseShipmentLine.IsEmpty then
            exit;
        if PostedWhseShipmentLine.Findset() then
            repeat
                UnitLinkManagement.CreateFrom_PostedWhsShipmentLine(SourceDocumentLink, PostedWhseShipmentLine, 0, 0);
            until PostedWhseShipmentLine.Next() = 0;
    end;

    /// <summary>
    /// For TMS
    /// </summary>
    procedure "TMAC Get Selected Lines Links"(var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        PostedWhseShipmentLine: Record "Posted Whse. Shipment Line";
    begin
        CurrPage.SetSelectionFilter(PostedWhseShipmentLine);
        PostedWhseShipmentLine.MarkedOnly(true);
        if PostedWhseShipmentLine.Count <= 1 then begin
            PostedWhseShipmentLine.Reset();
            PostedWhseShipmentLine.SetRange("No.", Rec."No.");
        end;
        if PostedWhseShipmentLine.IsEmpty then
            exit;
        if PostedWhseShipmentLine.Findset() then
            repeat
                SourceDocumentLink.Init();
                SourceDocumentLink.Clear();
                SourceDocumentLink."Source Type" := Database::"Posted Whse. Shipment Line";
                SourceDocumentLink."Source Subtype" := 0;
                SourceDocumentLink."Source ID" := PostedWhseShipmentLine."No.";
                SourceDocumentLink."Source Ref. No." := PostedWhseShipmentLine."Line No.";
                SourceDocumentLink.Insert(false);
            until PostedWhseShipmentLine.Next() = 0;
    end;

    var
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
        LogisticUnits: Code[20];


}
