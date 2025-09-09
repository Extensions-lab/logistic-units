page 71628655 "TMAC Aftership Trackings Card"
{

    Caption = 'Aftership Tracking Card';
    PageType = Card;
    SourceTable = "TMAC Aftership Tracking";
    Editable = false;
    DataCaptionExpression = GetCaption();
    UsageCategory = History;
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Tracking Number"; Rec."Tracking Number")
                {
                    ApplicationArea = All;
                }
                field(Tag; Rec.Tag)
                {
                    ApplicationArea = All;
                }
                field("SubTag Message"; Rec."SubTag Message")
                {
                    ApplicationArea = All;
                }
                field("Last Checkpoint Action"; Rec."Last Checkpoint Action")
                {
                    ApplicationArea = All;
                }
                field(CheckPoints; Rec.CheckPoints)
                {
                    Caption = 'Detailed History';
                    ApplicationArea = All;
                }
                field("Courier Tracking Link"; Rec."Courier Tracking Link")
                {
                    ApplicationArea = All;
                }
            }
            group(Package)
            {
                field("Shipment Package Count"; Rec."Shipment Package Count")
                {
                    ApplicationArea = All;
                }
                field("Shipment Weight"; Rec."Shipment Weight")
                {
                    ApplicationArea = All;
                }
                field("Shipment Weigh Unit"; Rec."Shipment Weigh Unit")
                {
                    ApplicationArea = All;
                }
            }
            group(OriginAndDestination)
            {
                Caption = 'Origin and Destination';

                field("Origin Country"; Rec."Origin Country")
                {
                    ApplicationArea = All;
                }
                field("Shipment Pickup Date"; Rec."Shipment Pickup Date")
                {
                    ApplicationArea = All;
                }
                field("Destination Country"; Rec."Destination Country")
                {
                    ApplicationArea = All;
                }
                field("Shipment Delivery Date"; Rec."Shipment Delivery Date")
                {
                    ApplicationArea = All;
                }
                field("Shipment Type"; Rec."Shipment Type")
                {
                    ApplicationArea = All;
                }

                field("Expected Delivery"; Rec."Expected Delivery")
                {
                    ApplicationArea = All;
                }
                field("Delivery Type"; Rec."Delivery Type")
                {
                    ApplicationArea = All;
                }
                field("Delivery Time (days)"; Rec."Delivery Time (days)")
                {
                    ApplicationArea = All;
                }
            }
            group("Order")
            {
                field("Order ID"; Rec."Order ID")
                {
                    Importance = Promoted;
                    ApplicationArea = All;
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;
                }
            }
            group(Additional)
            {
                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                }
                field(Slug; Rec.Slug)
                {
                    ApplicationArea = All;
                }
                field("Updated DateTime"; Rec."Updated DateTime")
                {
                    Importance = Promoted;
                    ApplicationArea = All;
                }
                field("Tracked Count"; Rec."Tracked Count")
                {
                    ApplicationArea = All;
                }
                field(Note; Rec.Note)
                {
                    ApplicationArea = All;
                }
                field(Language; Rec.Language)
                {
                    ApplicationArea = All;
                }
                field("Create DateTime"; Rec."Create DateTime")
                {
                    ApplicationArea = All;
                }
                field("Courier Destination Country"; Rec."Courier Destination Country")
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
                ToolTip = 'Update Tracking Number from tracking system on Aftership.com';
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

    local procedure GetCaption(): Text
    begin
        exit(CaptionMsg + '  ' + Rec."Tracking Number" + '   (' + rec.Slug + ')');
    end;

    var
        AfterShipAPI: Codeunit "TMAC AfterShip API";
        CaptionMsg: Label 'Tracking Number';

}
