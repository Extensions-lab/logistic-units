pageextension 71628608 "TMAC Invt. Receipt Subform" extends "Invt. Receipt Subform"
{
    layout
    {
        addbefore("Unit Amount")
        {
            field("TMAC Logistic Units"; LogisticUnits)
            {
                Caption = 'Logistic Units';
                Editable = false;
                ApplicationArea = all;
                ToolTip = 'Specifies the logistic units linked to current focument line.';
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
        //собираем выбранные строки
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
