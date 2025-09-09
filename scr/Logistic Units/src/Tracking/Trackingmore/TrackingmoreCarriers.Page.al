page 71628658 "TMAC Trackingmore Carriers"
{

    ApplicationArea = All;
    Caption = 'Trackingmore.com Couriers';
    PageType = List;
    SourceTable = "TMAC Trackingmore Carrier";
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {

                field(Code; Rec.Code)
                {
                    ToolTip = 'Specifies the unique code of courier of the tracking number.';
                    ApplicationArea = All;
                }
                field(Name; Rec.name)
                {
                    ToolTip = 'Specifies the name of courier.';
                    ApplicationArea = All;
                }
                field(Phone; Rec.Phone)
                {
                    ToolTip = 'Specifies the phone number in the courier website';
                    ApplicationArea = All;
                }
                field(Homepage; Rec.Homepage)
                {
                    ToolTip = 'Specifies the homepage of courier';
                    ApplicationArea = All;
                }
                field(TrackUrl; Rec."Track URL")
                {
                    ToolTip = 'Specifies the homepage of courier';
                    ApplicationArea = All;
                }
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies the service type of the courier, such as express, postal.';
                    ApplicationArea = All;
                }
                field(PictureURL; Rec."Picture URL")
                {
                    ToolTip = 'Specifies the The image url of the courier logo.';
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(AllCouriers)
            {
                Caption = 'Reload All Couriers';
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                Image = ExecuteBatch;
                PromotedCategory = Process;
                ToolTip = 'Reload Couriers from Aftership.com';
                trigger OnAction()
                var
                    TrackingmoreAPI: Codeunit "TMAC Trackingmore API";
                begin
                    TrackingmoreAPI.GetAllCouriers();
                end;
            }
        }
    }

}
