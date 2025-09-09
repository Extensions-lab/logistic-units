page 71628579 "TMAC Unit Actions"
{
    ApplicationArea = All;
    Caption = 'Logistic Unit Registration Actions';
    PageType = List;
    SourceTable = "TMAC Unit Action";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Create; Rec.Create)
                {
                    ApplicationArea = All;
                }
                field(Archive; Rec.Archive)
                {
                    ApplicationArea = All;
                }
                field(Purchase; Rec.Purchase)
                {
                    ApplicationArea = All;
                }
                field("Warehouse Receipt"; Rec."Warehouse Receipt")
                {
                    ApplicationArea = All;
                }
                field("Warehouse Put-away"; Rec."Warehouse Put-away")
                {
                    ApplicationArea = All;
                }
                field(Sale; Rec.Sale)
                {
                    ApplicationArea = All;
                }
                field("Warehouse Shipment"; Rec."Warehouse Shipment")
                {
                    ApplicationArea = All;
                }
                field("Warehouse Pickup"; Rec."Warehouse Pickup")
                {
                    ApplicationArea = All;
                }
                field("Relocation"; Rec."Relocation")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
