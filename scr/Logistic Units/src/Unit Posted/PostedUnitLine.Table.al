table 71628611 "TMAC Posted Unit Line"
{
    Caption = 'Posted Unit Line';

    fields
    {
        field(1; "Unit No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TMAC Posted Unit"."No.";
            ToolTip = 'Specifies the posted logistic unit number to which this line belongs.';
        }
        field(2; "Posted Version"; Integer)
        {
            Caption = 'Posted Version';
            Editable = false;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the version of the posted unit that this line is associated with.';
        }

        field(3; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the sequential line number for items or nested content in this posted unit.';
        }
        field(4; "Type"; Enum "TMAC Unit Line Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the line contains an item, another nested unit, or other content type.';
        }
        field(5; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the identifier based on the chosen Type. For example, an item number or another unit code.';
        }
        field(6; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the item variant, such as size or color, when the line Type is set to Item.';
        }
        field(7; "Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a brief text describing the content of this posted line, such as the item details.';
        }
        field(8; "Description 2"; Text[100])
        {
            Caption = 'Description 2';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies additional descriptive text to further clarify the contents of this line.';
        }

        field(9; GTIN; Code[14])
        {
            Caption = 'GTIN';
            Numeric = true;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the Global Trade Item Number if applicable for the item or unit on this line.';
        }
        field(10; "SSCC"; Code[25])
        {
            Caption = 'SSCC';
            DataClassification = CustomerContent;
            TableRelation = "TMAC SSCC"."No.";
            ToolTip = 'Specifies the Serial Shipping Container Code if this sub-unit itself is assigned an SSCC.';
        }
        field(13; "Quantity"; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            MinValue = 0;
            ToolTip = 'Specifies how many units of the selected item or nested logistic unit exist on this posted line.';
        }

        field(14; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the unit of measure (e.g., pcs) used to quantify the item or sub-unit on this line.';
        }
        field(15; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
            InitValue = 1;
            ToolTip = 'Specifies how many base units are contained in the selected unit of measure on this line.';
        }
        field(16; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the quantity in base units, automatically calculated from Qty. per Unit of Measure.';
        }

        field(17; "Gross Weight (base)"; Decimal)
        {
            Caption = 'Gross Weight';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the total weight including packaging or container materials for these items on this line.';
        }
        field(18; "Net Weight (base)"; Decimal)
        {
            Caption = 'Net Weight';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the net weight of the item content itself, excluding packaging or container weight.';
        }
        field(19; "Volume (base)"; Decimal)
        {
            Caption = 'Volume';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the cubic space occupied by the item content, relevant for storage or transport.';
        }

        field(20; "Unit Type Code"; Code[20])
        {
            Caption = 'Unit Type Code';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit Type".Code;
            ToolTip = 'Specifies the type code if the line references a specific style or classification of logistic unit.';
        }

        field(25; "Freight Class"; Code[10])
        {
            Caption = 'Freight Class';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Freight Class".Code;
            ToolTip = 'Specifies the freight classification for rating or regulatory compliance for these goods.';
        }

        field(40; "Linked Type Filter"; Integer)
        {
            Caption = 'Linked Type Filter';
            FieldClass = FlowFilter;
            ToolTip = 'Specifies a filter indicating which external source type is linked to this posted line, if any.';
        }
        field(41; "Linked Subtype Filter"; Integer)
        {
            Caption = 'Linked Subtype Filter';
            FieldClass = FlowFilter;
            ToolTip = 'Specifies a filter for more specific source subcategories or document types that are linked.';
        }

        field(42; "Linked Quantity"; decimal)
        {
            Caption = 'Linked Quantity';
            FieldClass = FlowField;
            CalcFormula = sum("TMAC Posted Unit Line Link"."Quantity"
                where(
                    "Unit No." = field("Unit No."),
                    "Posted Version" = field("Posted Version"),
                    "Unit Line No." = field("Line No."),
                    "Source Type" = FIELD("Linked Type Filter"),
                    "Source Subtype" = FIELD("Linked Subtype Filter")));
            Editable = false;
            ToolTip = 'Specifies how many units are associated with external documents matching the Type and Subtype filters.';
        }
        field(43; "Linked Quantity (Base)"; decimal)
        {
            Caption = 'Linked Quantity (Base)';
            FieldClass = FlowField;
            CalcFormula = sum("TMAC Posted Unit Line Link"."Quantity (Base)"
                where(
                    "Unit No." = field("Unit No."),
                    "Posted Version" = field("Posted Version"),
                    "Unit Line No." = field("Line No."),
                    "Source Type" = FIELD("Linked Type Filter"),
                    "Source Subtype" = FIELD("Linked Subtype Filter")));
            Editable = false;
            ToolTip = 'Specifies the base-unit equivalent of the linked quantity, if referencing a specific item measure.';
        }
        field(44; "Linked Links Exist"; Boolean)
        {
            Caption = 'Linked Links Exist';
            FieldClass = FlowField;
            CalcFormula = exist("TMAC Posted Unit Line Link"
                where(
                    "Unit No." = field("Unit No."),
                    "Posted Version" = field("Posted Version"),
                    "Unit Line No." = field("Line No."),
                    "Source Type" = FIELD("Linked Type Filter"),
                    "Source Subtype" = FIELD("Linked Subtype Filter")));
            Editable = false;
            ToolTip = 'Specifies if there are any external references or documents linked to this posted line.';
        }
        field(45; "Inventory Quantity"; Decimal)
        {
            Caption = 'Inventory Quantity';
            FieldClass = FlowField;
            CalcFormula = sum("TMAC Posted Unit Line Link"."Quantity" where(
                "Unit No." = field("Unit No."),
                "Posted Version" = field("Posted Version"),
                "Unit Line No." = field("Line No."),
                "Posted" = const(true),
                "Calculation" = const(true)));
            Editable = false;
            ToolTip = 'Specifies how many units have been posted to inventory, reflecting actual stock levels.';
        }

        field(46; "Inventory Quantity (Base)"; Decimal)
        {
            Caption = 'Inventory Quantity (Base)';
            FieldClass = FlowField;
            CalcFormula = sum("TMAC Posted Unit Line Link"."Quantity (Base)" where(
                "Unit No." = field("Unit No."),
                "Posted Version" = field("Posted Version"),
                "Unit Line No." = field("Line No."),
                "Posted" = const(true),
                "Calculation" = const(true)));
            Editable = false;
            ToolTip = 'Specifies the base-unit equivalent of the inventory quantity, indicating posted stock in base measure.';
        }
        field(47; "Expected Quantity"; Decimal)
        {
            Caption = 'Expected Quantity';
            FieldClass = FlowField;
            CalcFormula = sum("TMAC Posted Unit Line Link"."Quantity" where(
                "Unit No." = field("Unit No."),
                "Posted Version" = field("Posted Version"),
                "Unit Line No." = field("Line No."),
                "Calculation" = const(true)));
            Editable = false;
            ToolTip = 'Specifies how many units have not yet been posted but are anticipated in documents referencing this line.';
        }

        field(48; "Expected Quantity (Base)"; Decimal)
        {
            Caption = 'Expected Quantity (Base)';
            FieldClass = FlowField;
            CalcFormula = sum("TMAC Posted Unit Line Link"."Quantity (Base)" where(
                "Unit No." = field("Unit No."),
                "Posted Version" = field("Posted Version"),
                "Unit Line No." = field("Line No."),
                "Calculation" = const(true)));
            Editable = false;
            ToolTip = 'Specifies the expected quantity in base units, derived from unposted but valid document lines.';
        }

        field(50; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the physical warehouse location code for where this posted line is recognized.';
        }
        field(51; "Zone Code"; Code[10])
        {
            Caption = 'Zone Code';
            DataClassification = CustomerContent;
            TableRelation = Zone.Code WHERE("Location Code" = FIELD("Location Code"));
            ToolTip = 'Specifies the warehouse zone for further division of space where this posted line item is placed.';
        }
        field(52; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            DataClassification = CustomerContent;
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"));
            ToolTip = 'Specifies the bin or shelf location code for storing this posted line within the warehouse zone.';
        }

        field(150; "Posted Unit System ID"; Guid)
        {
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the unique system ID referencing the parent posted unit record for internal usage.';
        }
    }

    keys
    {
        key(PK; "Unit No.", "Posted Version", "Line No.")
        {
            Clustered = true;
            SumIndexFields = "Gross Weight (base)", "Net Weight (base)", "Volume (base)", "Quantity";
        }
    }


    trigger OnInsert()
    var
        PostedUnit: Record "TMAC Posted Unit";
    begin
        if PostedUnit.Get("Unit No.", "Posted Version") then
            "Posted Unit System ID" := PostedUnit.SystemId;
    end;

    trigger OnRename()
    var
        PostedUnit: Record "TMAC Unit";
        EmptyGUID: GUID;
    begin
        if PostedUnit.Get("Unit No.", "Posted Version") then
            "Posted Unit System ID" := PostedUnit.SystemId
        else
            "Posted Unit System ID" := EmptyGUID;
    end;

    trigger OnDelete()
    var
        PostedUnitLineLink: Record "TMAC Posted Unit Line Link";
    begin
        PostedUnitLineLink.SetRange("Unit No.", "Unit No.");
        PostedUnitLineLink.Setrange("Posted Version", "Posted Version");
        PostedUnitLineLink.SetRange("Unit Line No.", "Line No.");
        PostedUnitLineLink.DeleteAll(true);
    end;
}