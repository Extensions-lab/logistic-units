table 71628670 "TMAC Estimated Unit"
{
    Caption = 'Estimated Unit';
    DataClassification = CustomerContent;
    DrillDownPageId = "TMAC Estimated Units";
    LookupPageId = "TMAC Estimated Units";

    fields
    {
        field(1; "Source Type"; Integer)
        {
            Caption = 'Source Type';
            ToolTip = 'Specifies the record type (e.g. sales, purchase) that triggers creation of this estimated unit.';
        }

        field(2; "Source Subtype"; Integer)
        {
            Caption = 'Source Subtype';
            ToolTip = 'Specifies a more detailed classification of the source record, refining the main Source Type.';
        }

        field(3; "Source ID"; Code[20])
        {
            Caption = 'Source ID';
            ToolTip = 'Specifies the identifier or document number of the source record that yields this estimated unit.';
        }

        field(10; "No."; Integer)
        {
            Caption = 'No.';
            ToolTip = 'Specifies the unique number assigned to the estimated unit, aiding identification and ordering.';
        }

        field(11; "Type Code"; Code[20])
        {
            Caption = 'Type Code';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit Type".Code;
            ToolTip = 'Specifies the logistic unit type code, such as pallet or box, predicted for this estimate.';
        }
        field(12; "Type Description"; Text[100])
        {
            Caption = 'Type Description';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit Type".Code;
            ToolTip = 'Specifies the descriptive name of the predicted logistic unit type, clarifying its nature.';
        }
        field(22; "Type Weight Limit"; Decimal)
        {
            Caption = 'Weight Limit';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the maximum recommended weight the predicted unit type can safely accommodate.';

        }
        field(23; "Type Volume Limit"; Decimal)
        {
            Caption = 'Volume Limit';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the maximum recommended volume for items in this predicted logistic unit type.';
        }
        field(30; "Weight (Base)"; Decimal)
        {
            Caption = 'Weight (Base)';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Sum("TMAC Estimated Unit Line"."Weight (Base)" where("Source Type" = field("Source Type"), "Source Subtype" = field("Source Subtype"), "Source ID" = field("Source ID"), "Unit No." = field("No.")));
            DecimalPlaces = 0 : 3;
            ToolTip = 'Specifies the total base weight of all line items forming this estimated unit''s content.';
        }

        field(32; "Volume (Base)"; Decimal)
        {
            Caption = 'Volume (Base)';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Sum("TMAC Estimated Unit Line"."Volume (Base)" where("Source Type" = field("Source Type"), "Source Subtype" = field("Source Subtype"), "Source ID" = field("Source ID"), "Unit No." = field("No.")));
            DecimalPlaces = 0 : 3;
            ToolTip = 'Specifies the total base volume occupied by line items in this estimated logistic unit.';
        }
        field(33; "Lines"; Integer)
        {
            Caption = 'Lines';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("TMAC Estimated Unit Line" where("Source Type" = field("Source Type"), "Source Subtype" = field("Source Subtype"), "Source ID" = field("Source ID"), "Unit No." = field("No.")));
            ToolTip = 'Specifies how many detail lines combine to form this estimated logistic unit''s content.';
        }

        field(40; "Completion Status"; enum "TMAC Completion Status")
        {
            Caption = 'Completion Status';
            ToolTip = 'Specifies the current progress state of this estimated unit, such as Planned or Done.';
        }

    }
    keys
    {
        key(PK; "Source Type", "Source Subtype", "Source ID", "No.")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        EstimatedUnit: Record "TMAC Estimated Unit Line";
    begin
        EstimatedUnit.SetRange("Source Type", "Source Type");
        EstimatedUnit.SetRange("Source Subtype", "Source Subtype");
        EstimatedUnit.SetRange("Source ID", "Source ID");
        EstimatedUnit.SetRange("Unit No.", "No.");
        EstimatedUnit.DeleteAll(true);
    end;
}
