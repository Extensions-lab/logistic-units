page 71628584 "TMAC Unit Entries"
{
    ApplicationArea = All;
    Caption = 'Unit Entries';
    PageType = List;
    SourceTable = "TMAC Unit Entry";
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Date"; Rec."Date")
                {
                }
                field("Date And Time"; Rec."Date and time")
                {
                    Visible = false;
                }

                field("Action Code"; Rec."Action Code")
                {
                }
                field("LU Location Code"; Rec."LU Location Code")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field("Unit No."; Rec."Unit No.")
                {
                    Visible = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                }
                field("Zone Code"; Rec."Zone Code")
                {
                    Visible = false;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                }
                field("Entry ID"; Rec."Entry No.")
                {
                    Visible = false;
                }
            }
        }
    }
}
