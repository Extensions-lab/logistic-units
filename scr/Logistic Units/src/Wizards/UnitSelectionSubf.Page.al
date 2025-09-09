page 71628618 "TMAC Unit Selection Subf."
{
    Caption = 'Select Logistic Units';
    PageType = ListPart;
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
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Unit Type"; Rec."Unit Type")
                {
                    ApplicationArea = All;
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
                field("Weight Compatibility"; Rec."Weight Compatibility")
                {
                    ApplicationArea = All;
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
                field("Volume Compatibility"; Rec."Volume Compatibility")
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
            action(ShowOnlyEmtpy)
            {
                Caption = 'Show Only Compatible';
                Image = Line;
                ApplicationArea = All;
                ToolTip = 'Show only logistics units that are compatible by weight and volume.';
                trigger OnAction()
                begin
                    Rec.FilterGroup(2);
                    Rec.SetRange("Weight Compatibility", true);
                    Rec.SetRange("Volume Compatibility", true);
                    Rec.FilterGroup(0);
                end;
            }
            action(ShowAll)
            {
                Caption = 'Show All';
                Image = Line;
                ApplicationArea = All;
                ToolTip = 'Show all logistics units';
                trigger OnAction()
                begin
                    Rec.FilterGroup(2);
                    Rec.SetRange("Weight Compatibility");
                    Rec.SetRange("Volume Compatibility");
                    Rec.FilterGroup(0);
                end;
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

    internal procedure ShowLogisticUnits(Units: List of [Code[20]]; TotalWeight: Decimal; TotalVolume: Decimal)
    begin
        Rec.Reset();
        Rec.DeleteAll(false);
        Rec.CompleteUnits(Units, false, TotalWeight, TotalVolume);
        CurrPage.Update(false);
    end;

    internal procedure GetSelected(): Code[20]
    begin
        exit(Rec."Unit No.");
    end;

    var
        VolumeFieldStyle: Text;
        WeightFieldStyle: Text;

        OverWeightInfoMsg: Label 'Logistic Unit Type %1 has a weight limit %2 for internal items.', Comment = '%1 is a Unit type, %2 is a weight value';
        OverVolumeInfoMsg: Label 'Logistic Unit Type %1 has a volume limit %2 for internal items.', Comment = '%1 is a Unit type, %2 is a weight value';

}

