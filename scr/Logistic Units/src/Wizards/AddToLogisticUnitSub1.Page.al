page 71628615 "TMAC Add To Logistic Unit Sub1"
{

    Caption = 'Add Logistic Unit Sub';
    PageType = ListPart;
    SourceTable = "TMAC Unit";
    SourceTableTemporary = true;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                ShowAsTree = true;
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Type Code"; Rec."Type Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    internal procedure DeleteLines()
    begin
        Rec.DeleteAll();
    end;

    internal procedure AddLine(Unit: Record "TMAC Unit")
    begin
        Rec.TransferFields(Unit);
        Rec.Insert();
    end;
}
