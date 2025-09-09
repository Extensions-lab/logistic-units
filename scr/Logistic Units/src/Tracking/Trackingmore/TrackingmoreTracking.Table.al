table 71628658 "TMAC Trackingmore Tracking"
{
    Caption = 'Trackingmore.com Tracking';
    DrillDownPageId = "TMAC Trackingmore Trackings";
    LookupPageId = "TMAC Trackingmore Trackings";
    fields
    {
        /// <summary>
        /// Tracking ID.
        /// </summary>
        field(1; ID; Text[100])
        {
            Caption = 'ID';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Tracking number.
        /// </summary>
        field(4; "Tracking Number"; Text[250])
        {
            Caption = 'Tracking Number';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Unique code of courier. Get courier 
        /// </summary>
        field(5; "Carrier Code"; Text[100])
        {
            Caption = 'Carrier Code';
            DataClassification = CustomerContent;
        }

        field(6; "Order Create Time"; DateTime)
        {
            Caption = 'Order Create Time';
            DataClassification = CustomerContent;
        }
        
        field(7; "Status"; Enum "TMAC Trackingmore Status")
        {
            Caption = 'Status Code';
            DataClassification = CustomerContent;
        }
        
        field(8; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = CustomerContent;
        }
        
        field(9; "Customer Email"; Text[100])
        {
            Caption = 'Customer Email';
            DataClassification = CustomerContent;
        }
        
        field(10; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
        }
        
        field(11; "Order ID"; Text[100])
        {
            Caption = 'Order ID';
            DataClassification = CustomerContent;
        }

        field(12; "Comment"; Text[200])
        {
            Caption = 'Comment';
            DataClassification = CustomerContent;
        }
        
        field(13; "Title"; Text[200])
        {
            Caption = 'Title';
            DataClassification = CustomerContent;
        }
        
        field(14; "Logistics Channel"; Text[200])
        {
            Caption = 'Logistics Channel';
            DataClassification = CustomerContent;
        }
        
        field(15; "Destination"; Text[200])
        {
            Caption = 'Destination';
            DataClassification = CustomerContent;
        }

        field(16; "Updated At"; DateTime)
        {
            Caption = 'Updated At';
            DataClassification = CustomerContent;
        }
        
        field(17; "Sub Status"; Enum "TMAC Trackingmore Substatus")
        {
            Caption = 'Substatus Code';
            DataClassification = CustomerContent;
        }
        
        field(18; "Original Country"; Text[15])
        {
            Caption = 'Original Country';
            DataClassification = CustomerContent;
        }
        
        field(19; "Destination Country"; Text[15])
        {
            Caption = 'Destination Country';
            DataClassification = CustomerContent;
        }
        
        field(20; "Last Event"; Text[200])
        {
            Caption = 'Last Event';
            DataClassification = CustomerContent;
        }
        
        field(21; "Status Info"; Text[200])
        {
            Caption = 'Status Info';
            DataClassification = CustomerContent;
        }
        
        field(22; "Weight"; Text[20])
        {
            Caption = 'Weight';
            DataClassification = CustomerContent;
        }
        
        field(23; "Package Status"; Text[50])
        {
            Caption = 'Package Status';
            DataClassification = CustomerContent;
        }
        
        field(24; "Status Description"; Text[100])
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }

        field(25; "Substatus Description"; Text[100])
        {
            Caption = 'Substatus';
            DataClassification = CustomerContent;
        }

        field(202; "CheckPoints"; Integer)
        {
            Caption = 'CheckPoints';
            FieldClass = FlowField;
            CalcFormula = count("TMAC Trackingmore Checkpoint" where(id = field(id)));
            Editable = false;
        }

        field(203; "Mark for Delete"; Boolean)
        {
            Caption = 'Mark for Delete';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; ID)
        {
            Clustered = true;
        }
        key(Key2; "Tracking Number")
        {
        }
    }

    trigger OnDelete()
    var
        TrackingmoreCheckpoint: record "TMAC Trackingmore Checkpoint";
    begin
        TrackingmoreCheckpoint.SetRange(id, ID);
        TrackingmoreCheckpoint.DeleteAll(true);
    end;
}