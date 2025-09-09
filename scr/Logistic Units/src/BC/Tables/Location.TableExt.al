tableextension 71628576 "TMAC Location" extends Location
{
    fields
    {
        field(71628575; "TMAC Require LU for Rcpt"; Boolean)
        {
            Caption = 'Require Logistic Unit for Receipt';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the location requires a logistic unit for inbound receipts, ensuring items are associated with a logistic unit upon arrival.';
        }
        field(71628576; "TMAC Require LU for Spmt"; Boolean)
        {
            Caption = 'Require Logistic Unit for Shipment';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the location requires a logistic unit for outbound shipments. If cleared, the Disable Negative Quantity setting is also cleared.';
            trigger OnValidate()
            begin
                if not "TMAC Require LU for Spmt" then
                    "TMAC Disable Negative Quantity" := false;
            end;
        }
        field(71628577; "TMAC Disable Negative Quantity"; Boolean)
        {
            Caption = 'Disable Negative Quantity';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether negative inventory is disallowed at this location, preventing negative quantity postings for items or logistic units.';
        }

        /// <summary>
        /// Such an LU Location code should be assigned to LUs that arrive at this warehouse.
        /// </summary>
        field(71628578; "TMAC LU Location Code"; Code[20])
        {
            Caption = 'LU Location Code';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit Location";
            ToolTip = 'Specifies the logistic unit location code used when logistic units are placed at or received in this location.';
        }
    }
}
