page 71628596 "TMAC Unit Worksheet Names List"
{
    Caption = 'Logistic Units Worksheet Names List';
    SourceTable = "TMAC Unit Worksheet Name";
    DataCaptionFields = Name, Description;
    ApplicationArea = All;
    UsageCategory = Administration;
    PageType = List;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Name")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("USER ID"; Rec."USER ID")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
