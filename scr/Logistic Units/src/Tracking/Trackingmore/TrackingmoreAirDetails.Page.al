page 71628656 "TMAC Trackingmore Air Details"
{
    Caption = 'Trackingmore Air Tracking Detail';
    PageType = List;
    SourceTable = "TMAC Trackingmore Air Detail";
    SourceTableView = sorting("Tracking Number", "Actual Date");
    Editable = false;
    ApplicationArea = all;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Tracking Number"; Rec."Tracking Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the tracking number.';
                }
                field("Actual Date"; Rec."Actual Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the actual date of event.';
                }
                field("Plan Date"; Rec."Plan Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the plan date of event.';
                }
                field("Event"; Rec."Event")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the event.';
                }
                field("Station"; Rec."Station")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the station.';
                }
                field("Flight Number"; Rec."Flight Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the flight number(s)';
                }
                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status';
                }
                field("Piece"; Rec."Piece")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the pieces.';
                }
                field("Weight"; Rec."Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the weight.';
                }
            }
        }
    }
}