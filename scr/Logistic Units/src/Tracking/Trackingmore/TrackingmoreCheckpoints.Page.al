page 71628659 "TMAC Trackingmore Checkpoints"
{
    Caption = 'Trackingmore Checkpoints';
    PageType = List;
    SourceTable = "TMAC Trackingmore Checkpoint";
    SourceTableView = sorting("Side", "Checkpoint Time");
    ApplicationArea = all;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Checkpoint Time"; Rec."Checkpoint Time")
                {
                    ToolTip = 'Specifies the value of the Checkpoint Time field';
                    ApplicationArea = All;
                }
                field("Status Description"; Rec."Status Description")
                {
                    ToolTip = 'Specifies the value of the Status Description field';
                    ApplicationArea = All;
                }
                field(Details; Rec.Details)
                {
                    ToolTip = 'Specifies the value of the Details field';
                    ApplicationArea = All;
                }

                field("Checkpoint Status"; Rec."Checkpoint Status")
                {
                    ToolTip = 'Specifies the value of the Details field';
                    ApplicationArea = All;
                }
                field(Substatus; Rec.Substatus)
                {
                    ToolTip = 'Specifies the value of the Substatus field';
                    ApplicationArea = All;
                }
                field(Side; Rec.Side)
                {
                    ToolTip = 'Specifies the side.';
                    ApplicationArea = All;
                }
            }
        }
    }
}
