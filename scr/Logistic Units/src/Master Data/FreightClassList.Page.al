page 71628577 "TMAC Freight Class List"
{
    Caption = 'Freight Classes';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "TMAC Freight Class";

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
                field("Weight Range Per Cubic Foot"; Rec."Weight Range Per Cubic Foot")
                {
                    ApplicationArea = All;
                }
                field(Comment; Rec.Comment)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}