pageextension 71628621 "TMAC Item" extends "Item Card"
{
    layout
    {
        addbefore(Warehouse)
        {
            group("TMAC Logistic Units")
            {
                Caption = 'Logistic Units';
                field("TMAC LU Build Rules"; Rec."TMAC LU Build Rules")
                {
                    Tooltip = 'Defines a set of rules for the automatic generation of logistic units';
                    ApplicationArea = All;
                }
            }
        }
    }
}
