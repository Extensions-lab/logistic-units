tableextension 71628583 "TMAC Customer" extends Customer
{
    fields
    {
        field(71628575; "TMAC LU Location Code"; Code[20])
        {
            Caption = 'LU Location Code';
            DataClassification = CustomerContent;
            TableRelation = "TMAC Unit Location";
        }
    }
}
