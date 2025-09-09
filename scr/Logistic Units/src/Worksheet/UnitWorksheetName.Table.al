table 71628620 "TMAC Unit Worksheet Name"
{
    Caption = 'Logistic Unit Worksheet Name';
    DataClassification = CustomerContent;
    DrillDownPageId = "TMAC Unit Worksheet Names List";
    LookupPageId = "TMAC Unit Worksheet Names List";

    fields
    {
        field(1; "Name"; Code[10])
        {
            Caption = 'Worksheet Name';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the code or name identifying this logistic unit worksheet for user tasks.';
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a descriptive label to clarify the purpose of this worksheet.';
        }
        field(3; "USER ID"; Code[50])
        {
            Caption = 'USER ID';
            DataClassification = CustomerContent;
            TableRelation = User;
            ToolTip = 'Specifies which user or role is associated with this worksheet for ownership or filtering.';
        }
    }
    keys
    {
        key(PK; "Name")
        {
            Clustered = true;
        }
    }
}
