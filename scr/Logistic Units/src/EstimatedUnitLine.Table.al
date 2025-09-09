table 71628671 "TMAC Estimated Unit Line"
{
    Caption = 'Estimated Unit Line';
    DataClassification = CustomerContent;
    DrillDownPageId = "TMAC Estimated Unit Lines";
    LookupPageId = "TMAC Estimated Unit Lines";

    fields
    {
        field(1; "Source Type"; Integer)
        {
            Caption = 'Source Type';
            ToolTip = 'Specifies the main record category (e.g., sales or purchase) for creating this item estimate.';
        }

        field(2; "Source Subtype"; Integer)
        {
            Caption = 'Source Subtype';
            ToolTip = 'Specifies a further classification of the source record, refining the main Source Type value.';
        }

        field(3; "Source ID"; Code[20])
        {
            Caption = 'Source ID';
            ToolTip = 'Specifies the document number or identifier used by the source process to generate this line.';
        }

        field(4; "Unit No."; Integer)
        {
            Caption = 'Unit No.';
            ToolTip = 'Specifies the estimated unit''s number to which this line belongs, linking it to the item or nested unit.';
        }

        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
            ToolTip = 'Specifies a sequential index for this line within the estimated unit, ensuring unique identification.';
        }
        field(6; "Type"; Enum "TMAC Unit Line Type")
        {
            Caption = 'Type';
            ToolTip = 'Specifies whether this line references an Item or another logistic Unit for the estimate.';
        }
        field(7; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Type" = CONST(Item)) "Item"."No."
            ELSE
            IF ("Type" = CONST("Unit")) "TMAC Unit"."No.";
            ToolTip = 'Specifies the item number or logistic unit number that this line uses for the estimation.';
        }

        field(8; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST(Item)) "Item Variant".Code WHERE("Item No." = field("No."));
            ToolTip = 'Specifies the variant if the line refers to an item with multiple variations (e.g., color, size).';
        }
        field(9; "Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies additional text or name to clarify the item or nested unit on this estimated line.';
        }

        field(10; "Quantity"; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies how many units of the item or nested unit are included for the estimate.';
        }

        field(11; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST(Item), "No." = FILTER(<> '')) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));
            ToolTip = 'Specifies the measurement unit (e.g. pieces, boxes) for the quantity on this estimated line.';
        }
        field(12; "Weight (base)"; Decimal)
        {
            Caption = 'Weight';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the total weight (in base measure) for items or nested units included in this line.';
        }
        field(13; "Volume (base)"; Decimal)
        {
            Caption = 'Volume';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the total volume (in base measure) for items or nested units included in this line.';
        }
    }
    keys
    {
        key(PK; "Source Type", "Source Subtype", "Source ID", "Unit No.", "Line No.")
        {
            Clustered = true;
            SumIndexFields = "Weight (base)", "Volume (base)";
        }
    }
}
