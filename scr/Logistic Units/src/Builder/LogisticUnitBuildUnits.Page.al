page 71628621 "TMAC Logistic Unit Build Units"
{
    Caption = 'Logistic Units';
    PageType = ListPart;
    LinksAllowed = false;
    SourceTable = "TMAC Buffer Unit Build";
    SourceTableTemporary = true;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                IndentationColumn = Rec.Indent;
                IndentationControls = "No.", Description;
                ShowAsTree = true;
                ShowCaption = false;

                field("No."; Rec."No.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the number of the item or the transport unit, depending on what was selected in the Type field.';
                    Width = 10;
                    trigger OnDrillDown()
                    var
                        Unit: Record "TMAC Unit";
                    begin
                        Case Rec."Type" of
                            "TMAC Unit Line Type"::Unit:
                                if Unit.Get(Rec."No.") then
                                    PAGE.Run(PAGE::"TMAC Unit Card", Unit);
                        end;
                    end;

                }
                field("Unit Type Code"; Rec."Unit Type Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the unit type code.';
                    Width = 8;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies a description for the entry of the product to be forwarded.';
                    Width = 13;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the line type.';
                    Width = 5;
                }

                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Suite;
                    BlankZero = true;
                    ToolTip = 'Specifies the quantity.';
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how each item is measured. By default, the Base Unit of Measure is used.';
                    Width = 5;
                }

                field("Gross Weight (base)"; Rec."Gross Weight (base)")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '70611575,2,' + Rec.FieldCaption("Gross Weight (base)");
                    ToolTip = 'Specifies the gross weight of the item.';
                    DecimalPlaces = 2;
                }

                field("Volume (base)"; Rec."Volume (base)")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '70611575,1,' + Rec.FieldCaption("Volume (base)");
                    ToolTip = 'Specifies the volume of the item.';
                    DecimalPlaces = 2;
                }
            }

            group(Totals)
            {
                ShowCaption = false;
                field(TotalGrossWeight; TotalWeight)
                {
                    Caption = 'Total Gross Weight';
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    Editable = false;
                    ToolTip = 'Specifies the total weight of the logistic units.';
                }
                field(TotalVolume; TotalVolume)
                {
                    Caption = 'Total Volume';
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    Editable = false;
                    ToolTip = 'Specifies the volume of the logistic units.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(NewEmpty)
            {
                Caption = 'Include in New';
                Image = New;
                ToolTip = 'Create New Empty';
                ApplicationArea = All;
                trigger OnAction();
                var
                    UnitType: record "TMAC Unit Type";
                    Unit: Record "TMAC Unit";
                    ParentUnit: Record "TMAC Unit";
                begin
                    if Rec.Type = "TMAC Unit Line Type"::Unit then
                        if Unit.Get(Rec."No.") then
                            if Confirm(StrSubstNo('Should I create a new logistics unit and place logistics unit %1 inside it?', Rec."No.")) then
                                if Page.RunModal(0, UnitType) = Action::LookupOK then begin
                                    ParentUnit.Init();
                                    ParentUnit."No." := '';
                                    ParentUnit."Type Code" := UnitType.Code;
                                    ParentUnit.Insert(true);
                                    UnitManagement.IncludeUnitToUnit(Rec."No.", ParentUnit."No.");
                                    Units.Add(ParentUnit."No.");
                                    Units.Remove(Rec."No.");
                                    FillTable(0);
                                    CurrPage.Update(false);
                                end else
                                    Message('You need to choose a type for the new logistics unit.');
                end;
            }
            action(DeleteUnit)
            {
                Caption = 'Delete Unit';
                Image = Delete;
                ToolTip = 'Delete selected logistic units.';

                ApplicationArea = All;
                trigger OnAction();
                var
                    Unit: Record "TMAC Unit";
                begin
                    if Rec.Type = "TMAC Unit Line Type"::Unit then
                        if Unit.Get(Rec."No.") then
                            if Confirm(StrSubstNo(DeleteLURequestQst, Rec."No.")) then begin
                                Unit.Delete(True);
                                Units.Remove(Rec."No.");
                                FillTable(0);
                                CurrPage.Update(false);
                            end;
                end;
            }
            action(DeleteLines)
            {
                Caption = 'Delete Selected Lines';
                Image = Delete;
                ToolTip = 'Delete selected items from logistic unit';

                ApplicationArea = All;
                trigger OnAction();
                var
                    UnitLine: Record "TMAC Unit Line";
                begin
                    if not Confirm('Delete selected lines from logistic unit?') then
                        exit;

                    CurrPage.SETSELECTIONFILTER(Rec);
                    Rec.MarkedOnly(true);
                    if Rec.Findset() then
                        repeat
                            if (Rec.Type = "TMAC Unit Line Type"::Item) then begin
                                UnitLine.Reset();
                                UnitLine.SetRange("Unit No.", Rec."Parent Unit No.");
                                UnitLine.SetRange("Line No.", Rec."Parent Unit Line No.");
                                UnitLine.DeleteAll(True);
                            end;
                        until Rec.Next() = 0;

                    Rec.MarkedOnly(false);
                    FillTable(0);
                    CurrPage.Update(false);
                end;
            }

            action(IncludeUnit)
            {
                Caption = 'Include Unit Into';
                ApplicationArea = All;
                Image = Planning;
                ToolTip = 'Insert selected units into another unit.';
                trigger OnAction();
                var
                    Unit: Record "TMAC Unit";
                    TempUnit: Record "TMAC Unit" temporary;
                    UnitNo: Code[20];
                begin
                    CurrPage.SETSELECTIONFILTER(Rec);
                    Rec.MarkedOnly(true);

                    foreach UnitNo in Units do begin
                        Unit.Get(UnitNo);
                        TempUnit.TransferFields(Unit);
                        TempUnit.Insert(true);
                    end;

                    repeat
                        if Rec.Type = "TMAC Unit Line Type"::Unit then
                            if TempUnit.Get(Rec."No.") then
                                TempUnit.Delete(false);
                    until Rec.Next() = 0;

                    if Page.RunModal(0, TempUnit) = Action::LookupOK then
                        if Rec.Findset() then
                            repeat
                                if Rec.Type = "TMAC Unit Line Type"::Unit then
                                    UnitManagement.IncludeUnitToUnit(Rec."No.", TempUnit."No.");
                            until Rec.Next() = 0;

                    Rec.MarkedOnly(false);
                    FillTable(0);
                    CurrPage.Update(false);
                end;
            }
            action(ExcludeUnit)
            {
                Caption = 'Exclude Unit';
                ApplicationArea = All;
                Image = Planning;
                ToolTip = 'Exclude the selected units out of the parent unit.';
                trigger OnAction();
                var
                    UnitCheck: Record "TMAC Unit";
                begin
                    CurrPage.SETSELECTIONFILTER(Rec);
                    Rec.MarkedOnly(true);

                    if Rec.Findset() then
                        repeat
                            if Rec.Type = "TMAC Unit Line Type"::Unit then
                                if UnitCheck.Get(Rec."No.") then
                                    UnitManagement.ExcludeUnit(Rec."No.");
                        until Rec.Next() = 0;

                    Rec.MarkedOnly(false);
                    Rec.Reset();
                    FillTable(0);
                    CurrPage.Update(false);
                end;
            }

            action(Update)
            {
                Caption = 'Update';
                Image = UpdateDescription;
                ToolTip = 'Reread data and update page.';
                ApplicationArea = All;
                trigger OnAction();
                begin
                    FillTable(0);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin

    end;

    internal procedure UpdateSubpage(Units1: List of [Code[20]])
    begin
        Units := Units1;
        FillTable(0);
        CurrPage.Update(false);
    end;

    local procedure FillTable(Indent1: Integer)
    var
        Unit: Record "TMAC Unit";
        UnitNo: Code[20];
    begin
        Rec.Reset();
        Rec.DeleteAll();
        TotalWeight := 0;
        TotalVolume := 0;
        LineNo := 0;
        foreach UnitNo in Units do begin
            Unit.Get(UnitNo);
            AddUnit(Unit, Indent1, '', 0)
        end;
    end;

    internal procedure AddUnit(var Unit: Record "TMAC Unit"; Indent1: Integer; ParentUnitNo: code[20]; ParentLineNo: Integer)
    var
        ChildUnit: Record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
    begin
        LineNo := LineNo + 10000;
        Rec.Init();
        Rec."Entry No." := LineNo;
        Rec."Type" := "TMAC Unit Line Type"::Unit;
        Rec."No." := Unit."No.";
        Rec."Description" := Unit."Description";
        Rec."Unit Type Code" := Unit."Type Code";
        Rec."Gross Weight (base)" := Unit."Weight (Base)";
        Rec."Volume (base)" := Unit."Volume (Base)";
        Rec."Indent" := Indent1;
        Rec."Parent Unit No." := ParentUnitNo;
        Rec."Parent Unit Line No." := ParentLineNo;
        Rec.Insert(false);

        TotalWeight += Rec."Gross Weight (base)";
        TotalVolume += Rec."Volume (base)";

        UnitLine.Reset();
        UnitLine.SetRange("Unit No.", Unit."No.");
        UnitLine.SetRange("Type", "TMAC Unit Line Type"::Unit);
        if UnitLine.FindSet(false) then
            repeat
                if ChildUnit.Get(UnitLine."No.") then
                    AddUnit(ChildUnit, Indent1 + 1, UnitLine."Unit No.", UnitLine."Line No.");
            until UnitLine.Next() = 0;


        UnitLine.Reset();
        UnitLine.SetRange("Unit No.", Unit."No.");
        UnitLine.SetFilter("Type", '<>%1', "TMAC Unit Line Type"::Unit);
        if UnitLine.FindSet(false) then
            repeat
                LineNo := LineNo + 10000;
                Rec.Init();
                Rec."Entry No." := LineNo;
                Rec."Type" := UnitLine.Type;
                Rec."No." := UnitLine."No.";
                Rec."Description" := UnitLine."Description";
                Rec."Unit Type Code" := '';
                Rec.Quantity := UnitLine.Quantity;
                Rec."Gross Weight (base)" := UnitLine."Gross Weight (base)";
                Rec."Volume (base)" := UnitLine."Volume (base)";
                Rec."Indent" := Indent1 + 1;
                Rec."Parent Unit No." := UnitLine."Unit No.";
                Rec."Parent Unit Line No." := UnitLine."Line No.";
                Rec.Insert(false);
            until UnitLine.Next() = 0;
    end;

    var
        UnitManagement: Codeunit "TMAC Unit Management";

        Units: List of [Code[20]];
        LineNo: Integer;
        TotalWeight: Decimal;
        TotalVolume: Decimal;

        DeleteLURequestQst: Label 'Delete %1 logistic unit?', Comment = '%1 is a logistic unit number';
}