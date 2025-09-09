table 71628657 "TMAC Trackingmore Carrier"
{
    Caption = 'Trackingmore.com Carrier';
    LookupPageId = "TMAC Trackingmore Carriers";
    DrillDownPageId = "TMAC Trackingmore Carriers";

    fields
    {
        /// <summary>
        /// Unique code of courier of the tracking number
        /// </summary>
        field(1; Code; text[50])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Name of courier
        /// </summary>
        field(2; Name; text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }

        field(3; Phone; Text[50])
        {
            Caption = 'Phone';
            DataClassification = CustomerContent;
            ExtendedDatatype = PhoneNo;
        }

        /// <summary>
        /// Homepage of courier
        /// </summary>
        field(4; "Homepage"; Text[250])
        {
            Caption = 'Homepage';
            DataClassification = CustomerContent;
            ExtendedDatatype = URL;
        }

        /// <summary>
        /// Service type of the courier, such as express, postal
        /// </summary>
        field(5; "Type"; Text[50])
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// The image url of the courier logo
        /// </summary>
        field(6; "Picture URL"; Text[250])
        {
            Caption = 'Picture URL';
            DataClassification = CustomerContent;
            ExtendedDatatype = URL;
        }

        field(7; "Country Code"; Text[10])
        {
            Caption = 'Country Code';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Chinese name of courier company
        /// </summary>
        field(8; "Name CN"; Text[50])
        {
            Caption = 'Name CN';
            DataClassification = CustomerContent;
        }

        field(9; "Track URL"; Text[250])
        {
            Caption = 'Track URL';
            DataClassification = CustomerContent;
            ExtendedDatatype = URL;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }
}


