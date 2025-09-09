table 71628603 "TMAC Unit Entry"
{
    Caption = 'Unit Entry';
    DataClassification = CustomerContent;
    DrillDownPageId = "TMAC Unit Entries";
    LookupPageId = "TMAC Unit Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the unique identifier of this unit entry, used for referencing and sorting changes.';
        }

        field(2; "Unit No."; Code[20])
        {
            Caption = 'Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit"."No.";
            Tooltip = 'Specifies the logistic unit code to which this entry belongs, such as a pallet or container.';
        }

        //field(3 - reserved - in posted unit entry

        field(4; "Date"; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the posting date associated with this logistic unit entry.';
        }

        field(5; "Date and time"; DateTime)
        {
            Caption = 'Date and Time';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the exact date and time for this unit entry, combining date with a timestamp.';
        }

        field(6; "Action Code"; Code[20])
        {
            Caption = 'Action Code';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit Action";
            Tooltip = 'Specifies the type of operation performed on this logistic unit, such as creation or movement.';
        }

        field(7; "LU Location Code"; Code[20])
        {
            Caption = 'Logistic Unit Location';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit Location";
            Tooltip = 'Specifies a specialized code indicating where the logistic unit is located, such as onsite or offsite.';
        }

        field(8; "Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies any relevant notes or explanations for this unit entry, such as a reason or context.';
        }

        field(10; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the warehouse location assigned to this entry, for tracking and storage management.';
        }

        field(11; "Zone Code"; Code[10])
        {
            Caption = 'Zone Code';
            DataClassification = CustomerContent;
            TableRelation = Zone.Code WHERE("Location Code" = FIELD("Location Code"));
            Tooltip = 'Specifies the zone within the location, if zone management is used, where this entry is placed.';
        }

        field(12; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            DataClassification = CustomerContent;
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"));
            Tooltip = 'Specifies the bin or sub-location for the logistic unit entry, providing precise warehouse placement.';
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
