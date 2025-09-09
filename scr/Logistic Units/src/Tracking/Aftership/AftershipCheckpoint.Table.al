/// <summary>
///             {
///                     "slug": "ups",
///                     "city": null,
///                     "created_at": "2021-01-13T11:38:00+00:00",
///                     "location": "United States",
///                     "country_name": "USA",
///                     "message": "Shipper created a label, UPS has not received the package yet.",
///                     "country_iso3": "USA",
///                     "tag": "InfoReceived",
///                     "subtag": "InfoReceived_001",
///                     "subtag_message": "Info Received",
///                     "checkpoint_time": "2021-01-12T11:50:00",
///                     "coordinates": [],
///                     "state": null,
///                     "zip": null,
///                     "raw_tag": "MP"
///                 }
/// </summary>
table 71628652 "TMAC Aftership Checkpoint"
{
    Caption = 'Aftership.com Checkpoint';
    DataClassification = CustomerContent;
    DrillDownPageId = "TMAC Aftership Checkpoints";
    LookupPageId = "TMAC Aftership Checkpoints";
    fields
    {
        field(1; ID; Text[250])
        {
            Caption = 'ID';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a unique identifier for this checkpoint record as provided by aftership.com.';
        }
        field(2; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
            ToolTip = 'Specifies the sequential entry number assigned to each checkpoint record.';
        }
        /// <summary>
        /// he unique code of courier for this checkpoint message.
        /// </summary>
        field(3; "Slug"; Text[100])
        {
            Caption = 'Slug';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the courier code (e.g. ups) used by aftership.com to track this shipment.';
        }

        /// <summary>
        /// City info provided by carrier (if any)
        /// </summary>
        field(4; "City"; Text[50])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the city portion of the checkpoint location, if provided by the carrier.';
        }

        /// <summary>
        /// Date and time of the tracking created.
        /// </summary>
        field(5; "Created At"; DateTime)
        {
            Caption = 'Created AT';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date and time when the tracking entry was created in aftership.com.';
        }
        /// <summary>
        /// Location info provided by carrier (if any)
        /// </summary>
        field(6; "Location"; Text[100])
        {
            Caption = 'Location';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the general location details from the carrier, such as city and state combined.';
        }

        /// <summary>
        /// Country name of the checkpoint, may also contain other location info.
        /// </summary>
        field(7; "Country Name"; Text[100])
        {
            Caption = 'Country Name';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the full name of the country where the checkpoint occurred, if available.';
        }
        /// <summary>
        /// Checkpoint message
        /// </summary>
        field(8; "Message"; Text[100])
        {
            Caption = 'Action';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the checkpoint action or status update text as reported by the carrier.';
        }
        /// <summary>
        /// Country ISO Alpha-3 (three letters) of the checkpoint
        /// </summary>
        field(9; "Country"; Text[3])
        {
            Caption = 'Country';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the ISO Alpha-3 country code for this checkpoint, for example, USA or DEU.';
        }
        /// <summary>
        /// Current status of tracking.
        /// </summary>
        field(10; "Tag"; Enum "TMAC AfterShip TAG")
        {
            Caption = 'Tag';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the main status of this checkpoint, such as Delivered or InfoReceived.';
        }

        /// <summary>
        /// Current subtag of checkpoint.
        /// </summary>
        field(11; "SubTag"; Text[20])
        {
            Caption = 'SubTag';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a secondary status or reason code mapped to a subset of the main tag.';
        }

        /// <summary>
        /// Normalized checkpoint message.
        /// </summary>
        field(13; "SubTag Message"; Text[100])
        {
            Caption = 'Status Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a normalized explanation of the subtag to help clarify the checkpoint status.';
        }

        /// <summary>
        /// Date and time of the checkpoint, provided by courier. Value may be:
        /// - YYYY-MM-DD
        /// - YYYY-MM-DDTHH:MM:SS
        /// - YYYY-MM-DDTHH:MM:SS+TIMEZONE
        /// </summary>
        field(14; "Checkpoint Time"; DateTime)
        {
            Caption = 'Checkpoint Time';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date and time of this checkpoint event, provided by the carrier.';
        }

        /// <summary>
        /// State info provided by carrier (if any)
        /// </summary>
        field(17; "State"; Text[30])
        {
            Caption = 'State';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the state or region part of the checkpoint location, if reported by the carrier.';
        }

        /// <summary>
        /// Location info (if any)
        /// </summary>
        field(18; "Zip"; Text[30])
        {
            Caption = 'Zip';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the zip or postal code portion of the checkpoint location, if available.';
        }
        /// <summary>
        /// Checkpoint status provided by courier (if any)
        /// </summary>
        field(19; "raw_tag"; Text[100])
        {
            Caption = 'raw_tag';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the unprocessed checkpoint code as returned directly by the carrier.''s system.';
        }
    }

    keys
    {
        key(Key1; ID, "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; ID, "Checkpoint Time")
        {
        }
    }
}