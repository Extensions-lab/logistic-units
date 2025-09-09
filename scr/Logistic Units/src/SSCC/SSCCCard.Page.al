page 71628580 "TMAC SSCC Card"
{
    Caption = 'SSCC Card';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Documents;
    SourceTable = "TMAC SSCC";

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                Caption = 'General';

                field(Code; Rec."No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Global Company Prefix"; Rec."Global Company Prefix")
                {
                    ApplicationArea = All;
                }
                field("Serial Reference"; Rec."Serial Reference")
                {
                    ApplicationArea = All;
                }
            }

            part(Lines; "TMAC SSCC Card Lines Subform")
            {
                Caption = 'Identifiers';
                ApplicationArea = Basic, Suite;
                Editable = IsSubformEditable;
                SubPageLink = "SSCC No." = FIELD("No.");
                UpdatePropagation = Both;
            }

            group(LabelInformation)
            {
                Caption = 'Label Information';

                field("From"; Rec."From")
                {
                    ApplicationArea = All;
                }
                field("To"; Rec."To")
                {
                    ApplicationArea = All;
                }
                field("Carrier Name"; Rec."Carrier Name")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Bill of Landing Number"; Rec."Bill of Landing Number")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(PrintSSCC)
            {
                ApplicationArea = All;
                Caption = 'Print';
                Image = Print;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                InFooterBar = true;
                ToolTip = 'Print SSCC label';
                trigger OnAction()
                var
                    SSCC: Record "TMAC SSCC";
                    SSCCManagement: Codeunit "TMAC SSCC Management";
                begin
                    SSCC.Setrange("No.", Rec."No.");
                    SSCC.FindFirst();
                    SSCCManagement.PrintSSCC(SSCC);
                end;
            }
            action(Complete)
            {
                ApplicationArea = All;
                Caption = 'Complete';
                Image = CompleteLine;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                InFooterBar = true;
                ToolTip = 'Record the necessary data in the SSCC field from linked logistic unit. This includes the unique serial shipping container code (SSCC) number, the date of manufacture or packing, the country of origin, the weight, and any other relevant information.';
                trigger OnAction()
                var
                    Unit: Record "TMAC Unit";
                    SSCCManagement: Codeunit "TMAC SSCC Management";
                begin
                    Unit.Setrange("SSCC No.", Rec."No.");
                    if Unit.FindFirst() then
                        SSCCManagement.CompleteInformation(Unit, Rec);
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetEnableFields();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetEnableFields();
    end;

    local procedure SetEnableFields()
    begin
        IsSubformEditable := CurrPage.Editable;
    end;

    var
        IsSubformEditable: Boolean;
}