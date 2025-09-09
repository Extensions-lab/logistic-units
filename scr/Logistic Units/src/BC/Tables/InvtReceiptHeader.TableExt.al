tableextension 71628581 "TMAC Invt. Receipt Header" extends "Invt. Receipt Header"
{
    fields
    {
        field(71628575; "TMAC Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
}
