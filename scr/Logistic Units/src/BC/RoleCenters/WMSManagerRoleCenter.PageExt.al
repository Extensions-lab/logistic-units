pageextension 71628596 "TMAC WMS Manager Role Center" extends "Warehouse Manager Role Center"
{
    actions
    {
        addafter("Released Prod. Orders1")
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
        
        addafter("Warehouse Entries")
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