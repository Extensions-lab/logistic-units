pageextension 71628614 "TMAC Invt. Shipment Subform" extends "Invt. Shipment Subform"
{
    layout
    {
        addbefore("Unit Amount")
        {
            field("TMAC From Logistic Unit"; Rec."TMAC From Logistic Unit")
            {
                AccessByPermission = tabledata "TMAC Unit Line" = r;
                Caption = 'From Logistic Units';
                Editable = true;
                Visible = true;
                ApplicationArea = all;
                ToolTip = 'Specifies the form logistic units to current document line.';
            }
            field("TMAC Logistic Units"; LogisticUnits)
            {
                AccessByPermission = tabledata "TMAC Unit" = r;
                Caption = 'Logistic Units';
                Editable = false;
                ApplicationArea = all;
                ToolTip = 'Specifies the logistic units linked to current document line.';
                trigger OnDrillDown()
                begin
                    UnitLinkManagement.ShowLogisticUnitsList(Database::"Invt. Document Line", Rec."Document Type".AsInteger(), Rec."Document No.", Rec."Line No.", false);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        LogisticUnits := UnitLinkManagement.GetLogisticUnitsInText(Database::"Invt. Document Line", Rec."Document Type".AsInteger(), Rec."Document No.", Rec."Line No.");
    end;

    internal procedure GetSelectedLineLinks(var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        InvtDocumentLine: Record "Invt. Document Line";
    begin
        CurrPage.SetSelectionFilter(InvtDocumentLine);
        InvtDocumentLine.MarkedOnly(true);
        if InvtDocumentLine.Count <= 1 then begin
            InvtDocumentLine.Reset();
            InvtDocumentLine.SetRange("Document Type", Rec."Document Type");
            InvtDocumentLine.SetRange("Document No.", Rec."Document No.");
        end;
        if InvtDocumentLine.IsEmpty then
            exit;
        if InvtDocumentLine.Findset() then
            repeat
                UnitLinkManagement.CreateFrom_InvtDocumentLine(SourceDocumentLink, InvtDocumentLine, 0, 0);
            until InvtDocumentLine.Next() = 0;
    end;

    var
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
        LogisticUnits: Code[20];
}
