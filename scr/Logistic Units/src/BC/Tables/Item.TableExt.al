tableextension 71628584 "TMAC Item" extends Item
{
    fields
    {
        field(71628575; "TMAC LU Build Rules"; Integer)
        {
            Caption = 'Logistic Units Build Rules';
            FieldClass = FlowField;
            CalcFormula = count("TMAC Unit Build Rule" where("Type" = const(Item),
                                                             "No." = field("No."),
                                                             "Unit of Measure Code" = field("Base Unit of Measure")));
            Editable = false;
        }
    }
}