/// <summary>
/// connection between the contents of the Logistics Unit and external documents
/// </summary>
table 71628602 "TMAC Unit Line Link"
{
    Caption = 'Unit Line Link';
    DataClassification = CustomerContent;
    LookupPageId = "TMAC Unit Line Links";
    DrillDownPageId = "TMAC Unit Line Links";

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
            Tooltip = 'Specifies the code of the logistic unit that contains the referenced items or documents.';
        }

        /// <summary>
        /// Logistics unit line number
        /// </summary>
        field(3; "Unit Line No."; Integer)
        {
            Caption = 'Unit Line No.';
            TableRelation = "TMAC Unit Line"."Line No." where("Unit No." = field("Unit No."));
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the line number within the logistic unit for the linked items or references.';
        }

        /// <summary>
        /// Table number
        /// </summary>
        field(10; "Source Type"; Integer)
        {
            Caption = 'Source Type';
            Tooltip = 'Specifies the external table or type of the document referencing this logistic unit line.';
        }

        /// <summary>
        /// Document Type
        /// </summary>
        field(11; "Source Subtype"; Integer)
        {
            Caption = 'Source Subtype';
            Tooltip = 'Specifies a sub-classification of the source document for more detailed reference handling.';
        }

        /// <summary>
        /// Document number
        /// </summary>
        field(12; "Source ID"; Code[20])
        {
            Caption = 'Source ID';
            Tooltip = 'Specifies the identification number of the external document that references this line.';
        }

        field(13; "Source Batch Name"; Code[10])
        {
            Caption = 'Source Batch Name';
            Tooltip = 'Specifies the batch or process name associated with the external document, if applicable.';
        }

        field(14; "Source Prod. Order Line"; Integer)
        {
            Caption = 'Source Prod. Order Line';
            Tooltip = 'Specifies the production order line number if linked to a manufacturing process.';
        }

        field(15; "Source Ref. No."; Integer)
        {
            Caption = 'Source Ref. No.';
            Tooltip = 'Specifies an additional reference number from the external document or source line.';
        }

        /// <summary>
        /// Source description field
        /// </summary>
        field(16; "Source Name"; Text[50])
        {
            Caption = 'Source Name';
            Tooltip = 'Specifies a descriptive name for the external document or partner referencing this link.';
        }

        field(20; "Package No."; Code[50])
        {
            Caption = 'Package No.';
            CaptionClass = '6,1';
            Tooltip = 'Specifies the package identifier if items are grouped or shipped under a package label.';
        }

        field(21; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            Tooltip = 'Specifies the lot number for item tracking, ensuring batch-level traceability if needed.';
        }

        field(22; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
            Tooltip = 'Specifies the unique serial number, providing detailed item-level traceability if required.';
        }

        /// <summary>
        /// Field used for link splitting... for example, this is used in a transfer link when there are two links from a transfer line to a pallet line
        /// </summary>
        field(23; "Positive"; Boolean)
        {
            Caption = 'Positive';
            Editable = false;
            Tooltip = 'Specifies whether the linked quantity is incoming (true) or outgoing (false) for inventory purposes.';
        }

        field(30; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";
            Tooltip = 'Specifies the item number if this link represents a product being added or removed from the logistic unit.';
        }

        field(31; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."), Code = FIELD("Variant Code"));
            Tooltip = 'Specifies the specific variant (such as color or size) of the item, if applicable.';
        }

        field(32; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies a short description of the item or related context in this link.';
        }

        field(33; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            MinValue = 0;
            Tooltip = 'Specifies how many units of the item are associated with this logistic unit line link.';
        }

        field(34; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
            Tooltip = 'Specifies the designated unit of measure (for example, pcs or kg) for the specified item.';
        }

        field(35; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the quantity in base units, supporting standardized inventory calculations.';
        }

        /// <summary>
        /// Weight of this amount
        /// </summary>
        field(36; "Weight (Base)"; Decimal)
        {
            Caption = 'Weight (Base)';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the total weight, in base weight units, for the specified quantity of items in this link.';
        }

        /// <summary>
        /// Volume of this quantity
        /// </summary>
        field(37; "Volume (Base)"; Decimal)
        {
            Caption = 'Volume (Base)';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the total volume, in base volume units, for the specified quantity of items in this link.';
        }

        field(38; "Qty. per UoM"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
            InitValue = 1;
            Tooltip = 'Specifies how many base units are included in one unit of measure for this item.';
        }

        field(40; "Warranty Date"; Date)
        {
            Caption = 'Warranty Date';
            Editable = false;
            Tooltip = 'Specifies the warranty date if items carry a warranty period, indicating coverage end.';
        }

        field(41; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
            Editable = false;
            Tooltip = 'Specifies the date after which the items expire or are no longer valid for shipment or sale.';
        }

        /// <summary>
        /// Additional Information Fields
        /// </summary>
        field(42; "Unit Type"; Code[20])
        {
            Caption = 'Unit Type';
            TableRelation = "TMAC Unit Type".Code;
            Editable = false;
            Tooltip = 'Specifies the type category of the linked logistic unit, such as a box, pallet, or container.';
        }

        /// <summary>
        /// Field used in accounting to find specific links to specific LUs
        /// </summary>
        field(50; "Qty. to Post"; Decimal)
        {
            Caption = 'Qty. to Post';
            Editable = false;
            Tooltip = 'Specifies the quantity pending to be posted to the related document, reflecting incomplete processing.';
        }

        /// <summary>
        /// posted quantity. Filled only in links to unposted documents
        /// </summary>
        field(51; "Posted Quantity"; Decimal)
        {
            Caption = 'Posted Quantity';
            Editable = false;
            Tooltip = 'Specifies how many units have already been posted for this link in the external document.';
        }

        /// <summary>
        /// Indicates that the link points to an posted document (so there’s no need to filter by SourceType and so on)
        /// </summary>
        field(52; "Posted"; Boolean)
        {
            Caption = 'Posted';
            Editable = false;
            Tooltip = 'Specifies whether this link is associated with a fully posted document (true) or an open one (false).';
        }

        /// <summary>
        /// Indicates whether the operation is included in the calculation of expected and current stock
        /// </summary>
        field(53; "Calculation"; Boolean)
        {
            Caption = 'Calculation';
            Editable = false;
            Tooltip = 'Specifies whether this link is included in inventory or cost calculations, such as for expected and posted data.';
        }
    }
    keys
    {
        key(PK; "Unit No.", "Unit Line No.", "Source Type", "Source Subtype", "Source ID", "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.", "Package No.", "Lot No.", "Serial No.", "Positive")
        {
            Clustered = true;
        }

        key(Key1; "Unit No.", "Unit Line No.", "Source Type", "Source Subtype", Posted, Calculation)
        {
            SumIndexFields = "Quantity", "Quantity (Base)";
        }

        // key for posting
        key(Key2; "Source Type", "Source Subtype", "Source ID", "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.", "Package No.", "Lot No.", "Serial No.", "Positive", "Qty. to Post")
        {
            SumIndexFields = "Quantity", "Quantity (Base)";
        }
    }

    trigger OnInsert()
    begin
        "Source Name" := UnitLinkManagement.GetSourceName(Rec."Source Type", Rec."Source Subtype");
    end;

    trigger OnDelete()
    begin

    end;

    var
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
}