/// <summary>
/// A universal table that can represent a reference to any document or its line.
/// Used in the creation of logistic units in documents.
/// WARNING: this table is TEMPORARY by design!!!
/// </summary>
table 71628586 "TMAC Source Document Link"
{
    Caption = 'Source Document Line';
    DataClassification = CustomerContent;
    TableType = Temporary;


    fields
    {
        /// <summary>
        /// Table number
        /// </summary>
        field(1; "Source Type"; Integer)
        {
            Caption = 'Source Type';
            Tooltip = 'Specifies the numeric code for the external table or entity that links to this record.';
        }

        /// <summary>
        /// Document Type
        /// </summary>
        field(2; "Source Subtype"; Integer)
        {
            Caption = 'Source Subtype';
            Tooltip = 'Specifies a further classification of the source document or entity for this record.';
        }

        /// <summary>
        /// Document Number
        /// </summary>
        field(3; "Source ID"; Code[20])
        {
            Caption = 'Source ID';
            Tooltip = 'Specifies the identifier or number of the external document that feeds data into this record.';
        }

        field(4; "Source Batch Name"; Code[10])
        {
            Caption = 'Source Batch Name';
            Tooltip = 'Specifies the batch or group name under which the original source document is processed.';
        }

        field(5; "Source Prod. Order Line"; Integer)
        {
            Caption = 'Source Prod. Order Line';
            Tooltip = 'Specifies the production order line number if this record is linked to a manufacturing process.';
        }

        field(6; "Source Ref. No."; Integer)
        {
            Caption = 'Source Ref. No.';
            Tooltip = 'Specifies an additional reference or line number to identify the exact source document line.';
        }

        field(7; "Package No."; Code[50])
        {
            Caption = 'Package No.';
            CaptionClass = '6,1';
            Tooltip = 'Specifies the package identifier if the document items are grouped in a labeled package.';
        }

        field(8; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            Tooltip = 'Specifies the lot number of items for batch-level monitoring and traceability.';
        }

        field(9; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
            Tooltip = 'Specifies the unique serial number for individual item tracking if required.';
        }

        field(10; Positive; Boolean)
        {
            Caption = 'Positive';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies whether the movement is inbound (true) or outbound (false) for the logistic process.';
        }

        /// <summary>
        /// Reference to the source document. For example, each line in  
        /// Warehouse Shipment and Warehouse Receipt has a reference to the original document it was created from  
        /// - table number
        /// </summary>
        field(15; "Document Source Type"; Integer)
        {
            Caption = 'Document Source Type';
            Tooltip = 'Specifies the numeric code of the original external document from which this record is derived.';
        }

        /// <summary>
        /// Reference to the source document. For example, each line in  
        /// Warehouse Shipment and Warehouse Receipt has a reference to the original document it was created from  
        /// - document type
        /// </summary>
        field(16; "Document Source SubType"; Integer)
        {
            Caption = 'Document Source SubType';
            Tooltip = 'Specifies a further classification of the original document type for logistical operations.';
        }

        /// <summary>
        /// Reference to the source document. For example, each line in  
        /// Warehouse Shipment and Warehouse Receipt has a reference to the original document it was created from  
        /// - document number
        /// </summary>
        field(17; "Document Source ID"; Code[20])
        {
            Caption = 'Document Source ID';
            Tooltip = 'Specifies the ID or code of the original external document associated with this link.';
        }


        field(20; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the item code if this record references a particular product in the external document.';
        }

        field(21; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies a variation of the item, such as size or color, if relevant to the linked document.';
        }

        field(22; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies additional details about the item or line in the external document reference.';
        }

        field(30; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            MinValue = 0;
            Tooltip = 'Specifies how many units of the item are recorded in this link for the logistic process.';
        }

        field(31; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the measure (e.g., pcs, kg) used to quantify the item within this record.';
        }

        field(32; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
            MinValue = 0;
            Tooltip = 'Specifies the quantity of the item in base units for standardized calculations.';
        }

        /// <summary>
        /// Weight per unit of measure. Essentially the weight from the Item Unit of Measure.
        /// </summary>
        field(33; "Weight (Base) per UoM"; Decimal)
        {
            Caption = 'Weight (Base) per UoM';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
            MinValue = 0;
            Tooltip = 'Specifies how much one unit of measure weighs in the base weight unit, enabling shipping accuracy.';
        }

        /// <summary>
        /// Volume per unit of measure. Essentially the cubage from the Item Unit of Measure.
        /// </summary>
        field(34; "Volume (Base) per UoM"; Decimal)
        {
            Caption = 'Volume (Base) per UoM';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
            MinValue = 0;
            Tooltip = 'Specifies how much volume one unit of measure occupies in the base volume unit, aiding capacity checks.';
        }

        field(35; "Qty. per UoM"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
            InitValue = 1;
            Tooltip = 'Specifies the number of base units included in one unit of measure for this item.';
        }

        /// <summary>
        /// Quantity used to control links for a document line.  
        /// Essentially, this is the total quantity in the document for the original document line.
        /// </summary>
        field(36; "Control Quantity"; Decimal)
        {
            Caption = 'Control Quantity';
            DataClassification = CustomerContent;
            MinValue = 0;
            Tooltip = 'Specifies the total item quantity in the external document, used for linking validation checks.';
        }

        /// <summary>
        /// Recommended quantity for the Selected Quantity field  
        /// in the logistic unit creation wizard.
        /// </summary>
        field(37; "Default Selected Quantity"; Decimal)
        {
            Caption = 'Default Selected Quantity';
            DataClassification = CustomerContent;
            MinValue = 0;
            Tooltip = 'Specifies the suggested quantity for logistic unit creation if default selection is active.';
        }

        field(40; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies which warehouse location is linked to this item line for logistic tracking.';
        }

        field(42; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the bin or warehouse sub-location for storing or picking the item line in the document.';
        }

        /// <summary>
        /// Reference to logistic unit building rules.
        /// </summary>
        field(50; "No. of Build Rules"; Integer)
        {
            Caption = 'No. of Build Rules';
            FieldClass = FlowField;
            CalcFormula = count("TMAC Unit Build Rule" where("Type" = const(Item),
                                                             "No." = field("Item No."),
                                                             "Variant Code" = field("Variant Code"),
                                                             "Unit of Measure Code" = field("Unit of Measure Code")));
            Editable = false;
            Tooltip = 'Specifies how many logistic unit build rules match this item, variant, and unit of measure.';
        }

        /// <summary>
        /// Field for the logistic unit creation wizard.  
        /// Displays the quantity already allocated to logistic units, with sign.
        /// </summary>
        field(51; "Distributed Quantity"; Decimal)
        {
            Caption = 'Distributed Quantity';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula =
                sum("TMAC Unit Line Link"."Quantity" where(
                    "Source Type" = field("Source Type"),
                    "Source Subtype" = field("Source Subtype"),
                    "Source ID" = field("Source ID"),
                    "Source Batch Name" = field("Source Batch Name"),
                    "Source Prod. Order Line" = field("Source Prod. Order Line"),
                    "Source Ref. No." = field("Source Ref. No."),
                    "Package No." = field("Package No."),
                    "Lot No." = field("Lot No."),
                    "Serial No." = field("Serial No."),
                    "Positive" = field(Positive)));
            Tooltip = 'Specifies how many units of this document line have already been assigned to logistic units.';
        }

        field(52; "Distributed Weight (base)"; Decimal)
        {
            Caption = 'Distributed Weight (base)';
            Editable = false;
            FieldClass = FlowField;

            CalcFormula =
                sum("TMAC Unit Line Link"."Weight (Base)" where(
                    "Source Type" = field("Source Type"),
                    "Source Subtype" = field("Source Subtype"),
                    "Source ID" = field("Source ID"),
                    "Source Batch Name" = field("Source Batch Name"),
                    "Source Prod. Order Line" = field("Source Prod. Order Line"),
                    "Source Ref. No." = field("Source Ref. No."),
                    "Package No." = field("Package No."),
                    "Lot No." = field("Lot No."),
                    "Serial No." = field("Serial No."),
                    "Positive" = field(Positive)));
            Tooltip = 'Specifies the total weight of items from this line that are already assigned to logistic units.';
        }

        /// <summary>
        /// Field for the logistic unit creation wizard.  
        /// Specifies the selected quantity for creating a logistic unit and placing it into the newly created unit.
        /// </summary>
        field(55; "Selected Quantity"; Decimal)
        {
            Caption = 'Selected Quantity';
            DataClassification = CustomerContent;
            MinValue = 0;
            Tooltip = 'Specifies how many units from this document line are chosen for building or linking to a logistic unit.';
            trigger OnValidate()
            var
                LogisticUnitSetup: Record "TMAC Logistic Units Setup";
            begin
                LogisticUnitSetup.Get();

                CalcFields("Distributed Quantity");

                if LogisticUnitSetup."Set Default Selected Quantity" and LogisticUnitSetup."Strict Control Def. Qty." then begin
                    if "Selected Quantity" > "Default Selected Quantity" - ABS("Distributed Quantity") then
                        "Selected Quantity" := "Default Selected Quantity" - ABS("Distributed Quantity");
                end else
                    if "Selected Quantity" > "Quantity" - ABS("Distributed Quantity") then
                        "Selected Quantity" := "Quantity" - ABS("Distributed Quantity");

                if "Selected Quantity" < 0 then
                    "Selected Quantity" := 0;
            end;
        }

        /// <summary>
        /// Field used for linking a line to logistic units.
        /// </summary>
        field(56; "Selected Logistic Unit No."; Code[20])
        {
            Caption = 'Selected Logistic Unit';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies which logistic unit code is selected to carry these items, if any.';
        }

        /// <summary>
        /// Field used for linking to logistic units to calculate the quantity that has already  
        /// been linked to the related document.  
        /// For example:  
        /// if Source Type = Sales Line, then Opposite Source Type = Sales Shipment Line,  
        /// and vice versa.  
        /// This field is used in calculations to determine the quantity that can still be linked to the LU line.
        /// </summary>
        field(57; "Opposite Source Type"; Integer)
        {
            Caption = 'Opposite Source Type';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies a complementary document type used for posted or unposted lines in logistic linking.';
        }

        field(58; "Opposite Source Subtype"; Integer)
        {
            Caption = 'Opposite Source Subtype';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies a related subtype of the external document for advanced linking scenarios.';
        }

        /// <summary>
        /// Additional informational fields.  
        /// For now, this field will display the customer/vendor name.
        /// </summary>
        field(100; "Document Source Information"; Text[150])
        {
            Caption = 'Document Source Information';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies additional context about the source document, such as a partner or order reference.';
        }

        /// <summary>
        /// Used for various selection of lines based on certain criteria.
        /// </summary>
        field(110; "Select"; Boolean)
        {
            Caption = 'Select';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies whether this record is flagged for selection in the wizard or logistic unit creation flow.';
        }

    }

    keys
    {
        key(PK; "Source Type", "Source Subtype", "Source ID", "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.", "Package No.", "Lot No.", "Serial No.", "Positive")
        {
            Clustered = true;
        }
        key(Key1; "Item No.", "Variant Code", "Unit of Measure Code")
        {
        }

        key(Key2; "Document Source Type", "Document Source SubType", "Document Source ID")
        {
        }
    }

    /// <summary>
    /// For temporary tables, Init() doesn't work correctly and doesn't clear fields  
    /// (got caught with LotNo of type Code[] in the wizard because of this).
    /// </summary>
    procedure Clear()
    begin
        "Source Type" := 0;
        "Source Subtype" := 0;
        "Source ID" := '';
        "Source Batch Name" := '';
        "Source Prod. Order Line" := 0;
        "Source Ref. No." := 0;
        "Package No." := '';
        "Lot No." := '';
        "Serial No." := '';
        Positive := false;

        "Document Source Type" := 0;
        "Document Source SubType" := 0;
        "Document Source ID" := '';
        "Item No." := '';
        "Variant Code" := '';
        Description := '';
        Quantity := 0;
        "Unit of Measure Code" := '';
        "Quantity (Base)" := 0;
        "Weight (Base) per UoM" := 0;
        "Volume (Base) per UoM" := 0;
        "Qty. per UoM" := 0;
        "Control Quantity" := 0;
        "Location Code" := '';
        "Bin Code" := '';
        "Selected Quantity" := 0;
        "Selected Logistic Unit No." := '';
        "Opposite Source Type" := 0;
        "Opposite Source Subtype" := 0;
        "Document Source Information" := '';
    end;
}