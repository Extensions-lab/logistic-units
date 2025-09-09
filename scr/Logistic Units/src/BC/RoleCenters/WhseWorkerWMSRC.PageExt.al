pageextension 71628595 "TMAC Whse. Worker WMS RC" extends "Whse. Worker WMS Role Center"
{
    actions
    {
        addafter("Bin Contents")
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
        
        addafter("Posted Whse. Receipts")
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
