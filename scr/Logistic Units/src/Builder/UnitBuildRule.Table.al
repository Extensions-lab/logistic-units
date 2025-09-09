table 71628587 "TMAC Unit Build Rule"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = "TMAC Unit Build Rule List";
    LookupPageId = "TMAC Unit Build Rule List";

    fields
    {
        field(1; "Unit Build Rule Code"; Code[20])
        {
            Caption = 'Unit Build Rule Code';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the code used to identify this unit build rule for grouping or referencing in TMS processes.';
        }

        field(2; "Type"; Enum "TMAC Content Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the main content type for this rule: None, Unit Type, Unit, or Item.';
            trigger OnValidate()
            begin
                if Type <> xRec.Type then
                    Validate("No.", '');
            end;
        }
        
        field(3; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Type" = CONST(Item)) "Item"."No."
            ELSE
            IF ("Type" = CONST("Unit Type")) "TMAC Unit Type".Code
            ELSE
            IF ("Type" = CONST("Unit")) "TMAC Unit"."No.";
            ToolTip = 'Specifies the reference number for the content, like the item number or unit type code, based on Type.';

            trigger OnValidate()
            var
                UnitType: Record "TMAC Unit Type";
                Item: Record Item;
                Unit: Record "TMAC Unit";
            begin

                if "No." = '' then begin
                    ClearLine();
                    exit;
                end;

                case "Type" of
                    "Type"::"Item":
                        if Item.Get("No.") then begin
                            Validate(Description, Item.Description);
                            Validate("Description 2", Item."Description 2");
                            Validate("Unit of Measure Code", Item."Base Unit of Measure");
                        end;
                    "Type"::"Unit":
                        if Unit.Get("No.") then
                            Validate(Description, Unit.Description);
                    "Type"::"Unit Type":
                        if UnitType.Get("No.") then begin
                            Validate(Description, UnitType.Description);
                            Validate("Description 2", UnitType."Description 2");
                        end;
                end;
            end;
        }

        field(4; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST(Item)) "Item Variant".Code where("Item No." = field("No."));
            ToolTip = 'Specifies the variant code if the item has multiple variations, like size or color.';
            trigger OnValidate()
            var
                Item: Record Item;
                ItemVariant: Record "Item Variant";
            begin
                if "Variant Code" = '' then begin
                    if Item.Get("No.") then begin
                        Validate(Description, Item.Description);
                        Validate("Description 2", Item."Description 2");
                    end
                end else
                    if ItemVariant.get("Variant Code") then begin
                        Validate(Description, ItemVariant.Description);
                        Validate("Description 2", ItemVariant."Description 2");
                    end;
            end;
        }

        field(5; "Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies details or a descriptive name for the selected content, helping to identify it.';
        }

        field(6; "Description 2"; Text[100])
        {
            Caption = 'Description 2';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies additional descriptive text for extended details about the content.';
        }

        field(7; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST(Item), "No." = FILTER(<> '')) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));
            ToolTip = 'Specifies the base unit of measure applied to the content for quantity calculations.';
        }

        field(8; "Priority"; Integer)
        {
            Caption = 'Priority';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the order of importance when applying multiple build rules, with lower numbers processed first.';
        }

        field(9; "Build Action Type"; Enum "TMAC Build Action Type")
        {
            Caption = 'Build Action Type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies how the logistic unit is constructed: Create for new units or Add and Create for combining with existing units.';
        }

        field(11; "Split Qty."; Decimal)
        {
            Caption = 'Max Qty. in Logistic Unit';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the maximum quantity allowed per logistic unit before splitting into multiple units.';
        }

        field(12; "Remains can be mixed"; Boolean)
        {
            Caption = 'Remains Can Be Mixed';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether leftover quantities of an item can be placed in a unit containing different items.';
        }

        field(20; "Unit Type Code"; Code[20])
        {
            Caption = 'Unit Type Code';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit Type".Code;
            ToolTip = 'Specifies the logistic unit type code to create when the build rule is applied.';
            trigger OnValidate()
            Var
                UnitType: Record "TMAC Unit Type";
            begin
                "Unit Type Description" := '';
                if UnitType.Get("Unit Type Code") then
                    "Unit Type Description" := UnitType.Description;
            end;
        }

        field(21; "Unit Type Description"; Text[100])
        {
            Caption = 'Build Unit Type Description';
            DataClassification = CustomerContent;
            Editable = false;
            ToolTip = 'Specifies a read-only description of the selected logistic unit type to be created.';
        }

        field(22; "Blocked"; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether this rule is temporarily disabled from the auto-building process for logistic units.';
        }
    }

    keys
    {
        key(PK; "Unit Build Rule Code", "Type", "No.", "Variant Code", "Unit of Measure Code", "Priority")
        {
            Clustered = true;
        }
    }


    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

    local procedure ClearLine()
    begin
        Description := '';
        "Description 2" := '';
        "Unit of Measure Code" := '';
    end;

}