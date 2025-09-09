page 71628657 "TMAC Trackingmore Air Tracks"
{
    Caption = 'Trackingmore Air Tracking';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "TMAC Trackingmore Air Tracking";
    Editable = false;

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
                field("Event"; Rec."Last Event")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the last event.';
                }
                field("Tracking Detail"; Rec."Tracking Detail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the tracking detail.';
                }

                field("Airline"; Rec."Airline")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Airline.';
                }
                field("Airline Url"; Rec."Airline Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Airline Url.';
                }
                field("Airline Track Url"; Rec."Airline Track Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Airline Track Ur.';
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
                field("Origin"; Rec."Origin")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Origin.';
                }
                field("Destination"; Rec."Destination")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Destination.';
                }
                field("Flight Info"; Rec."Flight Info")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Flight Info.';
                }

                field("Origin Departure Time"; Rec."Origin Departure Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Origin Departure Time.';
                }

                field("Destination Arrival Time"; Rec."Destination Arrival Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Destination Arrival Time.';
                }
                field("Time Zone"; rec."Time Zone")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Time Zone.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(UpdateTracking)
            {
                Caption = 'Update Tracking';
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                Image = UpdateDescription;
                PromotedCategory = Process;
                ToolTip = 'Update Tracking Number information from tracking system on Trackingmore.com';
                trigger OnAction()
                var
                    TrackingmoreAirAPI: Codeunit "TMAC Trackingmore Air API";
                begin
                    TrackingmoreAirAPI.Track(Rec."Tracking Number", '');
                end;
            }
            action(DeleteTracking)
            {
                Caption = 'Delete Tracking';
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                Image = UpdateDescription;
                PromotedCategory = Process;
                ToolTip = 'Delete Tracking Number information.';
                trigger OnAction()
                begin
                    if Confirm(StrSubstno(DeleteQst, Rec."Tracking Number")) then
                        Rec.Delete(true);
                end;
            }
        }
    }
    var
        DeleteQst: Label 'Delete %1 track number.', Comment = '%1 is a tracking number';
}