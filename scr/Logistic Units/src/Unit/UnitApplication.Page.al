page 71628598 "TMAC Unit Application"
{
    ApplicationArea = All;
    Caption = 'Unit Application';
    PageType = List;
    SourceTable = "TMAC Source Document Link";
    SourceTableView = sorting("Document Source Type", "Document Source SubType", "Document Source ID");
    InsertAllowed = false;
    DeleteAllowed = false;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                ShowAsTree = true;
                field("Document Source ID"; Rec."Document Source ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Document Source Information"; Rec."Document Source Information")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Width = 15;
                }

                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = ItemTracking;
                    Editable = false;
                    Visible = false;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = ItemTracking;
                    Editable = false;
                }
                field("Package No."; Rec."Package No.")
                {
                    ApplicationArea = ItemTracking;
                    Editable = false;
                }

                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }

                field("Distributed Quantity"; Rec."Distributed Quantity")
                {
                    ApplicationArea = All;
                    AutoFormatExpression = '<Integer Thousand><Point or Comma><Decimals>';
                    AutoFormatType = 10;
                }

                field("Distributed Weight (base)"; Rec."Distributed Weight (base)")
                {
                    ApplicationArea = All;
                    Visible = false;
                }

                field("Selected Quantity"; Rec."Selected Quantity")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    BlankZero = true;

                    trigger OnValidate()
                    var
                        MaxAvlbQty: Decimal;
                    begin
                        MaxAvlbQty := UnitLinkManagement.GetQtyAvlbForSelectedUnit(Rec);
                        if Rec."Selected Quantity" > MaxAvlbQty then
                            Rec."Selected Quantity" := MaxAvlbQty;
                    end;
                }
            }
        }
    }

    internal procedure DeleteLines()
    begin
        Rec.DeleteAll();
    end;

    internal procedure AddLine(var SourceDocumentLink: Record "TMAC Source Document Link"; SelectedQty: Decimal)
    begin
        // records in the trace may be duplicated, so direct insertion is not used
        if Rec.Get(SourceDocumentLink."Source Type",
            SourceDocumentLink."Source Subtype",
            SourceDocumentLink."Source ID",
            SourceDocumentLink."Source Batch Name",
            SourceDocumentLink."Source Prod. Order Line",
            SourceDocumentLink."Source Ref. No.",
            SourceDocumentLink."Package No.",
            SourceDocumentLink."Lot No.",
            SourceDocumentLink."Serial No.")
        then begin
            Rec.Quantity += SourceDocumentLink.Quantity;
            Rec."Quantity (Base)" += SourceDocumentLink."Quantity (Base)";
            Rec.Validate("Selected Quantity", SelectedQty);
            Rec.Modify(true);
        end else begin
            Rec.init();
            Rec.TransferFields(SourceDocumentLink);
            Rec.Validate("Selected Quantity", SelectedQty);
            Rec.Insert(false);
        end;
    end;

    internal procedure HasDiffrentDocumentSource(): Boolean
    var
        CurrentDocumentNo: Code[20];
    begin
        Rec.Reset();
        Rec.SetFilter("Selected Quantity", '>0');
        if Rec.FindFirst() then begin
            CurrentDocumentNo := Rec."Document Source ID";
            repeat
                if CurrentDocumentNo <> Rec."Document Source ID" then
                    exit(true);
            until Rec.Next() = 0;
        end;
    end;

    internal procedure GetSelectedQty() Quantity: Decimal
    begin
        Rec.reset();
        if Rec.findset(false) then
            repeat
                Quantity += Rec."Selected Quantity";
            until Rec.Next() = 0;
    end;

    internal procedure GetSelectedWeight() Weight: Decimal
    begin
        Rec.reset();
        if Rec.findset(false) then
            repeat
                Weight += Round(Rec."Selected Quantity" * rec."Weight (Base) per UoM", 0.01);
            until Rec.Next() = 0;
    end;

    internal procedure GetSelectedVolume() Volume: Decimal
    begin
        if Rec.findset(false) then
            repeat
                Volume += Round(Rec."Selected Quantity" * rec."Weight (Base) per UoM", 0.01);
            until Rec.Next() = 0;
    end;

    internal procedure GetSelectedLines(var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        View: Text;
    begin
        View := Rec.GetView();
        Rec.Reset();
        Rec.SetFilter("Selected Quantity", '>0');
        if Rec.findset(false) then
            repeat
                SourceDocumentLink := Rec;
                SourceDocumentLink.Insert(false);
            until Rec.Next() = 0;
        Rec.SetView(View);
    end;

    var
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
}
