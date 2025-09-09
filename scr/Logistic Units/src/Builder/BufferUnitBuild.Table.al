table 71628593 "TMAC Buffer Unit Build"
{
    Caption = 'Buffer (Temp)';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(2; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(3; "Indent"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(4; "Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(6; "Unit Type Code"; Code[20])
        {
            Caption = 'Unit Type Code';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit Type".Code;
        }
        field(7; "Type"; Enum "TMAC Unit Line Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(8; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(9; "Unit of Measure"; code[20])
        {
            Caption = 'Unit of Measure"';
            DataClassification = CustomerContent;
        }
        field(10; "Gross Weight (base)"; Decimal)
        {
            Caption = 'Gross Weight (base)"';
            DataClassification = CustomerContent;
        }
        field(11; "Volume (base)"; Decimal)
        {
            Caption = 'Volume (base)"';
            DataClassification = CustomerContent;
        }

        field(21; "Parent Unit No."; Code[20])
        {
            Caption = 'Unit No.';
            Editable = false;
            TableRelation = "TMAC Unit"."No.";
            DataClassification = CustomerContent;
        }
        field(22; "Parent Unit Line No."; Integer)
        {
            Caption = 'Unit Line No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}