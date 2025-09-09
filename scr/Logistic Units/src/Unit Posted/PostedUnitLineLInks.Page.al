page 71628608 "TMAC Posted Unit Line Links"
{
    ApplicationArea = All;
    Caption = 'Posted Unit Line Links';
    PageType = List;
    SourceTable = "TMAC Posted Unit Line Link";
    UsageCategory = History;
    Editable = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Unit No."; Rec."Unit No.")
                {
                    ApplicationArea = All;
                }
                field(PostedVersion; rec."Posted Version")
                {
                    ApplicationArea = All;
                }

                field("Unit Line No."; Rec."Unit Line No.")
                {
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                    ApplicationArea = All;
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = All;
                }
                field("Source Subtype"; Rec."Source Subtype")
                {
                    ApplicationArea = All;
                }
                field("Source ID"; Rec."Source ID")
                {
                    ApplicationArea = All;
                }
                field("Source Ref. No."; Rec."Source Ref. No.")
                {
                    ApplicationArea = All;
                }
                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = ItemTracking;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = ItemTracking;
                }
                field("Package No."; Rec."Package No.")
                {
                    ApplicationArea = ItemTracking;
                }
                field("Warranty Date"; Rec."Warranty Date")
                {
                    ApplicationArea = ItemTracking;
                    Visible = false;
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ApplicationArea = ItemTracking;
                    Visible = false;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(OpenLogisticUnit)
            {
                Caption = 'Show Logistic Unit';
                ApplicationArea = all;
                Image = Card;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Shows the card of the linked logistic unit.';
                trigger OnAction()
                var
                    Unit: Record "TMAC Unit";
                begin
                    if Unit.Get(Rec."Unit No.") then
                        Page.RunModal(PAGE::"TMAC Unit Card", Unit);
                end;
            }
            action(OpenDocument)
            {
                Caption = 'Show Document';
                ApplicationArea = all;
                Image = Card;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Shows the card of the linked document.';
                trigger OnAction()
                begin
                    UnitLinkManagement.ShowDocument(Rec);
                end;
            }
        }
    }

    var
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
}