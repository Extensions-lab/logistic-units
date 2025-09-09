table 71628594 "TMAC Unit Load Details"
{
    Caption = 'Unit Load Details';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'Primary Type';
            Tooltip = 'Specifies an internal key for this record, used for ordering or referencing.';
        }
        field(2; Indent; Integer)
        {
            Caption = 'Indent';
            Tooltip = 'Specifies how far to indent the row, enabling hierarchical visualization of logistic units.';
        }
        field(3; "Unit No."; Code[20])
        {
            Caption = 'Unit No.';
            TableRelation = "TMAC Unit";
            Tooltip = 'Specifies the code of the logistic unit, such as a pallet or container.';
        }
        field(4; "Unit Type"; Code[20])
        {
            Caption = 'Unit Type';
            TableRelation = "TMAC Unit Type";
            Tooltip = 'Specifies the type of the logistic unit, for example a box or a pallet.';
        }
        field(20; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the item number if this load detail references an item instead of a nested unit.';
        }
        field(21; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the variant code for the item, detailing specific versions such as color or size.';
        }
        field(22; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies descriptive text about the logistic unit or item in this load detail.';
        }
        field(30; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the quantity of items or units included in this load detail record.';
            MinValue = 0;
        }
        field(31; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the unit of measure, such as pieces or kg, for the specified quantity.';
        }
        field(32; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
            MinValue = 0;
            Tooltip = 'Specifies the quantity in base units, ensuring consistent calculations across measures.';
        }

        field(33; "Weight (Base)"; Decimal)
        {
            Caption = 'Weight (Base)';
            Tooltip = 'Specifies the total weight in the base weight unit for this load detail.';
        }

        field(34; "Volume (Base)"; Decimal)
        {
            Caption = 'Volume (Base)';
            Tooltip = 'Specifies the total volume in the base volume unit for this load detail.';
        }

        //For notifying about weight or volume exceeding the limit

        field(35; "Weight Control Warning"; Boolean)
        {
            Caption = 'Weight Control Warning';
            Tooltip = 'Specifies whether the weight of the items in this unit exceeds the allowed limit.';
        }

        field(36; "Volume Control Warning"; Boolean)
        {
            Caption = 'Volume Control Warning';
            Tooltip = 'Specifies whether the volume of the items in this unit exceeds the allowed limit.';
        }

        field(40; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the warehouse location associated with this load detail, if any.';
        }

        field(42; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the bin within the location where this load detail is placed, if relevant.';
        }

        field(50; "Source Type"; Integer)
        {
            Caption = 'Source Type';
            Tooltip = 'Specifies the document type (purchase, sales, transfer) that serves as the origin of this record.';
        }

        field(51; "Source Subtype"; Integer)
        {
            Caption = 'Source Subtype';
            Tooltip = 'Specifies a further categorization of the source, used for detailed classification.';
        }

        field(52; "Source ID"; Code[20])
        {
            Caption = 'Source ID';
            Tooltip = 'Specifies the unique identifier of the source document related to this load detail.';
        }

        field(53; "Source Batch Name"; Code[10])
        {
            Caption = 'Source Batch Name';
            Tooltip = 'Specifies the name of the source batch or process from which this record originates.';
        }

        field(54; "Source Prod. Order Line"; Integer)
        {
            Caption = 'Source Prod. Order Line';
            Tooltip = 'Specifies the production order line number that generated this load detail, if any.';
        }
        field(55; "Source Ref. No."; Integer)
        {
            Caption = 'Source Ref. No.';
            Tooltip = 'Specifies any additional reference number used by the source document.';
        }
        field(56; "Source Name"; Text[50])
        {
            Caption = 'Source Name';
            Tooltip = 'Specifies the descriptive name of the source document or entity.';
        }
        field(57; "Package No."; Code[50])
        {
            Caption = 'Package No.';
            CaptionClass = '6,1';
            Tooltip = 'Specifies the unique identifier for the package containing these items or units.';
        }
        field(58; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            Tooltip = 'Specifies the lot number if these items are lot-tracked, enabling traceability.';
        }

        field(59; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
            Tooltip = 'Specifies the serial number if the items require individual tracking for traceability.';
        }

        field(70; "Weight Limit"; Decimal)
        {
            Caption = 'Weight Limit (Base)';
            Tooltip = 'Specifies the maximum weight capacity in base units for this logistic unit type.';
        }

        field(71; "Volume Limit"; Decimal)
        {
            Caption = 'Volume Limit (Base)';
            Tooltip = 'Specifies the maximum volume capacity in base units for this logistic unit type.';
        }

        field(72; "Weight Compatibility"; Boolean)
        {
            Caption = 'Weight Compatibility';
            Tooltip = 'Specifies whether the selected container can handle the current weight without exceeding capacity.';
            Editable = false;
        }

        field(73; "Volume Compatibility"; Boolean)
        {
            Caption = 'Volume Compatibility';
            Tooltip = 'Specifies whether the selected container can handle the current volume without exceeding capacity.';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }


    procedure CompleteUnits(Units: List of [Code[20]]; ShowItems: Boolean)
    begin
        CompleteUnits(Units, ShowItems, 0, 0);
    end;


    internal procedure CompleteUnits(Units: List of [Code[20]]; ShowItems: Boolean; TotalWeight: Decimal; TotalVolume: Decimal)
    var
        TopUnitNo: Code[20];
        CurrentUnit: Code[20];
        TopLevelUnits: List of [Code[20]];
    begin
        foreach CurrentUnit in Units do begin
            TopUnitNo := GetTopLevel(CurrentUnit);
            if not TopLevelUnits.Contains(TopUnitNo) then
                TopLevelUnits.Add(TopUnitNo);
        end;

        foreach CurrentUnit in TopLevelUnits do
            InsertUnit(CurrentUnit, 0, ShowItems, TotalWeight, TotalVolume);
    end;

    local procedure GetTopLevel(UnitNo: Code[20]): Code[20]
    var
        Unit: Record "TMAC Unit";
    begin
        if Unit.Get(UnitNo) then
            if Unit."Parent Unit No." = '' then
                exit(UnitNo)
            else
                exit(GetTopLevel(Unit."Parent Unit No."));
    end;

    local procedure InsertUnit(UnitNo: Code[20]; Indent1: Integer; ShowItems: Boolean; TotalWeight: Decimal; TotalVolume: Decimal)
    var
        Unit: Record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        UnitType: Record "TMAC Unit Type";
    begin
        Unit.Get(UnitNo);
        LineNo += 10000;
        Rec.Clear();
        Rec.Init();
        Rec."Primary Key" := LineNo;
        Rec.Indent := Indent1;
        Rec."Unit No." := UnitNo;
        Rec."Unit Type" := Unit."Type Code";
        Rec.Description := Unit.Description;

        //weight and volume control

        if UnitType.Get(Unit."Type Code") then begin
            Unit.CalcFields("Content Weight (Base)", "Content Volume (Base)");

            Rec."Weight (Base)" := Unit."Content Weight (Base)";
            Rec."Volume (Base)" := Unit."Content Volume (Base)";

            Rec."Weight Limit" := UnitType."Limit Filling Weight";
            Rec."Volume Limit" := UnitType."Limit Filling Volume";

            if UnitType."Limit Filling Weight Control" then
                if Unit."Content Weight (Base)" > UnitType."Limit Filling Weight" then
                    Rec."Weight Control Warning" := true;

            if UnitType."Limit Filling Volume Control" then
                if Unit."Content Volume (Base)" > UnitType."Limit Filling Volume" then
                    Rec."Volume Control Warning" := true;

            if Rec."Weight Limit" > 0 then begin
                if (Rec."Weight Limit" - Unit."Content Weight (Base)") >= TotalWeight then
                    Rec."Weight Compatibility" := true;
            end else
                Rec."Weight Compatibility" := true;

            if Rec."Volume Limit" > 0 then begin
                if (Rec."Volume Limit" - Unit."Content Volume (Base)") >= TotalVolume then
                    Rec."Volume Compatibility" := true;
            end else
                Rec."Volume Compatibility" := true;
        end;

        Rec.Insert();

        UnitLine.Reset();
        UnitLine.Setrange("Unit No.", UnitNo);
        UnitLine.SetRange(Type, "TMAC Unit Line Type"::Unit);
        UnitLine.SetLoadFields("No.");
        if UnitLine.FindSet(False) then
            repeat
                InsertUnit(UnitLine."No.", Indent1 + 1, ShowItems, TotalWeight, TotalVolume);
            until UnitLine.Next() = 0;

        if ShowItems then begin
            UnitLine.Reset();
            UnitLine.Setrange("Unit No.", UnitNo);
            UnitLine.SetRange(Type, "TMAC Unit Line Type"::Item);
            UnitLine.SetLoadFields("Line No.", "No.", "Variant Code", Description, "Unit of Measure Code");
            if UnitLine.FindSet(False) then
                repeat
                    //links are needed for document information
                    UnitLineLink.Reset();
                    UnitLineLink.Setrange("Unit No.", UnitNo);
                    UnitLineLink.SetRange("Unit Line No.", UnitLine."Line No.");
                    UnitLineLink.SetFilter("Source Type", '%1|%2|%3', Database::"Sales Line", Database::"Purchase Line", Database::"Transfer Line");
                    UnitLineLink.SetLoadFields("Quantity", "Quantity (Base)", "Weight (base)", "Volume (base)", "Source Type", "Source Subtype", "Source ID", "Source Name", "Source Ref. No.", "Source Batch Name", "Source Prod. Order Line");
                    if UnitLineLink.FindSet(false) then
                        repeat
                            Rec.Init();
                            Rec.Clear();
                            LineNo += 10000;
                            Rec.Init();
                            Rec."Primary Key" := LineNo;
                            Rec.Indent := Indent1 + 1;
                            Rec."Item No." := UnitLine."No.";
                            Rec."Variant Code" := UnitLine."Variant Code";
                            Rec.Description := UnitLine.Description;
                            Rec.Quantity := Abs(UnitLineLink.Quantity);
                            Rec."Unit of Measure Code" := UnitLine."Unit of Measure Code";
                            Rec."Quantity (Base)" := Abs(UnitLineLink."Quantity (Base)");
                            Rec."Weight (Base)" := UnitLineLink."Weight (base)";
                            Rec."Volume (Base)" := UnitLineLink."Volume (base)";
                            Rec."Source Type" := UnitLineLink."Source Type";
                            Rec."Source Subtype" := UnitLineLink."Source Subtype";
                            Rec."Source ID" := UnitLineLink."Source ID";
                            Rec."Source Name" := UnitLineLink."Source Name";
                            Rec."Source Ref. No." := UnitLineLink."Source Ref. No.";
                            Rec."Source Batch Name" := UnitLineLink."Source Batch Name";
                            rec."Source Prod. Order Line" := UnitLineLink."Source Prod. Order Line";
                            Rec.Insert();
                        until UnitLineLink.Next() = 0;
                until UnitLine.Next() = 0;
        end;
    end;

    internal procedure Clear()
    begin
        Indent := 0;
        "Unit No." := '';
        "Unit Type" := '';
        "Item No." := '';
        "Variant Code" := '';
        "Description" := '';
        Quantity := 0;
        "Unit of Measure Code" := '';
        "Quantity (Base)" := 0;
        "Weight (Base)" := 0;
        "Volume (Base)" := 0;
        "Weight Control Warning" := false;
        "Volume Control Warning" := false;
        "Weight Compatibility" := false;
        "Volume Compatibility" := false;
        "Weight Limit" := 0;
        "Volume Limit" := 0;
        "Location Code" := '';
        "Bin Code" := '';
        "Source Type" := 0;
        "Source Subtype" := 0;
        "Source ID" := '';
        "Source Batch Name" := '';
        "Source Prod. Order Line" := 0;
        "Source Ref. No." := 0;
        "Source Name" := '';
        "Package No." := '';
        "Lot No." := '';
        "Serial No." := '';
    end;

    var
        LineNo: Integer;
}
