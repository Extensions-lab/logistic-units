tableextension 71628580 "TMAC Invt. Document Header" extends "Invt. Document Header"
{
    fields
    {
        field(71628575; "TMAC Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
            DataClassification = CustomerContent;
        }
    }
}
