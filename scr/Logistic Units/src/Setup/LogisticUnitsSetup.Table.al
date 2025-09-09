table 71628575 "TMAC Logistic Units Setup"
{
    Caption = 'Logistic Units Setup';

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the main identifier for this logistic units setup record, used for referencing.';
        }

        field(2; "Assisted Setup Completed"; Boolean)
        {
            Caption = 'Assisted Setup Completed';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies whether the assisted setup wizard for logistic units has been finished.';
        }

        field(3; "Global Company Prefix"; Code[15])
        {
            Caption = 'Global Company Prefix';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the unique global prefix assigned by GS1 for identifying and tracking items or containers.';
        }

        field(4; "Default Shipping Agent"; Code[10])
        {
            Caption = 'Default Shipping Agent';
            DataClassification = CustomerContent;
            TableRelation = "Shipping Agent";
            Tooltip = 'Specifies which shipping agent is used by default when creating new logistic units, if none is specified.';
        }

        /// <summary>
        /// Number series used when no number series is defined for the logistic unit type.
        /// </summary>
        field(10; "Unit Nos."; Code[10])
        {
            Caption = 'Unit Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            Tooltip = 'Specifies the default number series for generating logistic unit codes if a unit type does not have its own series.';
        }

        field(11; "SSCC Nos."; Code[10])
        {
            Caption = 'SSCC Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            Tooltip = 'Specifies the number series for generating SSCC codes, used for uniquely identifying logistic units.';
        }
        field(12; "SSCC Check Digit"; Boolean)
        {
            Caption = 'SSCC Check Digit';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies whether a check digit is automatically calculated and appended to the SSCC code.';
        }


        field(30; "Base Weight Unit of Measure"; Code[10])
        {
            Caption = 'Base Weight Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit of Measure".Code where(Type = const(Mass), Blocked = const(false));
            Tooltip = 'Specifies the base unit of measure used for weight control, such as KG or LB.';
            trigger OnValidate()
            var
                UnitofMeasure: Record "TMAC Unit of Measure";
            begin
                if xRec."Base Weight Unit of Measure" <> "Base Weight Unit of Measure" then
                    if GuiAllowed then
                        if not Confirm(ChangeBaseWeightUoMQst) then
                            exit;
                UpdateBaseWeightUoM(xRec."Base Weight Unit of Measure", "Base Weight Unit of Measure");
                IF UnitofMeasure.get("Base Weight Unit of Measure") then
                    "Base Weight UoM Caption" := UnitofMeasure.Caption;
            end;
        }

        field(31; "Base Volume Unit of Measure"; Code[10])
        {
            Caption = 'Base Volume Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit of Measure".Code where(Type = const(Volume), Blocked = const(false));
            Tooltip = 'Specifies the base unit of measure for volume calculations, enabling dimension checks.';
            trigger OnValidate()
            var
                UnitofMeasure: Record "TMAC Unit of Measure";
            begin
                if xRec."Base Volume Unit of Measure" <> "Base Volume Unit of Measure" then
                    if GuiAllowed then
                        if not Confirm(ChangeBaseVolumeWeightUoMQst) then
                            exit;
                UpdateBaseVolumeUoM(xRec."Base Volume Unit of Measure", "Base Volume Unit of Measure");
                IF UnitofMeasure.get("Base Volume Unit of Measure") then
                    "Base Volume UoM Caption" := UnitofMeasure.Caption;
            end;
        }

        field(32; "Base Linear Unit of Measure"; Code[10])
        {
            Caption = 'Base Linear Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit of Measure".Code where(Type = const(Linear), Blocked = const(false));
            Tooltip = 'Specifies the base linear unit, such as CM or IN, used to track length, width, and height.';
            trigger OnValidate()
            var
                UnitofMeasure: Record "TMAC Unit of Measure";
            begin
                IF UnitofMeasure.get("Base Linear Unit of Measure") then
                    "Base Linear UoM Caption" := UnitofMeasure.Caption;
            end;
        }
        field(33; "Base Distance Unit of Measure"; Code[10])
        {
            Caption = 'Base Distance Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit of Measure".Code where(Type = const(Linear), Blocked = const(false));
            Tooltip = 'Specifies the base distance unit used to measure travel distance or shipping routes, if applicable.';
            trigger OnValidate()
            var
                UnitofMeasure: Record "TMAC Unit of Measure";
            begin
                if xRec."Base Distance Unit of Measure" <> "Base Distance Unit of Measure" then
                    if GuiAllowed then
                        if not Confirm(ChangeBaseDistanceUoMMQst) then
                            exit;
                IF UnitofMeasure.get("Base Distance Unit of Measure") then
                    "Base Distance UoM Caption" := UnitofMeasure.Caption;
            end;
        }

        field(40; "Use Addional Reporting UoM"; Boolean)
        {
            Caption = 'Use Addional Reporting Units of Measure';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies whether additional reporting units of measure are enabled for advanced calculations.';
        }
        field(41; "Add. Reporting Weight UoM"; Code[10])
        {
            Caption = 'Add. Reporting Weight Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit of Measure".Code where(Type = const(Mass));
            Editable = false;
            Tooltip = 'Specifies the alternative weight unit for reporting alongside the base measure, if used.';
        }
        field(42; "Add. Reporting Volume UoM"; Code[10])
        {
            Caption = 'Add. Reporting Volume Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit of Measure".Code where(Type = const(Volume));
            Editable = false;
            Tooltip = 'Specifies the alternative volume unit for reporting if dual measurement is used.';
        }

        field(43; "Add. Reporting Linear UoM"; Code[10])
        {
            Caption = 'Add. Reporting Linear Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit of Measure".Code where(Type = const(Linear));
            Editable = false;
            Tooltip = 'Specifies the alternative linear unit for reporting if second-length calculations are required.';
        }
        field(44; "Add. Reporting Distance UoM"; Code[10])
        {
            Caption = 'Add. Reporting Distance Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit of Measure".Code where(Type = const(Linear));
            Editable = false;
            Tooltip = 'Specifies the alternative distance unit if multiple distance metrics are needed for reporting.';
        }

        field(50; "Def. Unit Type"; Code[20])
        {
            Caption = 'Default Unit Type';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit Type";
            Tooltip = 'Specifies which unit type is used by default when creating new logistic units if none is selected.';
        }

        /// <summary>
        /// Setting that enables automatic population of the Selected Quantity field in the New Logistic Units wizard,  
        /// based on the value from the main document lines, such as Qty. to Ship, Qty. to Receive, etc.
        /// </summary>
        field(60; "Set Default Selected Quantity"; Boolean)
        {
            Caption = 'Set Default Selected Quantity';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies that lines in the logistic unit wizard may autofill the quantity to the requested amount from the source document.';
        }

        /// <summary>
        /// Setting that excludes lines in the logistic unit creation wizard  
        /// if they do not have a Default Selected Quantity set.
        /// </summary>
        field(61; "Exclude Lines w/o Def. Qty."; Boolean)
        {
            Caption = 'Exclude Lines w/o Def. Qty.';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies that lines lacking a default quantity from the source document will be hidden in the wizard.';
        }

        /// <summary>
        /// Controls setting the Selected Quantity based on the "Default Selected Qty" field = Qty. to Ship,  
        /// instead of the available quantity.
        /// </summary>
        field(62; "Strict Control Def. Qty."; Boolean)
        {
            Caption = 'Strict Control Default Quantity';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies that the selected quantity is strictly controlled by the default quantity, ignoring any available quantity logic.';
        }

        field(65; "Auto Build Logistic Units"; Boolean)
        {
            Caption = 'Auto Build Logistic Units';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies whether logistic units can be created automatically using predefined rules in the wizard.';
        }

        field(110; "Base Linear UoM Caption"; Text[50])
        {
            Caption = 'Base Linear Unit of Measure Caption';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the descriptive label for the base linear unit, displayed to users during entry or listing.';
        }
        field(111; "Base Volume UoM Caption"; Text[50])
        {
            Caption = 'Base Volume Unit of Measure Caption';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the text that appears for the base volume unit so users understand volume references.';
        }
        field(112; "Base Weight UoM Caption"; Text[50])
        {
            Caption = 'Base Weight Unit of Measure Caption';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the text that identifies the base weight unit so users can easily see which measure is in use.';
        }
        field(113; "Base Distance UoM Caption"; Text[50])
        {
            Caption = 'Base Distance Unit of Measure Caption';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the descriptive label for the base distance unit, clarifying which metric is used for travel or shipping distances.';
        }



    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }


    local procedure UpdateBaseWeightUoM(PrevValue: Code[10]; NewValue: Code[10]);
    var
        UnitLine: Record "TMAC Unit Line";
        PostedUnitLine: Record "TMAC Posted Unit Line";
    begin
        if UnitLine.findset(true) then
            repeat
                UnitLine."Gross Weight (base)" := UnitofMeasureMgmt.ConvertRnd(PrevValue, UnitLine."Gross Weight (base)", NewValue);
                UnitLine."Net Weight (base)" := UnitofMeasureMgmt.ConvertRnd(PrevValue, UnitLine."Net Weight (base)", NewValue);
                UnitLine.Modify(false);
            until UnitLine.Next() = 0;

        if PostedUnitLine.findset(true) then
            repeat
                PostedUnitLine."Gross Weight (base)" := UnitofMeasureMgmt.ConvertRnd(PrevValue, PostedUnitLine."Gross Weight (base)", NewValue);
                PostedUnitLine."Net Weight (base)" := UnitofMeasureMgmt.ConvertRnd(PrevValue, PostedUnitLine."Net Weight (base)", NewValue);
                PostedUnitLine.Modify(false);
            until PostedUnitLine.Next() = 0;
    end;

    local procedure UpdateBaseVolumeUoM(PrevValue: Code[10]; NewValue: Code[10]);
    var
        UnitLine: Record "TMAC Unit Line";
        PostedUnitLine: Record "TMAC Posted Unit Line";
        Unit: Record "TMAC Unit";
        PostedUnit: Record "TMAC Posted Unit";
    begin
        if Unit.findset(true) then
            repeat
                Unit."Volume (base)" := UnitofMeasureMgmt.ConvertRnd(PrevValue, Unit."Volume (base)", NewValue);
                Unit.Modify(false);
            until Unit.Next() = 0;

        if PostedUnit.findset(true) then
            repeat
                PostedUnit."Volume (base)" := UnitofMeasureMgmt.ConvertRnd(PrevValue, PostedUnit."Volume (base)", NewValue);
                PostedUnit.Modify(false);
            until PostedUnit.Next() = 0;

        if UnitLine.findset(true) then
            repeat
                UnitLine."Volume (base)" := UnitofMeasureMgmt.ConvertRnd(PrevValue, UnitLine."Volume (base)", NewValue);
                UnitLine.Modify(false);
            until UnitLine.Next() = 0;

        if PostedUnitLine.findset(true) then
            repeat
                PostedUnitLine."Volume (base)" := UnitofMeasureMgmt.ConvertRnd(PrevValue, PostedUnitLine."Volume (base)", NewValue);
                PostedUnitLine.Modify(false);
            until PostedUnitLine.Next() = 0;
    end;

    var
        UnitofMeasureMgmt: Codeunit "TMAC Unit of Measure Mgmt.";
        ChangeBaseWeightUoMQst: Label 'Gross and Net Weights in Base Unit of Measure will be changed for all documents and posted entries. This can take a long time. Run? ';
        ChangeBaseVolumeWeightUoMQst: Label 'Volume in Base Unit of Measure will be changed for all documents and posted entries. This can take a long time. Run? ';
        ChangeBaseDistanceUoMMQst: Label 'Distanse Unit of Measure will be changed for all documents and posted entries. This can take a long time. Run? ';

}