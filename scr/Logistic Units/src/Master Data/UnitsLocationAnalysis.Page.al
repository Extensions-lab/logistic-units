page 71628578 "TMAC Units Location Analysis"
{
    ApplicationArea = All;
    Caption = 'Units Location Analysis';
    PageType = List;
    SourceTable = "TMAC Units Location Analysis";
    UsageCategory = Lists;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("LU Location Code"; Rec."LU Location Code")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("Zone Code"; Rec."Zone Code")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Logistic Unit No."; Rec."Logistic Unit No.")
                {
                    ApplicationArea = All;
                }
                field("Source ID"; Rec."Source ID")
                {
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    begin
                        UnitLinkManagement.ShowDocument(Rec."Source Type", Rec."Source Subtype", Rec."Source ID");
                    end;
                }
                field("Source Information"; Rec."Source Information")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Update)
            {
                Caption = 'Update';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = Refresh;
                ToolTip = 'Update Data';

                trigger OnAction();
                begin
                    FillTable();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
    end;

    internal procedure FillTable()
    var
        Unit: Record "TMAC Unit";
        UnitLineLink: Record "TMAC Unit Line Link";
    begin
        Rec.Reset();
        Rec.DeleteAll();
        Unit.Reset();
        Unit.SetCurrentKey("LU Location Code", "Location Code", "Zone Code", "Bin Code");
        if Unit.FindSet() then
            repeat
                Rec.Init();
                Rec."LU Location Code" := Unit."LU Location Code";
                Rec."Location Code" := Unit."Location Code";
                Rec."Zone Code" := Unit."Zone Code";
                Rec."Bin Code" := Unit."Bin Code";
                Rec."Logistic Unit No." := Unit."No.";
                UnitLineLink.Reset();
                UnitLineLink.SetRange("Unit No.", Unit."No.");
                if UnitLineLink.Findset() then
                    repeat
                        Rec."Source Type" := UnitLineLink."Source Type";
                        Rec."Source Subtype" := UnitLineLink."Source Subtype";
                        Rec."Source ID" := UnitLineLink."Source ID";
                        Rec."Source Information" := UnitLinkManagement.GetSourceInformation(Rec."Source Type", Rec."Source Subtype", rec."Source ID");
                        if Rec.Insert() then;
                    until UnitLineLink.Next() = 0;
            until Unit.Next() = 0;
    end;

    var
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
}
