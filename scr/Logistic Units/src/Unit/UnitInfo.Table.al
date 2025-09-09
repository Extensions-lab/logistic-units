table 71628604 "TMAC Unit Info"
{
    Caption = 'TMAC Unit info';
    DataClassification = CustomerContent;
    TableType = Temporary;


    fields
    {
        field(2; "Unit No."; Code[20])
        {
            Caption = 'Unit No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the logistic unit number used to uniquely identify this record during operations.';
        }
        field(3; Logistics; Text[50])
        {
            Caption = 'Logistics';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the type or direction of the logistic units, such as inbound or outbound movements.';
        }
        field(4; "Posted"; Boolean)
        {
            Caption = 'Posted';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the logistic unit is recorded or posted in the system, indicating finalized status.';
        }

        /// <summary>
        /// Для TMS
        /// </summary>
        field(5; "Load State"; Text[100])
        {
            Caption = 'Load State';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the load status of the logistic unit, such as partially loaded, fully loaded, or empty.';
        }
    }

    keys
    {
        key(PK; "Unit No.", "Posted", Logistics)
        {
            Clustered = true;
        }
    }
}
