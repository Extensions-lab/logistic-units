page 71628653 "TMAC Aftership Trackings"
{
    ApplicationArea = All;
    Caption = 'Tracking Numbers';
    PageType = List;
    SourceTable = "TMAC Aftership Tracking";
    UsageCategory = History;
    Editable = false;
    CardPageId = "TMAC Aftership Trackings Card";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Tracking Number"; Rec."Tracking Number")
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
                    Caption = 'Sub status';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("SubTag Message"; Rec."SubTag Message")
                {
                    Caption = 'Status Message';
                    ApplicationArea = All;
                }
                field("Last Checkpoint Action"; Rec."Last Checkpoint Action")
                {
                    ApplicationArea = All;
                }
                field("CheckPoints"; Rec.CheckPoints)
                {
                    Caption = 'Detail History';
                    ApplicationArea = All;
                }
                field("Shipment Package Count"; Rec."Shipment Package Count")
                {
                    ApplicationArea = All;
                }
                field("Shipment Delivery Date"; Rec."Shipment Delivery Date")
                {
                    ApplicationArea = All;
                }
                field("Shipment Pickup Date"; Rec."Shipment Pickup Date")
                {
                    ApplicationArea = All;
                }
                field("Origin Country"; Rec."Origin Country")
                {
                    ApplicationArea = All;
                }
                field("Destination Country"; Rec."Destination Country")
                {
                    ApplicationArea = All;
                }
                field(Slug; Rec.Slug)
                {
                    Caption = 'Carrier';
                    ApplicationArea = All;
                }
                field(Note; Rec.Note)
                {
                    ApplicationArea = All;
                }
                field("Order ID"; Rec."Order ID")
                {
                    ApplicationArea = All;
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;
                }
                field("Courier Tracking Link"; Rec."Courier Tracking Link")
                {
                    ApplicationArea = All;
                }
                field("Expected Delivery"; Rec."Expected Delivery")
                {
                    ApplicationArea = All;
                }
                field("Delivery Time (days)"; Rec."Delivery Time (days)")
                {
                    ApplicationArea = All;
                }
                field("Delivery Type"; Rec."Delivery Type")
                {
                    ApplicationArea = All;
                }
                field("Shipment Type"; Rec."Shipment Type")
                {
                    ApplicationArea = All;
                }
                field("Shipment Weigh Unit"; Rec."Shipment Weigh Unit")
                {
                    ApplicationArea = All;
                }
                field("Shipment Weight"; Rec."Shipment Weight")
                {
                    ApplicationArea = All;
                }
                field("Updated DateTime"; Rec."Updated DateTime")
                {
                    ApplicationArea = All;
                }
                field("Create DateTime"; Rec."Create DateTime")
                {
                    ApplicationArea = All;
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
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
                ToolTip = 'Update Tracking Number information from tracking system on Aftership.com';
                trigger OnAction()
                begin
                    AfterShipAPI.Track(Rec."Tracking Number", Rec.Slug);
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
                ToolTip = 'Delete Tracking Number from tracking system on Aftership.com';
                trigger OnAction()
                begin
                    AfterShipAPI.DeleteTracking(Rec."Tracking Number", Rec.Slug);
                end;
            }
        }
    }

    var
        AfterShipAPI: Codeunit "TMAC AfterShip API";
}
