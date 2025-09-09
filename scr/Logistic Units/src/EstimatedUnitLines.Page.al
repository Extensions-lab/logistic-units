page 71628671 "TMAC Estimated Unit Lines"
{
    ApplicationArea = All;
    Caption = 'Estimated Logistics Units Lines';
    PageType = List;
    SourceTable = "TMAC Estimated Unit Line";
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Type"; Rec."Type")
                {
                }
                field("No."; Rec."No.")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field(Quantity; Rec.Quantity)
                {
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    Visible = false;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                }
                field("Volume (base)"; Rec."Volume (base)")
                {
                }
                field("Weight (base)"; Rec."Weight (base)")
                {
                }
            }
        }
    }
}
