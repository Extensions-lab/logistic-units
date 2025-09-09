
Codeunit 71628580 "TMAC Unit of Measure Mgmt."
{
    procedure Convert(FromUoMCode: Code[10]; Value: Decimal; ToUomCode: Code[10]): Decimal
    var
        TranspUnitofMeasure: Record "TMAC Unit of Measure";
    begin
        if Value = 0 then
            exit(0);

        if FromUoMCode = ToUomCode then
            exit(Value);

        if FromUoMCode = '' then
            exit(Value);

        TranspUnitofMeasure.Get(FromUoMCode);
        Value := TranspUnitofMeasure."Conversion Factor" * Value;
        TranspUnitofMeasure.Get(ToUomCode);
        if TranspUnitofMeasure."Conversion Factor" > 0 then
            exit(Value / TranspUnitofMeasure."Conversion Factor");
        exit(0);
    end;


    /// <summary>
    /// Conversion of a value from one unit of measure to another
    /// </summary>
    /// <param name="FromUoMCode">Source unit of measure code</param>
    /// <param name="Value">Value to convert</param>
    /// <param name="ToUomCode">Target unit of measure code</param>
    /// <returns>Converted value</returns>
    procedure ConvertRnd(FromUoMCode: Code[10]; Value: Decimal; ToUomCode: Code[10]): Decimal
    var
        TranspUnitofMeasure: Record "TMAC Unit of Measure";
        NewValue: Decimal;
    begin
        if Value = 0 then
            exit(0);

        if FromUoMCode = ToUomCode then
            NewValue := Value
        else
            NewValue := Convert(FromUoMCode, Value, ToUomCode);

        TranspUnitofMeasure.Get(ToUomCode);
        if TranspUnitofMeasure."Conversion Factor" > 0 then
            exit(Round(NewValue, TranspUnitofMeasure."Value Rounding Precision"))
        else
            exit(Round(NewValue, 0.01));
    end;

    local procedure ConvertToBase(Type: Enum "TMAC Unit of Measure Type"; UoMCode: Code[10]; Value: Decimal; Round: Boolean): Decimal
    var
        LogisticUnitsSetup: Record "TMAC Logistic Units Setup";
        BaseUoM: Code[10];
        ReturnValue: Decimal;
    begin
        if Value = 0 then
            exit(0);
        if UoMCode = '' then
            exit(Value);
        LogisticUnitsSetup.Get();
        case Type of
            "TMAC Unit of Measure Type"::Volume:
                BaseUoM := LogisticUnitsSetup."Base Volume Unit of Measure";
            "TMAC Unit of Measure Type"::Mass:
                BaseUoM := LogisticUnitsSetup."Base Weight Unit of Measure";
            "TMAC Unit of Measure Type"::Linear:
                BaseUoM := LogisticUnitsSetup."Base Linear Unit of Measure";
        end;

        if Round then
            ReturnValue := Convert(UoMCode, Value, BaseUoM)
        else
            ReturnValue := ConvertRnd(UoMCode, Value, BaseUoM);

        exit(ReturnValue);
    end;

    procedure ConvertToBaseWeightRnd(UoMCode: Code[10]; Value: Decimal): Decimal
    begin
        exit(ConvertToBase("TMAC Unit of Measure Type"::Mass, UoMCode, Value, true));
    end;

    procedure ConvertToBaseLinearRnd(UoMCode: Code[10]; Value: Decimal): Decimal
    begin
        exit(ConvertToBase("TMAC Unit of Measure Type"::Linear, UoMCode, Value, true));
    end;

    procedure ConvertToBaseVolumeRnd(UoMCode: Code[10]; Value: Decimal): Decimal
    begin
        exit(ConvertToBase("TMAC Unit of Measure Type"::Volume, UoMCode, Value, true));
    end;

    procedure ConvertToVolume(LinerUoMCode: Code[10]; Value: Decimal; VolumUomCode: Code[10]): Decimal
    var
        TranspUnitofMeasure: Record "TMAC Unit of Measure";
    begin
        if Value = 0 then
            exit(0);
        TranspUnitofMeasure.Get(LinerUoMCode);
        Value := Power(TranspUnitofMeasure."Conversion Factor", 3) * Value;
        TranspUnitofMeasure.Get(VolumUomCode);
        if TranspUnitofMeasure."Conversion Factor" > 0 then
            exit(Value / TranspUnitofMeasure."Conversion Factor");
        exit(0);
    end;

    procedure ConvertToVolumeRnd(LinerUoMCode: Code[10]; Value: Decimal; VolumUomCode: Code[10]): Decimal
    var
        TranspUnitofMeasure: Record "TMAC Unit of Measure";
    begin
        if Value = 0 then
            exit(0);
        Value := ConvertToVolume(LinerUoMCode, Value, VolumUomCode);
        TranspUnitofMeasure.Get(VolumUomCode);
        if TranspUnitofMeasure."Value Rounding Precision" > 0 then
            exit(Round(Value, TranspUnitofMeasure."Value Rounding Precision"))
        else
            exit(Value);
    end;

    procedure ConvertToSystemUoM(UoMCode: Code[10]; Value: Decimal): Decimal
    var
        TranspUnitofMeasure: Record "TMAC Unit of Measure";
    begin
        if Value = 0 then
            exit(0);
        if UoMCode = '' then
            exit(Value);
        TranspUnitofMeasure.Get(UoMCode);
        exit(TranspUnitofMeasure."Conversion Factor" * Value);
    end;

    procedure ConvertToSystemUoMRnd(UoMCode: Code[10]; Value: Decimal): Decimal
    var
        TranspUnitofMeasure: Record "TMAC Unit of Measure";
    begin
        if Value = 0 then
            exit(0);
        Value := ConvertToSystemUoM(UoMCode, Value);
        TranspUnitofMeasure.Get(UoMCode);
        if TranspUnitofMeasure."Value Rounding Precision" > 0 then
            exit(Round(Value, TranspUnitofMeasure."Value Rounding Precision"))
        else
            exit(Value);
    end;


    procedure ConvertFromSystemUoM(ToUoMCode: Code[10]; Value: Decimal): Decimal
    var
        TranspUnitofMeasure: Record "TMAC Unit of Measure";
    begin
        if Value = 0 then
            exit(0);

        if ToUoMCode = '' then
            exit(Value);
        TranspUnitofMeasure.Get(ToUoMCode);
        if TranspUnitofMeasure."Conversion Factor" <> 0 then
            exit(Value / TranspUnitofMeasure."Conversion Factor");
    end;

    procedure ConvertFromSystemUoMRnd(UoMCode: Code[10]; Value: Decimal): Decimal
    var
        TranspUnitofMeasure: Record "TMAC Unit of Measure";
    begin
        if Value = 0 then
            exit(0);

        Value := ConvertFromSystemUoM(UoMCode, Value);
        TranspUnitofMeasure.Get(UoMCode);
        if TranspUnitofMeasure."Value Rounding Precision" > 0 then
            exit(Round(Value, TranspUnitofMeasure."Value Rounding Precision"))
        else
            exit(Value);
    end;

    procedure RndPrecision(UoMCode: Code[10]): Decimal
    var
        TranspUnitofMeasure: Record "TMAC Unit of Measure";
    begin
        if TranspUnitofMeasure.Get(UomCode) then
            exit(TranspUnitofMeasure."Value Rounding Precision");
        exit(0.01);
    end;
}