table 71628653 "TMAC Aftership Tracking"
{
    Caption = 'Aftership.com Tracking';
    DrillDownPageId = "TMAC Aftership Trackings";
    LookupPageId = "TMAC Aftership Trackings";
    fields
    {
        /// <summary>
        /// Tracking ID.
        /// </summary>
        field(1; ID; Text[100])
        {
            Caption = 'ID';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the unique tracking ID assigned by aftership.com for this record.';
        }
        /// <summary>
        /// Tracking created date time.
        /// </summary>
        field(2; "Create DateTime"; DateTime)
        {
            Caption = 'Create DateTime';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date and time when this tracking record was initially created.';
        }
        /// <summary>
        /// Date and time of the tracking last updated.
        /// </summary>
        field(3; "Updated DateTime"; DateTime)
        {
            Caption = 'Updated DateTime';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the most recent date and time when the tracking information was updated.';
        }

        /// <summary>
        /// Tracking number.
        /// </summary>
        field(4; "Tracking Number"; Text[250])
        {
            Caption = 'Tracking Number';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the shipment''s tracking number, used for retrieval of status updates.';
        }
        /// <summary>
        /// Unique code of courier. Get courier 
        /// </summary>
        field(5; "Slug"; Text[100])
        {
            Caption = 'Slug';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the courier code recognized by aftership.com, for example, ups or fedex.';
        }

        /// <summary>
        /// Whether or not AfterShip will continue tracking the shipments. Value is false 
        /// when tag (status) is Delivered, Expired, or further updates for 30 days since last update.
        /// </summary>
        field(6; "Active"; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether aftership.com continues to track this shipment, given its current status.';
        }

        /// <summary>
        /// Customer name of the tracking.
        /// </summary>
        field(7; "Customer Name"; Text[250])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the name of the customer or recipient associated with this tracking record.';
        }

        /// <summary>
        /// Total delivery time in days.
        ///
        /// - Difference of 1st checkpoint time and delivered time for delivered shipments
        /// - Difference of 1st checkpoint time and current time for non-delivered shipments
        /// Value as 0 for pending shipments or delivered shipment with only one checkpoint.
        /// </summary>
        field(8; "Delivery Time (days)"; Integer)
        {
            Caption = 'Delivery Time (days)';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies how many days elapsed from the first checkpoint until delivery or current time.';
        }

        /// <summary>
        /// Destination country of the tracking. ISO Alpha-3 (three letters). If you use postal service to send international shipments, AfterShip will automatically 
        /// get tracking results from destination postal service based on destination country.
        /// </summary>
        field(9; "Destination Country"; Text[3])
        {
            Caption = 'Destination Country';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the ISO Alpha-3 code for the shipment''s target country, used for local tracking.';
        }

        /// <summary>
        /// Destination country of the tracking detected from the courier. ISO Alpha-3 (three letters). 
        /// Value will be null if the courier doesn't provide the destination country.
        /// </summary>
        field(10; "Courier Destination Country"; Text[3])
        {
            Caption = 'Courier Destination Country';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the destination country code detected by the courier, if provided.';
        }

        /// <summary>
        /// Expected delivery date.
        /// Available format:
        /// - YYYY-MM-DD
        /// - YYYY-MM-DDTHH:MM:SS
        /// - YYYY-MM-DDTHH:MM:SS+TIMEZONE
        /// </summary>
        field(11; "Expected Delivery"; Text[50])
        {
            Caption = 'Expected Delivery';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the expected delivery date or time range for the shipment, if available.';
        }

        /// <summary>
        /// Text field for the note.
        /// </summary>
        field(12; "Note"; Text[200])
        {
            Caption = 'Note';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a brief internal comment or memo about this tracking entry.';
        }
        /// <summary>
        /// Text field for order ID.
        /// </summary>
        field(13; "Order ID"; Text[100])
        {
            Caption = 'Order ID';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the related sales or delivery order identifier for reference purposes.';
        }
        /// <summary>
        /// Date and time of the order created
        /// </summary>
        field(14; "Order Date"; DateTime)
        {
            Caption = 'Order Date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies when the associated order was created or confirmed in the system.';
        }

        /// <summary>
        /// Origin country of the tracking. ISO Alpha-3 (three letters).
        /// </summary>
        field(15; "Origin Country"; Text[3])
        {
            Caption = 'Origin Country';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the ISO Alpha-3 code for the shipment''s originating country, if known.';
        }
        /// <summary>
        /// Number of packages under the tracking.
        /// </summary>
        field(16; "Shipment Package Count"; Integer)
        {
            Caption = 'Shipment Package Count';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies how many packages are included under this tracking record, if multiple items.';
        }
        /// <summary>
        /// Date and time the tracking was picked up.
        /// </summary>
        field(17; "Shipment Pickup Date"; DateTime)
        {
            Caption = 'Shipment Pickup Date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date and time when the carrier retrieved the shipment for transport.';
        }
        /// <summary>
        /// Date and time the tracking was delivered.
        /// </summary>
        field(18; "Shipment Delivery Date"; DateTime)
        {
            Caption = 'Shipment Delivery Date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date and time when the carrier reported the shipment as delivered.';
        }

        /// <summary>
        /// Shipment type provided by carrier.
        /// </summary>
        field(19; "Shipment Type"; Text[250])
        {
            Caption = 'Shipment Type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a classification of the shipment from the carrier, such as express or standard.';
        }

        /// <summary>
        /// Shipment weight provied by carrier.
        /// </summary>
        field(20; "Shipment Weight"; Integer)
        {
            Caption = 'Shipment Weight';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the total weight of the shipped items, if reported by the carrier.';
        }
        /// <summary>
        /// Weight unit provied by carrier, either in
        /// </summary>
        field(21; "Shipment Weigh Unit"; Text[20])
        {
            Caption = 'Shipment Weigh Unit';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the weight unit used by the carrier (e.g. kg, lb) for the shipment weight.';
        }
        /// <summary>
        /// Signed by information for delivered shipment.
        /// </summary>
        field(22; "Signed By"; Text[50])
        {
            Caption = 'Signed By';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the name or identifier of the person who acknowledged receipt, if delivered.';
        }
        /// <summary>
        /// Source of how this tracking is added.
        /// </summary>
        field(23; Source; text[50])
        {
            Caption = 'Source';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies how this tracking was added, for example automatically, from an order, or manually.';
        }
        /// <summary>
        /// Current status of tracking. 
        /// </summary>
        field(24; "Tag"; enum "TMAC AfterShip TAG")
        {
            Caption = 'Tag';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the current tracking status, for example, Delivered or InTransit.';
        }

        /// <summary>
        /// Current subtag of tracking.
        /// </summary>
        field(25; "SubTag"; Text[20])
        {
            Caption = 'SubTag';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a secondary status code, offering more detail on the main tracking status.';
        }

        /// <summary>
        /// Normalized tracking message
        /// </summary>
        field(26; "SubTag Message"; Text[100])
        {
            Caption = 'SubTag';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a localized or normalized message explaining the subtag status.';
        }

        /// <summary>
        /// Title of the tracking.
        /// </summary>
        field(27; "Title"; Text[100])
        {
            Caption = 'Title';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a shorthand name for the tracking, e.g. an internal reference or label.';
        }

        /// <summary>
        /// Number of attempts AfterShip tracks at courier's system.
        /// </summary>
        field(28; "Tracked Count"; Integer)
        {
            Caption = 'Tracked Count';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies how many times aftership.com has polled the carrier''s system for updates.';
        }
        /// <summary>
        /// Indicates if the shipment is trackable till the final destination.
        /// Three possible values:
        /// - true
        /// - false
        /// - null
        /// </summary>
        field(29; "Last Mile tracking Support"; Boolean)
        {
            Caption = 'Tracked Count';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies if final delivery details can be tracked through local carriers in the destination.';
        }
        /// <summary>
        /// Store, customer, or order language of the tracking.
        /// </summary>
        field(30; "Language"; Text[20])
        {
            Caption = 'Tracked Count';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the language used for tracking details, e.g. en or de, to localize updates.';
        }

        /// <summary>
        /// Shipment delivery type
        ///  - pickup_at_store
        ///  - pickup_at_courier
        ///  - door_to_door
        /// </summary>  
        field(31; "Delivery Type"; Text[20])
        {
            Caption = 'Delivery Type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies how the package is handed over: door-to-door, pickup at store, or other method.';
        }

        /// <summary>
        /// Official tracking URL of the courier (if any)
        /// </summary>
        field(32; "Courier Tracking Link"; Text[400])
        {
            Caption = 'Courier Tracking Link';
            DataClassification = CustomerContent;
            ExtendedDatatype = URL;
            ToolTip = 'Specifies the official carrier tracking URL for quick access to this shipment''s details.';
        }
        /// <summary>
        /// Checkpoint message заполняется из chekcpoints
        /// </summary>
        field(33; "Last Checkpoint Action"; Text[100])
        {
            Caption = 'Action';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the last reported action from the checkpoint, such as arrival or departure.';
        }

        field(202; "CheckPoints"; Integer)
        {
            Caption = 'Check Points';
            FieldClass = FlowField;
            CalcFormula = count("TMAC Aftership Checkpoint" where(id = field(id)));
            Editable = false;
            ToolTip = 'Specifies how many checkpoint events are linked to this tracking record.';
        }
        field(203; "Mark for Delete"; Boolean)
        {
            Caption = 'Mark for Delete';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies if this tracking record is queued for deletion or removal from aftership.com.';
        }
    }

    keys
    {
        key(Key1; ID)
        {
            Clustered = true;
        }
        key(Key2; "Tracking Number", "Slug")
        {
        }
        key(Key3; "Slug", "Tracking Number")
        {
        }
    }


    trigger OnDelete()
    var
        AftershipCheckpoint: Record "TMAC Aftership Checkpoint";
    begin
        AftershipCheckpoint.SetRange(ID, ID);
        AftershipCheckpoint.DeleteAll(true);
    end;
}