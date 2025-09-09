
table 71628576 "TMAC Unit Type"
{
    Caption = 'Unit Type';
    DrillDownPageID = "TMAC Unit Type List";
    LookupPageID = "TMAC Unit Type List";

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the unique code for this logistic unit type, identifying it in the system.';
        }

        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a short description of the logistic unit type for easy identification.';
        }
        field(3; "Description 2"; Text[100])
        {
            Caption = 'Description 2';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies an additional description text for further details about this unit type.';
        }

        field(10; "Linear Unit of Measure"; Code[10])
        {
            Caption = 'Linear Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit of Measure".Code where(Type = const(Linear), Blocked = const(false));
            ToolTip = 'Specifies how to measure length, width, and height for logistic units of this type.';
            trigger OnValidate()
            begin
                Validate("Internal Length", UnitofMeasureMgmt.ConvertRnd(xRec."Linear Unit of Measure", "Internal Length", Rec."Linear Unit of Measure"));
                Validate("Internal Width", UnitofMeasureMgmt.ConvertRnd(xRec."Linear Unit of Measure", "Internal Width", Rec."Linear Unit of Measure"));
                Validate("Internal Height", UnitofMeasureMgmt.ConvertRnd(xRec."Linear Unit of Measure", "Internal Height", Rec."Linear Unit of Measure"));
            end;
        }
        field(11; "Volume Unit of Measure"; Code[10])
        {
            Caption = 'Volume Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit of Measure".Code where(Type = const(Volume), Blocked = const(false));
            ToolTip = 'Specifies how to measure volumes (internal or external) for units of this type.';
            trigger OnValidate()
            begin
                CalcVolumes();
            end;
        }
        field(12; "Weight Unit of Measure"; Code[10])
        {
            Caption = 'Weight Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit of Measure".Code where(Type = const(Mass), Blocked = const(false));
            ToolTip = 'Specifies how to measure weight, including tare and payload, for units of this type.';
        }

        field(13; "Internal Length"; Decimal)
        {
            Caption = 'Internal Length';
            DataClassification = CustomerContent;
            MinValue = 0;
            DecimalPlaces = 0 : 4;
            ToolTip = 'Specifies the internal length of the unit''s usable space for placing goods.';
            trigger OnValidate()
            begin
                if "Length" = 0 then
                    Validate(Length, "Internal Length");

                if "Length" < "Internal Length" then
                    Validate(Length, "Internal Length");

                CalcVolumes();
            end;
        }
        field(14; "Internal Width"; Decimal)
        {
            Caption = 'Internal Width';
            DataClassification = CustomerContent;
            MinValue = 0;
            DecimalPlaces = 0 : 4;
            ToolTip = 'Specifies the internal width of the unit''s usable area, ensuring items fit properly.';
            trigger OnValidate()
            begin
                if "Width" = 0 then
                    Validate(Width, "Internal Width");

                if "Width" < "Internal Width" then
                    Validate(Width, "Internal Width");

                CalcVolumes();
            end;
        }
        field(15; "Internal Height"; Decimal)
        {
            Caption = 'Internal Height';
            DataClassification = CustomerContent;
            MinValue = 0;
            DecimalPlaces = 0 : 4;
            ToolTip = 'Specifies the internal height available for items within the unit (from base to top).';
            trigger OnValidate()
            begin
                if "Height" = 0 then
                    Validate(Height, "Internal Height");

                if "Height" < "Internal Height" then
                    Validate(Height, "Internal Height");

                CalcVolumes();
            end;
        }
        field(16; "Internal Volume"; Decimal)
        {
            Caption = 'Internal Volume';
            DataClassification = CustomerContent;
            MinValue = 0;
            DecimalPlaces = 0 : 4;
            Editable = false;
            ToolTip = 'Specifies the total inner volume of the logistic unit, used to calculate fill capacity.';
        }
        field(17; "Limit Filling Volume"; Decimal)
        {
            Caption = 'Limit Filling Volume';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 4;
            MinValue = 0;
            ToolTip = 'Specifies the maximum volume that should not be exceeded when adding items to this unit.';
        }
        field(18; "Unit Volume"; Decimal)
        {
            Caption = 'Unit Volume';
            DataClassification = CustomerContent;
            MinValue = 0;
            DecimalPlaces = 0 : 4;
            ToolTip = 'Specifies the external volume of this unit, from length × width × height measurements.';
        }
        field(19; "Tare Weight"; Decimal)
        {
            Caption = 'Tare Weight';
            DataClassification = CustomerContent;
            MinValue = 0;
            ToolTip = 'Specifies the empty weight of the logistic unit when no items are loaded.';
        }
        field(20; "Payload Weight"; Decimal)
        {
            Caption = 'Payload Weight';
            DataClassification = CustomerContent;
            MinValue = 0;
            ToolTip = 'Specifies how much cargo weight the unit can hold without exceeding structural limits.';
        }
        field(21; "Max Weight"; Decimal)
        {
            Caption = 'Max Weight';
            DataClassification = CustomerContent;
            MinValue = 0;
            ToolTip = 'Specifies the total loaded weight limit, including tare weight, to avoid overloading.';
        }
        field(22; "Limit Filling Weight"; Decimal)
        {
            Caption = 'Limit Filling Weight';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the recommended maximum weight for contents in this unit type, if enforced.';
        }

        field(23; "Length"; Decimal)
        {
            Caption = 'Length';
            DataClassification = CustomerContent;
            MinValue = 0;
            DecimalPlaces = 0 : 4;
            ToolTip = 'Specifies the unit''s external length dimension, used in volume and space calculations.';
            trigger OnValidate()
            begin
                CalcVolumes();
            end;
        }
        field(24; "Width"; Decimal)
        {
            Caption = 'Width';
            DataClassification = CustomerContent;
            MinValue = 0;
            DecimalPlaces = 0 : 4;
            ToolTip = 'Specifies the external width of the logistic unit for dimension-based calculations.';
            trigger OnValidate()
            begin
                CalcVolumes();
            end;
        }
        field(25; "Height"; Decimal)
        {
            Caption = 'Height';
            DataClassification = CustomerContent;
            MinValue = 0;
            DecimalPlaces = 0 : 4;
            ToolTip = 'Specifies the external height of the logistic unit, from its base to the top edge.';
            trigger OnValidate()
            begin
                CalcVolumes();
            end;
        }

        field(30; "Limit Filling Volume Control"; Boolean)
        {
            Caption = 'Strict Volume Control';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies if the unit strictly forbids volumes above the Limit Filling Volume value.';
        }

        field(31; "Limit Filling Weight Control"; Boolean)
        {
            Caption = 'Strict Weight Control';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies if the unit strictly forbids weights above the Limit Filling Weight setting.';
        }
        field(32; "Limit Filling Footage Control"; Boolean)
        {
            Caption = 'Strict Footage Control';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies if the unit strictly forbids footage (floor space) above the max Footage value.';
        }

        field(45; "Footage"; Decimal)
        {
            Caption = 'Footage';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the maximum floor area or footprint the unit can occupy or enforce.';
        }

        field(46; "Sort Order"; Integer)
        {
            Caption = 'Sort Order';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies how to rank or sort this unit type among others in selection lists.';
        }

        field(50; "Temperature Control"; Boolean)
        {
            Caption = 'Temperature Control';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies if a temperature level must be monitored or regulated for these units.';
            trigger OnValidate()
            begin
                if not "Temperature Control" then
                    Temperature := 0;
            end;
        }
        field(51; "Ventilation"; Boolean)
        {
            Caption = 'Ventilation';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies if the unit is equipped with features to allow airflow or ventilate goods.';
        }

        field(53; "Type of Loading"; Enum "TMAC Load Type")
        {
            Caption = 'Type of Loading';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies how items are placed or loaded into this unit: e.g. pallet, container, trailer.';
        }
        field(54; "Mix Source Document Allowed"; Boolean)
        {
            Caption = 'Mix Source Document Allowed';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies if items from multiple source documents can be combined within one unit.';
        }

        field(55; "Temperature"; Decimal)
        {
            Caption = 'Def. Temperature';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the default temperature for these units if Temperature Control is enabled.';
        }

        field(56; "Mix Location/Bin Allowed"; Boolean)
        {
            Caption = 'Mix Location/Bin Allowed';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies if items from different warehouse locations or bins can coexist in this unit.';
        }

        field(79; "Picture"; Media)
        {
            Caption = 'Picture';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies an optional image or icon representing this logistic unit type visually.';
        }
        field(80; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the number series used to generate IDs for logistic units of this type.';
        }
        field(90; "Reusable"; Boolean)
        {
            Caption = 'Reusable';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies if the logistic unit type is designed for repeated use, like standard pallets.';
        }
        field(91; "Automatic SSCC Creation"; Boolean)
        {
            Caption = 'Automatic SSCC Creation';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies if SSCC (Serial Shipping Container Codes) are automatically assigned on creation.';
        }
        field(92; "SSCC No. Series"; Code[20])
        {
            Caption = 'SSCC No. Series';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the number series used to assign SSCC numbers for new logistic units.';
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
        key(Key2; "Sort Order", "Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Code, Description, "Unit Volume", "Payload Weight")
        {
        }
    }

    trigger OnInsert()
    begin
        LogisticUnitsSetup.Get();
        if "Linear Unit of Measure" = '' then
            "Linear Unit of Measure" := LogisticUnitsSetup."Base Linear Unit of Measure";
        if "Volume Unit of Measure" = '' then
            "Volume Unit of Measure" := LogisticUnitsSetup."Base Volume Unit of Measure";
        if "Weight Unit of Measure" = '' then
            "Weight Unit of Measure" := LogisticUnitsSetup."Base Weight Unit of Measure";
    end;

    trigger OnModify()
    begin
    end;

    local procedure CalcVolumes()
    var
        Setup: Record "TMAC Logistic Units Setup";
        IntenalVolume: Decimal;
        UnitVolume: Decimal;
        LinearUnitofMeasure: Code[10];
        VolumeUnitofMeasure: Code[10];
    begin
        Setup.Get();
        LinearUnitofMeasure := "Linear Unit of Measure";
        VolumeUnitofMeasure := "Volume Unit of Measure";

        if LinearUnitofMeasure = '' then
            LinearUnitofMeasure := Setup."Base Linear Unit of Measure";

        if VolumeUnitofMeasure = '' then
            VolumeUnitofMeasure := Setup."Base Volume Unit of Measure";

        IntenalVolume := "Internal Width" * "Internal Height" * "Internal Length";
        IntenalVolume := UnitofMeasureMgmt.ConvertToVolumeRnd(LinearUnitofMeasure, IntenalVolume, VolumeUnitofMeasure);
        if "Internal Volume" <> IntenalVolume then
            Validate("Internal Volume", IntenalVolume);

        UnitVolume := "Length" * "Width" * "Height";
        UnitVolume := UnitofMeasureMgmt.ConvertToVolumeRnd(LinearUnitofMeasure, UnitVolume, VolumeUnitofMeasure);
        if "Unit Volume" <> UnitVolume then
            Validate("Unit Volume", UnitVolume);
    end;

    procedure GetCaptionSufix(ValueType: Option Linear,Volume,Mass): Text[80]
    var
        UnitOfMeasureCode: Code[10];
    begin
        case ValueType of
            ValueType::"Linear":
                UnitOfMeasureCode := "Linear Unit of Measure";
            ValueType::"Volume":
                UnitOfMeasureCode := "Volume Unit of Measure";
            ValueType::"Mass":
                UnitOfMeasureCode := "Weight Unit of Measure";
        end;
        exit(GetCachedCaption(UnitOfMeasureCode));
    end;

    local procedure GetCachedCaption(UnitOfMeasureCode: Code[10]): Text[80]
    var
        UnitofMeasure: Record "TMAC Unit of Measure";
        Suffix: Text[80];
    begin
        if UnitOfMeasureCode = '' then
            exit('');

        if CaptionsCache.ContainsKey(UnitOfMeasureCode) then
            exit(CaptionsCache.Get(UnitOfMeasureCode))
        else
            if UnitofMeasure.Get(UnitOfMeasureCode) then begin
                if UnitofMeasure.Caption <> '' then
                    Suffix := CopyStr(' (' + UnitofMeasure.Caption + ')', 1, 80)
                else
                    Suffix := '';
                CaptionsCache.Add(UnitOfMeasureCode, Suffix);
                exit(Suffix);
            end else
                CaptionsCache.Add(UnitOfMeasureCode, '');
    end;

    var
        LogisticUnitsSetup: Record "TMAC Logistic Units Setup";
        UnitofMeasureMgmt: Codeunit "TMAC Unit of Measure Mgmt.";

        CaptionsCache: Dictionary of [Code[10], Text[80]];
}