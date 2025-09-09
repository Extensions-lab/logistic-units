table 71628591 "TMAC Freight Class"
{
    Caption = 'Freight Class';
    DataClassification = ToBeClassified;
    DrillDownPageId = "TMAC Freight Class List";
    LookupPageId = "TMAC Freight Class List";

    fields
    {
        field(1; Code; Code[10])
        {
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the code that uniquely identifies the freight class for transport and rating.';
        }
        field(2; Description; Text[100])
        {
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the name or details that clarify the nature of the freight class.';
        }
        field(3; "Weight Range Per Cubic Foot"; Text[100])
        {
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the range of weight per cubic foot that qualifies for this freight class.';
        }
        field(4; "Comment"; Text[100])
        {
            DataClassification = CustomerContent;
            ToolTip = 'Specifies any additional remarks or guidance related to this freight class.';
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; Code, Description, Comment)
        {
        }
    }

}