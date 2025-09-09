table 71628656 "TMAC Trackingmore Air Tracking"
{
    Caption = 'Trackingmore.com Air Tracking';
    DrillDownPageId = "TMAC Trackingmore Air Tracks";
    LookupPageId = "TMAC Trackingmore Air Tracks";

    fields
    {
        field(1; "Tracking Number"; Text[50])
        {
            Caption = 'Tracking Number';
            DataClassification = CustomerContent;
        }

        field(2; "Last Event"; Text[250])
        {
            Caption = 'Last Event';
            DataClassification = CustomerContent;
        }

        field(3; "Airline"; Text[250])
        {
            Caption = 'Airline';
            DataClassification = CustomerContent;
        }

        field(4; "Airline Url"; Text[250])
        {
            Caption = 'Airline Url';
            DataClassification = CustomerContent;
        }

        field(5; "Airline Track Url"; Text[250])
        {
            Caption = 'Airline Track Url';
            DataClassification = CustomerContent;
        }

        field(6; "Weight"; Text[50])
        {
            Caption = 'Weight';
            DataClassification = CustomerContent;
        }

        field(7; "Piece"; Integer)
        {
            Caption = 'Piece';
            DataClassification = CustomerContent;
        }
        field(8; "Origin"; Text[10])
        {
            Caption = 'Origin';
            DataClassification = CustomerContent;
        }

        field(9; "Destination"; Text[10])
        {
            Caption = 'Destination';
            DataClassification = CustomerContent;
        }

        field(10; "Flight Info"; Text[100])
        {
            Caption = 'Flight Info';
            DataClassification = CustomerContent;
        }

        field(11; "Origin Departure Time"; Datetime)
        {
            Caption = 'Origin Departure Time';
            DataClassification = CustomerContent;
        }

        field(12; "Destination Arrival Time"; Datetime)
        {
            Caption = 'Destination Arrival Time';
            DataClassification = CustomerContent;
        }

        field(13; "Time Zone"; Text[15])
        {
            Caption = 'Time Zone';
            DataClassification = CustomerContent;
        }

        field(14; "Tracking Detail"; Integer)
        {
            Caption = 'Tracking Detail';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("TMAC Trackingmore Air Detail" where("Tracking Number" = field("Tracking Number")));
        }

        field(203; "Mark for Delete"; Boolean)
        {
            Caption = 'Mark for Delete';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Tracking Number")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        TrackingmoreAirDetail: Record "TMAC Trackingmore Air Detail";
    begin
        TrackingmoreAirDetail.SetRange("Tracking Number", "Tracking Number");
        TrackingmoreAirDetail.DeleteAll(True);
    end;
}