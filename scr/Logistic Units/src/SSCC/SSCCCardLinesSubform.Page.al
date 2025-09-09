page 71628581 "TMAC SSCC Card Lines Subform"
{
    Caption = 'Identifiers';
    PageType = ListPart;
    LinksAllowed = false;
    SourceTable = "TMAC SSCC Line";
    AutoSplitKey = true;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Identifier"; Rec."Identifier")
                {
                    ApplicationArea = All;
                    Width = 4;
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                }
                field("Value"; Rec."Value")
                {
                    ApplicationArea = All;
                    Width = 10;
                }
                field("Bar Code"; Rec."Barcode")
                {
                    ApplicationArea = All;
                }
                field("Barcode Type"; Rec."Barcode Type")
                {
                    ApplicationArea = All;
                }
                field("Label Text"; Rec."Label Text")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}