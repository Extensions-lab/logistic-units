
page 71628586 "TMAC Unit Card Lines Subf."
{
    AutoSplitKey = true;
    Caption = 'Lines';
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "TMAC Unit Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;

                field(Type; Rec.Type)
                {
                    ApplicationArea = Suite;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Suite;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Planning;
                    Editable = IsLineEditable;
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Suite;
                    Editable = IsLineEditable;
                    Width = 15;
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = Suite;
                    Editable = IsLineEditable;
                    Visible = false;
                }

                field(GTIN; Rec.GTIN)
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    Width = 10;
                    Visible = false;
                }

                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Suite;
                    BlankZero = true;
                    Width = 8;
                    Editable = IsLineEditable;
                }

                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Editable = IsLineEditable;
                }

                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                    ApplicationArea = All;
                    Editable = IsLineEditable;
                    Visible = false;
                }

                field("Expected Quantity"; Rec."Expected Quantity")
                {
                    ApplicationArea = All;
                    Width = 4;
                }

                field("Inventory Quantity"; Rec."Inventory Quantity")
                {
                    ApplicationArea = All;
                    Width = 4;
                }

                field("Gross Weight (base)"; Rec."Gross Weight (base)")
                {
                    ApplicationArea = All;
                    CaptionClass = '71628575,2,' + Rec.FieldCaption("Gross Weight (base)");
                    Editable = IsLineEditable;
                }

                field("Net Weight (base)"; Rec."Net Weight (base)")
                {
                    ApplicationArea = All;
                    CaptionClass = '71628575,2,' + Rec.FieldCaption("Net Weight (base)");
                    Editable = IsLineEditable;
                    Visible = false;
                }
                field("Volume (base)"; Rec."Volume (base)")
                {
                    ApplicationArea = All;
                    CaptionClass = '71628575,1,' + Rec.FieldCaption("Volume (base)");
                    Editable = IsLineEditable;
                }
                field("Linked Links Exist"; Rec."Linked Links Exist")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                }

                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                }
                field("Freight Class"; Rec."Freight Class")
                {
                    ApplicationArea = All;
                    Editable = IsLineEditable;
                    Visible = false;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    Visible = false;
                }
                field("Linked Quantity"; Rec."Linked Quantity")
                {
                    ApplicationArea = All;
                    Visible = false;
                }

                field("Linked Quantity (Base)"; Rec."Linked Quantity (Base)")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {

            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action(LogisticUnitApplication)
                {
                    Caption = 'Application';
                    Image = ApplyTemplate;
                    Tooltip = 'Application of one line of a logistic unit to another, reflecting the logical relationship of the source of the goods.';
                    ApplicationArea = All;
                    trigger OnAction()
                    begin
                        UnitLinkManagement.UnitLineApplication(Rec);
                    end;
                }
            }

            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
            }
        }
    }


    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if xRec."Unit No." <> '' then
            Rec.Type := xRec.Type;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        IsLineEditable := true;
        if (Rec."Unit No." <> '') and (Rec."Line No." <> 0) then begin
            Rec.CalcFields("Linked Links Exist");
            IsLineEditable := not Rec."Linked Links Exist";

            if Rec."Type" = "TMAC Unit Line Type"::Unit then
                IsLineEditable := false;
        end;
    end;


    internal procedure UpdateForm(SetSaveRecord: Boolean)
    begin
        CurrPage.Update(SetSaveRecord);
    end;

    var
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
        IsLineEditable: Boolean;
}
