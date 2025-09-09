page 71628593 "TMAC Posted Unit Entries"
{

    ApplicationArea = All;
    Caption = 'Posted Unit Entries';
    PageType = List;
    SourceTable = "TMAC Posted Unit Entry";
    UsageCategory = History;
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
