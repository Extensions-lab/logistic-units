table 71628654 "TMAC Aftership Courier"
{
    Caption = 'Aftership.com Courier';
    LookupPageId = "TMAC Aftership Couriers";
    DrillDownPageId = "TMAC Aftership Couriers";
    fields
    {
        field(1; Slug; Text[100])
        {
            Caption = 'Slug';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the unique identifier used by Aftership to refer to this courier in tracking requests.';
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the official courier name as recognized by aftership.com.';
        }
        field(3; Phone; Text[50])
        {
            Caption = 'Phone';
            DataClassification = CustomerContent;
            ExtendedDatatype = PhoneNo;
            ToolTip = 'Specifies the contact phone number for the courier, used for reference or communication.';
        }
        field(4; "Other Name"; Text[250])
        {
            Caption = 'Other Name';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies any alternative names or aliases for this courier recognized by Aftership.';
        }
        field(5; "Web Url"; Text[250])
        {
            Caption = 'URL';
            DataClassification = CustomerContent;
            ExtendedDatatype = URL;
            ToolTip = 'Specifies the courier’s website or tracking portal address for user reference.';
        }
        field(6; "Required Fields"; text[1000])
        {
            Caption = 'Required Fields';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies any mandatory fields that must be included in tracking requests for this courier.';
        }
        field(7; "Optional Fields"; text[1000])
        {
            Caption = 'Optional Fields';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies additional optional data elements for more detailed tracking requests.';
        }
        field(8; "Default Language"; text[10])
        {
            Caption = 'Default Language';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the default language code used for the courier’s tracking updates if none is defined.';
        }
        field(9; "Support Languages"; text[1000])
        {
            Caption = 'Support Languages';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies which languages this courier supports for shipment tracking and notifications.';
        }
        field(10; "Service From Countries"; text[1000])
        {
            Caption = 'Service From Countries';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies which countries are served by this courier, as listed by aftership.com.';
        }
        field(11; Activated; Boolean)
        {
            Caption = 'Activated';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the courier is enabled in your aftership.com account for live tracking requests.';
        }
    }

    keys
    {
        key(Key1; slug)
        {
            Clustered = true;
        }
    }
}