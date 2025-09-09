table 71628605 "TMAC Unit Document Info"
{
    Caption = 'TMAC Unit Document Info';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "Unit No."; Code[20])
        {
            Caption = 'Unit No.';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the code of the logistic unit to which these documents are linked.';
        }
        field(2; "Sorting"; Integer)
        {
            Caption = 'Sorting';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the numeric order used to arrange these document records in the subform.';
        }
        field(3; "Document Name"; text[50])
        {
            Caption = 'Document Name';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies a descriptive name or title for the external or related document.';
        }
        field(4; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the code or reference number identifying the external or related document.';
        }

        field(10; "Source Type"; Integer)
        {
            Caption = 'Source Type';
            Tooltip = 'Specifies the numeric code indicating which table or entity owns this external document.';
        }

        field(11; "Source Subtype"; Integer)
        {
            Caption = 'Source Subtype';
            Tooltip = 'Specifies a subtype or detailed classification for the associated external document.';
        }
        field(12; "Source ID"; Code[20])
        {
            Caption = 'Source ID';
            Tooltip = 'Specifies the ID of the source record or document that references this logistic unit.';
        }
        field(13; "Source Batch Name"; Code[10])
        {
            Caption = 'Source Batch Name';
            Tooltip = 'Specifies the name of the batch or process to which the external document belongs.';
        }

        field(14; "Source Prod. Order Line"; Integer)
        {
            Caption = 'Source Prod. Order Line';
            Tooltip = 'Specifies the production order line number if the document is linked to manufacturing.';
        }
        field(15; "Source Ref. No."; Integer)
        {
            Caption = 'Source Ref. No.';
            Tooltip = 'Specifies any additional reference or line number from the source document for clarity.';
        }
    }
    keys
    {
        key(PK; "Unit No.", "Sorting", "Source Type", "Source Subtype", "Source ID", "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.")
        {
            Clustered = true;
        }
    }
}