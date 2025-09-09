page 71628652 "TMAC Aftership Checkpoints"
{

    ApplicationArea = All;
    Caption = 'Aftership Checkpoints';
    PageType = List;
    SourceTable = "TMAC Aftership Checkpoint";
    UsageCategory = Lists;
    SourceTableView = sorting("ID", "Checkpoint Time");
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Checkpoint Time"; Rec."Checkpoint Time")
                {
                    ApplicationArea = All;
                }
                field(Tag; Rec.Tag)
                {
                    Caption = 'Status';
                    ApplicationArea = All;
                }
                field(SubTag; Rec.SubTag)
                {
                    Caption = 'Substatus';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("SubTag Message"; Rec."SubTag Message")
                {
                    ApplicationArea = All;
                }
                field(Message; Rec.Message)
                {
                    ApplicationArea = All;
                }
                field(State; Rec.State)
                {
                    ApplicationArea = All;
                }
                field(Country; Rec.Country)
                {
                    ApplicationArea = All;
                }
                field("Country Name"; Rec."Country Name")
                {
                    ApplicationArea = All;
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                }
                field(Location; Rec.Location)
                {
                    ApplicationArea = All;
                }
                field(Zip; Rec.Zip)
                {
                    ApplicationArea = All;
                }
                field("Created At"; Rec."Created At")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Slug; Rec.Slug)
                {
                    Caption = 'Carrier';
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

}
