
page 71628607 "TMAC Posted Unit List"
{
    Caption = 'Posted Logistic Units';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = History;
    SourceTable = "TMAC Posted Unit";
    Editable = false;
    CardPageId = "TMAC Posted Unit Card";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    AboutTitle = 'Logistic Unit';
    AboutText = ' is box, pallet or container; is a combination of: a logistics carrier, such as a pallet, which is uniquely identified worldwide by means of a Global Returnable Asset Identifier **(GRAI)**. and products uniquely identified worldwide using Global Trade Item Numbers **(GTIN’s)**.';

    ContextSensitiveHelpPage = 'blob/main/logisticunit.md';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Posted version"; Rec."Posted version")
                {
                    ApplicationArea = All;
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                }
                field("Type Code"; Rec."Type Code")
                {
                    ApplicationArea = All;
                }
                field("SSCC No."; Rec."SSCC No.")
                {
                    ApplicationArea = All;
                }
                field("Barcode No."; Rec."Barcode")
                {
                    ApplicationArea = All;
                }

                field("Gross Weight (Base)"; Rec."Content Weight (Base)")
                {
                    CaptionClass = '71628575,2,' + Rec.FieldCaption("Content Weight (Base)");
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Content Volume (Base)"; Rec."Content Volume (Base)")
                {
                    CaptionClass = '71628575,1,' + Rec.FieldCaption("Content Volume (Base)");
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Weight (Base)"; Rec."Weight (Base)")
                {
                    CaptionClass = '71628575,2,' + Rec.FieldCaption("Weight (Base)");
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Volume (Base)"; Rec."Volume (Base)")
                {
                    CaptionClass = '71628575,1,' + Rec.FieldCaption("Volume (Base)");
                    ApplicationArea = All;
                    Importance = Promoted;
                }

                field("Length"; Rec.Length)
                {
                    ApplicationArea = All;
                }
                field("Width"; Rec.Width)
                {
                    ApplicationArea = All;
                }
                field("Height"; Rec.Height)
                {
                    ApplicationArea = All;
                }

                field("Volume"; Rec."Volume")
                {
                    ApplicationArea = All;
                }
                field("Tracking Information"; Rec."Tracking Information")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}