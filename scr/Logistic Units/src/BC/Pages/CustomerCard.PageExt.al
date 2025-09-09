pageextension 71628615 "TMAC Customer Card" extends "Customer Card"
{
    layout
    {
        addafter("Shipping")
        {
            group("TMAC Logistic Units")
            {
                Caption = 'Logistic Units Control';

                field("TMAC LU Location Code"; Rec."TMAC LU Location Code")
                {
                    AccessByPermission = tabledata "TMAC Unit" = I;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Defines the LU Location Code that will be applied to all logistics units included in shipments for this client.';
                }
            }
        }
    }
}
