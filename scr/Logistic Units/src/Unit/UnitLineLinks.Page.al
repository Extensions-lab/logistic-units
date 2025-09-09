page 71628589 "TMAC Unit Line Links"
{
    ApplicationArea = All;
    Caption = 'Unit Line Links';
    PageType = List;
    SourceTable = "TMAC Unit Line Link";
    UsageCategory = Lists;
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
                field("Unit Line No."; Rec."Unit Line No.")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    Visible = IsItemInfoVisible;
                    ApplicationArea = All;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    Visible = IsItemInfoVisible;
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Posted Quantity"; Rec."Posted Quantity")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Source Name"; Rec."Source Name")
                {
                    ApplicationArea = All;
                }
                field("Source ID"; Rec."Source ID")
                {
                    ApplicationArea = All;
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = All;
                }
                field("Source Subtype"; Rec."Source Subtype")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Source Ref. No."; Rec."Source Ref. No.")
                {
                    ApplicationArea = All;
                }
                field("Serial No."; Rec."Serial No.")
                {
                    Visible = false;
                    ApplicationArea = ItemTracking;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = ItemTracking;
                }
                field("Package No."; Rec."Package No.")
                {
                    Visible = false;
                    ApplicationArea = ItemTracking;
                }
                field(Positive; Rec.Positive)
                {
                    Visible = false;
                    ApplicationArea = ItemTracking;
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
                        Page.Run(PAGE::"TMAC Unit Card", Unit);
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

    internal procedure SetItemInfoVisible(Value: Boolean)
    begin
        IsItemInfoVisible := Value;
    end;

    var
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
        IsItemInfoVisible: Boolean;

}
