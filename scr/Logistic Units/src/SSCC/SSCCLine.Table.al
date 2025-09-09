table 71628581 "TMAC SSCC Line"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "SSCC No."; Code[25])
        {
            Caption = 'SSCC No.';
            DataClassification = CustomerContent;
            TableRelation = "TMAC SSCC";
            ToolTip = 'Specifies the SSCC to which this line belongs, linking identifiers or additional data to the container code.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the sequential line number for this SSCC record, keeping track of multiple lines of data.';
        }
        field(3; "Identifier"; Code[10])
        {
            Caption = 'Identifier';
            DataClassification = CustomerContent;
            TableRelation = "TMAC SSCC GS1 AI".Code;
            ToolTip = 'Specifies the GS1 application identifier code that labels the type of data in this line.';
            trigger OnValidate()
            var
                SSCCGS1AI: Record "TMAC SSCC GS1 AI";
            begin
                if SSCCGS1AI.get("Identifier") then
                    Validate("Description", SSCCGS1AI.Description);
            end;
        }
        field(4; "Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a descriptive label for the GS1 application identifier or the data it represents.';
        }
        field(5; "Value"; Text[250])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the actual data associated with the identifier, such as a lot number or date.';
        }
        field(6; "Barcode"; enum "TMAC SSCC Barcode Place")
        {
            Caption = 'Barcode';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the position for this data in the printed barcode. For example: Top, Bottom, or Middle.';
        }
        field(7; "Barcode Type"; enum "TMAC SSCC Barcode Type")
        {
            Caption = 'Barcode Type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the selected barcode symbology, such as Code 128 or EAN-13, for encoding this line.';
        }
        field(8; "Label Text"; enum "TMAC SSCC Label Text Number")
        {
            Caption = 'Label Text';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies which label text reference is used when printing, allowing for different label messages.';
        }
    }

    keys
    {
        key(PK; "SSCC No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key1; "SSCC No.", "Barcode")
        {
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
}