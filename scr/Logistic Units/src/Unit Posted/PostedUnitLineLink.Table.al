table 71628612 "TMAC Posted Unit Line Link"
{
    Caption = 'Posted Unit Line Link';

    DataClassification = CustomerContent;
    LookupPageId = "TMAC Posted Unit Line Links";
    DrillDownPageId = "TMAC Posted Unit Line Links";

    fields
    {
        /// <summary>
        /// Logistics unit number
        /// </summary>
        field(1; "Unit No."; Code[20])
        {
            Caption = 'Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit"."No.";
            ToolTip = 'Specifies the posted logistic unit number for this link, connecting item lines to the top-level unit.';
        }

        /// <summary>
        /// Version number of the posted logistics unit
        /// </summary>
        field(2; "Posted Version"; Integer)
        {
            Caption = 'Posted Version';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "TMAC Posted Unit"."Posted Version" where("No." = field("Unit No."));
            ToolTip = 'Specifies the posted version of the logistic unit at the time this link was created.';
        }

        /// <summary>
        /// Logistics unit line number
        /// </summary>
        field(3; "Unit Line No."; Integer)
        {
            Caption = 'Unit Line No.';
            TableRelation = "TMAC Unit Line"."Line No." where("Unit No." = field("Unit No."));
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the line number within the posted unit that this link references for item or nested data.';
        }

        /// <summary>
        /// Table number
        /// </summary>
        field(10; "Source Type"; Integer)
        {
            Caption = 'Source Type';
            ToolTip = 'Specifies the type of external document or record (e.g. table ID) that this link connects to.';
        }

        /// <summary>
        /// Document Type
        /// </summary>
        field(11; "Source Subtype"; Integer)
        {
            Caption = 'Source Subtype';
            ToolTip = 'Specifies additional classification, such as the specific document type (e.g. sales, purchase, etc.).';
        }

        /// <summary>
        /// Document number
        /// </summary>
        field(12; "Source ID"; Code[20])
        {
            Caption = 'Source ID';
            ToolTip = 'Specifies the external document number or identifier connected to this posted line link.';
        }
        field(13; "Source Batch Name"; Code[10])
        {
            Caption = 'Source Batch Name';
            ToolTip = 'Specifies the name of the processing batch or group in which this source record is managed.';
        }
        field(14; "Source Prod. Order Line"; Integer)
        {
            Caption = 'Source Prod. Order Line';
            ToolTip = 'Specifies the production order line number if the source link references a manufacturing process.';
        }
        field(15; "Source Ref. No."; Integer)
        {
            Caption = 'Source Ref. No.';
            ToolTip = 'Specifies an additional reference number for that source document, aiding identification.';
        }
        field(16; "Source Name"; Text[50])
        {
            Caption = 'Source Name';
            ToolTip = 'Specifies a descriptive name (customer, vendor, or entity) that the linked source record belongs to.';
        }
        field(20; "Package No."; Code[50])
        {
            Caption = 'Package No.';
            CaptionClass = '6,1';
            ToolTip = 'Specifies the separate package identifier if items are grouped or labeled by package number.';
        }
        field(21; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            ToolTip = 'Specifies the lot number for batch tracking or regulatory compliance of the item(s).';
        }
        field(22; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
            ToolTip = 'Specifies the serial number used to track a single unique item within the link.';
        }
        field(23; "Positive"; Boolean)
        {
            Caption = 'Positive';
            Editable = false;
            ToolTip = 'Specifies whether the quantity is incoming (true) or outgoing (false) for inventory posting.';
        }
        field(30; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = "Item"."No.";
            ToolTip = 'Specifies which item is linked to this posted unit line, referencing the item master record.';
        }
        field(31; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."), Code = FIELD("Variant Code"));
            ToolTip = 'Specifies any variant that differentiates items of the same number, such as color or size.';
        }
        field(32; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a short descriptive text for easier identification of the linked item or process.';
        }
        field(33; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            MinValue = 0;
            ToolTip = 'Specifies how many units of the item are being handled in this link, referencing source docs.';
        }
        field(34; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
            ToolTip = 'Specifies the unit of measure (e.g. pcs, box) used for the item quantity in this link.';
        }
        field(35; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the quantity in base units for consistent calculations or conversions, if applicable.';
        }

        /// <summary>
        /// Weight of this quantity
        /// </summary>
        field(36; "Weight (Base)"; Decimal)
        {
            Caption = 'Weight (Base)';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the accumulated weight in the base measure for the items or units on this link.';
        }

        /// <summary>
        /// Volume of this quantity
        /// </summary>
        field(37; "Volume (Base)"; Decimal)
        {
            Caption = 'Volume (Base)';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the total volume in the base measure for items or units linked to this record.';
        }
        field(38; "Qty. per UoM"; Decimal)
        {
            Caption = 'Qty. per UoM';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
            InitValue = 1;
            ToolTip = 'Specifies how many base units are contained in one unit of measure, aiding conversions.';
        }
        field(40; "Warranty Date"; Date)
        {
            Caption = 'Warranty Date';
            Editable = false;
            ToolTip = 'Specifies the date until which the item or unit is under warranty, if relevant.';
        }
        field(41; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
            Editable = false;
            ToolTip = 'Specifies the date when the item or unit is no longer valid or fit for use, if it''s perishable.';
        }

        /// <summary>
        /// Additional Information Fields
        /// </summary>
        field(42; "Unit Type"; Code[20])
        {
            Caption = 'Unit Type';
            TableRelation = "TMAC Unit Type";
            Editable = false;
            ToolTip = 'Specifies the type of logistic unit, if the source link references a container classification.';
        }

        field(50; "Qty to Post"; Decimal)
        {
            Caption = 'Qty to Post';
            Editable = false;
            ToolTip = 'Specifies how many items from this link have yet to be posted, referencing the source doc.';
        }

        /// <summary>
        /// posted quantity
        /// </summary>
        field(51; "Posted Quantity"; Decimal)
        {
            Caption = 'Posted Quantity';
            Editable = false;
            ToolTip = 'Specifies how many items in this link are recorded in official inventory or posted documents.';
        }

        /// <summary>
        /// Indicates that the link points to an posted document  
        /// (so there’s no need to filter by SourceType and so on)
        /// </summary>
        field(52; "Posted"; Boolean)
        {
            Caption = 'Posted';
            Editable = false;
            ToolTip = 'Specifies whether the quantity under this link has been fully posted in the system records.';
        }

        /// <summary>
        /// Indicates whether the operation is included in the calculation of expected and current stock
        /// </summary>
        field(53; "Calculation"; Boolean)
        {
            Caption = 'Calculation';
            Editable = false;
            ToolTip = 'Specifies if this link is included in on-hand or expected quantity calculations for inventory tracking.';
        }
    }

    keys
    {
        key(PK; "Unit No.", "Posted Version", "Unit Line No.", "Source Type", "Source Subtype", "Source ID", "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.", "Package No.", "Lot No.", "Serial No.", "Positive")
        {
            Clustered = true;
        }

        key(Key1; "Unit No.", "Posted Version", "Unit Line No.", "Source Type", "Source Subtype", Posted, Calculation)
        {
            SumIndexFields = "Quantity", "Quantity (Base)";
        }
    }
}
