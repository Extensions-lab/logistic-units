table 71628659 "TMAC Trackingmore Checkpoint"
{
    Caption = 'Trackingmore.com Checkpoint';
    DataClassification = ToBeClassified;
    DrillDownPageId = "TMAC Trackingmore Checkpoints";
    LookupPageId = "TMAC Trackingmore Checkpoints";

    fields
    {
        field(1; ID; Text[250])
        {
            Caption = 'ID';
            DataClassification = CustomerContent;
        }
        field(2; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        /// <summary>
        /// he unique code of courier for this checkpoint message.
        /// </summary>
        field(3; "Checkpoint Time"; DateTime)
        {
            Caption = 'Checkpoint Time';
            DataClassification = CustomerContent;
        }
        field(4; "Status Description"; Text[100])
        {
            Caption = 'Status Description';
            DataClassification = CustomerContent;
        }
        field(5; "Details"; Text[100])
        {
            Caption = 'Details';
            DataClassification = CustomerContent;
        }
        field(6; "Checkpoint Status"; Text[100])
        {
            Caption = 'Checkpoint Status';
            DataClassification = CustomerContent;
        }
        field(7; "Substatus"; Text[100])
        {
            Caption = 'Substatus';
            DataClassification = CustomerContent;
        }
        field(8; "Side"; Text[10])
        {
            Caption = 'Side';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; ID, "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; ID, Side, "Checkpoint Time")
        {
        }
    }
}