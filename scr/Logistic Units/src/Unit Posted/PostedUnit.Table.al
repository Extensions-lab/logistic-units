table 71628610 "TMAC Posted Unit"
{
    Caption = 'Posted Logistic Unit';
    DrillDownPageId = "TMAC Posted Unit List";
    LookupPageId = "TMAC Posted Unit List";
    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the posted logistic unit number. It is assigned from a number series or can be entered manually if allowed.';
        }
        field(2; "Posted Version"; Integer)
        {
            Caption = 'Posted Version';
            Editable = false;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the posted version number of the logistic unit, updated each time it is posted.';
        }
        field(3; "Type Code"; Code[20])
        {
            Caption = 'Type Code';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit Type".Code;
            ToolTip = 'Specifies the logistic unit type code, such as a pallet or container.';
        }
        field(4; "Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a brief description of the posted logistic unit to help identify it.';
        }

        field(5; "Tracking No."; Text[50])
        {
            Caption = 'Tracking No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the shipping agent’s tracking number for external shipment tracking.';
        }

        field(7; Select; Boolean)
        {
            Caption = 'Select';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the posted unit is selected for further operations or review.';
        }
        field(8; "SSCC No."; Code[25])
        {
            Caption = 'SSCC No.';
            DataClassification = CustomerContent;
            TableRelation = "TMAC SSCC"."No.";
            ToolTip = 'Specifies the Serial Shipping Container Code (SSCC) that uniquely identifies this posted unit.';
        }

        field(9; "Barcode"; Text[200])
        {
            Caption = 'Barcode';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies an additional barcode or scannable code for identifying the posted logistic unit.';
        }

        field(10; "Parent Unit No."; Code[20])
        {
            Caption = 'Parent Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit"."No.";
            ToolTip = 'Specifies the number of the parent logistic unit in which this unit is nested.';
        }

        field(11; "Parent Unit Posted Version"; Integer)
        {
            Caption = 'Parent Unit Posted Version';
            Editable = false;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the posted version of the parent logistic unit, if this one is nested inside another.';
        }

        field(12; Indent; Integer)
        {
            Caption = 'Indent';
            DataClassification = CustomerContent;
            Editable = false;
            ToolTip = 'Specifies the nesting level of this posted unit within a hierarchy of units.';
        }

        field(13; "LU Location Code"; Code[20])
        {
            Caption = 'LU Location Code';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit Location";
            Editable = false;
            ToolTip = 'Specifies the code of the location where this posted unit is placed, such as in a warehouse or with a customer.';
        }
        field(14; "Inbound Logistics Enabled"; Boolean)
        {
            Caption = 'Inbound Logistics Enabled';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether inbound processes, such as receiving or put-away, can be applied to this posted unit.';
        }
        field(15; "Outbound Logistics Enabled"; Boolean)
        {
            Caption = 'Outbound Logistics Enabled';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether outbound processes, such as shipments or picking, can be applied to this posted unit.';
        }

        field(20; "Content Weight (Base)"; Decimal)
        {
            Caption = 'Content Weight (Base)';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Sum("TMAC Posted Unit Line"."Gross Weight (Base)" where("Unit No." = field("No."), "Posted Version" = field("Posted Version")));
            DecimalPlaces = 5 : 7;
            ToolTip = 'Specifies the total weight of all items or content within this posted unit, computed from its lines.';
        }

        field(22; "Content Volume (Base)"; Decimal)
        {
            Caption = 'Content Volume (Base)';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Sum("TMAC Posted Unit Line"."Volume (Base)" where("Unit No." = field("No."), "Posted Version" = field("Posted Version")));
            DecimalPlaces = 5 : 7;
            ToolTip = 'Specifies the total volume of this unit’s content, calculated from posted lines referencing it.';
        }
        field(23; "Weight (Base)"; Decimal)
        {
            Caption = 'Weight (Base)';
            DataClassification = CustomerContent;
            DecimalPlaces = 5 : 7;
            ToolTip = 'Specifies the total weight of the posted logistic unit itself, excluding contents if measured separately.';
        }

        field(24; "Volume (Base)"; Decimal)
        {
            Caption = 'Volume (Base)';
            DataClassification = CustomerContent;
            DecimalPlaces = 5 : 7;
            ToolTip = 'Specifies the total volume of the posted logistic unit itself, excluding contents if measured separately.';
        }

        field(30; "Length"; Decimal)
        {
            Caption = 'Length';
            DataClassification = CustomerContent;
            MinValue = 0;
            DecimalPlaces = 4 :;
            ToolTip = 'Specifies the measured length of the posted logistic unit for storage or shipping purposes.';
        }

        field(31; "Width"; Decimal)
        {
            Caption = 'Width';
            DataClassification = CustomerContent;
            MinValue = 0;
            DecimalPlaces = 4 :;
            ToolTip = 'Specifies the measured width of the posted logistic unit to help manage warehouse space.';
        }

        field(33; "Height"; Decimal)
        {
            Caption = 'Height';
            DataClassification = CustomerContent;
            MinValue = 0;
            DecimalPlaces = 4 :;
            ToolTip = 'Specifies the measured height of the posted logistic unit, relevant for stacking or transport plans.';
        }

        field(34; "Volume"; Decimal)
        {
            Caption = 'Volume';
            DataClassification = CustomerContent;
            MinValue = 0;
            DecimalPlaces = 4 :;
            ToolTip = 'Specifies the overall volume occupied by the posted logistic unit, separate from any base volume fields.';
        }

        field(40; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the code of the physical location in Business Central where this posted unit is stored.';
        }
        field(41; "Zone Code"; Code[10])
        {
            Caption = 'Zone Code';
            DataClassification = CustomerContent;
            TableRelation = Zone.Code WHERE("Location Code" = FIELD("Location Code"));
            ToolTip = 'Specifies the warehouse zone assigned to this posted logistic unit within the selected location.';
        }
        field(42; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            DataClassification = CustomerContent;
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"));
            ToolTip = 'Specifies the bin within the location zone where the posted logistic unit is placed.';
        }

        field(50; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent';
            DataClassification = CustomerContent;
            TableRelation = "Shipping Agent";
            ToolTip = 'Specifies which shipping agent is responsible for external transport or courier services of this unit.';
        }

        field(51; "Tracking Information"; Text[100])
        {
            Caption = 'Tracking Information';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies additional carrier or agent details about the posted logistic unit’s shipping status.';
        }

        field(80; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ToolTip = 'Specifies the number series that automatically assigns unit numbers, if manual entry is disabled.';
        }
        field(90; "Reusable"; Boolean)
        {
            Caption = 'Reusable';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the posted logistic unit can be reused multiple times, such as a standardized pallet.';
        }

        //field(100 - is reserved)
    }

    keys
    {
        key(PK; "No.", "Posted Version")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        PostedUnitLine: Record "TMAC Posted Unit Line";
        PostedUnitEntry: Record "TMAC Posted Unit Entry";
    begin
        PostedUnitLine.SetRange("Unit No.", "No.");
        PostedUnitLine.SetRange("Posted Version", "Posted Version");
        PostedUnitLine.DeleteAll(true);

        PostedUnitEntry.Setrange("Unit No.", "No.");
        PostedUnitEntry.SetRange("Posted Version", "Posted Version");
        PostedUnitEntry.DeleteAll(true);
    end;
}