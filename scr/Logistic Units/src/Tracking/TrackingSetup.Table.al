table 71628650 "TMAC Tracking Setup"
{
    Caption = 'Tracking Setup';

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }

        field(10; "AfterShip API Key"; Text[100])
        {
            Caption = 'AfterShip.com API Key';
            ExtendedDatatype = Masked;
            DataClassification = CustomerContent;
        }
        field(11; "AfterShip All Courier URL"; Text[100])
        {
            Caption = 'AfterShip.com All Couriers URL';
            ExtendedDatatype = URL;
            DataClassification = CustomerContent;
        }
        field(12; "Aftership Active Couriers URL"; Text[200])
        {
            Caption = 'AfterShip.com All Couriers URL';
            ExtendedDatatype = URL;
            DataClassification = CustomerContent;
        }
        field(13; "Aftership Picture"; Media)
        {
            Caption = 'Aftership Picture';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14; "Aftership Setup Completed"; Boolean)
        {
            Caption = 'Aftership Setup Completed';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(15; "AfterShip GetTracking URL"; Text[100])
        {
            Caption = 'AfterShip.com GetTracking URL';
            ExtendedDatatype = URL;
            DataClassification = CustomerContent;
        }

        field(20; "Trackingmore Picture"; Media)
        {
            Caption = 'Trackingmore Picture';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(21; "Trackingmore API Key"; Text[100])
        {
            Caption = 'Trackingmore API Key';
            ExtendedDatatype = Masked;
            DataClassification = CustomerContent;
        }
        field(22; "Trackingmore All Courier URL"; Text[100])
        {
            Caption = 'Trackingmore All Couriers URL';
            ExtendedDatatype = URL;
            DataClassification = CustomerContent;
        }
        field(23; "Trackingmore AirCargo URL"; Text[100])
        {
            Caption = 'Trackingmore AirCargo URL';
            ExtendedDatatype = URL;
            DataClassification = CustomerContent;
        }
        field(24; "Trackingmore Ger User Info URL"; Text[100])
        {
            Caption = '"Trackingmore Ger User Info URL';
            ExtendedDatatype = URL;
            DataClassification = CustomerContent;
        }
        field(25; "Trackingmore Setup Completed"; Boolean)
        {
            Caption = 'Trackingmore Setup Completed';
            Editable = false;
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// //https://api.trackingmore.com/v2/trackings/post
        /// </summary>
        field(26; "Trackingmore Create Tracking"; Text[100])
        {
            Caption = 'Trackingmore Create Tracking URL';
            ExtendedDatatype = URL;
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// https://api.trackingmore.com/v2/trackings
        /// </summary>
        field(27; "Trackingmore Delete Tracking"; Text[100])
        {
            Caption = 'Trackingmore Delete Tracking URL';
            ExtendedDatatype = URL;
            DataClassification = CustomerContent;
        }
    }


    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

}