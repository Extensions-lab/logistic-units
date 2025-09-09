page 71628582 "TMAC SSCC GS1 AI List"
{
    Caption = 'GS1 Application Identifiers';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "TMAC SSCC GS1 AI";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Format; Rec.Format)
                {
                    ApplicationArea = All;
                }
                field(Title; Rec.Title)
                {
                    ApplicationArea = All;
                }
                field("Regular Expression"; Rec."Regular Expression")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}