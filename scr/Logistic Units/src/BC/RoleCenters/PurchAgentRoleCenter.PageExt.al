pageextension 71628592 "TMAC Purch. Agent Role Center" extends "Purchasing Agent Role Center"
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

        addafter("Posted Assembly Orders")
        {
            action("TMAC Posted Unit")
            {
                AccessByPermission = TableData "TMAC Posted Unit" = R;
                ApplicationArea = Basic, Suite;
                Caption = 'Posted Logistic Units';
                Image = Vendor;
                RunObject = Page "TMAC Posted Unit List";
                ToolTip = 'Specifies the posted logistic units.';
            }
        }
    }
}