/// <summary>
/// Manages the creation of logistic units based on build rules.
/// </summary>
/// <remarks>
/// This codeunit provides procedures to create and estimate logistic units from source documents.
/// It also applies rules to ensure source lines come from the same document or location.
/// </remarks>
codeunit 71628577 "TMAC Unit Build Management"
{

    /// <summary>
    /// Creates a logistic unit of the specified unit type and links it to the provided source document lines.
    /// </summary>
    /// <remarks>
    /// This function validates source lines for mixing restrictions, creates a new unit using "TMAC Unit Management",
    /// and adds item lines from the source document. Useful for manual logistic unit creation (wizard, etc.).
    /// </remarks>
    /// <param name="UnitTypeCode">Specifies the code of the unit type to create.</param>
    /// <param name="SourceDocumentLink">A record containing the source lines to attach to the new logistic unit.</param>
    /// <returns>The newly created logistic unit number.</returns>
    internal procedure BuildLogisticUnit(UnitTypeCode: Code[20]; var SourceDocumentLink: Record "TMAC Source Document Link") UnitNo: Code[20]
    var
        UnitType: Record "TMAC Unit Type";
        UnitManagement: Codeunit "TMAC Unit Management";
    begin
        SourceDocumentLink.Reset();
        SourceDocumentLink.SetCurrentKey("Item No.", "Variant Code", "Unit of Measure Code");
        if SourceDocumentLink.Count() = 0 then
            exit;

        UnitType.Get(UnitTypeCode);

        if HasDiffrentDocumentSource(SourceDocumentLink) and not UnitType."Mix Source Document Allowed" then
            error(MixSourceDocumentErr, UnitTypeCode);

        if HasDifferentLocations(SourceDocumentLink) and not UnitType."Mix Location/Bin Allowed" then
            error(MixLocationsErr, UnitTypeCode);


        UnitNo := UnitManagement.CreateLogisticUnit(UnitTypeCode);

        SourceDocumentLink.Reset();
        SourceDocumentLink.SetCurrentKey("Item No.", "Variant Code", "Unit of Measure Code");
        if SourceDocumentLink.findset(false) then
            repeat
                SourceDocumentLink.Validate("Selected Quantity");
                UnitManagement.AddItemToLogisticUnit(UnitNo, SourceDocumentLink."Selected Quantity", SourceDocumentLink);
            until SourceDocumentLink.Next() = 0;

        UnitManagement.UpdateUnitWeightAndVolume(UnitNo, 0, 0, 0);
    end;


    /// <summary>
    /// Checks if source document lines come from different underlying documents.
    /// </summary>
    /// <remarks>
    /// This procedure scans the "Document Source ID" field of each line. If more than one unique ID is found,
    /// true is returned, indicating that lines originate from different documents.
    /// </remarks>
    /// <param name="SourceDocumentLink">A record filter set for the lines to check.</param>
    /// <returns>True if multiple document sources exist; otherwise false.</returns>
    internal procedure HasDiffrentDocumentSource(var SourceDocumentLink: Record "TMAC Source Document Link"): Boolean
    var
        CurrentDocumentNo: Code[20];
    begin
        if SourceDocumentLink.FindFirst() then begin
            CurrentDocumentNo := SourceDocumentLink."Document Source ID";
            repeat
                if CurrentDocumentNo <> SourceDocumentLink."Document Source ID" then
                    exit(true);
            until SourceDocumentLink.Next() = 0;
        end;
    end;

    /// <summary>
    /// Checks if source document lines come from different locations.
    /// </summary>
    /// <remarks>
    /// Similar to HasDiffrentDocumentSource, but checks the "Location Code" field. Used to ensure lines do not mix
    /// from multiple locations when the unit type forbids that.
    /// </remarks>
    /// <param name="SourceDocumentLink">A record filter set for the lines to check.</param>
    /// <returns>True if multiple locations exist; otherwise false.</returns>
    internal procedure HasDifferentLocations(var SourceDocumentLink: Record "TMAC Source Document Link"): Boolean
    var
        CurrentLocationNo: Code[10];
    begin
        if SourceDocumentLink.FindFirst() then begin
            CurrentLocationNo := SourceDocumentLink."Location Code";
            repeat
                if CurrentLocationNo <> SourceDocumentLink."Location Code" then
                    exit(true);
            until SourceDocumentLink.Next() = 0;
        end;
    end;

    /// <summary>
    /// Automatically builds logistic units for the provided source document lines.
    /// </summary>
    /// <remarks>
    /// This procedure processes lines grouped by document (type, subtype, ID). It calls BuildLogisticUnitBySource
    /// to create new units or add to existing ones according to build rules.
    /// </remarks>
    /// <param name="SourceDocumentLink">Source lines from which to build logistic units.</param>
    /// <returns>A list of created logistic unit numbers.</returns>
    internal procedure AutoBuildLogisticUnits(var SourceDocumentLink: Record "TMAC Source Document Link"): List of [Code[20]]
    var
        //Unit: Record "TMAC Unit";
        CreatedUnits: List of [Code[20]];
        DocumentSourceType: Integer;
        DocumentSourceSubype: Integer;
        DocumentSourceID: code[20];
    //UnitNo: Code[20];
    begin
        DocumentSourceType := 0;
        DocumentSourceSubype := 0;
        DocumentSourceID := '';

        SourceDocumentLink.Reset();
        SourceDocumentLink.SetCurrentKey("Document Source Type", "Document Source SubType", "Document Source ID");
        if SourceDocumentLink.findfirst() then
            repeat
                if (DocumentSourceType <> SourceDocumentLink."Document Source Type") or
                   (DocumentSourceSubype <> SourceDocumentLink."Document Source SubType") or
                   (DocumentSourceID <> SourceDocumentLink."Document Source ID")
                then begin
                    Clear(CreatedUnits);
                    DocumentSourceType := SourceDocumentLink."Document Source Type";
                    DocumentSourceSubype := SourceDocumentLink."Document Source SubType";
                    DocumentSourceID := SourceDocumentLink."Document Source ID";
                end;
                SourceDocumentLink.Validate("Selected Quantity");
                BuildLogisticUnitBySource(CreatedUnits, SourceDocumentLink);
            until SourceDocumentLink.next() = 0;

        exit(CreatedUnits);
    end;

    /// <summary>
    /// Creates or updates logistic units based on the lines from one particular document source.
    /// </summary>
    /// <remarks>
    /// This helper routine is called by AutoBuildLogisticUnits as it iterates the source lines. It applies unit
    /// build rules to either create new logistic units or add items to existing ones.
    /// </remarks>
    /// <param name="CreatedUnits">A list of unit numbers that have been created or updated so far.</param>
    /// <param name="SourceDocumentLink">The specific line being processed.</param>
    local procedure BuildLogisticUnitBySource(var CreatedUnits: List of [Code[20]]; var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        Unit: Record "TMAC Unit";
        UnitBuildRuleLine: Record "TMAC Unit Build Rule";
        UnitManagement: Codeunit "TMAC Unit Management";
        Qty: Decimal;
        WeightPerUoM: Decimal;
        VolumePerUoM: Decimal;
        NoOfUnits: Integer;
        UnitNo: Code[20];
        LimitQty: Decimal;
        ItemQuantityInUnit: Decimal;
    begin
        Qty := SourceDocumentLink."Selected Quantity";
        WeightPerUoM := SourceDocumentLink."Weight (Base) per UoM";
        VolumePerUoM := SourceDocumentLink."Volume (Base) per UoM";

        UnitBuildRuleLine.Reset();
        UnitBuildRuleLine.SetCurrentKey("Unit Build Rule Code", "Type", "No.", "Variant Code", "Unit of Measure Code", "Priority");
        UnitBuildRuleLine.Setrange(Type, "TMAC Content Type"::Item);
        UnitBuildRuleLine.Setrange("No.", SourceDocumentLink."Item No.");
        UnitBuildRuleLine.SetRange("Variant Code", SourceDocumentLink."Variant Code");
        UnitBuildRuleLine.SetRange("Unit of Measure Code", SourceDocumentLink."Unit of Measure Code");
        UnitBuildRuleLine.SetFilter("Unit Type Code", '<>''''');
        UnitBuildRuleLine.SetRange(Blocked, false);
        if UnitBuildRuleLine.FindSet(false) then
            repeat
                if Qty > 0 then
                    case UnitBuildRuleLine."Build Action Type" of
                        "TMAC Build Action Type"::Create:
                            begin
                                //создание монопаллет
                                NoOfUnits := Qty DIV UnitBuildRuleLine."Split Qty.";
                                CreateLogisticUnits(CreatedUnits, NoOfUnits, UnitBuildRuleLine."Split Qty.", UnitBuildRuleLine."Unit Type Code", SourceDocumentLink);
                                Qty := Qty - NoOfUnits * UnitBuildRuleLine."Split Qty.";
                            end;
                        "TMAC Build Action Type"::"Add or Create":
                            begin
                                //ищем паллету с тем же товаром
                                foreach UnitNo in CreatedUnits do
                                    if Qty > 0 then begin
                                        Unit.Get(UnitNo);
                                        //if (Unit.State <> "TMAC Unit State"::"Packed") and (Unit."Type Code" = UnitBuildRuleLine."Unit Type Code") then begin
                                        if (Unit."Type Code" = UnitBuildRuleLine."Unit Type Code") then begin
                                            ItemQuantityInUnit := UnitManagement.GetItemQty(UnitNo, SourceDocumentLink."Item No.", SourceDocumentLink."Variant Code", SourceDocumentLink."Unit of Measure Code");
                                            if ItemQuantityInUnit > 0 then  //нашли LU с таким же типом и таким же товаром
                                                LimitQty := UnitBuildRuleLine."Split Qty." - ItemQuantityInUnit; //сколько можно положить

                                            if LimitQty > 0 then
                                                if LimitQty <= Qty then begin
                                                    UnitManagement.AddItemToLogisticUnit(UnitNo, LimitQty, SourceDocumentLink);
                                                    Qty := Qty - LimitQty;
                                                    //Unit.Validate(State, "TMAC Unit State"::Packed); //меняем статус если она стала полной
                                                    Unit.Modify(true);
                                                    UnitManagement.UpdateUnitWeightAndVolume(UnitNo, 0, 0, 0);
                                                end else begin
                                                    UnitManagement.AddItemToLogisticUnit(UnitNo, Qty, SourceDocumentLink);
                                                    Qty := 0;
                                                    UnitManagement.UpdateUnitWeightAndVolume(Unit."No.", 0, 0, 0);
                                                end;
                                        end;
                                    end;

                                //остаток запихивавем в отдельную паллету или в микс если можно
                                if (Qty > 0) and (UnitBuildRuleLine."Remains can be mixed") then
                                    foreach UnitNo in CreatedUnits do
                                        if Qty > 0 then begin
                                            Unit.Get(UnitNo);
                                            //if (Unit.State <> "TMAC Unit State"::"Packed") and (Unit."Type Code" = UnitBuildRuleLine."Unit Type Code") then begin
                                            if Unit."Type Code" = UnitBuildRuleLine."Unit Type Code" then begin

                                                LimitQty := UnitManagement.GetQtyLimitToAdd(Unit, WeightPerUoM, VolumePerUoM);
                                                if LimitQty > 0 then
                                                    if LimitQty <= Qty then begin
                                                        UnitManagement.AddItemToLogisticUnit(Unit."No.", LimitQty, SourceDocumentLink);
                                                        Qty := Qty - LimitQty;
                                                        //закрываем паллету т.к. она уперлась в ограничения
                                                        //Unit.Validate(State, "TMAC Unit State"::Packed);
                                                        Unit.Modify(true);
                                                        UnitManagement.UpdateUnitWeightAndVolume(Unit."No.", 0, 0, 0);
                                                    end else begin
                                                        UnitManagement.AddItemToLogisticUnit(Unit."No.", Qty, SourceDocumentLink);
                                                        Qty := 0;
                                                        UnitManagement.UpdateUnitWeightAndVolume(Unit."No.", 0, 0, 0);
                                                    end;
                                            end;
                                        end;

                                if (Qty > 0) then begin
                                    UnitNo := UnitManagement.CreateLogisticUnit(UnitBuildRuleLine."Unit Type Code");
                                    UnitManagement.AddItemToLogisticUnit(UnitNo, Qty, SourceDocumentLink);
                                    Unit.Reset();
                                    Unit.Get(UnitNo);
                                    Unit.Validate("Location Code", SourceDocumentLink."Location Code");
                                    //Unit.Validate(State, "TMAC Unit State"::"Partially filled");
                                    Unit.Modify(true);

                                    if not CreatedUnits.Contains(UnitNo) then
                                        CreatedUnits.Add(UnitNo);

                                    UnitManagement.UpdateUnitWeightAndVolume(UnitNo, 0, 0, 0);
                                    Qty := 0;
                                end;
                            end;
                    end;
            until UnitBuildRuleLine.Next() = 0;
    end;

    /// <summary>
    /// Creates multiple logistic units of a specified type and fills each with a given quantity from source lines.
    /// </summary>
    /// <remarks>
    /// Used when a rule demands a fixed split quantity. Repeats creation of blank units, then adds the item lines.
    /// </remarks>
    /// <param name="Units">Maintains a list of all newly created units.</param>
    /// <param name="UnitQty">How many units to create.</param>
    /// <param name="LineQty">The quantity of items to place into each unit.</param>
    /// <param name="UnitTypeCode">Which unit type to create.</param>
    /// <param name="SourceDocumentLink">Reference to the lines to be added into these units.</param>
    internal procedure CreateLogisticUnits(var Units: List of [Code[20]]; UnitQty: Integer; LineQty: Decimal; UnitTypeCode: Code[20]; var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        Unit: Record "TMAC Unit";
        UnitManagement: Codeunit "TMAC Unit Management";
        UnitNo: Code[20];
        i: Integer;
    begin
        if UnitQty = 0 then
            exit;

        For i := 1 TO UnitQty DO begin
            UnitNo := UnitManagement.CreateLogisticUnit(UnitTypeCode);
            UnitManagement.AddItemToLogisticUnit(UnitNo, LineQty, SourceDocumentLink);
            Unit.Get(UnitNo);
            Unit.Validate("Location Code", SourceDocumentLink."Location Code");
            Unit.Modify(true);
            UnitManagement.UpdateUnitWeightAndVolume(UnitNo, 0, 0, 0);

            if not Units.Contains(UnitNo) then
                Units.Add(UnitNo);
        end;
    end;


    /// <summary>
    /// Estimates the number of logistic units needed for the given source lines.
    /// </summary>
    /// <remarks>
    /// This procedure loops all source lines, calling EstimateNumberLogisticUnitLine for each. It is used to
    /// pre-calculate how many units may be required.
    /// </remarks>
    /// <param name="SourceDocumentLink">Source lines to estimate for.</param>
    procedure EstimateNumberLogisticUnit(var SourceDocumentLink: Record "TMAC Source Document Link")
    begin
        SourceDocumentLink.Reset();
        SourceDocumentLink.SetCurrentKey("Document Source Type", "Document Source SubType", "Document Source ID");
        if SourceDocumentLink.findfirst() then
            repeat
                EstimateNumberLogisticUnitLine(SourceDocumentLink);
            until SourceDocumentLink.next() = 0;
    end;

    /// <summary>
    /// Estimates logistic units needed for a single line from the source document.
    /// </summary>
    /// <remarks>
    /// This procedure checks the item quantity, finds relevant unit build rules, and calculates how many units
    /// or partial units to create. It can handle splitting, mixing, or partial forming.
    /// </remarks>
    /// <param name="SourceDocumentLink">A single source line for which to do the estimate.</param>
    local procedure EstimateNumberLogisticUnitLine(var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        UnitBuildRuleLine: Record "TMAC Unit Build Rule";

        Qty: Decimal;
        NoOfUnits: Integer;
    begin
        Qty := SourceDocumentLink."Selected Quantity";

        UnitBuildRuleLine.Reset();
        UnitBuildRuleLine.SetCurrentKey("Unit Build Rule Code", "Type", "No.", "Variant Code", "Unit of Measure Code", "Priority");
        UnitBuildRuleLine.Setrange(Type, "TMAC Content Type"::Item);
        UnitBuildRuleLine.Setrange("No.", SourceDocumentLink."Item No.");
        UnitBuildRuleLine.SetRange("Variant Code", SourceDocumentLink."Variant Code");
        UnitBuildRuleLine.SetRange("Unit of Measure Code", SourceDocumentLink."Unit of Measure Code");
        UnitBuildRuleLine.SetFilter("Unit Type Code", '<>''''');
        UnitBuildRuleLine.SetRange(Blocked, false);
        if UnitBuildRuleLine.FindSet(false) then
            repeat
                if Qty > 0 then
                    case UnitBuildRuleLine."Build Action Type" of
                        //Create - Caption
                        "TMAC Build Action Type"::Create:
                            begin
                                //создание монопаллет!!!!
                                NoOfUnits := Qty DIV UnitBuildRuleLine."Split Qty.";
                                if NoOfUnits > 0 then begin
                                    CreateMonoEstimatedUnit(SourceDocumentLink, NoOfUnits, UnitBuildRuleLine."Unit Type Code", UnitBuildRuleLine."Split Qty.", "TMAC Completion Status"::"Fully Formed");
                                    Qty := Qty - NoOfUnits * UnitBuildRuleLine."Split Qty.";
                                end;
                            end;
                        //Add to Mono - Caption
                        "TMAC Build Action Type"::"Add or Create":
                            //сколько можно сначала кладем в паллету с темже товаром но не больше UnitBuildRuleLine."Split Qty."
                            Qty := AddToSame(SourceDocumentLink, UnitBuildRuleLine."Unit Type Code", Qty, UnitBuildRuleLine."Split Qty.");
                        //Add to Mix
                        "TMAC Build Action Type"::"Add to Mix":
                            Qty := AddToMix(SourceDocumentLink, UnitBuildRuleLine."Unit Type Code", Qty);
                        //Create to Mix
                        "TMAC Build Action Type"::"Create Mix":
                            CreateMonoEstimatedUnit(SourceDocumentLink, 1, UnitBuildRuleLine."Unit Type Code", Qty, "TMAC Completion Status"::"Partially Formed");
                    end;
            until UnitBuildRuleLine.Next() = 0;
    end;



    /// <summary>
    /// Creates an estimated unit record for a single item that fills or partially fills the logistic unit.
    /// </summary>
    /// <remarks>
    /// This function builds temporary ("TMAC Estimated Unit") records, used to plan how many units are required.
    /// It is used by the EstimateNumberLogisticUnitLine routine.
    /// </remarks>
    /// <param name="SourceDocumentLink">The item lines to place into the newly created estimated unit.</param>
    /// <param name="NoOfUnits">How many units to create at once.</param>
    /// <param name="UnitTypeCode">Which unit type to simulate.</param>
    /// <param name="ItemQuantity">How many items to put in each unit.</param>
    /// <param name="CompletionStatus">Indicates whether the newly created units are fully formed or partially.
    /// </param>
    local procedure CreateMonoEstimatedUnit(var SourceDocumentLink: Record "TMAC Source Document Link"; NoOfUnits: Integer; UnitTypeCode: Code[20]; ItemQuantity: Decimal; CompletionStatus: Enum "TMAC Completion Status")
    var
        UnitType: Record "TMAC Unit Type";
        EstimatedUnit: record "TMAC Estimated Unit";
        EstimatedUnitLine: Record "TMAC Estimated Unit Line";
        i: Integer;
        UnitNo: Integer;
    begin
        UnitNo := 0;
        EstimatedUnit.Init();
        EstimatedUnit.SetRange("Source Type", SourceDocumentLink."Source Type");
        EstimatedUnit.SetRange("Source Subtype", SourceDocumentLink."Source Subtype");
        EstimatedUnit.SetRange("Source ID", SourceDocumentLink."Source ID");
        if EstimatedUnit.FindLast() then
            UnitNo := EstimatedUnit."No.";


        UnitType.Get(UnitTypeCode);
        For i := 1 TO NoOfUnits DO begin
            UnitNo += 1;
            EstimatedUnit.Init();
            EstimatedUnit."Source Type" := SourceDocumentLink."Source Type";
            EstimatedUnit."Source Subtype" := SourceDocumentLink."Source Subtype";
            EstimatedUnit."Source ID" := SourceDocumentLink."Source ID";
            EstimatedUnit."No." := UnitNo;
            EstimatedUnit."Type Code" := UnitTypeCode;
            EstimatedUnit."Type Description" := UnitType.Description;
            EstimatedUnit."Type Weight Limit" := UnitType."Limit Filling Weight";
            EstimatedUnit."Type Volume Limit" := UnitType."Limit Filling Volume";
            EstimatedUnit."Completion Status" := CompletionStatus;
            EstimatedUnit.Insert(true);

            EstimatedUnitLine.Init();
            EstimatedUnitLine."Source Type" := SourceDocumentLink."Source Type";
            EstimatedUnitLine."Source Subtype" := SourceDocumentLink."Source Subtype";
            EstimatedUnitLine."Source ID" := SourceDocumentLink."Source ID";
            EstimatedUnitLine."Unit No." := EstimatedUnit."No.";
            EstimatedUnitLine."Line No." := 10000;
            EstimatedUnitLine."Type" := "TMAC Unit Line Type"::Item;
            EstimatedUnitLine."No." := SourceDocumentLink."Item No.";
            EstimatedUnitLine."Variant Code" := SourceDocumentLink."Variant Code";
            EstimatedUnitLine.Description := SourceDocumentLink.Description;
            EstimatedUnitLine.Quantity := ItemQuantity;
            EstimatedUnitLine."Unit of Measure Code" := SourceDocumentLink."Unit of Measure Code";
            EstimatedUnitLine."Weight (base)" := ItemQuantity * SourceDocumentLink."Weight (Base) per UoM";
            EstimatedUnitLine."Volume (base)" := ItemQuantity * SourceDocumentLink."Volume (Base) per UoM";
            EstimatedUnitLine.Insert(true);
        end;
    end;

    /// <summary>
    /// Adds items to an existing estimated unit that already contains the same item, if space is available.
    /// </summary>
    /// <remarks>
    /// For example, if a rule-based story indicates a certain maximum quantity per unit, this function attempts
    /// to fill that capacity for the item.
    /// </remarks>
    /// <param name="SourceDocumentLink">The source lines referencing item, variant, UoM to place in the unit.</param>
    /// <param name="UnitTypeCode">Which unit type we are adding to.</param>
    /// <param name="Qty">The item quantity left to place in the existing units.</param>
    /// <param name="RuleLimit">The maximum item quantity allowed per unit, if any.</param>
    /// <returns>The quantity still remaining after attempting to fill the existing units.</returns>
    local procedure AddToSame(var SourceDocumentLink: Record "TMAC Source Document Link"; UnitTypeCode: Code[20]; Qty: Decimal; RuleLimit: Decimal) RemainingQty: Decimal
    var
        UnitType: Record "TMAC Unit Type";
        EstimatedUnit: record "TMAC Estimated Unit";
        EstimatedUnitLine: Record "TMAC Estimated Unit Line";
        CanBePlacedQty1: Decimal;
        LineNo: Integer;
        MaxByRuleQty: Decimal;
    begin
        RemainingQty := Qty;
        UnitType.Get(UnitTypeCode);

        EstimatedUnit.Reset();
        EstimatedUnit.SetRange("Source Type", SourceDocumentLink."Source Type");
        EstimatedUnit.SetRange("Source Subtype", SourceDocumentLink."Source Subtype");
        EstimatedUnit.SetRange("Source ID", SourceDocumentLink."Source ID");
        EstimatedUnit.SetRange("Completion Status", "TMAC Completion Status"::Empty, "TMAC Completion Status"::"Partially Formed");
        EstimatedUnit.SetRange("Type Code", UnitTypeCode);
        EstimatedUnit.SetAutoCalcFields("Weight (Base)", "Volume (Base)");
        if EstimatedUnit.FindSet() then
            repeat
                if RemainingQty > 0 then begin
                    //определяем сколько можно положить с учетом огранчений по логистическим едиинцам
                    CanBePlacedQty1 := CanBePlacedQty(RemainingQty, UnitType, EstimatedUnit, SourceDocumentLink);

                    if RuleLimit > 0 then begin
                        EstimatedUnitLine.Reset();
                        EstimatedUnitLine.SetRange("Source Type", SourceDocumentLink."Source Type");
                        EstimatedUnitLine.SetRange("Source Subtype", SourceDocumentLink."Source Subtype");
                        EstimatedUnitLine.SetRange("Source ID", SourceDocumentLink."Source ID");
                        EstimatedUnitLine.Setrange("Unit No.", EstimatedUnit."No.");
                        EstimatedUnitLine.Setrange("Type", "TMAC Unit Line Type"::Item);
                        EstimatedUnitLine.Setrange("No.", SourceDocumentLink."Item No.");
                        EstimatedUnitLine.CalcSums(Quantity);
                        MaxByRuleQty := RuleLimit - EstimatedUnitLine.Quantity;
                        if MaxByRuleQty < CanBePlacedQty1 then
                            CanBePlacedQty1 := MaxByRuleQty;
                    end;

                    //паллета с таким же товаром
                    EstimatedUnitLine.Reset();
                    EstimatedUnitLine.SetRange("Source Type", SourceDocumentLink."Source Type");
                    EstimatedUnitLine.SetRange("Source Subtype", SourceDocumentLink."Source Subtype");
                    EstimatedUnitLine.SetRange("Source ID", SourceDocumentLink."Source ID");
                    EstimatedUnitLine.Setrange("Unit No.", EstimatedUnit."No.");
                    EstimatedUnitLine.Setrange("Type", "TMAC Unit Line Type"::Item);
                    EstimatedUnitLine.Setrange("No.", SourceDocumentLink."Item No.");
                    if not EstimatedUnitLine.IsEmpty() then begin
                        //кладем
                        LineNo := 10000;
                        EstimatedUnitLine.Reset();
                        EstimatedUnitLine.SetRange("Source Type", SourceDocumentLink."Source Type");
                        EstimatedUnitLine.SetRange("Source Subtype", SourceDocumentLink."Source Subtype");
                        EstimatedUnitLine.SetRange("Source ID", SourceDocumentLink."Source ID");
                        EstimatedUnitLine.Setrange("Unit No.", EstimatedUnit."No.");
                        if EstimatedUnitLine.FindLast() then
                            LineNo := EstimatedUnitLine."Line No." + 10000;

                        EstimatedUnitLine.Reset();
                        EstimatedUnitLine.Init();
                        EstimatedUnitLine."Source Type" := SourceDocumentLink."Source Type";
                        EstimatedUnitLine."Source Subtype" := SourceDocumentLink."Source Subtype";
                        EstimatedUnitLine."Source ID" := SourceDocumentLink."Source ID";
                        EstimatedUnitLine."Unit No." := EstimatedUnit."No.";
                        EstimatedUnitLine."Line No." := LineNo;
                        EstimatedUnitLine."Type" := "TMAC Unit Line Type"::Item;
                        EstimatedUnitLine."No." := SourceDocumentLink."Item No.";
                        EstimatedUnitLine."Variant Code" := SourceDocumentLink."Variant Code";
                        EstimatedUnitLine.Description := SourceDocumentLink.Description;
                        EstimatedUnitLine.Quantity := CanBePlacedQty1;
                        EstimatedUnitLine."Unit of Measure Code" := SourceDocumentLink."Unit of Measure Code";
                        EstimatedUnitLine."Weight (base)" := CanBePlacedQty1 * SourceDocumentLink."Weight (Base) per UoM";
                        EstimatedUnitLine."Volume (base)" := CanBePlacedQty1 * SourceDocumentLink."Volume (Base) per UoM";
                        EstimatedUnitLine.Insert(true);
                        RemainingQty := RemainingQty - CanBePlacedQty1;
                    end;
                end;
            until EstimatedUnit.Next() = 0;
    end;

    /// <summary>
    /// Attempts to mix item lines into any existing partially used units.
    /// </summary>
    /// <remarks>
    /// This function differs from AddToSame in that it does not require the unit to contain the same item.
    /// It's used when the rule allows mixing multiple items on the same logistic unit.
    /// </remarks>
    /// <param name="SourceDocumentLink">The source lines referencing item data to be placed.</param>
    /// <param name="UnitTypeCode">Which type of unit we might fill.
    /// Additional checks ensure capacity is not exceeded.
    /// </param>
    /// <param name="Qty">The item quantity left to place in existing units.</param>
    /// <returns>The quantity that remains unplaced after filling possible units.</returns>
    local procedure AddToMix(var SourceDocumentLink: Record "TMAC Source Document Link"; UnitTypeCode: Code[20]; Qty: Decimal) RemainingQty: Decimal
    var
        UnitType: Record "TMAC Unit Type";
        EstimatedUnit: record "TMAC Estimated Unit";
        EstimatedUnitLine: Record "TMAC Estimated Unit Line";
        CanBePlacedQty1: Decimal;
        LineNo: Integer;

    begin
        RemainingQty := Qty;
        UnitType.Get(UnitTypeCode);

        //в паллета c любым товаром
        EstimatedUnit.Reset();
        EstimatedUnit.SetRange("Source Type", SourceDocumentLink."Source Type");
        EstimatedUnit.SetRange("Source Subtype", SourceDocumentLink."Source Subtype");
        EstimatedUnit.SetRange("Source ID", SourceDocumentLink."Source ID");
        EstimatedUnit.SetRange("Completion Status", "TMAC Completion Status"::Empty, "TMAC Completion Status"::"Partially Formed");
        EstimatedUnit.SetRange("Type Code", UnitTypeCode);
        EstimatedUnit.SetAutoCalcFields("Weight (Base)", "Volume (Base)");
        if EstimatedUnit.FindSet() then
            repeat
                if RemainingQty > 0 then begin
                    //определяем сколько можно положить с учетом огранчений по логистическим едиинцам
                    CanBePlacedQty1 := CanBePlacedQty(RemainingQty, UnitType, EstimatedUnit, SourceDocumentLink);

                    LineNo := 10000;
                    EstimatedUnitLine.Reset();
                    EstimatedUnitLine.SetRange("Source Type", SourceDocumentLink."Source Type");
                    EstimatedUnitLine.SetRange("Source Subtype", SourceDocumentLink."Source Subtype");
                    EstimatedUnitLine.SetRange("Source ID", SourceDocumentLink."Source ID");
                    EstimatedUnitLine.Setrange("Unit No.", EstimatedUnit."No.");
                    if EstimatedUnitLine.FindLast() then
                        LineNo := EstimatedUnitLine."Line No." + 10000;

                    EstimatedUnitLine.Reset();
                    EstimatedUnitLine.Init();
                    EstimatedUnitLine."Source Type" := SourceDocumentLink."Source Type";
                    EstimatedUnitLine."Source Subtype" := SourceDocumentLink."Source Subtype";
                    EstimatedUnitLine."Source ID" := SourceDocumentLink."Source ID";
                    EstimatedUnitLine."Unit No." := EstimatedUnit."No.";
                    EstimatedUnitLine."Line No." := LineNo;
                    EstimatedUnitLine."Type" := "TMAC Unit Line Type"::Item;
                    EstimatedUnitLine."No." := SourceDocumentLink."Item No.";
                    EstimatedUnitLine."Variant Code" := SourceDocumentLink."Variant Code";
                    EstimatedUnitLine.Description := SourceDocumentLink.Description;
                    EstimatedUnitLine.Quantity := CanBePlacedQty1;
                    EstimatedUnitLine."Unit of Measure Code" := SourceDocumentLink."Unit of Measure Code";
                    EstimatedUnitLine."Weight (base)" := CanBePlacedQty1 * SourceDocumentLink."Weight (Base) per UoM";
                    EstimatedUnitLine."Volume (base)" := CanBePlacedQty1 * SourceDocumentLink."Volume (Base) per UoM";
                    EstimatedUnitLine.Insert(true);
                    RemainingQty := RemainingQty - CanBePlacedQty1;
                end;
            until EstimatedUnit.Next() = 0;
    end;

    /// <summary>
    /// Calculates how many items can still be placed in a partially filled or empty logistic unit.
    /// </summary>
    /// <remarks>
    /// This routine checks weight and volume limits based on the item data from SourceDocumentLink,
    /// returning whichever is more restrictive.
    /// </remarks>
    /// <param name="PlaceQty">The total number of items we want to place.</param>
    /// <param name="UnitType">A record referencing the logistic unit type, which may have weight/volume controls.</param>
    /// <param name="EstimatedUnit">A partially or empty unit to see how many items it can still accept.</param>
    /// <param name="SourceDocumentLink">The item details, such as weight and volume per unit.
    /// </param>
    /// <returns>The maximum quantity that can be placed without exceeding the unit's constraints.</returns>
    local procedure CanBePlacedQty(PlaceQty: decimal; var UnitType: Record "TMAC Unit Type"; var EstimatedUnit: record "TMAC Estimated Unit"; var SourceDocumentLink: Record "TMAC Source Document Link") returnvalue: Decimal
    var
        MaxQtyByWeight: Decimal;
        MaxQtyByVolume: Decimal;
    begin
        //определяем сколько можно положить с учетом огранчений по логистическим едиинцам
        MaxQtyByWeight := PlaceQty; //хотим положить все
        if UnitType."Limit Filling Weight Control" then
            if SourceDocumentLink."Weight (Base) per UoM" <> 0 then
                MaxQtyByWeight := Round(UnitType."Limit Filling Weight" - EstimatedUnit."Weight (Base)" / SourceDocumentLink."Weight (Base) per UoM");

        //определяем сколько можно полоить исходя из объема
        MaxQtyByVolume := PlaceQty; //хотим положить все
        if UnitType."Limit Filling Volume Control" then
            if SourceDocumentLink."Volume (Base) per UoM" <> 0 then
                MaxQtyByVolume := Round(UnitType."Limit Filling Volume" - EstimatedUnit."Volume (Base)" / SourceDocumentLink."Volume (Base) per UoM");

        // итого сколько можем положить     
        if MaxQtyByVolume < MaxQtyByWeight then
            returnvalue := MaxQtyByVolume
        else
            returnvalue := MaxQtyByWeight;
    end;

    /// <summary>
    /// Returns the default volume for an item given its unit of measure.
    /// </summary>
    /// <remarks>
    /// Looks up the "Item" record for an assigned Unit Volume, or checks the "Item Unit of Measure".
    /// Used by build logic to guess how much volume the item occupies.
    /// </remarks>
    /// <param name="ItemNo">Which item is in question.</param>
    /// <param name="UnitOfMeasureCode">Specifies the measure used for the item.</param>
    /// <returns>The default volume for that item in that measure, or zero if not defined.</returns>
    internal procedure GetItemVolume(ItemNo: Code[20]; UnitOfMeasureCode: Code[10]): Decimal
    var
        Item: Record Item;
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        if Item.Get(ItemNo) then
            if Item."Unit Volume" <> 0 then
                exit(Item."Unit Volume");

        if ItemUnitOfMeasure.Get(ItemNo, UnitOfMeasureCode) then
            exit(ItemUnitOfMeasure.Cubage);

        exit(0);
    end;
    /// <summary>
    /// Returns the default gross weight for an item given its unit of measure.
    /// </summary>
    /// <remarks>
    /// Looks up the "Item" record for a Gross Weight, or checks "Item Unit of Measure".
    /// Used by build logic to guess the item’s total weight.
    /// </remarks>
    /// <param name="ItemNo">Which item is in question.</param>
    /// <param name="UnitOfMeasureCode">Specifies the measure used for the item.</param>
    /// <returns>The gross weight for that item in that measure, or zero if not defined.</returns>
    internal procedure GetItemGrossWeight(ItemNo: Code[20]; UnitOfMeasureCode: Code[10]): Decimal
    var
        Item: Record Item;
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        if Item.Get(ItemNo) then
            if Item."Gross Weight" <> 0 then
                exit(Item."Gross Weight");

        if ItemUnitOfMeasure.Get(ItemNo, UnitOfMeasureCode) then
            exit(ItemUnitOfMeasure.Weight);
        exit(0);
    end;

    var
        MixSourceDocumentErr: Label 'Unit Type %1 does not allow to mix source documents for the content. Select lines for one Source Document.', Comment = '%1 is Unit Type';
        MixLocationsErr: Label 'Unit Type %1 does not allow to mix location codes for the content. Select lines for one Source Document.', Comment = '%1 is Unit Type';

}
