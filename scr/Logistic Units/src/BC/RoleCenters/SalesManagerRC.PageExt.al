pageextension 71628594 "TMAC Sales Manager RC" extends "Sales Manager Role Center"
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