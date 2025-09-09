table 71628583 "TMAC SSCC Default Identifier"
{
    Caption = 'SSCC Default Identifier';
    DrillDownPageId = "TMAC SSCC Default Identifiers";
    LookupPageId = "TMAC SSCC Default Identifiers";

    fields
    {
        field(3; "Identifier"; Code[10])
        {
            Caption = 'Identifier';
            DataClassification = CustomerContent;
            TableRelation = "TMAC SSCC GS1 AI".Code;
            ToolTip = 'Specifies the GS1 Application Identifier code used as a default for SSCC generation.';
            trigger OnValidate()
            var
                SSCCGS1AI: Record "TMAC SSCC GS1 AI";
            begin
                if SSCCGS1AI.get("Identifier") then
                    Validate("Description", SSCCGS1AI.Description);
            end;
        }
        field(4; "Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a descriptive text for the default identifier, clarifying its meaning or usage.';
        }
        field(5; "Value"; Text[250])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the preset or default data string associated with the identifier, such as a code fragment.';
        }

        field(6; "Barcode Place"; Enum "TMAC SSCC Barcode Place")
        {
            Caption = 'Barcode Place';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies where to position this default identifier within the barcode layout, for example: Top or Bottom.';
        }

        field(7; "Barcode Type"; Enum "TMAC SSCC Barcode Type")
        {
            Caption = 'Barcode Type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the type of encoding for the barcode, such as Code 128 or EAN, used for this identifier.';
        }
        field(8; "Label Text"; enum "TMAC SSCC Label Text Number")
        {
            Caption = 'Label Text';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the label reference used when printing, letting you customize text for different identifier lines.';
        }
    }

    keys
    {
        key(PK; "Identifier")
        {
            Clustered = true;
        }
    }
}
