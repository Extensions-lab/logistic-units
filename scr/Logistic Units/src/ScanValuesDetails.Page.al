page 71628627 "TMAC Scan Values Details"
{
    ApplicationArea = All;
    Caption = 'Scan Values Details';
    PageType = ListPart;
    SourceTable = "TMAC Scanned Value";
    Editable = false;
    SourceTableView = sorting("User ID", "Entry No.") Order(descending);
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Barcode; Rec.Barcode)
                {
                }
                field(Format; rec.Format)
                {
                }
                field(Result; Rec.Result)
                {
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.FilterGroup(2);
        Rec.Setrange("User ID", UserId());
        Rec.FilterGroup(0);
    end;
}