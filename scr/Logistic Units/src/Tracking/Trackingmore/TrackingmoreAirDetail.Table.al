table 71628655 "TMAC Trackingmore Air Detail"
{
    Caption = 'Trackingmore Air Detail';
    LookupPageId = "TMAC Trackingmore Air Details";
    DrillDownPageId = "TMAC Trackingmore Air Details";
    fields
    {
        field(1; "Tracking Number"; Text[50])
        {
            Caption = 'Tracking Number';
            DataClassification = CustomerContent;
        }
        field(2; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(3; "Plan Date"; DateTime)
        {
            Caption = 'Plan Date';
            DataClassification = CustomerContent;
        }
        field(4; "Actual Date"; DateTime)
        {
            Caption = 'Actual Date';
            DataClassification = CustomerContent;
        }
        field(5; "Event"; text[250])
        {
            Caption = 'Event';
            DataClassification = CustomerContent;
        }
        field(6; "Station"; Text[10])
        {
            Caption = 'Station';
            DataClassification = CustomerContent;
        }
        field(7; "Flight Number"; Text[15])
        {
            Caption = 'Flight Number';
            DataClassification = CustomerContent;
        }
        field(8; "Status"; Text[50])
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(9; "Piece"; Text[20])
        {
            Caption = 'Piece';
            DataClassification = CustomerContent;
        }
        field(10; "Weight"; Text[15])
        {
            Caption = 'Weight';
            DataClassification = CustomerContent;
        }
    }


    keys
    {
        key(Key1; "Tracking Number", "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Tracking Number", "Actual Date")
        {
        }
    }
}