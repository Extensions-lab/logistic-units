table 71628595 "TMAC Scanned Value"
{
    Caption = 'Scanned Value';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            ToolTip = 'Specifies the user who performed the scan, linking the scanned record to their session.';
        }

        field(2; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            ToolTip = 'Specifies a unique sequential number assigned to each scanned record for tracking.';
        }

        field(3; "Barcode"; Text[1000])
        {
            Caption = 'Barcode';
            ToolTip = 'Specifies the raw scanned text captured by the scanning device, such as a barcode or QR code.';
        }

        field(4; "Format"; Text[1000])
        {
            Caption = 'Format';
            ToolTip = 'Specifies the recognized barcode format (for example, QR Code or Code128) of the scanned data.';
        }

        field(5; Result; Text[50])
        {
            Caption = 'Format';
            ToolTip = 'Specifies additional interpreted details or outcomes derived from the scanned value.';
        }
    }

    keys
    {
        key(PK; "User ID", "Entry No.")
        {
            Clustered = true;
        }
    }
}
