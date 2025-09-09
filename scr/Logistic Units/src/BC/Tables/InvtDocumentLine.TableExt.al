tableextension 71628582 "TMAC Invt. Document Line" extends "Invt. Document Line"
{
    fields
    {
        field(71628575; "TMAC From Logistic Unit"; Code[20])
        {
            Caption = 'From Logistic Unit';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit Line" where("Bin Code" = field("Bin Code"));
        }
    }
}
