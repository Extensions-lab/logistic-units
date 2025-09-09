table 71628613 "TMAC Posted Unit Entry"
{
    Caption = 'Posted Unit Entry';
    DataClassification = CustomerContent;
    DrillDownPageId = "TMAC Posted Unit Entries";
    LookupPageId = "TMAC Posted Unit Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the unique sequential number assigned to this posted unit entry for record-keeping.';
        }
        field(2; "Unit No."; Code[20])
        {
            Caption = 'Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit"."No.";
            ToolTip = 'Specifies the posted logistic unit to which this entry belongs, linking it to a unit record.';
        }
        field(3; "Posted Version"; Integer)
        {
            Caption = 'Posted Version';
            Editable = false;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the posted version at the time the entry was recorded, reflecting changes over time.';
        }
        field(4; "Date"; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the posting date for the logistic unit activity, such as creation or movement.';
        }
        field(5; "Date and time"; DateTime)
        {
            Caption = 'Date and Time';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the precise timestamp of the posted event, capturing both date and hour.';
        }

        field(6; "Action Code"; Code[20])
        {
            Caption = 'Action Code';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit Action";
            ToolTip = 'Specifies which type of action was performed on the logistic unit, such as Sale or Archive.';
        }

        field(7; "LU Location Code"; Code[20])
        {
            Caption = 'Logistic Unit Location';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit Location";
            ToolTip = 'Specifies where the logistic unit was placed or recorded during this entry, e.g., a warehouse location.';
        }
        field(8; "Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies extra details about this posted unit entry, such as reason or reference notes.';
        }

        field(10; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the warehouse location in Business Central linked to this posted unit entry.';
        }
        field(11; "Zone Code"; Code[10])
        {
            Caption = 'Zone Code';
            DataClassification = CustomerContent;
            TableRelation = Zone.Code WHERE("Location Code" = FIELD("Location Code"));
            ToolTip = 'Specifies the warehouse zone for additional grouping of bins where this entry is located.';
        }
        field(12; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            DataClassification = CustomerContent;
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"));
            ToolTip = 'Specifies the bin within the zone where this logistic unit entry is recorded or stored.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(key2; "Unit No.", "Date", "LU Location Code", "Action Code")
        {
        }
    }


}
