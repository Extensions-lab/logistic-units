pageextension 71628611 "TMAC Shipping Agents" extends "Shipping Agents"
{
    layout
    {
        addbefore("Internet Address")
        {
            field("TMAC Tracking Provider"; Rec."TMAC Tracking Provider")
            {
                ApplicationArea = all;
                ToolTip = 'Tracking API Service Provider.';
            }

            field("TMAC Tracking Courier Code"; Rec."TMAC Tracking Courier Code")
            {
                ApplicationArea = all;
                ToolTip = 'Tracking API Service Provider - Carrier';
            }
        }
    }
}
