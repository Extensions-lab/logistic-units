tableextension 71628579 "TMAC Purchase Line" extends "Purchase Line"
{
    fields
    {
        modify(Quantity)
        {
            trigger OnAfterValidate()
            var
                UnitLineLink: Record "TMAC Unit Line Link";
            begin
                if not UnitLineLink.ReadPermission then
                    exit;

                UnitLineLink.Reset();
                UnitLineLink.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.", "Package No.", "Lot No.", "Serial No.", "Positive", "Qty. to Post");
                UnitLineLink.SetRange("Source Type", Database::"Purchase Line");
                UnitLineLink.SetRange("Source Subtype", Rec."Document Type");
                UnitLineLink.SetRange("Source ID", Rec."Document No.");
                UnitLineLink.SetRange("Source Ref. No.", Rec."Line No.");
                UnitLineLink.CalcSums(Quantity);
                if UnitLineLink.Quantity > Rec.Quantity then
                    UnitLineLink.DeleteAll();
            end;
        }
    }
}