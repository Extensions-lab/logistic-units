table 71628621 "TMAC Unit Worksheet Line"
{
    Caption = 'Unit Worksheet Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Name; Code[10])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the code of the logistic unit worksheet to which this line belongs.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the sequential number used to identify each entry in the worksheet.';
        }
        field(3; "Unit No."; Code[20])
        {
            Caption = 'Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit";
            ToolTip = 'Specifies the logistic unit number that this worksheet line references for operations.';
            trigger OnValidate()
            var
                UnitEntry: Record "TMAC Unit Entry";
            begin
                UnitEntry.SetRange("Unit No.", "Unit No.");
                if UnitEntry.FindLast() then begin
                    "LU Location Code" := UnitEntry."LU Location Code";
                    "Location Code" := UnitEntry."Location Code";
                    "Zone Code" := UnitEntry."Zone Code";
                    "Bin Code" := UnitEntry."Bin Code";
                end;
            end;
        }
        field(4; "Date"; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date for this worksheet entry, used to track when the action occurred.';
            trigger OnValidate()
            begin
                "Date And Time" := CreateDateTime("Date", 0T);
            end;
        }

        field(5; "Date And Time"; DateTime)
        {
            Caption = 'Date And Time';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the exact date and time for the worksheet line entry, derived from the Date field.';
            trigger OnValidate()
            begin
                Date := DT2DATE("Date And Time");
            end;
        }

        field(6; "Action Code"; Code[20])
        {
            Caption = 'Action Code';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit Action";
            ToolTip = 'Specifies the code defining the operation performed on this unit, referencing TMAC Unit Action.';
            trigger OnValidate()
            var
                LogisticUnitAction: Record "TMAC Unit Action";
            begin
                if LogisticUnitAction.get("Action Code") then
                    Description := LogisticUnitAction.Description;
            end;
        }
        field(7; "LU Location Code"; Code[20])
        {
            Caption = 'Logistic Unit Location';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit Location";
            ToolTip = 'Specifies the location code assigned to the logistic unit, indicating where it is stored or handled.';
        }
        field(8; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies an additional text describing the purpose or context of this worksheet line.';
        }
        field(10; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the Business Central location relevant to this operation or unit storage.';
        }

        field(11; "Zone Code"; Code[10])
        {
            Caption = 'Zone Code';
            DataClassification = CustomerContent;
            TableRelation = Zone.Code WHERE("Location Code" = FIELD("Location Code"));
            ToolTip = 'Specifies the warehouse zone, if any, linked to the location for this unit line.';
        }

        field(12; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            DataClassification = CustomerContent;
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"));
            ToolTip = 'Specifies the bin within the warehouse location for storing or handling this unit.';
        }

    }
    keys
    {
        key(PK; Name, "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        "Date And Time" := CurrentDateTime;
        "Date" := DT2Date("Date and Time");
    end;
}
