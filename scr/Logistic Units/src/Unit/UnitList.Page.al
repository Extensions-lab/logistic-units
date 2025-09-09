
page 71628588 "TMAC Unit List"
{
    Caption = 'Logistic Units';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "TMAC Unit";
    Editable = false;
    CardPageId = "TMAC Unit Card";
   
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

                field("Reusable"; Rec."Reusable")
                {
                    ApplicationArea = All;
                }

                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                }
                field("SSCC"; Rec."SSCC No.")
                {
                    ApplicationArea = All;
                }
                field("Barcode"; Rec."Barcode")
                {
                    ApplicationArea = All;
                    Width = 15;
                }
                field("Type Code"; Rec."Type Code")
                {
                    ApplicationArea = All;
                }
                field("Tracking No."; Rec."Tracking No.")
                {
                    ApplicationArea = All;
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
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Width"; Rec.Width)
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Height"; Rec.Height)
                {
                    Visible = false;
                    ApplicationArea = All;
                }

                field("Volume"; Rec."Volume")
                {
                    Visible = false;
                    ApplicationArea = All;
                }

                field("LU Location Code"; Rec."LU Location Code")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }

                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
                field("Zone Code"; Rec."Zone Code")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    Visible = false;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
                field("Tracking Information"; Rec."Tracking Information")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {
        }
    }
}