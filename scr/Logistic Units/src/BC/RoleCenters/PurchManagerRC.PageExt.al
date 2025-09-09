pageextension 71628593 "TMAC Purch. Manager RC" extends "Purchasing Manager Role Center"
{
    actions
    {
        addafter(Items)
        {
            action("TMAC Units")
            {
                AccessByPermission = tabledata "TMAC Unit" = I;
                ApplicationArea = Basic, Suite;
                Caption = 'Logistic Units';
                Image = Item;
                RunObject = Page "TMAC Unit List";
                ToolTip = 'List of all logistic units.';
            }
        }
    }
}