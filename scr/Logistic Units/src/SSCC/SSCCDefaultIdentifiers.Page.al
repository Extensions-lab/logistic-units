page 71628594 "TMAC SSCC Default Identifiers"
{
    ApplicationArea = All;
    Caption = 'SSCC - Default Identifiers';
    PageType = List;
    SourceTable = "TMAC SSCC Default Identifier";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Identifier; Rec.Identifier)
                {
                }
                field(Description; Rec.Description)
                {
                }
                field("Value"; Rec."Value")
                {
                }
                field("Bar Code Place"; Rec."Barcode Place")
                {
                }
                field("Barcode Type"; Rec."Barcode Type")
                {
                }
                field("Label Text"; Rec."Label Text")
                {
                }
            }
        }
    }
}
