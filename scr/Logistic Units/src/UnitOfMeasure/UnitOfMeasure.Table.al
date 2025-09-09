
table 71628579 "TMAC Unit of Measure"
{
    Caption = 'Unit of Measure (Logistic Units)';
    DataCaptionFields = "Code", Description;
    DrillDownPageID = "TMAC Units Of Measure";
    LookupPageID = "TMAC Units Of Measure";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a code identifying this unit of measure for use in the transportation management system.';
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a descriptive name for this unit of measure, aiding user recognition.';
        }
        field(3; "Type"; Enum "TMAC Unit of Measure Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the measurement category: Linear, Area, Volume, or Mass.';
        }

        field(4; "Conversion Factor"; Decimal)
        {
            Caption = 'Conversion Factor';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 10;
            MinValue = 0;
            ToolTip = 'Specifies how to convert this unit into the metric base (e.g. metres, cubic metres, kilograms).';
        }

        field(5; "International Standard Code"; Code[10])
        {
            Caption = 'International Standard Code';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the standard UNECERec20 code for electronic documents referencing this unit.';
        }

        field(6; Caption; Text[10])
        {
            Caption = 'Caption';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a short text label for fields that use this unit of measure.';
        }

        field(7; Comment; Text[100])
        {
            Caption = 'Comment';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies additional notes about this unit of measure, such as usage tips or remarks.';
        }

        field(8; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether this unit of measure is disallowed for usage in new records.';
        }
        field(9; "Value Rounding Precision"; Decimal)
        {
            Caption = 'Value Rounding Precision';
            DataClassification = CustomerContent;
            InitValue = 0.001;
            MinValue = 0;
            ToolTip = 'Specifies the smallest decimal increment to which values in this unit are rounded.';
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; "Code", Description, "International Standard Code")
        {
        }
        fieldgroup(DropDown; "Code", Description, Caption)
        {
        }
    }

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}