table 71628600 "TMAC Unit"
{
    Caption = 'Logistic Unit';
    DrillDownPageId = "TMAC Unit List";
    LookupPageId = "TMAC Unit List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the unique identifier of the logistic unit. If the logistic unit is reusable, it can be identified by a GRAI (Global Returnable Asset Identifier).';
        }
        field(3; "Type Code"; Code[20])
        {
            Caption = 'Type Code';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit Type".Code;
            Tooltip = 'Specifies the logistic unit type, determining its default dimensions, volume, and reusability. This field is linked to the TMAC Unit Type table.';
            trigger OnValidate()
            var
                UnitType: Record "TMAC Unit Type";
                UnitofMeasureMgmt: Codeunit "TMAC Unit of Measure Mgmt.";
                SeriesNo: Code[20];
            begin
                if not UnitType.Get("Type Code") then
                    exit;

                LogisticUnitsSetup.Get();

                OrderWasRenamed := false;

                Validate("Volume (Base)", UnitofMeasureMgmt.ConvertToBaseVolumeRnd(UnitType."Volume Unit of Measure", UnitType."Unit Volume"));
                Description := UnitType.Description;

                if LogisticUnitsSetup."Base Linear Unit of Measure" <> '' then begin
                    Validate(Length, UnitofMeasureMgmt.ConvertRnd(UnitType."Linear Unit of Measure", UnitType.Length, LogisticUnitsSetup."Base Linear Unit of Measure"));
                    Validate(Width, UnitofMeasureMgmt.ConvertRnd(UnitType."Linear Unit of Measure", UnitType.Width, LogisticUnitsSetup."Base Linear Unit of Measure"));
                    Validate(Height, UnitofMeasureMgmt.ConvertRnd(UnitType."Linear Unit of Measure", UnitType.Height, LogisticUnitsSetup."Base Linear Unit of Measure"));
                end else begin
                    Validate(Length, UnitofMeasureMgmt.ConvertToSystemUoMRnd(UnitType."Linear Unit of Measure", UnitType.Length));
                    Validate(Width, UnitofMeasureMgmt.ConvertToSystemUoMRnd(UnitType."Linear Unit of Measure", UnitType.Width));
                    Validate(Height, UnitofMeasureMgmt.ConvertToSystemUoMRnd(UnitType."Linear Unit of Measure", UnitType.Height));
                end;

                "Reusable" := UnitType."Reusable";

                if "No." = '' then begin
                    if UnitType."No. Series" <> '' then
                        SeriesNo := UnitType."No. Series"
                    else
                        SeriesNo := LogisticUnitsSetup."Unit Nos.";

                    "No." := NoSeries.GetNextNo(SeriesNo);
                end;
            end;
        }

        field(4; "Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies a short description of the logistic unit, such as the type or intended contents.';
        }
        field(5; "Tracking No."; Text[50])
        {
            Caption = 'Tracking No.';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the carrier-provided package identifier for tracking shipments related to this logistic unit.';
        }

        field(7; Select; Boolean)
        {
            Caption = 'Select';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies whether this logistic unit ismarked for further processing or bulk operations.';
        }

        field(8; "SSCC No."; Code[25])
        {
            Caption = 'SSCC';
            DataClassification = CustomerContent;
            TableRelation = "TMAC SSCC"."No.";
            Tooltip = 'Specifies the Serial Shipping Container Code (SSCC) for unique global identification of this logistic unit.';
        }

        field(9; "Barcode"; Text[200])
        {
            Caption = 'Barcode';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies an additional barcode used to scan and identify this logistic unit in warehouse processes.';
        }

        field(10; "Parent Unit No."; Code[20])
        {
            Caption = 'Parent Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit"."No.";
            Tooltip = 'Specifies the parent logistic unit, if any, indicating that this unit is nested inside another.';
            Editable = false;
        }

        // field(11) - reserved - dont use!!!!

        field(12; Indent; Integer)
        {
            Caption = 'Indent';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the hierarchical level of the logistic unit in nested structures. Used internally for display.';
            Editable = false;
        }

        field(13; "LU Location Code"; Code[20])
        {
            Caption = 'LU Location Code';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit Location";
            Tooltip = 'Specifies a custom location code that indicates if this logistic unit is in the warehouse or off-site.';
            Editable = false;
        }

        /// <summary>
        /// Essentially system fields from Logistic Unit Location that determine  
        /// whether we can use pallets in certain processes.
        /// </summary>
        field(14; "Inbound Logistics Enabled"; Boolean)
        {
            Caption = 'Inbound Logistics Enabled';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies whether inbound operations, such as receiving or returns, can be performed on this logistic unit.';
        }

        field(15; "Outbound Logistics Enabled"; Boolean)
        {
            Caption = 'Outbound Logistics Enabled';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies whether outbound operations, such as shipping or transfers, can be performed on this logistic unit.';
        }

        field(20; "Content Weight (Base)"; Decimal)
        {
            Caption = 'Content Weight (Base)';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Sum("TMAC Unit Line"."Gross Weight (Base)" where("Unit No." = field("No.")));
            DecimalPlaces = 0 : 3;
            Tooltip = 'Specifies the total weight of items contained in this unit, in base weight units.';
        }

        field(22; "Content Volume (Base)"; Decimal)
        {
            Caption = 'Content Volume (Base)';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Sum("TMAC Unit Line"."Volume (Base)" where("Unit No." = field("No.")));
            DecimalPlaces = 0 : 3;
            Tooltip = 'Specifies the total volume of items contained in this unit, in base volume units.';
        }

        /// <summary>
        /// Total weight including packaging and contents.
        /// </summary>
        field(23; "Weight (Base)"; Decimal)
        {
            Caption = 'Weight (Base)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 3;
            Tooltip = 'Specifies the total weight of this logistic unit, including packaging and contents, in base weight units.';
        }

        field(24; "Volume (Base)"; Decimal)
        {
            Caption = 'Volume (Base)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 3;
            Tooltip = 'Specifies the total volume of this logistic unit (tare plus contents), in base volume units.';
        }

        field(30; "Length"; Decimal)
        {
            Caption = 'Length';
            DataClassification = CustomerContent;
            MinValue = 0;
            Tooltip = 'Specifies the length of this logistic unit, used to calculate volume and determine warehouse storage needs.';
            trigger OnValidate()
            begin
                Validate("Volume", "Length" * "Width" * "Height");
            end;
        }

        field(31; "Width"; Decimal)
        {
            Caption = 'Width';
            DataClassification = CustomerContent;
            MinValue = 0;
            Tooltip = 'Specifies the width of this logistic unit, used to calculate volume and determine storage layout.';
            trigger OnValidate()
            begin
                Validate("Volume", "Length" * "Width" * "Height");
            end;
        }
        field(33; "Height"; Decimal)
        {
            Caption = 'Height';
            DataClassification = CustomerContent;
            MinValue = 0;
            Tooltip = 'Specifies the height of this logistic unit, used to calculate volume and assess stackability.';
            trigger OnValidate()
            begin
                Validate("Volume", "Length" * "Width" * "Height");
            end;
        }
        field(34; "Volume"; Decimal)
        {
            Caption = 'Volume';
            DataClassification = CustomerContent;
            MinValue = 0;
            Tooltip = 'Specifies the manually set volume of this logistic unit. Changing this resets the length, width, and height to zero.';
            trigger OnValidate()
            begin
                if CurrFieldNo = FieldNo("Volume") then begin
                    Length := 0;
                    Width := 0;
                    Height := 0;
                end;
            end;
        }

        field(40; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the warehouse location code where this logistic unit resides, used for inventory and shipping management.';
            trigger OnValidate()
            begin
                if "Location Code" = '' then begin
                    "Zone Code" := '';
                    "Bin Code" := '';
                end;
            end;
        }

        field(41; "Zone Code"; Code[10])
        {
            Caption = 'Zone Code';
            DataClassification = CustomerContent;
            TableRelation = Zone.Code WHERE("Location Code" = FIELD("Location Code"));
            Tooltip = 'Specifies the zone within the location where this logistic unit is stored, if zones are used.';
        }

        field(42; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            DataClassification = CustomerContent;
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"));
            Tooltip = 'Specifies the bin where the logistic unit is physically placed, providing precise storage tracking.';
        }
        field(50; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent';
            DataClassification = CustomerContent;
            TableRelation = "Shipping Agent";
            Tooltip = 'Specifies the shipping agent responsible for transporting this logistic unit, such as a carrier or external courier.';
        }
        field(51; "Tracking Information"; Text[100])
        {
            Caption = 'Tracking Information';
            DataClassification = CustomerContent;
            Editable = false;
            Tooltip = 'Specifies additional carrier tracking details or status updates, enabling real-time shipment visibility.';
        }

        field(80; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            Tooltip = 'Specifies the number series used if the logistic unit number is automatically generated rather than entered manually.';
        }
        field(90; "Reusable"; Boolean)
        {
            Caption = 'Reusable';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies whether this logistic unit is suitable for repeated use, such as a standardized reusable pallet.';
        }

        field(100; "Archived"; Integer)
        {
            Caption = 'Archived';
            FieldClass = FlowField;
            CalcFormula = count("TMAC Posted Unit" where("No." = field("No.")));
            Editable = false;
            Tooltip = 'Specifies how many archived versions exist for this logistic unit in the posted ledger, showing its historical usage.';
        }

    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(Key1; "LU Location Code", "Location Code", "Zone Code", "Bin Code")
        {

        }
    }

    trigger OnInsert()
    var
        UnitAction: Record "TMAC Unit Action";
        UnitLocation: Record "TMAC Unit Location";
        UnitType: Record "TMAC Unit Type";
        SSCCManagement: Codeunit "TMAC SSCC Management";
        UnitManagement: Codeunit "TMAC Unit Management";
        Location: Code[20];
        Action: Code[10];
    begin
        if IsTemporary then
            exit;

        LogisticUnitsSetup.Get();

        InitRecord();

        UnitAction.Setrange(Create, true);
        if UnitAction.FindFirst() then
            Action := UnitAction.Code;

        UnitLocation.Setrange("Default Creation Location", true);
        if UnitLocation.FindFirst() then begin
            "LU Location Code" := UnitLocation.Code;
            "Inbound Logistics Enabled" := UnitLocation."Inbound Logistics Enabled";
            "Outbound Logistics Enabled" := UnitLocation."Outbound Logistics Enabled";
            Location := UnitLocation.Code;
        end;

        if (Action <> '') or (Location <> '') then
            UnitManagement.CreateUnitEntry("No.", Action, Location);


        if UnitType.GET("Type Code") then
            if UnitType."Automatic SSCC Creation" then
                SSCCManagement.CreateSSCC(Rec);

        if "Shipping Agent Code" = '' then
            if LogisticUnitsSetup."Default Shipping Agent" <> '' then
                "Shipping Agent COde" := LogisticUnitsSetup."Default Shipping Agent";
    end;

    trigger OnDelete()
    var
        UnitLine: Record "TMAC Unit Line";
        UnitEntry: Record "TMAC Unit Entry";
        UnitManagement: Codeunit "TMAC Unit Management";
    begin
        if IsTemporary then
            exit;

        if "Reusable" then
            Error(DeleteReusableLUErr);

        // if there are nested LUs, deletion is not allowed
        UnitLine.Reset();
        UnitLine.Setrange("Unit No.", "No.");
        UnitLine.Setrange(Type, UnitLine.Type::Unit);
        if not UnitLine.IsEmpty then
            Error(DeleteLUErr);

        // delete the Unit Line of the logistic unit that THIS LU was part of
        UnitLine.Reset();
        UnitLine.Setrange(Type, UnitLine.Type::Unit);
        UnitLine.SetRange("No.", "No.");
        if UnitLine.FindFirst() then begin
            UnitLine.Delete(false); // the trigger should not be called (since it excludes this unit there)
            UnitManagement.UpdateUnitWeightAndVolume(UnitLine."Unit No.", 0, 0, 0); // update the weight of the parent LU
        end;

        // delete the contents of this logistic unit
        Clear(UnitLine);
        UnitLine.Reset();
        UnitLine.HeaderDelete(true);
        UnitLine.Setrange("Unit No.", "No.");
        while UnitLine.FindFirst() Do  // why delete like this? DeleteAll(true) doesn't recognize the variable set via the UnitLine.HeaderDelete(true) function
            UnitLine.Delete(true);

        UnitEntry.Setrange("Unit No.", "No.");
        UnitEntry.DeleteAll(true);
    end;

    local procedure InitRecord()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitRecord(Rec, IsHandled);
        if IsHandled then
            exit;

        InsertTrigger := true;
        Validate("Type Code");

        OnAfterInitRecord(Rec);
    end;

    var
        LogisticUnitsSetup: Record "TMAC Logistic Units Setup";
        NoSeries: Codeunit "No. Series";

    internal procedure IsOrderRenamed(): Boolean
    begin
        exit(OrderWasRenamed);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitRecord(var Unit: Record "TMAC Unit")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitRecord(var Unit: Record "TMAC Unit"; var IsHandled: Boolean)
    begin
    end;

    var
        InsertTrigger: Boolean;
        OrderWasRenamed: Boolean;

        DeleteLUErr: Label 'You cannot delete logistic units with nested logistic units. Eliminate the nested LUs before deleting this logistic unit.';

        DeleteReusableLUErr: Label 'You cannot delete a reusable logistics unit. The reusable field protects the logistic unit from deletion, preventing accidental deletions.';
}