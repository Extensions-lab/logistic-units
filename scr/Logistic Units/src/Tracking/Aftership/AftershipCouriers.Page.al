page 71628654 "TMAC Aftership Couriers"
{

    ApplicationArea = All;
    Caption = 'Aftership.com Couriers';
    PageType = List;
    SourceTable = "TMAC Aftership Courier";
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Activated; Rec.Activated)
                {
                    ApplicationArea = All;
                }

                field(Slug; Rec.slug)
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.name)
                {
                    ApplicationArea = All;
                }
                field("Other Name"; Rec."Other Name")
                {
                    ApplicationArea = All;
                }
                field("Web Url"; Rec."Web Url")
                {
                    ApplicationArea = All;
                }
                field(Phone; Rec.Phone)
                {
                    ApplicationArea = All;
                }
                field("Default Language"; Rec."Default Language")
                {
                    ApplicationArea = All;
                }
                field("Required Fields"; Rec."Required Fields")
                {
                    ApplicationArea = All;
                }
                field("Optional Fields"; Rec."Optional Fields")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Support Languages"; Rec."Support Languages")
                {
                    ApplicationArea = All;
                }
                field("Service From Countries"; Rec."Service From Countries")
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
                    AfterShipAPI: Codeunit "TMAC AfterShip API";
                begin
                    AfterShipAPI.GetAllCouriers();
                    Rec.SetRange(Activated);
                end;
            }
            action(ActiveCouriers)
            {
                Caption = 'Show Active Couriers';
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                Image = ExecuteBatch;
                PromotedCategory = Process;
                ToolTip = 'Get list of the active couriers set up on Aftership.com';
                trigger OnAction()
                var
                    AfterShipAPI: Codeunit "TMAC AfterShip API";
                begin
                    AfterShipAPI.GetActiveCouriers();
                    Rec.SetRange(Activated, true);
                end;
            }
            action(CreateShippingAgent)
            {
                Caption = 'Create Shipping Agent';
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                Image = ExecuteBatch;
                PromotedCategory = Process;
                ToolTip = 'Create new Shipping Agent by the Aftership courier';
                trigger OnAction()
                var
                    AfterShipAPI: Codeunit "TMAC AfterShip API";
                begin
                    AfterShipAPI.CreateShippingAgent(Rec);
                end;
            }
        }
    }

}
