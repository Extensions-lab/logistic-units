table 71628601 "TMAC Unit Line"
{
    Caption = 'Unit Line';

    fields
    {
        field(1; "Unit No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit"."No.";
            Tooltip = 'Specifies the logistic unit that this line belongs to, such as a pallet or container.';
        }
        field(3; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the number that uniquely identifies this line within the logistic unit.';
        }
        field(4; "Type"; Enum "TMAC Unit Line Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the line type: Item for products or Unit for nested logistic units.';
            trigger OnValidate()
            begin
                if Type <> xRec.Type then
                    Validate("No.", '');

                OnAfterTypeValidate(Rec, xRec);
            end;
        }
        field(5; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Type" = CONST(Item)) "Item"."No."
            ELSE
            IF ("Type" = CONST("Unit")) "TMAC Unit"."No.";
            Tooltip = 'Specifies the identifier of the item or nested logistic unit, based on the line type.';

            trigger OnValidate()
            var
                Item: Record Item;
                Unit: Record "TMAC Unit";
                UnitHeader: Record "TMAC Unit";
            begin
                if Rec."No." <> xRec."No." then
                    ClearLine();

                if "No." = '' then
                    exit;

                UnitHeader.get("Unit No.");

                case "Type" of
                    "Type"::"Item":
                        begin
                            Item.Get("No.");
                            Validate(Description, Item.Description);
                            Validate("Description 2", Item."Description 2");
                            Validate("Unit of Measure Code", Item."Base Unit of Measure");
                            Validate(GTIN, Item.GTIN);
                        end;
                    "Type"::"Unit":
                        begin
                            Unit.Get("No.");
                            if "Unit No." = "No." then
                                error(CannotAddToItselfErr);
                            Validate(Description, Unit.Description);
                            Validate(SSCC, Unit."SSCC No.");
                            Validate(Quantity, 1);
                            Validate("Unit of Measure Code", '');
                            Validate("Quantity (Base)", 1);
                            Validate("Gross Weight (base)", Unit."Weight (Base)");
                            Validate("Volume (base)", Unit."Volume (Base)");
                            UnitManagement.Include("No.", "Unit No.", "Line No.");
                        end;
                end;

                OnAfterNoValidate(Rec, xRec);
            end;

            trigger OnLookup()
            var
                Item: Record Item;
                Unit: Record "TMAC Unit";
                UnitHeader: Record "TMAC Unit";
            begin
                UnitHeader.get("Unit No.");
                case "Type" of
                    "Type"::"Item":
                        begin
                            if Item.Get("No.") then;
                            if Page.RunModal(0, Item) = Action::LookupOK then
                                Validate("No.", Item."No.");
                        end;
                    "Type"::"Unit":
                        begin
                            Unit.Reset();
                            Unit.FilterGroup(2);
                            Unit.SetFilter("No.", '<>%1', "Unit No.");
                            Unit.Setrange(Indent, 0);
                            Unit.FilterGroup(0);
                            if Page.RunModal(0, Unit) = Action::LookupOK then
                                Validate("No.", Unit."No.");
                        end;
                end;
                OnAfterNoLookup(Rec, xRec);
            end;
        }
        field(6; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST(Item)) "Item Variant".Code where("Item No." = field("No."));
            Tooltip = 'Specifies the item variant, such as color or size, if the line type is Item.';
            trigger OnValidate()
            var
                Item: Record Item;
                ItemVariant: Record "Item Variant";
            begin
                if Type = "TMAC Unit Line Type"::Item then
                    if "Variant Code" = '' then begin
                        Item.Get("No.");
                        Validate(Description, Item.Description);
                        Validate("Description 2", Item."Description 2");
                    end else begin
                        ItemVariant.get("No.", "Variant Code");
                        Validate(Description, ItemVariant.Description);
                        Validate("Description 2", ItemVariant."Description 2");
                    end;
            end;
        }
        field(7; "Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies a short description of the item or nested logistic unit on this line.';
        }
        field(8; "Description 2"; Text[100])
        {
            Caption = 'Description 2';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies an additional line of description for the item or nested logistic unit.';
        }
        field(9; GTIN; Code[14])
        {
            Caption = 'GTIN';
            Numeric = true;
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the Global Trade Item Number for uniquely identifying the product worldwide.';
        }
        field(10; "SSCC"; Code[25])
        {
            Caption = 'SSCC';
            DataClassification = CustomerContent;
            TableRelation = "TMAC SSCC"."No.";
            Tooltip = 'Specifies the Serial Shipping Container Code for globally tracking the logistic unit line.';
        }
        field(13; "Quantity"; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            MinValue = 0;
            Tooltip = 'Specifies how many units of the item or nested logistic unit are included on this line.';

            trigger OnValidate()
            var
                Item: Record Item;
                ItemUnitOFMeasure: Record "Item Unit of Measure";
            begin

                case Type of
                    Type::Item:
                        begin
                            Item.Get("No.");
                            "Quantity (Base)" := BCUnitofMeasureManagement.CalcBaseQty(Quantity, "Qty. per Unit of Measure");
                            ItemUnitOFMeasure.Get("No.", "Unit of Measure Code");

                            if ItemUnitOFMeasure.Weight <> 0 then begin
                                Validate("Gross Weight (base)", ItemUnitOFMeasure.Weight * "Quantity");
                                Validate("Net Weight (base)", ItemUnitOFMeasure.Weight * "Quantity");
                            end else begin
                                Validate("Gross Weight (base)", Item."Gross Weight" * "Quantity (Base)");
                                Validate("Net Weight (base)", Item."Net Weight" * "Quantity (Base)");
                            end;
                            if ItemUnitOFMeasure.Cubage <> 0 then
                                Validate("Volume (base)", ItemUnitOFMeasure.Cubage * "Quantity")
                            else
                                Validate("Volume (base)", Item."Unit Volume" * "Quantity (Base)");
                        end;
                    Type::Unit:
                        Quantity := 1;
                end;

                OnAfterQuantityValidate(Rec, xRec);
            end;
        }
        field(14; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST(Item), "No." = FILTER(<> '')) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));
            Tooltip = 'Specifies how each unit is measured if this line is an item. By default, the item’s base unit is used.';

            trigger OnValidate()
            var
                Item: Record Item;
                ItemUnitOFMeasure: Record "Item Unit of Measure";
            begin
                case "Type" of
                    "Type"::Item:
                        begin
                            ItemUnitOFMeasure.Get("No.", "Unit of Measure Code");
                            Item.Get("No.");
                            "Qty. per Unit of Measure" := BCUnitofMeasureManagement.GetQtyPerUnitOfMeasure(Item, "Unit of Measure Code");
                        end;
                end;

                OnAfterUnitOfMeasureCodeValidate(Rec, xRec);

                if Quantity <> 0 then
                    Validate(Quantity);
            end;

        }
        field(15; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
            InitValue = 1;
            Tooltip = 'Specifies how many base units of the item fit into the selected unit of measure.';
        }
        field(16; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the quantity in base units of measure, for consistent calculations.';
        }
        field(17; "Gross Weight (base)"; Decimal)
        {
            Caption = 'Gross Weight';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the total weight, including packaging, in base weight units for this line.';
        }
        field(18; "Net Weight (base)"; Decimal)
        {
            Caption = 'Net Weight';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the item’s weight minus packaging, in base weight units.';
        }
        field(19; "Volume (base)"; Decimal)
        {
            Caption = 'Volume';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the total volume in base volume units for the item or nested unit on this line.';
        }
        field(20; "Unit Type Code"; Code[20])
        {
            Caption = 'Unit Type Code';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit Type".Code;
            Tooltip = 'Specifies the type code for the logistic unit, if relevant for dimensions or usage rules.';
        }
        field(25; "Freight Class"; Code[10])
        {
            Caption = 'Freight Class';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Freight Class".Code;
            Tooltip = 'Specifies the classification for freight rating or compliance when shipping this product.';
        }

        field(40; "Linked Type Filter"; Integer)
        {
            Caption = 'Linked Type Filter';
            FieldClass = FlowFilter;
            Tooltip = 'Specifies a filter used internally for linking this line to specific source documents or references.';
        }
        field(41; "Linked Subtype Filter"; Integer)
        {
            Caption = 'Linked Subtype Filter';
            FieldClass = FlowFilter;
            Tooltip = 'Specifies a further filter for linking the line to particular subtypes of source documents or references.';
        }
        field(42; "Linked Quantity"; decimal)
        {
            Caption = 'Linked Quantity';
            FieldClass = FlowField;
            Tooltip = 'Specifies the total linked quantity from documents or records associated with this line.';
            CalcFormula = sum("TMAC Unit Line Link"."Quantity" where(
                "Unit No." = field("Unit No."),
                "Unit Line No." = field("Line No."),
                "Source Type" = FIELD("Linked Type Filter"),
                "Source Subtype" = FIELD("Linked Subtype Filter")));
            Editable = false;
        }
        field(43; "Linked Quantity (Base)"; decimal)
        {
            Caption = 'Linked Quantity (Base)';
            FieldClass = FlowField;
            Tooltip = 'Specifies the total base quantity from documents or records linked to this line.';
            CalcFormula = sum("TMAC Unit Line Link"."Quantity (Base)" where(
                "Unit No." = field("Unit No."),
                "Unit Line No." = field("Line No."),
                "Source Type" = FIELD("Linked Type Filter"),
                "Source Subtype" = FIELD("Linked Subtype Filter")));
            Editable = false;
        }
        field(44; "Linked Links Exist"; Boolean)
        {
            Caption = 'Linked Links Exist';
            FieldClass = FlowField;
            Tooltip = 'Specifies whether this line has any references to external documents or lines.';
            CalcFormula = exist("TMAC Unit Line Link" where(
                "Unit No." = field("Unit No."),
                "Unit Line No." = field("Line No."),
                "Source Type" = FIELD("Linked Type Filter"),
                "Source Subtype" = FIELD("Linked Subtype Filter")));
            Editable = false;
        }

        field(45; "Inventory Quantity"; Decimal)
        {
            Caption = 'Inventory Quantity';
            FieldClass = FlowField;
            Tooltip = 'Specifies the posted quantity from related documents, reflecting actual usage or stock movements.';
            CalcFormula = sum("TMAC Unit Line Link"."Quantity" where(
                "Unit No." = field("Unit No."),
                "Unit Line No." = field("Line No."),
                "Posted" = const(true),
                "Calculation" = const(true)));
            Editable = false;
        }

        field(46; "Inventory Quantity (Base)"; Decimal)
        {
            Caption = 'Inventory Quantity (Base)';
            FieldClass = FlowField;
            Tooltip = 'Specifies the posted base quantity from related documents, in the item’s base units.';
            CalcFormula = sum("TMAC Unit Line Link"."Quantity (Base)" where(
                "Unit No." = field("Unit No."),
                "Unit Line No." = field("Line No."),
                "Posted" = const(true),
                "Calculation" = const(true)));
            Editable = false;
        }

        /// <summary>
        /// Expected quantity taking into account all unposted documents,  
        /// i.e. all planned receipts and shipments,  
        /// therefore no filter by "posted" is needed.
        /// </summary>
        field(47; "Expected Quantity"; Decimal)
        {
            Caption = 'Expected Quantity';
            FieldClass = FlowField;
            Tooltip = 'Specifies the total unposted quantity from planned or open documents that affect this line.';
            CalcFormula = sum("TMAC Unit Line Link"."Quantity" where(
                "Unit No." = field("Unit No."),
                "Unit Line No." = field("Line No."),
                "Calculation" = const(true)));
            Editable = false;
        }

        field(48; "Expected Quantity (Base)"; Decimal)
        {
            Caption = 'Expected Quantity (Base)';
            FieldClass = FlowField;
            Tooltip = 'Specifies the total unposted base quantity from planned or open documents for this line.';
            CalcFormula = sum("TMAC Unit Line Link"."Quantity (Base)" where(
                "Unit No." = field("Unit No."),
                "Unit Line No." = field("Line No."),
                "Calculation" = const(true)));
            Editable = false;
        }


        field(50; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the location where the item or nested unit on this line is physically stored.';
            trigger OnValidate()
            begin
                OnAfterLocationCodeChanged(Rec, xRec);
            end;
        }
        field(51; "Zone Code"; Code[10])
        {
            Caption = 'Zone Code';
            DataClassification = CustomerContent;
            TableRelation = Zone.Code WHERE("Location Code" = FIELD("Location Code"));
            Tooltip = 'Specifies the warehouse zone within the location where this line is placed, if zones are used.';
        }
        field(52; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            DataClassification = CustomerContent;
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"));
            Tooltip = 'Specifies the bin in the warehouse location or zone where this line is placed.';
            trigger OnValidate()
            begin
                OnAfterBinCodeChanged(Rec, xRec);
            end;
        }

        field(150; "Unit System ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Tooltip = 'Specifies the unique system identifier used for synchronizing and linking logistic units in the system.';
        }
    }

    keys
    {
        key(PK; "Unit No.", "Line No.")
        {
            Clustered = true;
            SumIndexFields = "Gross Weight (base)", "Net Weight (base)", "Volume (base)", "Quantity";
        }
        key(key1; "Type", "No.")
        {
        }
        key(Key2; "Type", "No.", "Variant Code", "Location Code", "Bin Code")
        {
        }
    }


    trigger OnInsert()
    var
        Unit: Record "TMAC Unit";
    begin
        if Unit.Get("Unit No.") then begin
            "Unit Type Code" := Unit."Type Code";
            "Unit System ID" := Unit.SystemId;
        end;

        if IsTemporary then
            exit;

        if "Type" = "TMAC Unit Line Type"::Unit then
            UnitManagement.Include("No.", "Unit No.", "Line No.");

        UnitManagement.UpdateUnitWeightAndVolume("Unit No.", 0, "Gross Weight (base)", 0);

        OnAfterInsertNewLine(Rec);
    end;

    trigger OnModify()
    begin
        CalcFields("Linked Links Exist");
        if Rec."Linked Links Exist" then
            error(LineIsLinkedErr);
    end;

    trigger OnDelete()
    var
        UnitLineLink: Record "TMAC Unit Line Link";
    begin
        if IsTemporary then
            exit;

        UnitLineLink.Reset();
        UnitLineLink.Setrange("Unit No.", "Unit No.");
        UnitLineLink.SetRange("Unit Line No.", "Line No.");
        UnitLineLink.DeleteAll();

        //removal of mirrored links FOR THIS line (these are connection links line LU <-> line LU)
        UnitLineLink.Reset();
        UnitLineLink.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.", "Package No.", "Lot No.", "Serial No.", "Positive", "Qty. to Post");
        UnitLineLink.Setrange("Source Type", Database::"TMAC Unit Line");
        UnitLineLink.SetRange("Source Subtype", 0);
        UnitLineLink.SetRange("Source ID", Rec."Unit No.");
        UnitLineLink.Setrange("Source Ref. No.", "Line No.");
        UnitLineLink.DeleteAll(true);

        if Type = "TMAC Unit Line Type"::Unit then
            UnitManagement.Exclude("No.");

        //if the entire pallet is removed, nothing needs to be recalculated (most likely not correct though, the parent should be updated)
        if not IsHeaderDelete then
            UnitManagement.UpdateUnitWeightAndVolume("Unit No.", "Line No.", 0, 0); //we deleted something from this logistic unit, which means the weight has changed too
    end;

    trigger OnRename()
    var
        Unit: Record "TMAC Unit";
        EmptyGUID: GUID;
    begin
        if Unit.Get("Unit No.") then begin
            "Unit Type Code" := Unit."Type Code";
            "Unit System ID" := Unit.SystemId;
        end else
            "Unit System ID" := EmptyGUID;
    end;

    local procedure ClearLine()
    begin
        Description := '';
        "Description 2" := '';
        Quantity := 0;
        "Unit of Measure Code" := '';
        "Quantity (Base)" := 0;
        "Qty. per Unit of Measure" := 0;
        "Gross Weight (base)" := 0;
        "Net Weight (base)" := 0;
        "Volume (base)" := 0;
    end;

    internal procedure HeaderDelete(SetValue: Boolean)
    begin
        IsHeaderDelete := SetValue;
    end;

    var
        UnitManagement: Codeunit "TMAC Unit Management";
        BCUnitofMeasureManagement: Codeunit "Unit of Measure Management";
        CannotAddToItselfErr: Label 'You cannot add a unit to itself.';
        LineIsLinkedErr: Label 'Logistic unit line is linked to the documents.';

    protected var
        IsHeaderDelete: Boolean;


    [IntegrationEvent(false, false)]
    local procedure OnAfterLocationCodeChanged(var UnitLine: Record "TMAC Unit Line"; var xUnitLine: Record "TMAC Unit Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBinCodeChanged(var UnitLine: Record "TMAC Unit Line"; var xUnitLine: Record "TMAC Unit Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertNewLine(var UnitLine: Record "TMAC Unit Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTypeValidate(var UnitLine: Record "TMAC Unit Line"; var xUnitLine: Record "TMAC Unit Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterNoValidate(var UnitLine: Record "TMAC Unit Line"; var xUnitLine: Record "TMAC Unit Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterNoLookup(var UnitLine: Record "TMAC Unit Line"; var xUnitLine: Record "TMAC Unit Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterQuantityValidate(var UnitLine: Record "TMAC Unit Line"; var xUnitLine: Record "TMAC Unit Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUnitOfMeasureCodeValidate(var UnitLine: Record "TMAC Unit Line"; var xUnitLine: Record "TMAC Unit Line")
    begin
    end;
}