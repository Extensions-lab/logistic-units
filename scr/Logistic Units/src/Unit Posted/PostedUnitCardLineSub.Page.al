page 71628606 "TMAC Posted Unit Card Line Sub"
{
    Caption = 'Content';
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "TMAC Posted Unit Line";
    Editable = false;

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
                    Editable = false;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Planning;
                    Visible = false;
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    Width = 15;
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    Visible = false;
                }

                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Suite;
                    BlankZero = true;
                    Width = 8;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                    Editable = false;
                    ApplicationArea = All;
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
                    Editable = false;
                    ApplicationArea = All;
                    CaptionClass = '71628575,2,' + Rec.FieldCaption("Gross Weight (base)");
                }

                field("Net Weight (base)"; Rec."Net Weight (base)")
                {
                    ApplicationArea = All;
                    CaptionClass = '71628575,2,' + Rec.FieldCaption("Net Weight (base)");
                    Visible = false;
                }

                field("Volume (base)"; Rec."Volume (base)")
                {
                    ApplicationArea = All;
                    CaptionClass = '71628575,1,' + Rec.FieldCaption("Volume (base)");
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
                }

                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    Visible = false;
                }
            }
        }
    }
}
