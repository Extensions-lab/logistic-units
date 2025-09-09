/// <summary>
/// The table is used as a temporary one in the processes of selecting a logistics unit.  
/// In logistics unit accounting, not this one is used, but a regular temporary table.
/// </summary>
table 71628590 "TMAC Unit Select By Source"
{
    Caption = 'Logistic Unit Select';
    TableType = Temporary;
    DrillDownPageId = "TMAC Unit Selection";
    LookupPageId = "TMAC Unit Selection";

    fields
    {
        field(1; "Unit No."; Code[20])
        {
            Caption = 'Unit No.';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the code assigned to this logistic unit, enabling identification of the pallet, container, or box in the system.';
        }
        field(2; "Source Type"; Integer)
        {
            Caption = 'Source Type';
            DataClassification = SystemMetadata;
            Tooltip = 'Specifies the document type or classification (such as purchase or sales) that generated this logistic unit.';
        }
        field(3; "Source Subtype"; Integer)
        {
            Caption = 'Source Subtype';
            DataClassification = SystemMetadata;
            Tooltip = 'Specifies a more detailed category of the logistic unit’s source, such as a sub-process or sub-document type.';
        }
        field(4; "Source ID"; Code[20])
        {
            Caption = 'Source ID';
            DataClassification = SystemMetadata;
            Tooltip = 'Specifies the unique identifier of the document or record from which this logistic unit originates.';
        }
        field(5; "Source Name"; Text[50])
        {
            Caption = 'Source Name';
            Tooltip = 'Specifies a descriptive name referencing the origin of this logistic unit, such as a related document or partner.';
        }
        field(6; "Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies additional information or notes about the logistic unit''s purpose or contents.';
        }
        field(7; "Customer/Vendor No."; Code[20])
        {
            Caption = 'Customer/Vendor No.';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the external partner number, such as a customer or vendor, relevant to this logistic unit.''s source.';
        }
        field(8; "Customer/Vendor Name"; Text[100])
        {
            Caption = 'Customer/Vendor No.';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the name of the external partner, such as a customer or vendor, tied to this logistic unit.''s source.';
        }
        field(9; "Country Code"; Code[10])
        {
            Caption = 'Country Code';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the country or region code associated with the address for this logistic unit.''s source.';
        }
        field(10; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the postal code of the address linked to this logistic unit.''s source.';
        }
        field(11; "County"; Text[30])
        {
            CaptionClass = '5,1,' + "Country Code";
            Caption = 'County';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the county or region for the address associated with this logistic unit.''s source.';
        }
        field(12; "City"; Code[30])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the city or locality for the address related to this logistic unit.''s source.';
        }
        field(13; "Address"; Text[200])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the street or detailed address information for the location connected to this logistic unit.''s source.';
        }

        field(14; Weight; Decimal)
        {
            Caption = 'Weight';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the total weight of the logistic unit or contents, aiding load planning and shipping.';
        }
        field(15; Volume; Decimal)
        {
            Caption = 'Volume';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the total volume of the logistic unit, supporting capacity checks and freight calculation.';
        }
        field(16; "Location Code"; Code[20])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the warehouse or physical location where this logistic unit is or should be stored.';
        }
        field(17; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies the bin within the warehouse location for the logistic unit, if applicable.';
        }
        field(18; "LU Location Code"; Code[20])
        {
            Caption = 'LU Location Code';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies a specialized location code used to identify if the logistic unit resides in a warehouse or with a customer.';
        }
        field(19; "Tracking No."; Text[50])
        {
            Caption = 'Tracking No.';
            DataClassification = CustomerContent;
            Tooltip = 'Specifies a carrier tracking identifier or reference number for monitoring this logistic unit in transit.';
        }
    }

    keys
    {
        key(PK; "Unit No.", "Source Type", "Source Subtype", "Source ID")
        {
            Clustered = true;
        }
    }
}