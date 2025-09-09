table 71628582 "TMAC SSCC GS1 AI"
{
    Caption = 'GS1 Application Identifier';
    DataClassification = ToBeClassified;
    LookupPageId = "TMAC SSCC GS1 AI List";
    DrillDownPageId = "TMAC SSCC GS1 AI List";

    fields
    {
        field(1; Code; Code[10])
        {
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the GS1 Application Identifier code, such as (01) or (10), used for labeling data fields.';
        }
        field(2; Description; Text[250])
        {
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a description that clarifies the purpose or scope of the GS1 Application Identifier.';
        }
        field(3; Format; Text[100])
        {
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the expected data pattern for the identifier, such as numeric-only or including date info.';
        }
        field(4; Title; Text[100])
        {
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a descriptive title or label for the GS1 Application Identifier for user reference.';
        }
        field(5; "Regular Expression"; Text[200])
        {
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the regex pattern used to validate that data or check the correct format for the identifier.';
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Code, Description, Title)
        {
        }
    }
}