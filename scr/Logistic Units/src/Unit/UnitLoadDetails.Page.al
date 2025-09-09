page 71628599 "TMAC Unit Load Details"
{
    ApplicationArea = All;
    Caption = 'Logistic Units Load Details';
    PageType = List;
    SourceTable = "TMAC Unit Load Details";
    UsageCategory = None;

    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                ShowAsTree = true;
                IndentationColumn = Rec.Indent;
                IndentationControls = "Unit No.";

                field("Unit No."; Rec."Unit No.")
                {
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    var
                        Unit: Record "TMAC Unit";
                    begin
                        if Unit.Get(Rec."Unit No.") then
                            Page.Run(Page::"TMAC Unit Card", Unit);
                    end;
                }
                field("Unit Type"; Rec."Unit Type")
                {
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field(QuantityBase; Rec."Quantity (Base)")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Visible = false;
                }
                field("Weight Limit"; Rec."Weight Limit")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field(WeightBase; Rec."Weight (Base)")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    StyleExpr = WeightFieldStyle;
                    trigger OnDrillDown()
                    var
                        UnitType: record "TMAC Unit Type";
                    begin
                        if Rec."Weight Control Warning" then
                            if UnitType.Get(Rec."Unit Type") then
                                Message(OverWeightInfoMsg, Rec."Unit Type", Rec."Weight (Base)");
                    end;
                }
                field("Volume Limit"; Rec."Volume Limit")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field(VolumeBase; Rec."Volume (Base)")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Visible = false;
                    StyleExpr = VolumeFieldStyle;
                    trigger OnDrillDown()
                    var
                        UnitType: record "TMAC Unit Type";
                    begin
                        if Rec."Volume Control Warning" then
                            if UnitType.Get(Rec."Unit Type") then
                                Message(OverVolumeInfoMsg, Rec."Unit Type", Rec."Volume (Base)");
                    end;
                }
                field("Source ID"; Rec."Source ID")
                {
                    trigger OnDrillDown()
                    begin
                        UnitLinkManagement.ShowDocument(Rec."Source Type", Rec."Source Subtype", Rec."Source ID");
                    end;
                }
                field("Source Name"; Rec."Source Name")
                {
                }
                field("Lot No."; Rec."Lot No.")
                {
                    Visible = false;
                }
                field("Serial No."; Rec."Serial No.")
                {
                    Visible = false;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        WeightFieldStyle := '';
        VolumeFieldStyle := '';
        if Rec."Volume Control Warning" then
            VolumeFieldStyle := 'Unfavorable';
        if Rec."Weight Control Warning" then
            WeightFieldStyle := 'Unfavorable';
    end;

    procedure SetUnits(Units: List of [Code[20]])
    begin
        Rec.CompleteUnits(Units, true);
    end;

    procedure GetSelected(): Code[20]
    begin
        exit(Rec."Unit No.");
    end;

    var
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
        VolumeFieldStyle: Text;
        WeightFieldStyle: Text;

        OverWeightInfoMsg: Label 'Logistic Unit Type %1 has a weight limit %2 for internal items.', Comment = '%1 is a Unit type, %2 is a weight value';
        OverVolumeInfoMsg: Label 'Logistic Unit Type %1 has a volume limit %2 for internal items.', Comment = '%1 is a Unit type, %2 is a weight value';
}
