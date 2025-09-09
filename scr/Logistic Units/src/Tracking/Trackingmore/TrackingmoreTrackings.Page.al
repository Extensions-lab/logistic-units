page 71628661 "TMAC Trackingmore Trackings"
{
    Caption = 'Trackingmore Trackings';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "TMAC Trackingmore Tracking";
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
                    ToolTip = 'Specify the tracking number';
                }
                field("Status Description"; Rec."Status Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify the status.';
                }
                field("Substatus Description"; Rec."Substatus Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify the sub status.';
                }
                field("CheckPoints"; Rec.CheckPoints)
                {
                    Caption = 'Detail History';
                    ToolTip = 'Specifies the checkpoints history';
                    ApplicationArea = All;
                }
                field("Last Event"; Rec."Last Event")
                {
                    Caption = 'Last Event';
                    ToolTip = 'Specifies the last event of the tracking';
                    ApplicationArea = All;
                }
                field("Original Country"; Rec."Original Country")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify the Created At.';
                }
                field("Destination Country"; Rec."Destination Country")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify the Created At.';
                }
                field(Weight; Rec.Weight)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify the Weight.';
                }
                field("Created At"; Rec."Created At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify the Created At.';
                }
                field("Carrier Code"; Rec."Carrier Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify the carrier code.';
                }

                field("Customer Email"; Rec."Customer Email")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify the Customer Email.';
                    Visible = false;
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify the Customer Name.';
                    Visible = false;
                }

                field("Order ID"; Rec."Order ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify the Order ID.';
                    Visible = false;
                }

                field("Comment"; Rec."Comment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify the Comment.';
                    Visible = false;
                }
                field("Title"; Rec."Title")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify the Title.';
                    Visible = false;
                }

                field("Logistics Channel"; Rec."Logistics Channel")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify the Logistics Channel.';
                    Visible = false;
                }
                field("Destination"; Rec."Destination")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify the Destination.';
                    Visible = false;
                }
                field("Updated At"; Rec."Updated At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify the Updated At.';
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
                    TrackingmoreAPI: Codeunit "TMAC Trackingmore API";
                begin
                    TrackingmoreAPI.Track(Rec."Tracking Number", Rec."Carrier Code");
                end;
            }

            action(CancelTracking)
            {
                Caption = 'Cancel Tracking';
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                Image = Cancel;
                PromotedCategory = Process;
                ToolTip = 'Delete Tracking Number from tracking system on Trackingmore.com';
                trigger OnAction()
                var
                    TrackingmoreAPI: Codeunit "TMAC Trackingmore API";
                begin
                    TrackingmoreAPI.DeleteTracking(Rec."Tracking Number", Rec."Carrier Code");
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