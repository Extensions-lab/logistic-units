page 71628670 "TMAC Estimated Units"
{
    ApplicationArea = All;
    Caption = 'Estimated Logistics Units Forecast';
    PageType = List;
    SourceTable = "TMAC Estimated Unit";
    UsageCategory = None;
    Editable = false;

    AboutTitle = 'Estimated Logistics Units Forecast';
    AboutText = 'This window displays a list of logistics units (e.g., pallets, boxes, containers). It provides information about the types and quantities of logistics units that are expected to be created based on **Logistics Unit Build Rules**, helping the user assess upcoming operations and prepare for their execution.';
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Type Code"; Rec."Type Code")
                {
                    Width = 3;
                }
                field("Type Description"; Rec."Type Description")
                {
                    Width = 5;
                }
                field(Lines; Rec.Lines)
                {
                }
                field("Volume (Base)"; Rec."Volume (Base)")
                {
                }
                field("Weight (Base)"; Rec."Weight (Base)")
                {
                }
                field("Completion Status"; Rec."Completion Status")
                {
                }
                field("Type Volume Limit"; Rec."Type Volume Limit")
                {
                }
                field("Type Weight Limit"; Rec."Type Weight Limit")
                {
                }
            }
        }
    }
}
