page 71628592 "TMAC Unit List FactBox"
{
    Caption = 'Logistic Units';
    PageType = ListPart;
    SourceTable = "TMAC Unit Info";
    SourceTableView = sorting("Unit No.", "Posted", Logistics);
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                IndentationColumn = 0;
                field(Name; Rec."Unit No.")
                {
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    var
                        Unit: Record "TMAC Unit";
                    begin
                        if Unit.Get(Rec."Unit No.") then
                            PAGE.Run(PAGE::"TMAC Unit Card", Unit);
                    end;
                }
                field(Logistics; Rec.Logistics)
                {
                    ApplicationArea = All;
                    Visible = true;
                    Width = 5;
                }
                field(Posted; Rec."Posted")
                {
                    ApplicationArea = All;
                    Visible = true;
                }
                field("Load State"; Rec."Load State")
                {
                    ApplicationArea = All;
                    Visible = false;
                    trigger OnDrillDown()
                    begin
                        OnLoadStateDrillDown(Rec, GlobalSourceType, GlobalSourceSubtype, GlobalSourceID);
                    end;
                }
            }
        }
    }

    procedure SetSource(SourceType: Integer; SourceDocumentType: Integer; SourceDocumentNo: Code[20]; PositiveText: Text; NegativeText: Text) returnvalue: Integer
    var
        UnitLineLink: Record "TMAC Unit Line Link";
    begin
        GlobalSourceType := SourceType;
        GlobalSourceSubtype := SourceDocumentType;
        GlobalSourceID := SourceDocumentNo;

        if not UnitLineLink.ReadPermission then
            exit;

        Rec.DeleteAll();
        if SourceType = 0 then
            exit;

        UnitLineLink.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.", "Package No.", "Lot No.", "Serial No.", "Positive", "Qty. to Post");
        UnitLineLink.SetRange("Source Type", SourceType);

        if SourceType <> Database::"Transfer Line" then
            UnitLineLink.SetRange("Source Subtype", SourceDocumentType);

        UnitLineLink.SetRange("Source ID", SourceDocumentNo);
        UnitLineLink.SetLoadFields("Unit No.", "Posted Quantity");
        if UnitLineLink.FindSet(false) then
            repeat
                Rec.Init();
                Rec."Unit No." := UnitLineLink."Unit No.";
                if UnitLineLink.Positive then
                    Rec.Logistics := CopyStr(PositiveText, 1, 50)
                else
                    Rec.Logistics := CopyStr(NegativeText, 1, 50);
                Rec.Posted := false;
                Rec.Posted := Rec.Posted or (UnitLineLink."Posted Quantity" <> 0);
                OnSetSource(Rec, GlobalSourceType, GlobalSourceSubtype, GlobalSourceID);
                if Rec.Insert(false) then;
            until UnitLineLink.Next() = 0;

        Returnvalue := Rec.Count();
        CurrPage.Update(false);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLoadStateDrillDown(var UnitInfo: Record "TMAC Unit Info"; SourceType: Integer; SourceDocumentType: Integer; SourceDocumentNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetSource(var UnitInfo: Record "TMAC Unit Info"; SourceType: Integer; SourceDocumentType: Integer; SourceDocumentNo: Code[20])
    begin
    end;

    var
        GlobalSourceType: Integer;
        GlobalSourceSubtype: Integer;
        GlobalSourceID: Code[20];
}