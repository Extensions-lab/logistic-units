/// <summary>
/// Manages logistic units, including creation, archiving, and linking content.
/// </summary>
/// <remarks>
/// Provides methods to create, archive, and manipulate logistic units (LM) in the TMS.
/// </remarks>
codeunit 71628579 "TMAC Unit Management"
{
    /// <summary>
    /// Archives the specified logistic unit.
    /// </summary>
    /// <remarks>
    /// Checks if the unit or any nested units link to unposted documents, disallows archiving if so.
    /// If archived, the unit is either removed if non-reusable, or reset if reusable.
    /// </remarks>
    /// <param name="Unit">Reference to the logistic unit record to archive.</param>
    /// <returns>Integer representing any relevant version or zero if canceled.</returns>
    procedure ArchiveUnit(var Unit: Record "TMAC Unit"): Integer
    begin
        //eсли по паллете есть неучт. документы то ее учитывать нельзя тк какойто процесс не завершен
        //проверяет и все вложенные паллеты
        CheckUnit(Unit."No.");

        //если единиц включена во другую единицу то учитывать можно только ту
        if Unit."Parent Unit No." <> '' then
            Error(LogisticUnitIncludedErr, Unit."Parent Unit No.");

        if not Confirm(StrSubstNo(PostConfirmQst, Unit."No.")) then
            exit;

        ArchiveImpl(Unit, 0);
    end;

    /// <summary>
    /// Performs the core archiving work, including nested child units.
    /// </summary>
    /// <remarks>
    /// This local function creates a posted version copy of each child, copying all lines and links,
    /// then deletes original records if the unit is not reusable.
    /// </remarks>
    /// <param name="Unit">The logistic unit record to archive.</param>
    /// <param name="ParentPostedVersion">Indicates the posted version of the parent, if any.</param>
    /// <returns>The newly assigned posted version for this unit.</returns>
    local procedure ArchiveImpl(var Unit: Record "TMAC Unit"; ParentPostedVersion: Integer) ArchiveVersion: Integer
    var
        UnitAction: Record "TMAC Unit Action";
        UnitLine: Record "TMAC Unit Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        UnitEntry: Record "TMAC Unit Entry";
        PostedUnit: Record "TMAC Posted Unit";
        PostedUnitLine: Record "TMAC Posted Unit Line";
        PostedUnitLineLink: Record "TMAC Posted Unit Line Link";
        PostedUnitEntry: Record "TMAC Posted Unit Entry";
        InnerUnit: Record "TMAC Unit";
    begin
        ArchiveVersion := 1;

        PostedUnit.Reset();
        PostedUnit.SetRange("No.", Unit."No.");
        if PostedUnit.FindLast() then
            ArchiveVersion := PostedUnit."Posted Version" + 1;

        PostedUnit.Init();
        PostedUnit.TransferFields(Unit);
        PostedUnit.Validate("Posted Version", ArchiveVersion);
        PostedUnit.Validate("Parent Unit Posted Version", ParentPostedVersion);
        PostedUnit.Insert(true);

        PostedUnit.CopyLinks(Unit);

        //Copying lines 
        UnitLine.Reset();
        UnitLine.SetRange("Unit No.", Unit."No.");
        if UnitLine.FindSet(false) then
            repeat
                PostedUnitLine.Init();
                PostedUnitLine.TransferFields(UnitLine);
                PostedUnitLine.Validate("Posted Version", ArchiveVersion);
                PostedUnitLine."Posted Unit System ID" := PostedUnit.SystemId;
                PostedUnitLine.Insert(true);
                if UnitLine."Type" = "TMAC Unit Line Type"::Unit then begin //archiving nested units

                    InnerUnit.Get(UnitLine."No.");
                    ArchiveImpl(InnerUnit, ArchiveVersion);
                end
            until UnitLine.Next() = 0;

        //copying links to documents
        UnitLineLink.Reset();
        UnitLineLink.SetRange("Unit No.", Unit."No.");
        if UnitLineLink.FindSet(false) then
            repeat
                PostedUnitLineLink.Init();
                PostedUnitLineLink.TransferFields(UnitLineLink);
                PostedUnitLineLink.Validate("Posted Version", ArchiveVersion);
                PostedUnitLineLink.Insert(true);
            until UnitLineLink.Next() = 0;

        //adding an event to the log about archiving
        UnitAction.SetRange(Archive, true);
        if UnitAction.FindFirst() then
            CreateUnitEntry(Unit."No.", UnitAction.Code);

        UnitEntry.Reset();
        UnitEntry.SetRange("Unit No.", Unit."No.");
        if UnitEntry.FindSet(false) then
            repeat
                PostedUnitEntry.Init();
                PostedUnitEntry.TransferFields(UnitEntry);
                PostedUnitEntry.Validate("Posted Version", ArchiveVersion);
                PostedUnitEntry.Insert(true);
            until UnitEntry.Next() = 0;


        UnitEntry.DeleteAll(true);

        UnitLine.DeleteAll(true); //will also delete the links

        if Unit."Reusable" then begin
            Unit."Weight (Base)" := 0;
            Unit."Volume (Base)" := 0;
            Unit.Modify(true);
        end else begin
            Unit.Find('=');
            Unit.Delete(true);
        end;
    end;

    /// <summary>
    /// Checks if the specified logistic unit or nested child units are linked to any unposted documents.
    /// </summary>
    /// <remarks>
    /// Raises an error if a link to an unposted document is found, disallowing archiving.
    /// Called recursively for each nested logistic unit.
    /// </remarks>
    /// <param name="UnitCode">The number of the logistic unit to verify.</param>
    local procedure CheckUnit(UnitCode: Code[20])
    var
        UnitLine: Record "TMAC Unit Line";
        UnitLineLink: Record "TMAC Unit Line Link";
    begin
        UnitLine.Reset();
        UnitLine.SetRange("Unit No.", UnitCode);
        if UnitLine.FindSet(false) then
            repeat
                UnitLineLink.Reset();
                UnitLineLink.SetRange("Unit No.", UnitLine."Unit No.");
                UnitLineLink.SetRange("Unit Line No.", UnitLine."Line No.");
                UnitLineLink.SetFilter("Source Type", '%1|%2|%3|%4|%5|%6',
                    Database::"Purchase Line",
                    Database::"Sales Line",
                    Database::"Transfer Line",
                    Database::"Warehouse Receipt Line",
                    Database::"Warehouse Shipment Line",
                    Database::"Warehouse Activity Line");
                UnitLineLink.SetLoadFields("Source ID");
                if UnitLineLink.FindFirst() then
                    error(DocumentExistedErr, UnitLineLink."Source ID");

                if UnitLine."Type" = "TMAC Unit Line Type"::Unit then
                    CheckUnit(UnitLine."No.");
            until UnitLine.Next() = 0;
    end;

    /// <summary>
    /// Creates a logistic unit of the specified type.
    /// </summary>
    /// <remarks>
    /// Used externally to quickly create a new unit with a given type code, returning its assigned number.
    /// </remarks>
    /// <param name="UnitTypeCode">Specifies which logistic unit type to create.</param>
    /// <returns>The newly created logistic unit number.</returns>
    procedure CreateLogisticUnit(UnitTypeCode: Code[20]) UnitNo: Code[20]
    begin
        UnitNo := CreateUnitByType(UnitTypeCode, '');
    end;

    /// <summary>
    /// Creates a logistic unit by type with an optional description.
    /// </summary>
    /// <remarks>
    /// Internally called. Initializes the unit record, assigns the type code, and inserts it.
    /// </remarks>
    /// <param name="UnitTypeCode">Specifies the type of logistic unit to create.</param>
    /// <param name="Description">Optional descriptive text for the new unit.</param>
    /// <returns>The newly assigned unit number.</returns>
    procedure CreateUnitByType(UnitTypeCode: Code[20]; Description: Text[100]): Code[20]
    var
        Unit: Record "TMAC Unit";
    begin
        Unit.Init();
        Unit."No." := '';
        Unit."Type Code" := UnitTypeCode;
        Unit.Description := Description;
        Unit.Insert(true);
        exit(Unit."No.");
    end;

    /// <summary>
    /// Includes an existing logistic unit within another logistic unit's structure.
    /// </summary>
    /// <remarks>
    /// Typically called from triggers. It sets the parent-child relationship by updating parent references.
    /// Throws an error if the unit is already included in another.
    /// </remarks>
    /// <param name="UnitNo">The logistic unit number being included.</param>
    /// <param name="ToUnitNo">The parent logistic unit number to include into.</param>
    /// <param name="UnitLineNo">The line number referencing the parent-child relationship.
    /// Normally assigned in the parent unit lines.
    /// </param>
    internal procedure Include(UnitNo: Code[20]; ToUnitNo: Code[20]; UnitLineNo: Integer)
    var
        Unit: Record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
        ParentUnit: Record "TMAC Unit";
    begin
        if (UnitNo = '') or (ToUnitNo = '') or (UnitLineNo = 0) then
            exit;

        if UnitNo = ToUnitNo then
            exit;

        Unit.Get(UnitNo);
        ParentUnit.Get(ToUnitNo);

        //searching for the pallet being added inside the one we’re adding to
        UnitLine.Reset();
        UnitLIne.SetCurrentKey("Type", "No.");
        UnitLine.SetRange("Unit No.", ToUnitNo);
        UnitLine.SetRange(Type, UnitLine.Type::Unit);
        UnitLine.SetRange("No.", UnitNo);
        UnitLine.SetFilter("Line No.", '<>%1', UnitLineNo); //перевыбрать паллету можно
        UnitLine.SetLoadFields("Unit No.");
        if UnitLine.FindFirst() then
            Error(LogisticUnitAlreadyIncludedErr, UnitNo, UnitLine."Unit No.");

        //checking whether the pallet is inside another one
        UnitLine.Reset();
        UnitLIne.SetCurrentKey("Type", "No.");
        UnitLine.SetFilter("Unit No.", '<>%1', ToUnitNo);
        UnitLine.SetRange(Type, UnitLine.Type::Unit);
        UnitLine.SetRange("No.", UnitNo);
        UnitLine.SetLoadFields("Unit No.");
        if UnitLine.FindFirst() then
            Error(LogisticUnitAlreadyIncludedErr, UnitNo, UnitLine."Unit No.");

        SetParentAndIndent(Unit, ToUnitNo, ParentUnit.Indent + 1);
    end;

    /// <summary>
    /// Sets or updates the parent unit and indent level for a logistic unit recursively.
    /// </summary>
    /// <remarks>
    /// This local procedure is used to maintain hierarchical nesting of logistic units, updating each child's indent.
    /// </remarks>
    /// <param name="Unit">The child logistic unit record to update.</param>
    /// <param name="ParentUnitNo">The parent's logistic unit number ("Parent Unit No.").</param>
    /// <param name="Indent">The new indent level for this child. Child-of-child will increment further.
    /// </param>
    local procedure SetParentAndIndent(var Unit: Record "TMAC Unit"; ParentUnitNo: Code[20]; Indent: Integer)
    var
        InnerUnit: record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
    begin
        if Unit."Parent Unit No." <> ParentUnitNo then
            Unit."Parent Unit No." := ParentUnitNo;
        Unit.Indent := Indent;
        Unit.Modify(false);

        //all nested pallets in the one we are including need to have their Indent shifted
        UnitLine.Reset();
        UnitLine.SetRange("Unit No.", Unit."No.");
        UnitLine.SetRange(Type, UnitLine.Type::Unit);
        UnitLine.SetLoadFields("No.");
        if UnitLine.Findset(false) then
            repeat
                InnerUnit.Get(UnitLine."No.");
                SetParentAndIndent(InnerUnit, UnitLine."Unit No.", Indent + 1);
            until UnitLine.Next() = 0;
    end;

    /// <summary>
    /// Includes one logistic unit into another by creating a line that references the child.
    /// </summary>
    /// <remarks>
    /// Used for parent-child associations. Updates the child unit's Parent Unit No. and Indent.
    /// Inserts a new line in the parent referencing the child.
    /// </remarks>
    /// <param name="UnitNo">Child unit number.</param>
    /// <param name="ToUnitNo">Parent unit number to include into.</param>
    internal procedure IncludeUnitToUnit(UnitNo: Code[20]; ToUnitNo: Code[20])
    var
        Unit: Record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
        ParentUnit: Record "TMAC Unit";
    begin
        if (UnitNo = '') or (ToUnitNo = '') then
            exit;
        if UnitNo = ToUnitNo then
            exit;
        Unit.Get(UnitNo);
        ParentUnit.Get(ToUnitNo);

        Unit."Parent Unit No." := ToUnitNo;
        Unit.Indent := ParentUnit.Indent + 1;
        Unit.Modify(false);

        UnitLine.Init();
        UnitLine.Validate("Unit No.", ToUnitNo);
        UnitLine.Validate("Line No.", UnitNextLineNo(ToUnitNo));
        UnitLine.Validate(Type, "TMAC Unit Line Type"::Unit);
        UnitLine.Validate("No.", UnitNo);
        UnitLine.Insert(true);
    end;

    /// <summary>
    /// Excludes a logistic unit from its parent, effectively detaching it.
    /// </summary>
    /// <remarks>
    /// Clears the Parent Unit No. and Indent, making the unit stand alone.
    /// </remarks>
    /// <param name="UnitNo">The logistic unit number to exclude from its parent.</param>
    internal procedure Exclude(UnitNo: Code[20])
    var
        Unit: Record "TMAC Unit";
    begin
        if not Unit.Get(UnitNo) then
            exit;
        SetParentAndIndent(Unit, '', 0);
    end;

    /// <summary>
    /// Excludes a logistic unit by removing the referencing line in the parent unit.
    /// </summary>
    /// <remarks>
    /// This method updates the references and calls UpdateUnitWeightAndVolume to recalc the parent's capacity.
    /// </remarks>
    /// <param name="UnitNo">The logistic unit number to remove from its parent's line references.</param>
    internal procedure ExcludeUnit(UnitNo: Code[20])
    var
        Unit: Record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
    begin
        if (UnitNo = '') then
            exit;

        Unit.Get(UnitNo);

        UnitLine.Reset();
        UnitLIne.SetCurrentKey("Type", "No.");
        UnitLine.SetRange(Type, UnitLine.Type::Unit);
        UnitLine.SetRange("No.", UnitNo);
        while UnitLine.FindFirst() do
            UnitLine.Delete(true);

        UpdateUnitWeightAndVolume(UnitNo, 0, 0, 0);
    end;

    /// <summary>
    /// Updates the logistic unit's weight and volume after excluding or adding lines.
    /// </summary>
    /// <remarks>
    /// Sums all lines except a certain excluded line number, then optionally adds the specified AddWeight/AddVolume.
    /// Recursively updates parent units to reflect changes.
    /// </remarks>
    /// <param name="UnitNo">The logistic unit being recalculated.</param>
    /// <param name="ExcludeLineNo">The line number to ignore if any (like for a line being deleted).</param>
    /// <param name="AddWeight">Additional weight to apply, e.g., for a new line insertion.</param>
    /// <param name="AddVolume">Additional volume in base measure to apply if needed.</param>
    internal procedure UpdateUnitWeightAndVolume(UnitNo: Code[20]; ExcludeLineNo: Integer; AddWeight: Decimal; AddVolume: Decimal)
    var
        UnitLine: Record "TMAC Unit Line";
        Unit: Record "TMAC Unit";
        UnitType: Record "TMAC Unit Type";
    begin
        //weight and volume of the contents
        UnitLine.Reset();
        UnitLine.SetRange("Unit No.", UnitNo);
        if ExcludeLineNo <> 0 then
            UnitLine.SetFilter("Line No.", '<>%1', ExcludeLineNo);
        UnitLine.CalcSums("Gross Weight (base)", "Volume (base)");

        //calculating the total weight and volume for this specific LU
        Unit.Get(UnitNo);
        UnitType.Get(Unit."Type Code");
        Unit.Validate("Weight (Base)", UnitLine."Gross Weight (base)" + UnitType."Tare Weight" + AddWeight);
        Unit.Validate("Volume (Base)", UnitLine."Volume (base)" + AddVolume);
        Unit.Modify(true);

        //updating for the parent
        if Unit."Parent Unit No." <> '' then begin
            UnitLine.Reset();
            UnitLine.SetRange("No.", UnitNo);
            if UnitLine.FindFirst() then begin
                UnitLine.Validate("Gross Weight (base)", Unit."Weight (Base)");
                UnitLine.Validate("Volume (Base)", Unit."Volume (Base)");
                UnitLine.Modify(true);
            end;
            UpdateUnitWeightAndVolume(Unit."Parent Unit No.", 0, 0, 0);
        end;
    end;

    /// <summary>
    /// Overload that updates the logistic unit's weight and volume by references to the unit record directly.
    /// </summary>
    /// <remarks>
    /// Recalculates the weight and volume from the unit's content fields plus tare weight, modifies if requested.
    /// </remarks>
    /// <param name="Unit">The logistic unit record to recalc and optionally modify.</param>
    /// <param name="Modify">If true, the changes are saved with Unit.Modify().</param>
    internal procedure UpdateUnitWeightAndVolume(var Unit: Record "TMAC Unit"; Modify: Boolean)
    var
        UnitType: Record "TMAC Unit Type";
    begin
        Unit.CalcFields("Content Weight (Base)", "Content Volume (Base)");

        UnitType.Get(Unit."Type Code");
        Unit.Validate("Weight (Base)", Unit."Content Weight (Base)" + UnitType."Tare Weight");
        Unit.Validate("Volume (Base)", Unit."Content Volume (Base)"); ///может UnitType.Unit Volume???
        if Modify then
            Unit.Modify(true);
    end;

    /// <summary>
    /// Determines how many items can still be placed in a logistic unit, respecting weight/volume constraints.
    /// </summary>
    /// <remarks>
    /// Reads the unit type's limit controls, compares to current content, returns max quantity.
    /// </remarks>
    /// <param name="Unit">The logistic unit record to check capacity on.</param>
    /// <param name="OneWeight">Base weight per single item quantity being added.</param>
    /// <param name="OneVolume">Base volume per single item quantity being added.</param>
    /// <returns>The maximum quantity that can fit without exceeding weight or volume limits.</returns>
    internal procedure GetQtyLimitToAdd(var Unit: Record "TMAC Unit"; OneWeight: Decimal; OneVolume: Decimal): Decimal
    var
        UnitType: Record "TMAC Unit Type";
        ReturnValue: Decimal;
        Avl2AddWeight: Decimal;
        Avl2AddVolume: Decimal;
        LimitWeightBase: Decimal;
        LImitVolumeBase: Decimal;
    begin
        ReturnValue := 0;

        UnitType.Get(Unit."Type Code");
        Unit.CalcFields("Content Weight (Base)", "Content Volume (Base)");
        if UnitType."Limit Filling Weight Control" then begin
            //how much weight can still be added to the pallet
            LimitWeightBase := UnitofMeasureMgmt.ConvertToBaseWeightRnd(UnitType."Weight Unit of Measure", UnitType."Limit Filling Weight");
            Avl2AddWeight := LimitWeightBase - Unit."Content Weight (Base)";
            if OneWeight > 0 then
                ReturnValue := Avl2AddWeight DIV OneWeight;
        end;
        if UnitType."Limit Filling Volume Control" then begin
            //how much volume can still be added to the pallet
            LImitVolumeBase := UnitofMeasureMgmt.ConvertToBaseVolumeRnd(UnitType."Volume Unit of Measure", UnitType."Limit Filling Volume");
            Avl2AddVolume := LImitVolumeBase - Unit."Content Volume (Base)";
            if OneVolume > 0 then
                if ReturnValue > (Avl2AddVolume DIV OneVolume) then
                    ReturnValue := Avl2AddVolume DIV OneVolume;
        end;
        exit(ReturnValue);
    end;

    /// <summary>
    /// Retrieves how many of a specified item are in a logistic unit.
    /// </summary>
    /// <remarks>
    /// Filters by item, variant, and UoM in the unit lines, summing the quantity.
    /// </remarks>
    /// <param name="UnitNo">The logistic unit to search within.</param>
    /// <param name="ItemNo">Which item code to find.</param>
    /// <param name="VariantCode">Which variant if applicable.</param>
    /// <param name="UoM">Which unit of measure lines to match.</param>
    /// <returns>The total quantity found or zero if none match.</returns>
    internal procedure GetItemQty(UnitNo: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UoM: Code[10]): Decimal
    var
        UnitLine: Record "TMAC Unit Line";
    begin
        UnitLine.Reset();
        UnitLine.SetRange("Unit No.", UnitNo);
        UnitLine.SetRange("Type", UnitLine.Type::Item);
        UnitLine.SetRange("No.", ItemNo);
        UnitLine.SetRange("Variant Code", VariantCode);
        UnitLine.SetRange("Unit of Measure Code", UoM);
        UnitLine.CalcSums(Quantity);
        exit(UnitLine.Quantity);
    end;

    /// <summary>
    /// Adds lines for an item into the logistic unit from a source document link.
    /// </summary>
    /// <remarks>
    /// The quantity is validated, item references are set, and the line is inserted. If the unit type
    /// forbids mixing sources or locations, an error occurs.
    /// </remarks>
    /// <param name="UnitNo">Which logistic unit to add an item line to.</param>
    /// <param name="Qty">How many items to add.</param>
    /// <param name="SourceDocumentLink">A record referencing the item, location, lot/serial info, etc.</param>
    /// <returns>The newly assigned line number for that item in the logistic unit.</returns>
    procedure AddItemToLogisticUnit(UnitNo: Code[20]; Qty: Decimal; var SourceDocumentLink: Record "TMAC Source Document Link"): Integer
    var
        UnitLineLink: Record "TMAC Unit Line Link";
        UnitType: Record "TMAC Unit Type";
        Unit: Record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
        Locations: List of [Code[20]];
        LocationCode: Code[20];
        Handled: Boolean;
    begin
        if not Unit.Get(UnitNo) then
            exit;

        if Qty = 0 then
            exit;

        UnitType.Get(Unit."Type Code");

        if UnitType."Mix Source Document Allowed" = False then begin
            UnitLineLink.Reset();
            UnitLineLink.SetRange("Unit No.", UnitNo);
            UnitLineLink.SetRange("Source Type", SourceDocumentLink."Source Type"); //only checking by one type (since purchase order and warehouse receipt)
            UnitLineLink.SetRange("Source SubType", SourceDocumentLink."Source SubType");
            UnitLineLink.Setfilter("Source ID", '<>%1', SourceDocumentLink."Source ID");
            if not UnitLineLink.IsEmpty() then
                error(MixSourceDocumentErr, Unit."Type Code");
        end;

        if UnitType."Mix Location/Bin Allowed" = False then begin
            UnitLine.Reset();
            UnitLine.SetRange("Unit No.", UnitNo);
            UnitLine.SetLoadFields("Location Code", "Bin Code");
            if UnitLine.FindSet(false) then
                repeat
                    if (UnitLine."Location Code" <> SourceDocumentLink."Location Code") then
                        error(LogisticUnitTypeCheckErr, Unit."Type Code");
                    if (UnitLine."Bin Code" <> SourceDocumentLink."Bin Code") then
                        error(LogisticUnitTypeCheckErr, Unit."Type Code");
                until UnitLine.Next() = 0;
        end;

        UnitLine.Reset();
        UnitLine.Init();
        UnitLine."Unit No." := UnitNo;
        UnitLine."Line No." := UnitNextLineNo(UnitNo);
        UnitLine.Insert(true);

        //for the event when LU lines are filled not with items, but for example with Product in TMS or in some other extension
        OnBeforeCompleteUnitLine(UnitLine, SourceDocumentLink, Qty, Handled);
        if Handled then begin
            UnitLinkManagement.CreateLink(UnitLine, SourceDocumentLink, Qty, false);
            exit;
        end;

        UnitLine.Validate(Type, UnitLine.Type::Item);
        UnitLine.Validate("No.", SourceDocumentLink."Item No.");
        UnitLine.Validate("Variant Code", SourceDocumentLink."Variant Code");
        UnitLine.Validate(Description, SourceDocumentLink.Description);
        UnitLine.Validate(Quantity, Qty);
        UnitLine.Validate("Unit of Measure Code", SourceDocumentLink."Unit of Measure Code");
        UnitLine.Validate("Quantity (Base)", Qty * SourceDocumentLink."Qty. per UoM");
        UnitLine.Validate("Gross Weight (base)", Qty * SourceDocumentLink."Weight (Base) per UoM");
        UnitLine.Validate("Net Weight (base)", Qty * SourceDocumentLink."Weight (Base) per UoM");
        UnitLine.Validate("Volume (base)", Qty * SourceDocumentLink."Volume (Base) per UoM");
        UnitLine.Validate("Location Code", SourceDocumentLink."Location Code");
        UnitLine.Validate("Bin Code", SourceDocumentLink."Bin Code");
        UnitLine.Modify(true);

        UnitLinkManagement.CreateLink(UnitLine, SourceDocumentLink, Qty, false);


        //setting the warehouse code in the header
        UnitLine.Reset();
        UnitLine.SetRange("Unit No.", UnitNo);
        UnitLine.SetLoadFields("Location Code");
        if UnitLine.FindSet(false) then
            repeat
                if not Locations.Contains(UnitLine."Location Code") then
                    Locations.Add(UnitLine."Location Code");
            until UnitLine.Next() = 0;

        if Locations.Count() > 0 then
            if Locations.Count() = 1 then begin //lines have the same warehouse
                Locations.Get(1, LocationCode);
                if Unit."Location Code" <> LocationCode then begin
                    Unit.Get(UnitNo);
                    Unit.Validate("Location Code", LocationCode);
                    Unit.Modify(true);
                end
            end else begin
                Unit.Get(UnitNo);
                Unit."Location Code" := '';
                Unit."Zone Code" := '';
                Unit."Bin Code" := '';
                Unit.Modify(true);
            end;

        UpdateUnitWeightAndVolume(UnitNo, 0, 0, 0);

        exit(UnitLine."Line No.");
    end;

    /// <summary>
    /// Prepares a page or data set for selecting logistic units, filling a table with their info.
    /// </summary>
    /// <remarks>
    /// Typically used to open a selection page for the user, listing relevant units plus location,
    /// address, and dimension data.
    /// </remarks>
    /// <param name="Units">A list of unit numbers to process.</param>
    /// <param name="UnitSelectBySource">The record used to store selection lines.
    /// The page or UI references this record.
    /// </param>
    procedure CompleteUnitSelection(Units: List of [Code[20]]; var UnitSelectBySource: Record "TMAC Unit Select By Source")
    var
        UnitLine: Record "TMAC Unit Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        SalesHeader: Record "Sales Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        PurchaseHeader: Record "Purchase Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        TransferHeader: Record "Transfer Header";
        Unit: Record "TMAC Unit";
        UnitNo: Code[20];
        Locations: List of [Code[20]];
        Bins: List of [Code[20]];
        LocationCode: Code[20];
        BinCode: Code[20];
    begin
        foreach UnitNo in Units do begin

            Clear(Locations);
            Clear(Bins);

            Unit.Get(UnitNo);
            if not Locations.Contains(Unit."Location Code") then
                Locations.Add(Unit."Location Code");
            if not Bins.Contains(Unit."Bin Code") then
                Bins.Add(Unit."Bin Code");

            UnitLine.Reset();
            UnitLine.SetRange("Unit No.", UnitNo);
            if UnitLine.FindSet() then
                repeat
                    if not Locations.Contains(UnitLine."Location Code") then
                        Locations.Add(UnitLine."Location Code");
                    if not Bins.Contains(UnitLine."Bin Code") then
                        Bins.Add(UnitLine."Bin Code");
                until UnitLine.next() = 0;

            LocationCode := '';
            if Locations.Count() > 0 then
                if Locations.Count() = 1 then
                    Locations.Get(1, LocationCode)
                else
                    LocationCode := '(MULTIPLE)';

            BinCode := '';
            if Bins.Count() > 0 then
                if Bins.Count() = 1 then
                    Bins.Get(1, BinCode)
                else
                    LocationCode := '(MULTIPLE)';

            UnitLineLink.Reset();
            UnitLineLink.Setrange("Unit No.", UnitNo);
            UnitLineLink.Setfilter("Source Type", '%1|%2|%3|%4', Database::"Sales Line", Database::"Purchase Line", Database::"Sales Shipment Line", database::"Purch. Rcpt. Line");
            UnitLineLink.SetFilter(Quantity, '<>0'); //есть есть линк не неучт. и учт. то выберет учтенный
            if UnitLineLink.FindSet(false) then
                repeat
                    Unit.Get(UnitLineLink."Unit No.");
                    Unit.CalcFields("Content Weight (Base)", "Content Volume (Base)");

                    UnitSelectBySource.Init();
                    UnitSelectBySource."Unit No." := UnitLineLink."Unit No.";
                    UnitSelectBySource."Description" := Unit.Description;
                    UnitSelectBySource."Source Type" := UnitLineLink."Source Type";
                    UnitSelectBySource."Source Subtype" := UnitLineLink."Source Subtype";
                    UnitSelectBySource."Source ID" := UnitLineLink."Source ID";
                    UnitSelectBySource.Weight := Unit."Content Weight (Base)";
                    UnitSelectBySource.Volume := Unit."Content Volume (Base)";

                    UnitSelectBySource."Location Code" := LocationCode;
                    UnitSelectBySource."Bin Code" := BinCode;
                    UnitSelectBySource."LU Location Code" := Unit."LU Location Code";
                    UnitSelectBySource."Tracking No." := Unit."Tracking No.";

                    case UnitLineLink."Source Type" of
                        database::"Sales Line":
                            begin
                                UnitSelectBySource."Source Type" := Database::"Sales Header"; //switching to source document instead of line
                                SalesHeader.Get(UnitLineLink."Source Subtype", UnitLineLink."Source ID");
                                UnitSelectBySource."Customer/Vendor No." := SalesHeader."Sell-to Customer No.";
                                UnitSelectBySource."Customer/Vendor Name" := SalesHeader."Sell-to Customer Name";
                                UnitSelectBySource."Country Code" := SalesHeader."Sell-to Country/Region Code";
                                UnitSelectBySource.County := SalesHeader."Sell-to County";
                                UnitSelectBySource.City := SalesHeader."Sell-to City";
                                UnitSelectBySource."Post Code" := SalesHeader."Sell-to Post Code";
                                UnitSelectBySource.Address := SalesHeader."Sell-to Address";
                            end;
                        database::"Sales Shipment Line":
                            begin
                                UnitSelectBySource."Source Type" := Database::"Sales Shipment Header"; //switching to source document instead of line
                                SalesShipmentHeader.Get(UnitLineLink."Source ID");
                                UnitSelectBySource."Customer/Vendor No." := SalesShipmentHeader."Sell-to Customer No.";
                                UnitSelectBySource."Customer/Vendor Name" := SalesShipmentHeader."Sell-to Customer Name";
                                UnitSelectBySource."Country Code" := SalesShipmentHeader."Sell-to Country/Region Code";
                                UnitSelectBySource.County := SalesShipmentHeader."Sell-to County";
                                UnitSelectBySource.City := SalesShipmentHeader."Sell-to City";
                                UnitSelectBySource."Post Code" := SalesShipmentHeader."Sell-to Post Code";
                                UnitSelectBySource.Address := SalesShipmentHeader."Sell-to Address";
                            end;
                        database::"Purchase Line":
                            begin
                                UnitSelectBySource."Source Type" := Database::"Purchase Header"; //switching to source document instead of line
                                PurchaseHeader.Get(UnitLineLink."Source Subtype", UnitLineLink."Source ID");
                                UnitSelectBySource."Customer/Vendor No." := PurchaseHeader."Buy-from Vendor No.";
                                UnitSelectBySource."Customer/Vendor Name" := PurchaseHeader."Buy-from Vendor Name";
                                UnitSelectBySource."Country Code" := PurchaseHeader."Buy-from Country/Region Code";
                                UnitSelectBySource.County := PurchaseHeader."Buy-from County";
                                UnitSelectBySource.City := PurchaseHeader."Buy-from City";
                                UnitSelectBySource."Post Code" := PurchaseHeader."Buy-from Post Code";
                                UnitSelectBySource.Address := PurchaseHeader."Buy-from Address";
                            end;
                        database::"Purch. Rcpt. Line":
                            begin
                                UnitSelectBySource."Source Type" := Database::"Purch. Rcpt. Header"; //switching to source document instead of line
                                PurchRcptHeader.Get(UnitLineLink."Source ID");
                                UnitSelectBySource."Customer/Vendor No." := PurchRcptHeader."Buy-from Vendor No.";
                                UnitSelectBySource."Customer/Vendor Name" := PurchRcptHeader."Buy-from Vendor Name";
                                UnitSelectBySource."Country Code" := PurchRcptHeader."Buy-from Country/Region Code";
                                UnitSelectBySource.County := PurchRcptHeader."Buy-from County";
                                UnitSelectBySource.City := PurchRcptHeader."Buy-from City";
                                UnitSelectBySource."Post Code" := PurchRcptHeader."Buy-from Post Code";
                                UnitSelectBySource.Address := PurchRcptHeader."Buy-from Address";
                            end;
                        database::"Transfer Line":
                            begin
                                UnitSelectBySource."Source Type" := Database::"Transfer Header"; //switching to source document instead of line
                                TransferHeader.Get(UnitLineLink."Source ID");
                                UnitSelectBySource."Customer/Vendor No." := '';
                                UnitSelectBySource."Customer/Vendor Name" := 'Transfer';
                                UnitSelectBySource."Country Code" := TransferHeader."Trsf.-to Country/Region Code";
                                UnitSelectBySource.County := TransferHeader."Transfer-to County";
                                UnitSelectBySource.City := TransferHeader."Transfer-to City";
                                UnitSelectBySource."Post Code" := TransferHeader."Transfer-to Post Code";
                                UnitSelectBySource.Address := TransferHeader."Transfer-to Address";
                            end;
                    end;
                    UnitSelectBySource."Source Name" := UnitLinkManagement.GetSourceName(UnitSelectBySource."Source Type", UnitSelectBySource."Source Subtype");

                    if UnitSelectBySource.Insert(false) then; //will be the same since there are many lines in the main document
                until UnitLineLink.next() = 0
            else begin
                //if there are no links at all
                Unit.Get(UnitNo);
                Unit.CalcFields("Content Weight (Base)", "Content Volume (Base)");
                UnitSelectBySource.Init();
                UnitSelectBySource."Unit No." := UnitNo;
                UnitSelectBySource."Description" := Unit.Description;
                UnitSelectBySource."Source Name" := 'New';
                UnitSelectBySource.Weight := Unit."Content Weight (Base)";
                UnitSelectBySource.Volume := Unit."Content Volume (Base)";
                UnitSelectBySource."LU Location Code" := Unit."LU Location Code";
                if UnitSelectBySource.Insert(false) then;
            end;
        end;
    end;

    /// <summary>
    /// Allows the user to pick logistic units to load into a given order.
    /// </summary>
    /// <remarks>
    /// This function filters logistic units that match the type (purchase/sales/transfer/invt),
    /// then calls a selection page. The chosen units' item lines are appended to the order.
    /// </remarks>
    /// <param name="SourceType">Indicates the table: purchase line, sales line, etc.</param>
    /// <param name="SourceDocumentType">Subtype or status for the order.</param>
    /// <param name="SourceDocumentNo">Which specific document no. lines to add to.</param>
    /// <param name="OppositeSourceType">Used for additional constraints in item lines.
    /// For instance, transferring from purchase to something else.
    /// </param>
    internal procedure IncludeUnitInOrder(SourceType: Integer; SourceDocumentType: Integer; SourceDocumentNo: Code[20]; OppositeSourceType: Integer)
    var
        Unit: Record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        InvtDocumentHeader: Record "Invt. Document Header";
        InvtDocumentLine: Record "Invt. Document Line";
        ReservationEntry: Record "Reservation Entry";
        ReservationEntry2: Record "Reservation Entry";
        Item: Record Item;
        UnitSelectBySource: Record "TMAC Unit Select By Source";
        UnitSelection: Page "TMAC Unit Selection";
        Units: List of [Code[20]];
        SelectedUnits: List of [Code[20]];
        AlreadyIncludedUnits: List of [Code[20]];
        LineNo: Integer;
        UnitNo: Code[20];
        LocationCode: Code[20];
    begin

        case SourceType of
            database::"Purchase Line":
                begin
                    PurchaseHeader.Get(SourceDocumentType, SourceDocumentNo);
                    PurchaseHeader.TestField(Status, "Purchase Document Status"::Open);
                    LocationCode := PurchaseHeader."Location Code";
                    PurchaseLine.Reset();
                    PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
                    PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
                    if PurchaseLine.FindLast() then
                        LineNo := PurchaseLine."Line No.";
                    PurchaseLine.Reset();

                    case SourceDocumentType of
                        0, 1, 2:
                            Unit.Setrange("Inbound Logistics Enabled", true);
                        3, 5:
                            Unit.Setrange("Outbound Logistics Enabled", true); //credit note and return
                    end;
                end;
            database::"Sales Line":
                begin
                    SalesHeader.Get(SourceDocumentType, SourceDocumentNo);
                    SalesHeader.TestField(Status, "Sales Document Status"::Open);
                    LocationCode := SalesHeader."Location Code";
                    SalesLine.Reset();
                    SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                    SalesLine.SetRange("Document No.", SalesHeader."No.");
                    if SalesLine.FindLast() then
                        LineNo := SalesLine."Line No.";
                    SalesLine.Reset();

                    case SourceDocumentType of
                        0, 1, 2:
                            Unit.Setrange("Outbound Logistics Enabled", true);
                        3, 5:
                            Unit.Setrange("Inbound Logistics Enabled", true); //credit note and return
                    end;
                end;
            database::"Transfer Line":
                begin
                    TransferHeader.Get(SourceDocumentNo);
                    TransferHeader.TestField(Status, "Sales Document Status"::Open);
                    LocationCode := TransferHeader."Transfer-from Code"; //since lines are being added, they must belong to the shipping warehouse

                    TransferLine.Reset();
                    TransferLine.SetRange("Document No.", TransferHeader."No.");
                    if TransferLine.FindLast() then
                        LineNo := TransferLine."Line No.";
                    TransferLine.Reset();
                    Unit.Setrange("Outbound Logistics Enabled", true); //it will have to be shipped first
                end;
            Database::"Invt. Document Line":
                begin
                    InvtDocumentHeader.Get(SourceDocumentType, SourceDocumentNo);
                    InvtDocumentHeader.TestField(Status, InvtDocumentHeader.Status::Open);
                    //LocationCode := InvtDocumentHeader."Location Code";
                    InvtDocumentLine.Reset();
                    InvtDocumentLine.SetRange("Document Type", InvtDocumentHeader."Document Type");
                    InvtDocumentLine.SetRange("Document No.", InvtDocumentHeader."No.");
                    if InvtDocumentLine.FindLast() then
                        LineNo := InvtDocumentLine."Line No.";
                    InvtDocumentLine.Reset();
                end;
        end;

        //first filter out the pallets that have already been posted for
        if Unit.Findset() then
            repeat
                UnitLine.Reset();
                UnitLine.Setrange("Unit No.", Unit."No.");
                if LocationCode <> '' then
                    UnitLine.SetRange("Location Code", LocationCode);
                UnitLine.SetRange(Type, UnitLine.Type::Item);
                UnitLine.SetRange("Linked Type Filter", OppositeSourceType);
                UnitLine.SetAutoCalcFields("Linked Links Exist");
                UnitLine.SetRange("Linked Links Exist", false);
                UnitLine.SetLoadFields("Unit No.");
                if UnitLine.FindSet(false) then
                    repeat
                        if not Units.Contains(UnitLine."Unit No.") then
                            Units.Add(UnitLine."Unit No.");
                    until UnitLine.next() = 0;
            until Unit.Next() = 0;


        //filtering out pallets that are added to other unposted orders
        foreach UnitNo in Units do begin
            UnitLine.Reset();
            UnitLine.SetRange("Unit No.", UnitNo);
            UnitLine.SetRange("Type", UnitLine.Type::Item);
            UnitLine.SetRange("Linked Type Filter", SourceType);
            UnitLine.SetRange("Linked Subtype Filter", SourceDocumentType);
            UnitLine.SetAutoCalcFields("Linked Links Exist");
            UnitLine.SetRange("Linked Links Exist", false);
            UnitLine.SetLoadFields("Unit No.");
            if UnitLine.FindFirst() then
                if not SelectedUnits.Contains(UnitLine."Unit No.") then
                    SelectedUnits.Add(UnitLine."Unit No.");
        end;

        //SelectedUnits - list of pallets that contain at least one line without a link to posted or unposted documents
        CompleteUnitSelection(SelectedUnits, UnitSelectBySource);
        UnitSelectBySource.Reset();
        if UnitSelectBySource.findset(false) then
            repeat
                UnitSelection.AddLine(UnitSelectBySource);
            until UnitSelectBySource.next() = 0;

        UnitSelection.LookupMode(true);
        if UnitSelection.RunModal() = Action::LookupOK then begin
            UnitSelection.SetSelectionFilter(UnitSelectBySource);
            UnitSelectBySource.MarkedOnly(true);
            if UnitSelectBySource.findset() then
                repeat
                    if not AlreadyIncludedUnits.Contains(UnitSelectBySource."Unit No.") then begin
                        AlreadyIncludedUnits.Add(UnitSelectBySource."Unit No.");

                        //transfer only the lines that are not connected to other documents
                        UnitLine.Reset();
                        UnitLine.SetRange("Unit No.", UnitSelectBySource."Unit No.");
                        UnitLine.SetRange(Type, UnitLine.Type::Item);
                        UnitLine.SetRange("Linked Type Filter", SourceType);
                        UnitLine.SetRange("Linked Subtype Filter", SourceDocumentType);
                        UnitLine.SetAutoCalcFields("Linked Links Exist");
                        UnitLine.SetRange("Linked Links Exist", false);
                        if UnitLine.FindFirst() then
                            repeat
                                LineNo += 10000;
                                case SourceType of
                                    database::"Purchase Line":
                                        begin
                                            PurchaseLine.Init();
                                            PurchaseLine."Document Type" := PurchaseHeader."Document Type";
                                            PurchaseLine."Document No." := PurchaseHeader."No.";
                                            PurchaseLine."Line No." := LineNo;
                                            PurchaseLine.Insert(true);
                                            PurchaseLine.Validate(Type, "Purchase Line Type"::Item);
                                            PurchaseLine.Validate("No.", UnitLine."No.");
                                            PurchaseLine.Validate("Variant Code", UnitLine."Variant Code");
                                            PurchaseLine.Validate(Description, UnitLine.Description);
                                            PurchaseLine.Validate(Quantity, UnitLine.Quantity);
                                            PurchaseLine.Validate("Unit of Measure Code", UnitLine."Unit of Measure Code");
                                            PurchaseLine.Validate("Location Code", UnitLine."Location Code");
                                            PurchaseLine.Modify(true);

                                            Item.Get(UnitLine."No.");
                                            if Item."Item Tracking Code" <> '' then begin
                                                UnitLineLink.Reset();
                                                UnitLineLink.SetRange("Unit No.", UnitLine."Unit No.");
                                                UnitLineLink.SetRange("Unit Line No.", UnitLine."Line No.");
                                                UnitLineLink.SetFilter("Source Type", '%1|%2', 37, 121);
                                                UnitLineLink.SetFilter(Quantity, '<>0');
                                                if UnitLineLink.FindSet() then
                                                    repeat
                                                        ReservationEntry.Init();
                                                        ReservationEntry."Entry No." := 0;
                                                        ReservationEntry.Positive := true;
                                                        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Surplus;
                                                        ReservationEntry."Item No." := PurchaseLine."No.";
                                                        ReservationEntry."Location Code" := PurchaseLine."Location Code";
                                                        ReservationEntry."Variant Code" := PurchaseLine."Variant Code";
                                                        ReservationEntry."Creation Date" := Today();
                                                        ReservationEntry."Source Type" := Database::"Purchase Line";
                                                        ReservationEntry."Source Subtype" := PurchaseLine."Document Type".AsInteger();
                                                        ReservationEntry."Source ID" := PurchaseLine."Document No.";
                                                        ReservationEntry."Source Batch Name" := '';
                                                        ReservationEntry."Source Prod. Order Line" := 0;
                                                        ReservationEntry."Source Ref. No." := PurchaseLine."Line No.";
                                                        ReservationEntry."Expected Receipt Date" := Today();
                                                        ReservationEntry.Quantity := Abs(UnitLineLink.Quantity);
                                                        ReservationEntry."Qty. per Unit of Measure" := PurchaseLine."Qty. per Unit of Measure";
                                                        ReservationEntry."Quantity (Base)" := ABS(UnitLineLink."Quantity (Base)");
                                                        ReservationEntry."Qty. to Handle (Base)" := ABS(UnitLineLink."Quantity (Base)");
                                                        ReservationEntry."Qty. to Invoice (Base)" := ABS(UnitLineLink."Quantity (Base)");
                                                        ReservationEntry."Lot No." := UnitLineLink."Lot No.";
                                                        ReservationEntry."Package No." := UnitLineLink."Package No.";
                                                        ReservationEntry."Serial No." := UnitLineLink."Serial No.";
                                                        ReservationEntry."Created By" := CopyStr(UserID(), 1, 50);
                                                        ReservationEntry."Item Tracking" := GetItemTrackingType(UnitLineLink."Lot No.", UnitLineLink."Package No.", UnitLineLink."Serial No.");
                                                        ReservationEntry.Insert(true);
                                                    until UnitLineLink.Next() = 0
                                            end;
                                            UnitLinkManagement.CreateLink(UnitLine, PurchaseLine);
                                        end;
                                    database::"Sales Line":
                                        begin
                                            SalesLine.Init();
                                            SalesLine."Document Type" := SalesHeader."Document Type";
                                            SalesLine."Document No." := SalesHeader."No.";
                                            SalesLine."Line No." := LineNo;
                                            SalesLine.Insert(true);
                                            SalesLine.Validate(Type, "Sales Line Type"::Item);
                                            SalesLine.Validate("No.", UnitLine."No.");
                                            SalesLine.Validate("Variant Code", UnitLine."Variant Code");
                                            SalesLine.Validate(Description, UnitLine.Description);
                                            SalesLine.Validate(Quantity, UnitLine.Quantity);
                                            SalesLine.Validate("Unit of Measure Code", UnitLine."Unit of Measure Code");
                                            SalesLine.Validate("Location Code", UnitLine."Location Code");
                                            SalesLine.Modify(true);
                                            Item.Get(UnitLine."No.");
                                            if Item."Item Tracking Code" <> '' then begin
                                                UnitLineLink.Reset();
                                                UnitLineLink.SetRange("Unit No.", UnitLine."Unit No.");
                                                UnitLineLink.SetRange("Unit Line No.", UnitLine."Line No.");
                                                UnitLineLink.SetFilter("Source Type", '%1|%2', 39, 121);
                                                UnitLineLink.SetFilter(Quantity, '<>0');
                                                if UnitLineLink.FindSet() then
                                                    repeat
                                                        ReservationEntry.Init();
                                                        ReservationEntry."Entry No." := 0;
                                                        ReservationEntry.Positive := false;
                                                        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Surplus;
                                                        ReservationEntry."Item No." := SalesLine."No.";
                                                        ReservationEntry."Location Code" := SalesLine."Location Code";
                                                        ReservationEntry."Variant Code" := SalesLine."Variant Code";
                                                        ReservationEntry."Creation Date" := Today();
                                                        ReservationEntry."Source Type" := Database::"Sales Line";
                                                        ReservationEntry."Source Subtype" := SalesLine."Document Type".AsInteger();
                                                        ReservationEntry."Source ID" := SalesLine."Document No.";
                                                        ReservationEntry."Source Batch Name" := '';
                                                        ReservationEntry."Source Prod. Order Line" := 0;
                                                        ReservationEntry."Source Ref. No." := SalesLine."Line No.";
                                                        ReservationEntry."Expected Receipt Date" := Today();
                                                        ReservationEntry.Quantity := -ABS(UnitLineLink.Quantity);
                                                        ReservationEntry."Qty. per Unit of Measure" := SalesLine."Qty. per Unit of Measure";
                                                        ReservationEntry."Quantity (Base)" := -ABS(UnitLineLink."Quantity (Base)");
                                                        ReservationEntry."Qty. to Handle (Base)" := -ABS(UnitLineLink."Quantity (Base)");
                                                        ReservationEntry."Qty. to Invoice (Base)" := -ABS(UnitLineLink."Quantity (Base)");
                                                        ReservationEntry."Lot No." := UnitLineLink."Lot No.";
                                                        ReservationEntry."Package No." := UnitLineLink."Package No.";
                                                        ReservationEntry."Serial No." := UnitLineLink."Serial No.";
                                                        ReservationEntry."Created By" := CopyStr(UserID(), 1, 50);
                                                        ReservationEntry."Item Tracking" := GetItemTrackingType(UnitLineLink."Lot No.", UnitLineLink."Package No.", UnitLineLink."Serial No.");
                                                        ReservationEntry.Insert(true);
                                                    until UnitLineLink.Next() = 0
                                            end;
                                            UnitLinkManagement.CreateLink(UnitLine, SalesLine);
                                        end;
                                    database::"Transfer Line":
                                        begin
                                            TransferLine.Init();
                                            TransferLine."Document No." := TransferHeader."No.";
                                            TransferLine."Line No." := LineNo;
                                            TransferLine.Insert(true);
                                            TransferLine.Validate("Item No.", UnitLine."No.");
                                            TransferLine.Validate("Variant Code", UnitLine."Variant Code");
                                            TransferLine.Validate(Description, UnitLine.Description);
                                            TransferLine.Validate(Quantity, UnitLine.Quantity);
                                            TransferLine.Validate("Unit of Measure Code", UnitLine."Unit of Measure Code");
                                            TransferLine.Modify(true);
                                            Item.Get(UnitLine."No.");
                                            if Item."Item Tracking Code" <> '' then begin
                                                UnitLineLink.Reset();
                                                UnitLineLink.SetRange("Unit No.", UnitLine."Unit No.");
                                                UnitLineLink.SetRange("Unit Line No.", UnitLine."Line No.");
                                                UnitLineLink.SetFilter("Source Type", '%1|%2', 39, 121);
                                                UnitLineLink.SetFilter(Quantity, '<>0');
                                                if UnitLineLink.FindSet() then
                                                    repeat
                                                        ReservationEntry.Init();
                                                        ReservationEntry."Entry No." := 0;
                                                        ReservationEntry.Positive := false;
                                                        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Surplus;
                                                        ReservationEntry."Item No." := TransferLine."Item No.";
                                                        ReservationEntry."Location Code" := TransferLine."Transfer-from Code";
                                                        ReservationEntry."Variant Code" := TransferLine."Variant Code";
                                                        ReservationEntry."Creation Date" := Today();
                                                        ReservationEntry."Source Type" := Database::"Transfer Line";
                                                        ReservationEntry."Source Subtype" := 0; //^
                                                        ReservationEntry."Source ID" := TransferLine."Document No.";
                                                        ReservationEntry."Source Batch Name" := '';
                                                        ReservationEntry."Source Prod. Order Line" := 0;
                                                        ReservationEntry."Source Ref. No." := TransferLine."Line No.";
                                                        ReservationEntry."Expected Receipt Date" := Today();
                                                        ReservationEntry.Quantity := -ABS(UnitLineLink.Quantity);
                                                        ReservationEntry."Qty. per Unit of Measure" := TransferLine."Qty. per Unit of Measure";
                                                        ReservationEntry."Quantity (Base)" := -ABS(UnitLineLink."Quantity (Base)");
                                                        ReservationEntry."Qty. to Handle (Base)" := -ABS(UnitLineLink."Quantity (Base)");
                                                        ReservationEntry."Qty. to Invoice (Base)" := -ABS(UnitLineLink."Quantity (Base)");
                                                        ReservationEntry."Lot No." := UnitLineLink."Lot No.";
                                                        ReservationEntry."Package No." := UnitLineLink."Package No.";
                                                        ReservationEntry."Serial No." := UnitLineLink."Serial No.";
                                                        ReservationEntry."Created By" := CopyStr(UserID(), 1, 50);
                                                        ReservationEntry."Item Tracking" := GetItemTrackingType(UnitLineLink."Lot No.", UnitLineLink."Package No.", UnitLineLink."Serial No.");
                                                        ReservationEntry.Insert(true);

                                                        ReservationEntry2.Init();
                                                        ReservationEntry2.TransferFields(ReservationEntry);
                                                        ReservationEntry2."Source Subtype" := 1;
                                                        ReservationEntry2."Entry No." := 0;
                                                        ReservationEntry2.Positive := true;
                                                        ReservationEntry2."Location Code" := TransferLine."Transfer-to Code";
                                                        ReservationEntry2."Quantity" := ABS(UnitLineLink.Quantity);
                                                        ReservationEntry2."Quantity (Base)" := ABS(UnitLineLink."Quantity (Base)");
                                                        ReservationEntry2."Qty. to Handle (Base)" := ABS(UnitLineLink."Quantity (Base)");
                                                        ReservationEntry2."Qty. to Invoice (Base)" := ABS(UnitLineLink."Quantity (Base)");

                                                        ReservationEntry2.Insert(true);

                                                    until UnitLineLink.Next() = 0
                                            end;
                                            UnitLinkManagement.CreateLink(UnitLine, TransferLine, false);
                                        end;
                                    Database::"Invt. Document Line":
                                        begin
                                            InvtDocumentLine.Init();
                                            InvtDocumentLine."Document Type" := InvtDocumentHeader."Document Type";
                                            InvtDocumentLine."Document No." := InvtDocumentHeader."No.";
                                            InvtDocumentLine."Line No." := LineNo;
                                            InvtDocumentLine.Insert(true);
                                            InvtDocumentLine.Validate("Item No.", UnitLine."No.");
                                            InvtDocumentLine.Validate("Variant Code", UnitLine."Variant Code");
                                            InvtDocumentLine.Validate(Description, UnitLine.Description);
                                            InvtDocumentLine.Validate(Quantity, UnitLine.Quantity);
                                            InvtDocumentLine.Validate("Unit of Measure Code", UnitLine."Unit of Measure Code");
                                            InvtDocumentLine.Validate("Location Code", InvtDocumentHeader."Location Code");
                                            InvtDocumentLine.Modify(true);
                                            Item.Get(UnitLine."No.");
                                            if Item."Item Tracking Code" <> '' then begin
                                                UnitLineLink.Reset();
                                                UnitLineLink.SetRange("Unit No.", UnitLine."Unit No.");
                                                UnitLineLink.SetRange("Unit Line No.", UnitLine."Line No.");
                                                //UnitLineLink.SetFilter("Source Type", '%1|%2', 39, 121);
                                                UnitLineLink.SetFilter(Quantity, '<>0');
                                                if UnitLineLink.FindSet() then
                                                    repeat
                                                        ReservationEntry.Init();
                                                        ReservationEntry."Entry No." := 0;
                                                        ReservationEntry.Positive := false;
                                                        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Surplus;
                                                        ReservationEntry."Item No." := InvtDocumentLine."Item No.";
                                                        ReservationEntry."Location Code" := InvtDocumentLine."Location Code";
                                                        ReservationEntry."Variant Code" := InvtDocumentLine."Variant Code";
                                                        ReservationEntry."Creation Date" := Today();
                                                        ReservationEntry."Source Type" := Database::"Invt. Document Line";
                                                        ReservationEntry."Source Subtype" := InvtDocumentLine."Document Type".AsInteger();
                                                        ReservationEntry."Source ID" := InvtDocumentLine."Document No.";
                                                        ReservationEntry."Source Batch Name" := '';
                                                        ReservationEntry."Source Prod. Order Line" := 0;
                                                        ReservationEntry."Source Ref. No." := InvtDocumentLine."Line No.";
                                                        ReservationEntry."Expected Receipt Date" := Today();
                                                        ReservationEntry.Quantity := -ABS(UnitLineLink.Quantity);
                                                        ReservationEntry."Qty. per Unit of Measure" := InvtDocumentLine."Qty. per Unit of Measure";
                                                        ReservationEntry."Quantity (Base)" := -ABS(UnitLineLink."Quantity (Base)");
                                                        ReservationEntry."Qty. to Handle (Base)" := -ABS(UnitLineLink."Quantity (Base)");
                                                        ReservationEntry."Qty. to Invoice (Base)" := -ABS(UnitLineLink."Quantity (Base)");
                                                        ReservationEntry."Lot No." := UnitLineLink."Lot No.";
                                                        ReservationEntry."Package No." := UnitLineLink."Package No.";
                                                        ReservationEntry."Serial No." := UnitLineLink."Serial No.";
                                                        ReservationEntry."Created By" := CopyStr(UserID(), 1, 50);
                                                        ReservationEntry."Item Tracking" := GetItemTrackingType(UnitLineLink."Lot No.", UnitLineLink."Package No.", UnitLineLink."Serial No.");
                                                        ReservationEntry.Insert(true);
                                                    until UnitLineLink.Next() = 0
                                            end;
                                            UnitLinkManagement.CreateLink(UnitLine, InvtDocumentLine);
                                        end;
                                end;
                            until UnitLine.Next() = 0;
                    end;
                until UnitSelectBySource.next() = 0;
        end;
    end;

    /// <summary>
    /// Local helper to interpret item tracking type from lot, package, and serial.
    /// </summary>
    /// <remarks>
    /// Checks which fields are filled in. Returns the appropriate enum from "Item Tracking Entry Type".
    /// </remarks>
    /// <param name="LotNo">If set, means lot-based tracking.</param>
    /// <param name="PackageNo">If set, means package-based tracking.</param>
    /// <param name="SerialNo">If set, means serial-based tracking.</param>
    /// <returns>A combined item tracking type enumerating all that apply.</returns>
    local procedure GetItemTrackingType(LotNo: Code[50]; PackageNo: Code[50]; SerialNo: Code[50]) ItemTrackingType: Enum "Item Tracking Entry Type"
    begin
        ItemTrackingType := "Item Tracking Entry Type"::None;
        if LotNo <> '' then
            if PackageNo <> '' then begin
                if SerialNo <> '' then
                    ItemTrackingType := "Item Tracking Entry Type"::"Lot and Serial and Package No."
                else
                    ItemTrackingType := "Item Tracking Entry Type"::"Lot and Package No.";
            end else
                if SerialNo <> '' then
                    ItemTrackingType := "Item Tracking Entry Type"::"Lot and Serial No."
                else
                    ItemTrackingType := "Item Tracking Entry Type"::"Lot No."
        else
            if PackageNo <> '' then begin
                if SerialNo <> '' then
                    ItemTrackingType := "Item Tracking Entry Type"::"Serial and Package No."
                else
                    ItemTrackingType := "Item Tracking Entry Type"::"Package No.";
            end else
                if SerialNo <> '' then
                    ItemTrackingType := "Item Tracking Entry Type"::"Serial No.";
    end;

    /// <summary>
    /// Excludes logistic units from an order by removing their item lines.
    /// </summary>
    /// <remarks>
    /// The user selects which units to remove, and any lines referencing them are removed from the document.
    /// If the line's entire quantity is removed, the line is deleted.
    /// </remarks>
    /// <param name="SourceType">The table type (purchase, sales, or transfer lines).</param>
    /// <param name="SourceDocumentType">The doc subtype, e.g. order, invoice, or similar.</param>
    /// <param name="SourceDocumentNo">The doc no. from which to remove logistic units.</param>
    internal procedure ExcludeUnitInOrder(SourceType: Integer; SourceDocumentType: Integer; SourceDocumentNo: Code[20])
    var
        UnitLineLink: Record "TMAC Unit Line Link";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        ReservationEntry: Record "Reservation Entry";
        Item: Record Item;
        UnitSelectBySource: Record "TMAC Unit Select By Source";
        UnitSelection: Page "TMAC Unit Selection";
        SelectedUnits: List of [Code[20]];
        AlreadyIncludedUnits: List of [Code[20]];
        LinesList: List of [integer];
        LineNo: Integer;
        DocumentLineQty: Decimal;
    begin

        case SourceType of
            database::"Purchase Line":
                begin
                    PurchaseHeader.Get(SourceDocumentType, SourceDocumentNo);
                    PurchaseHeader.TestField(Status, "Purchase Document Status"::Open);
                end;
            database::"Sales Line":
                begin
                    SalesHeader.Get(SourceDocumentType, SourceDocumentNo);
                    SalesHeader.TestField(Status, "Sales Document Status"::Open);
                end;
            database::"Transfer Line":
                begin
                    TransferHeader.Get(SourceDocumentNo);
                    TransferHeader.TestField(Status, "Sales Document Status"::Open);
                end;
        end;

        //list of pallets for this document
        UnitLineLink.Reset();
        UnitLineLink.SetRange("Source Type", SourceType);
        UnitLineLink.SetRange("Source Subtype", SourceDocumentType);
        UnitLineLink.SetRange("Source ID", SourceDocumentNo);
        UnitLineLink.SetRange(Posted, false);
        if UnitLineLink.FindSet(false) then
            repeat
                if not SelectedUnits.Contains(UnitLineLink."Unit No.") then
                    SelectedUnits.Add(UnitLineLink."Unit No.");
            until UnitLineLink.Next() = 0;

        //SelectedUnits - list of pallets that contain at least one line without a link to posted or unposted documents
        CompleteUnitSelection(SelectedUnits, UnitSelectBySource);
        UnitSelectBySource.Reset();
        if UnitSelectBySource.findset(false) then
            repeat
                UnitSelection.AddLine(UnitSelectBySource);
            until UnitSelectBySource.next() = 0;

        UnitSelection.LookupMode(true);
        if UnitSelection.RunModal() = Action::LookupOK then begin
            UnitSelection.SetSelectionFilter(UnitSelectBySource);
            UnitSelectBySource.MarkedOnly(true);
            if UnitSelectBySource.findset() then
                repeat
                    if not AlreadyIncludedUnits.Contains(UnitSelectBySource."Unit No.") then begin
                        AlreadyIncludedUnits.Add(UnitSelectBySource."Unit No.");
                        Clear(LinesList);
                        UnitLineLink.Reset();
                        UnitLineLink.SetRange("Unit No.", UnitSelectBySource."Unit No.");
                        UnitLineLink.SetRange("Source Type", SourceType);
                        UnitLineLink.SetRange("Source Subtype", SourceDocumentType);
                        UnitLineLink.SetRange("Source ID", SourceDocumentNo);
                        if UnitLineLink.FindSet() then
                            repeat
                                if not LinesList.Contains(UnitLineLink."Source Ref. No.") then
                                    LinesList.Add(UnitLineLink."Source Ref. No.");
                            until UnitLineLink.next() = 0;

                        //deleting lines from the purchase order
                        foreach LineNo in LinesList do begin
                            DocumentLineQty := 0;
                            case SourceType of
                                database::"Purchase Line":
                                    begin
                                        PurchaseLine.Get(SourceDocumentType, SourceDocumentNo, LineNo);
                                        DocumentLineQty := PurchaseLine.Quantity;
                                    end;
                                database::"Sales Line":
                                    begin
                                        SalesLine.Get(SourceDocumentType, SourceDocumentNo, LineNo);
                                        DocumentLineQty := SalesLine.Quantity;
                                    end;
                                database::"Transfer Line":
                                    begin
                                        TransferLine.Get(SourceDocumentNo, LineNo);
                                        DocumentLineQty := TransferLine.Quantity;
                                    end;
                            end;

                            //a document line can be connected to one pallet with multiple links (to different pallet lines)
                            UnitLineLink.Reset();
                            UnitLineLink.SetRange("Unit No.", UnitSelectBySource."Unit No.");
                            UnitLineLink.SetRange("Source Type", SourceType);
                            UnitLineLink.SetRange("Source Subtype", SourceDocumentType);
                            UnitLineLink.SetRange("Source ID", SourceDocumentNo);
                            UnitLineLink.SetRange("Source Ref. No.", LineNo);
                            UnitLineLink.SetRange(Posted, false);
                            UnitLineLink.CalcSums(Quantity); //may have a different sign
                            if ABS(UnitLineLink.Quantity) = DocumentLineQty then   //if the quantity matches, then delete the line
                                case SourceType of
                                    database::"Purchase Line":
                                        begin
                                            PurchaseLine.Get(SourceDocumentType, SourceDocumentNo, LineNo);
                                            if PurchaseLine.Type = "Purchase Line Type"::Item then
                                                if Item.Get(PurchaseLine."No.") then
                                                    if Item."Item Tracking Code" <> '' then begin
                                                        ReservationEntry.Reset();
                                                        ReservationEntry.SetRange("Source Type", Database::"Purchase Line");
                                                        ReservationEntry.SetRange("Source Subtype", PurchaseLine."Document Type".AsInteger());
                                                        ReservationEntry.SetRange("Source ID", PurchaseLine."Document No.");
                                                        ReservationEntry.Setrange("Source Ref. No.", PurchaseLine."Line No.");
                                                        ReservationEntry.DeleteAll(false);
                                                    end;
                                            PurchaseLine.Delete(true);
                                        end;
                                    database::"Sales Line":
                                        begin
                                            SalesLine.Get(SourceDocumentType, SourceDocumentNo, LineNo);
                                            if SalesLine.Type = "Sales Line Type"::Item then
                                                if Item.Get(SalesLine."No.") then
                                                    if Item."Item Tracking Code" <> '' then begin
                                                        ReservationEntry.Reset();
                                                        ReservationEntry.SetRange("Source Type", Database::"Sales Line");
                                                        ReservationEntry.SetRange("Source Subtype", SalesLine."Document Type".AsInteger());
                                                        ReservationEntry.SetRange("Source ID", SalesLine."Document No.");
                                                        ReservationEntry.Setrange("Source Ref. No.", SalesLine."Line No.");
                                                        ReservationEntry.DeleteAll(false);
                                                    end;
                                            SalesLine.Delete(true);
                                        end;
                                    database::"Transfer Line":
                                        begin
                                            TransferLine.Get(SourceDocumentNo, LineNo);
                                            TransferLine.Delete(true);
                                        end;
                                end
                            else  //otherwise, delete only the links in the document line; the quantity must not be changed, since all links to other pallets would break
                                UnitLineLink.DeleteAll(true);
                        end;
                    end;
                until UnitSelectBySource.next() = 0;
        end;
    end;

    /// <summary>
    /// For transfers, allows the user to pick logistic units to receive.
    /// </summary>
    /// <remarks>
    /// Creates reverse links in the codeunit to handle inbound or outbound.
    /// </remarks>
    /// <param name="DocumentNo">The transfer doc no. to attach or detach units from.</param>
    /// <param name="Positive">If true, indicates an inbound receipt scenario.
    /// </param>
    internal procedure TransferSelectforReceipt(DocumentNo: Code[20]; Positive: Boolean)
    var
        TransferLine: Record "Transfer Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        UnitLineLink2: Record "TMAC Unit Line Link";
        UnitSelectBySource: Record "TMAC Unit Select By Source";
        UnitSelection: Page "TMAC Unit Selection";
        Units: List of [Code[20]];
        DoneUnits: List of [Code[20]];
    begin
        UnitLineLink.Reset();
        UnitLineLink.SetRange("Source Type", Database::"Transfer Line"); ////list of pallets for this document

        if Positive then
            UnitLineLink.SetRange("Source Subtype", 1)
        else
            UnitLineLink.SetRange("Source Subtype", 0);

        UnitLineLink.SetRange("Source ID", DocumentNo);
        UnitLineLink.SetRange(Positive, Positive);
        UnitLineLink.Setrange(Posted, false);
        UnitLineLink.SetLoadFields("Unit No.");
        if UnitLineLink.FindSet(false) then
            repeat
                // check that this has not already been done
                UnitLineLink2.Reset();
                UnitLineLink2.SetRange("Unit No.", UnitLineLink."Unit No.");
                UnitLineLink2.Setrange("Unit Line No.", UnitLineLink."Unit Line No.");
                UnitLineLink2.SetRange("Source Type", UnitLineLink."Source Type");
                UnitLineLink2.SetRange("Source Subtype", UnitLineLink."Source Subtype");
                UnitLineLink2.SetRange("Source ID", UnitLineLink."Source ID");
                UnitLineLink2.Setrange("Source Ref. No.", UnitLineLink."Source Ref. No.");
                UnitLineLink2.Setrange(Positive, not Positive);
                if UnitLineLink2.IsEmpty then
                    if not Units.Contains(UnitLineLink."Unit No.") then
                        Units.Add(UnitLineLink."Unit No.");
            until UnitLineLink.Next() = 0;

        CompleteUnitSelection(Units, UnitSelectBySource);
        UnitSelectBySource.Reset();
        if UnitSelectBySource.findset(false) then
            repeat
                UnitSelection.AddLine(UnitSelectBySource);
            until UnitSelectBySource.next() = 0;

        UnitSelection.LookupMode(true);
        if UnitSelection.RunModal() = Action::LookupOK then begin
            UnitSelection.SetSelectionFilter(UnitSelectBySource);
            UnitSelectBySource.MarkedOnly(true);
            if UnitSelectBySource.findset() then
                repeat
                    if not DoneUnits.Contains(UnitSelectBySource."Unit No.") then begin
                        DoneUnits.Add(UnitSelectBySource."Unit No.");

                        UnitLineLink.Reset();
                        UnitLineLink.SetRange("Unit No.", UnitSelectBySource."Unit No.");
                        UnitLineLink.SetRange("Source Type", Database::"Transfer Line");

                        if Positive then
                            UnitLineLink.SetRange("Source Subtype", 1)
                        else
                            UnitLineLink.SetRange("Source Subtype", 0);

                        UnitLineLink.SetRange("Source ID", DocumentNo);
                        UnitLineLink.Setrange(Positive, Positive);
                        UnitLineLink.Setrange(Posted, false);
                        if UnitLineLink.FindSet() then
                            repeat
                                TransferLine.Get(DocumentNo, UnitLineLink."Source Ref. No.");
                                UnitLinkManagement.CreateReverseLink(UnitLineLink, true);
                            until UnitLineLink.next() = 0;
                    end;
                until UnitSelectBySource.next() = 0;
        end;
    end;

    /// <summary>
    /// Determines the next line number for a logistic unit.
    /// </summary>
    /// <remarks>
    /// Finds the highest line no. in the unit lines and adds 10000.
    /// </remarks>
    /// <param name="UnitNo">The logistic unit to retrieve the next line no. for.</param>
    /// <returns>A line number offset by 10000 from the last line.</returns>
    procedure UnitNextLineNo(UnitNo: Code[20]): Integer
    var
        UnitLine: Record "TMAC Unit Line";
    begin
        UnitLine.SetRange("Unit No.", UnitNo);
        if UnitLine.FindLast() then
            Exit(UnitLine."Line No." + 10000)
        else
            exit(10000);
    end;

    /// <summary>
    /// Returns the top-level parent of a logistic unit.
    /// </summary>
    /// <remarks>
    /// Recursively follows "Parent Unit No." fields until the top is found.
    /// Useful for nested structures.
    /// </remarks>
    /// <param name="UnitNo">Any logistic unit number that may be nested.</param>
    /// <returns>The top-most logistic unit number in the chaining hierarchy.</returns>
    procedure GetTopParentLogisticUnit(UnitNo: Code[20]): Code[20]
    var
        Unit: Record "TMAC Unit";
    begin
        if Unit.Get(UnitNo) then
            if Unit."Parent Unit No." <> '' then
                exit(GetTopParentLogisticUnit(Unit."Parent Unit No."))
            else
                exit(UnitNo);
    end;

    /// <summary>
    /// Creates a new record in the TMAC Unit Entry ledger to log an action performed.
    /// </summary>
    /// <remarks>
    /// Overload #1. Omits LULocationCode param. Defaults to today’s date.
    /// </remarks>
    /// <param name="UnitNo">The logistic unit that is being recorded in the ledger.</param>
    /// <param name="ActionCode">Indicates which action took place.</param>
    internal procedure CreateUnitEntry(UnitNo: Code[20]; ActionCode: Code[20])
    begin
        CreateUnitEntry(UnitNo, Today(), ActionCode, '', '', '', '');
    end;

    /// <summary>
    /// Creates a new record in the TMAC Unit Entry ledger, specifying a LU location code.
    /// </summary>
    /// <remarks>
    /// Overload #2. Also uses the current date.
    /// </remarks>
    /// <param name="UnitNo">The logistic unit whose action is being logged.</param>
    /// <param name="ActionCode">Which action code to store in the ledger.</param>
    /// <param name="LULocationCode">Specifies the LU location code used in the entry.
    /// </param>
    internal procedure CreateUnitEntry(UnitNo: Code[20]; ActionCode: Code[20]; LULocationCode: Code[20])
    begin
        CreateUnitEntry(UnitNo, Today(), ActionCode, LULocationCode, '', '', '');
    end;

    /// <summary>
    /// Creates a new record in the TMAC Unit Entry ledger with full parameters.
    /// </summary>
    /// <remarks>
    /// Overload #3. Allows specifying date/time, location codes, for advanced usage.
    /// </remarks>
    /// <param name="UnitNo">Which logistic unit is being logged.</param>
    /// <param name="Date">The date of the action, used in the ledger entry.</param>
    /// <param name="ActionCode">Which action was performed.</param>
    /// <param name="LULocationCode">If relevant, the logistic unit location code used.</param>
    /// <param name="LocationCode">If relevant, the standard location code used.</param>
    /// <param name="ZoneCode">Which zone code was used, if any.</param>
    /// <param name="BinCode">Which bin code was used, if any.</param>
    /// <returns>The newly inserted Unit Entry record, if needed.
    /// or an empty record if not used.
    /// </returns>
    internal procedure CreateUnitEntry(UnitNo: Code[20]; "Date": Date; ActionCode: Code[20]; LULocationCode: Code[20]; LocationCode: Code[10]; ZoneCode: Code[10]; BinCode: Code[20]) UnitEntry: Record "TMAC Unit Entry"
    begin
        UnitEntry.Init();
        UnitEntry."Entry No." := 0;
        UnitEntry."Unit No." := UnitNo;
        UnitEntry."Date" := "Date";
        UnitEntry."Date and time" := CreateDateTime(Date, 0T);
        UnitEntry."Action Code" := ActionCode;
        UnitEntry."LU Location Code" := LULocationCode;
        UnitEntry."Location Code" := LocationCode;
        UnitEntry."Zone Code" := ZoneCode;
        UnitEntry."Bin Code" := BinCode;
        UnitEntry.Insert();
    end;

    /// <summary>
    /// Posts an entire Unit Worksheet, line by line.
    /// </summary>
    /// <remarks>
    /// After posting, the lines are removed. This is typically used to confirm moves or other logistic actions.
    /// </remarks>
    /// <param name="UnitWorksheetLine">A record containing multiple logistic unit worksheet lines.
    /// These lines are posted in a batch.
    /// </param>
    internal procedure PostUnitWorksheet(var UnitWorksheetLine: Record "TMAC Unit Worksheet Line")
    begin
        if UnitWorksheetLine.Findset() then
            repeat
                PostUnitWorksheetLine(UnitWorksheetLine);
            until UnitWorksheetLine.next() = 0;
        UnitWorksheetLine.DeleteAll(true);
    end;

    /// <summary>
    /// Posts a single Unit Worksheet line, creating the associated Unit Entry.
    /// </summary>
    /// <remarks>
    /// Called by PostUnitWorksheet in a loop. Sets the location code, date/time, or other relevant fields.
    /// </remarks>
    /// <param name="UnitWorksheetLine">The single line from the Worksheet to post.
    /// This line’s data is moved into the Unit Entry ledger.
    /// </param>
    local procedure PostUnitWorksheetLine(var UnitWorksheetLine: Record "TMAC Unit Worksheet Line")
    var
        Unit: Record "TMAC Unit";
        UnitEntry: Record "TMAC Unit Entry";
        UnitLocation: Record "TMAC Unit Location";
    begin
        UnitWorksheetLine.TestField(Date);
        UnitWorksheetLine.TestField("Unit No.");

        UnitEntry.Init();
        UnitEntry."Entry No." := 0;
        UnitEntry."Unit No." := UnitWorksheetLine."Unit No.";
        UnitEntry."Date" := UnitWorksheetLine."Date";
        UnitEntry."Date and time" := UnitWorksheetLine."Date And Time";
        UnitEntry."Action Code" := UnitWorksheetLine."Action Code";
        UnitEntry."LU Location Code" := UnitWorksheetLine."LU Location Code";
        UnitEntry."Location Code" := UnitWorksheetLine."Location Code";
        UnitEntry."Zone Code" := UnitWorksheetLine."Zone Code";
        UnitEntry."Bin Code" := UnitWorksheetLine."Bin Code";
        UnitEntry.Description := UnitWorksheetLine.Description;
        UnitEntry.Insert(true);

        Unit.Get(UnitWorksheetLine."Unit No.");
        Unit."LU Location Code" := UnitWorksheetLine."LU Location Code";
        if UnitLocation.Get(UnitWorksheetLine."LU Location Code") then begin
            Unit."Inbound Logistics Enabled" := UnitLocation."Inbound Logistics Enabled";
            Unit."Outbound Logistics Enabled" := UnitLocation."Outbound Logistics Enabled";
        end;
        Unit.Modify(true);
    end;

    var
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
        UnitofMeasureMgmt: Codeunit "TMAC Unit of Measure Mgmt.";
        DocumentExistedErr: Label 'It is not allowed to archive the logistic unit with links to unposted documents. Logistic unit has link to the %1 document.', Comment = '%1 is a document number.';
        LogisticUnitTypeCheckErr: Label 'Logistic unit type %1 does not allow mixing lines from different locations or bins.', Comment = '%1 is a unit type code.';
        PostConfirmQst: Label 'Do you want to post the %1 logistic unit? Posting this logistic unit will transfer its operations to the posted entries, and it will be deleted if it does not have "Reusable" setting.', Comment = '%1 = Document Type';
        LogisticUnitAlreadyIncludedErr: Label 'Logistic Unit %1 is already included in %2 logistic unit.', Comment = '%1 is a logistic unit, %2 is a logistic unit';
        LogisticUnitIncludedErr: Label 'Logistic Units is included in another logistic unit %1. You must archive %1', Comment = '%1 is a logistic unit';
        MixSourceDocumentErr: Label 'Unit Type %1 does not allow to mix source documents for the content. Select lines for one Source Document.', Comment = '%1 is Unit Type';


    [IntegrationEvent(false, false)]
    local procedure OnBeforeCompleteUnitLine(var UnitLine: Record "TMAC Unit Line"; var SourceDocumentLink: Record "TMAC Source Document Link"; Qty: Decimal; var Handled: Boolean)
    begin
    end;
}

