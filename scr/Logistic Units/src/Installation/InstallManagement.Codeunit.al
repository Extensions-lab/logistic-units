codeunit 71628585 "TMAC Install Management"
{
    internal procedure CreateFreightClass(Code: Code[10]; Description: Text[100]; Comment: Text[100])
    var
        FreightClass: Record "TMAC Freight Class";
    begin
        if not FreightClass.Get(Code) then begin
            FreightClass.Init();
            FreightClass.Validate(Code, Code);
            FreightClass.Validate(Description, Description);
            FreightClass.Validate(Comment, Comment);
            FreightClass.Insert(true);
        end;
    end;

    internal procedure CreatePostCode(Code: Code[20]; City: Text[30]; CountryRegionCode: Code[10]; County: Text[30])
    var
        PostCode: Record "Post Code";
        CountryRegion: Record "Country/Region";
    begin
        IF not CountryRegion.Get(CountryRegionCode) then begin
            CountryRegion.Init();
            CountryRegion.Code := CountryRegionCode;
            CountryRegion.Insert(true);
        end;
        PostCode.SetRange("Search City", "City");
        PostCode.SetRange(Code, Code);
        if PostCode.IsEmpty then begin
            PostCode.Init();
            PostCode.Validate(Code, Code);
            PostCode.Validate(City, City);
            PostCode.Validate("Country/Region Code", CountryRegionCode);
            PostCode.Validate(County, County);
            PostCode.Insert(true);
        end;
    end;

    internal procedure CreateUnitOfMeasure(Type: enum "TMAC Unit of Measure Type"; InternationalStandardCode: Code[10]; Code: Code[10]; Description: Text[100]; Caption: Text[100]; ConvertionFactor: Decimal; Comment: Text[100])
    var
        UnitofMeasure: Record "TMAC Unit of Measure";
    begin
        if not UnitofMeasure.get(Code) then begin
            UnitofMeasure.Init();
            UnitofMeasure.Validate(Code, Code);
            UnitofMeasure.Validate(Description, Description);
            UnitofMeasure.Validate(Type, Type);
            UnitofMeasure.Validate("Conversion Factor", ConvertionFactor);
            UnitofMeasure.Validate("International Standard Code", InternationalStandardCode);
            if Caption = '' then
                UnitofMeasure.Validate(Caption, Code)
            else
                UnitofMeasure.Validate(Caption, Caption);
            UnitofMeasure.Validate(Comment, Comment);
            UnitofMeasure.Validate("Value Rounding Precision", 0.0001);
            UnitofMeasure.Insert(true);
        end;
    end;

    internal procedure CreateUnitType(Code: Code[20]; Description: Text; Description2: Text; PackageType: Code[10];
        LinearUoM: Code[10]; VolumeUoM: Code[10]; WeightUoM: Code[10];
        InternalLength: Decimal; InternalWidth: Decimal; InternalHeight: Decimal; UnitVolume: Decimal; LimitVolumeControl: Boolean;
        TareWeight: Decimal; PayloadWeight: Decimal; MaxWeight: Decimal; LimitWeightControl: Boolean;
        TemperatureControl: Boolean; Ventilation: Boolean; TypeofLoading: Enum "TMAC Load Type"; NoSeriesCode: Code[20])
    var
        UnitType: Record "TMAC Unit Type";
    begin
        UnitType.Init();
        UnitType.Validate(Code, Code);
        UnitType.Validate(Description, Description);
        UnitType.Validate("Description 2", Description2);
        
        UnitType.Validate("Linear Unit of Measure", LinearUoM);
        UnitType.Validate("Volume Unit of Measure", VolumeUoM);
        UnitType.Validate("Weight Unit of Measure", WeightUoM);

        UnitType.Validate("Internal Length", InternalLength);
        UnitType.Validate("Internal Width", InternalWidth);
        UnitType.Validate("Internal Height", InternalHeight);
        
        if UnitVolume <> 0 then
            UnitType.Validate("Unit Volume", UnitVolume);
        
        UnitType.Validate("Limit Filling Volume", UnitType."Internal Volume");
        UnitType.Validate("Limit Filling Volume Control", LimitVolumeControl);
        
        UnitType.Validate("Tare Weight", TareWeight);
        UnitType.Validate("Payload Weight", PayloadWeight);
        UnitType.Validate("Max Weight", MaxWeight);
        
        UnitType.Validate("Limit Filling Weight", UnitType."Payload Weight");
        UnitType.Validate("Limit Filling Weight Control", LimitWeightControl);
        
        UnitType.Validate("Temperature Control", TemperatureControl);
        UnitType.Validate("Ventilation", Ventilation);
        UnitType.Validate("Type of Loading", TypeofLoading);
        UnitType.Validate("No. Series", NoSeriesCode);

        if not UnitType.Insert(true) then
            UnitType.Modify(false);

    end;

    /// <summary>
    /// Create Unit Build Rule
    /// </summary>
    internal procedure CreateUnitBuildRule(UBRCode: Code[20]; Type: Enum "TMAC Content Type"; No: Code[20]; UoM: code[10]; Priority: Integer; BAT: Enum "TMAC Build Action Type"; SplitQty: Decimal; UTC: Code[20]; Blocked: Boolean)
    var
        UnitBuildRuleLine: Record "TMAC Unit Build Rule";
    begin
        UnitBuildRuleLine.Init();
        UnitBuildRuleLine."Unit Build Rule Code" := UBRCode;
        UnitBuildRuleLine.Validate(Type, Type);
        UnitBuildRuleLine.Validate("No.", No);
        UnitBuildRuleLine.Validate("Unit of Measure Code", UoM);
        UnitBuildRuleLine.Validate(Priority, Priority);
        UnitBuildRuleLine.Validate("Build Action Type", BAT);
        UnitBuildRuleLine.Validate("Split Qty.", SplitQty);
        UnitBuildRuleLine.Validate("Unit Type Code", UTC);
        UnitBuildRuleLine.Validate("Remains can be mixed", true);
        UnitBuildRuleLine.Validate(Blocked, Blocked);
        if UnitBuildRuleLine.insert(true) then
            UnitBuildRuleLine.Modify(true);
    end;

    internal procedure CreateLogisticUnitAction(Code: Code[10]; Description: Text; Create: Boolean; Archive: Boolean; Purchase: Boolean; WhsReceipt: Boolean; WhsPutAway: Boolean; Sale: Boolean; WhsShipment: Boolean; WhsPick: Boolean; Relocation: Boolean)
    var
        LogisticUnitAction: Record "TMAC Unit Action";
    begin
        LogisticUnitAction.Init();
        LogisticUnitAction.Code := Code;
        LogisticUnitAction.Description := CopyStr(Description, 1, 50);
        LogisticUnitAction.Create := Create;
        LogisticUnitAction.Archive := Archive;
        LogisticUnitAction.Purchase := Purchase;
        LogisticUnitAction."Warehouse Receipt" := WhsReceipt;
        LogisticUnitAction."Warehouse Put-away" := WhsPutAway;
        LogisticUnitAction.Sale := Sale;
        LogisticUnitAction."Warehouse Shipment" := WhsShipment;
        LogisticUnitAction."Warehouse Pickup" := WhsPick;
        LogisticUnitAction.Relocation := Relocation;

        if LogisticUnitAction.Insert() then
            LogisticUnitAction.Modify();
    end;

    internal procedure CreateUnitLocation(Code: Code[20]; Description: Text[50]; InboundLogisticsEnabled: Boolean; OutboundLogisticsEnabled: Boolean; DefaultShipmentLocation: Boolean; DefaultReceiptLocation: Boolean; DefaultCreationLocation: Boolean)
    var
        UnitLocation: Record "TMAC Unit Location";
    begin
        UnitLocation.Init();
        UnitLocation.Code := Code;
        UnitLocation.Description := Description;
        UnitLocation."Inbound Logistics Enabled" := InboundLogisticsEnabled;
        UnitLocation."Outbound Logistics Enabled" := OutboundLogisticsEnabled;
        UnitLocation."Default Shipment Location" := DefaultShipmentLocation;
        UnitLocation."Default Receipt Location" := DefaultReceiptLocation;
        UnitLocation."Default Creation Location" := DefaultCreationLocation;
        if UnitLocation.Insert() then;
    end;

    internal procedure CreateNoSeriesWithCheck(NoSeriesCode: Code[20]; Description: Text; StartNo: Code[20]; EndNo: Code[20]) rv: Code[20]
    var
        NoSeries: Record "No. Series";
    begin
        if not NoSeries.Get(NoSeriesCode) then
            exit(CreateNoSeries(NoSeriesCode, Description, StartNo, EndNo));
        exit(NoSeriesCode);
    end;

    internal procedure CreateNoSeries(NoSeriesCode: Code[20]; Description: Text; StartNo: Code[20]; EndNo: Code[20]) rv: Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        NoSeries.Init();
        NoSeries.Code := NoSeriesCode;
        NoSeries.Description := CopyStr(Description, 1, 100);
        NoSeries.Insert(true);
        NoSeries.Validate("Manual Nos.", true);
        NoSeries.Validate("Default Nos.", true);
        NoSeries.Modify(true);

        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := NoSeriesCode;
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine.Insert(true);
        NoSeriesLine.Validate("Starting No.", StartNo);
        NoSeriesLine.Validate("Ending No.", EndNo);
        NoSeriesLine.Modify(true);
        exit(NoSeriesCode);
    end;

    internal procedure CreateGS1AI(Code: Code[10]; Description: Text[250]; Format: Text[100]; Title: Text[100]; RegularExpression: text[200])
    var
        SSCCGS1AI: Record "TMAC SSCC GS1 AI";
    begin
        SSCCGS1AI.Init();
        SSCCGS1AI.Code := Code;
        SSCCGS1AI.Description := Description;
        SSCCGS1AI.Format := Format;
        SSCCGS1AI.Title := Title;
        SSCCGS1AI."Regular Expression" := RegularExpression;
        if not SSCCGS1AI.Insert(true) then
            SSCCGS1AI.Modify(false);
    end;

    internal procedure CreateDefaultSSCCLine(Identifier: Code[10]; BarCodePlace: enum "TMAC SSCC Barcode Place"; BarCodeType: enum "TMAC SSCC Barcode Type"; LabelTextNumber: enum "TMAC SSCC Label Text Number")
    var
        SSCCDefaultIdentifier: Record "TMAC SSCC Default Identifier";
    begin
        SSCCDefaultIdentifier.Init();
        SSCCDefaultIdentifier.Validate(Identifier, Identifier);
        SSCCDefaultIdentifier.Validate("Barcode Place", BarCodePlace);
        SSCCDefaultIdentifier.Validate("Barcode Type", BarCodeType);
        SSCCDefaultIdentifier.Validate("Label Text", LabelTextNumber);
        if SSCCDefaultIdentifier.Insert() then;
    end;
}