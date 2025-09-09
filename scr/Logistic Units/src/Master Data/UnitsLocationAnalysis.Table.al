table 71628592 "TMAC Units Location Analysis"
{
    Caption = 'Units Location';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "LU Location Code"; Code[20])
        {
            Caption = 'LU Location Code';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the logistic unit location code, indicating where the unit is stored or placed.';
        }
        field(2; "Location Code"; Code[20])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the warehouse or site code where this logistic unit is located.';
        }
        field(3; "Zone Code"; Code[20])
        {
            Caption = 'Zone Code';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the zone within the warehouse used for organizing and grouping related bins.';
        }
        field(4; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the bin for more specific placement within the warehouse zone.';
        }
        field(5; "Logistic Unit No."; Code[20])
        {
            Caption = 'Logistic Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit";
            ToolTip = 'Specifies the unique number of the logistic unit associated with this location entry.';
        }
        field(10; "Source Type"; Integer)
        {
            Caption = 'Source Type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the type of source document or entity referencing this logistic unit.';
        }
        field(11; "Source Subtype"; Integer)
        {
            Caption = 'Source Subtype';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies an additional category or subtype of the source document, if applicable.';
        }
        field(12; "Source ID"; Code[20])
        {
            Caption = 'Source ID';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the identifier of the document or record referencing this logistic unit.';
        }
        field(13; "Source Information"; Text[150])
        {
            Caption = 'Source Information';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies descriptive details about the source document or record for clarity.';
        }
        field(20; Indent; Integer)
        {
            Caption = 'Indent';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the indentation level to visually represent hierarchy in location analysis.';
        }
    }
    keys
    {
        key(PK; "LU Location Code", "Location Code", "Bin Code", "Logistic Unit No.")
        {
            Clustered = true;
        }
    }
}
