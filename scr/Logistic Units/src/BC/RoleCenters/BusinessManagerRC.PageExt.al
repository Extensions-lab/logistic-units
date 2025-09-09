pageextension 71628590 "TMAC Business Manager RC" extends "Business Manager Role Center"
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

        addafter("Item Charges")
        {
            action("TMAC Units 2")
            {
                AccessByPermission = tabledata "TMAC Unit" = I;
                ApplicationArea = Basic, Suite;
                Caption = 'Logistic Units';
                Image = Item;
                RunObject = Page "TMAC Unit List";
                ToolTip = 'List of all logistic units';
            }
        }

        addafter(Action131)
        {
            action("TMAC Units 3")
            {
                AccessByPermission = tabledata "TMAC Unit" = I;
                ApplicationArea = Basic, Suite;
                Caption = 'Logistic Units';
                Image = Item;
                RunObject = Page "TMAC Unit List";
                ToolTip = 'List of all logistic units';
            }
        }

        addafter("Posted Sales Return Receipts")
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