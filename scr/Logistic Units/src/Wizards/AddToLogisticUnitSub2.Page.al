page 71628617 "TMAC Add To Logistic Unit Sub2"
{

    Caption = 'Add Logistic Unit Sub';
    PageType = ListPart;
    SourceTable = "TMAC Source Document Link";
    SourceTableView = sorting("Document Source Type", "Document Source SubType", "Document Source ID");
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                ShowAsTree = true;

                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = LineStyle;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = LineStyle;
                }

                field(DocumentQuantity; Rec."Control Quantity")
                {
                    Caption = 'Document Line Qty.';
                    ApplicationArea = All;
                    Editable = false;
                }

                field(Quantity; Rec.Quantity - Abs(Rec."Distributed Quantity"))
                {
                    Caption = 'Available Qty.';
                    ToolTip = 'Specify the quantity available for assignment to a logistics unit. The value is calculated as the document line quantity - posted quantity - the distributed quantity among other logistic units. Detailing shows the links of distribution with other logistics units.';
                    ApplicationArea = All;
                    Editable = false;
                    BlankZero = true;
                    StyleExpr = LineStyle;
                    trigger OnDrillDown()
                    var
                        UnitLineLink: Record "TMAC Unit Line Link";
                    begin
                        UnitLineLink.Setrange("Source Type", Rec."Source Type");
                        UnitLineLink.Setrange("Source Subtype", Rec."Source Subtype");
                        UnitLineLink.Setrange("Source ID", Rec."Source ID");
                        UnitLineLink.Setrange("Source Batch Name", Rec."Source Batch Name");
                        UnitLineLink.Setrange("Source Prod. Order Line", Rec."Source Prod. Order Line");
                        UnitLineLink.Setrange("Source Ref. No.", Rec."Source Ref. No.");
                        UnitLineLink.Setrange("Package No.", Rec."Package No.");
                        UnitLineLink.Setrange("Lot No.", Rec."Lot No.");
                        UnitLineLink.Setrange("Serial No.", Rec."Serial No.");
                        UnitLineLink.Setrange("Positive", Rec.Positive);
                        Page.RunModal(0, UnitLineLink);
                    end;
                }

                field("Default Selected Quantity"; Rec."Default Selected Quantity")
                {
                    ApplicationArea = All;
                    StyleExpr = LineStyle;
                    Editable = false;
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

                        CurrPage.Update(true);
                    end;
                }
                field("Document Source ID"; Rec."Document Source ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = LineStyle;
                }
                field("Document Source Information"; Rec."Document Source Information")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Width = 15;
                    StyleExpr = LineStyle;
                }

                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = ItemTracking;
                    Editable = false;
                    Visible = false;
                    StyleExpr = LineStyle;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = ItemTracking;
                    Editable = false;
                    StyleExpr = LineStyle;
                }
                field("Package No."; Rec."Package No.")
                {
                    ApplicationArea = ItemTracking;
                    Editable = false;
                    StyleExpr = LineStyle;
                }

                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    StyleExpr = LineStyle;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = LineStyle;
                }
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    StyleExpr = LineStyle;
                }

                field("Distributed Quantity"; Rec."Distributed Quantity")
                {
                    ApplicationArea = All;
                    AutoFormatExpression = '<Integer Thousand><Point or Comma><Decimals>';
                    AutoFormatType = 10;
                    StyleExpr = LineStyle;
                    Visible = false;
                }

                field("Distributed Weight (base)"; Rec."Distributed Weight (base)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    StyleExpr = LineStyle;
                }
            }
            group("Totals")
            {
                ShowCaption = false;
                grid(Totals2)
                {
                    field("TMAC TotalWeight"; TotalWeight)
                    {
                        Caption = 'Total Weight';
                        ApplicationArea = Basic, Suite;
                        Editable = false;
                        ToolTip = 'Specifies the total weight of ther selected lines.';
                    }
                    field("TMAC TotalVolume"; TotalVolume)
                    {
                        Caption = 'Total Volume';
                        ApplicationArea = Basic, Suite;
                        Editable = false;
                        ToolTip = 'Specifies the total volume of the selected lines.';
                    }
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(UpdateLinesUI)
            {
                Caption = 'Set Selected Quantity';
                Image = Line;
                ApplicationArea = All;
                ToolTip = 'Automatic completion of the "Selected Quantity" field for all rows.';
                trigger OnAction()
                begin
                    SetSelectedQty();
                end;
            }

            action(ZeroLinesUI)
            {
                Caption = 'Clear Selected Quantity';
                Image = AllLines;
                ApplicationArea = All;
                ToolTip = 'Set the "Selected Quantity" field to zero for all lines.';
                trigger OnAction()
                begin
                    ZeroLines();
                end;
            }

            action(DeleteLinkUI)
            {
                Caption = 'Delete Links';
                Image = UpdateDescription;
                ApplicationArea = all;
                ToolTip = 'Delete all links to the logistic units.';
                Visible = false;
                Enabled = false;
                trigger OnAction()
                begin
                    UnitLinkManagement.Deletelinks(Rec);
                end;
            }
        }
    }

    trigger OnInit()
    var
        UnitOfMeasure: Record "TMAC Unit of Measure";
    begin
        LogisticUnitSetup.Get();

        WeightRoundPrecision := 0.01;
        if UnitOfMeasure.Get(LogisticUnitSetup."Base Weight Unit of Measure") then
            WeightRoundPrecision := UnitOfMeasure."Value Rounding Precision";

        VolumeRoundPrecision := 0.01;
        if UnitOfMeasure.Get(LogisticUnitSetup."Base Volume Unit of Measure") then
            VolumeRoundPrecision := UnitOfMeasure."Value Rounding Precision";
    end;

    trigger OnAfterGetRecord()
    begin
        LineStyle := '';
        if abs(Rec.Quantity) = abs(Rec."Distributed Quantity") then
            LineStyle := 'Unfavorable';
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CalcTotals();
    end;

    internal procedure DeleteLines()
    begin
        Rec.DeleteAll();
    end;

    internal procedure AddLine(var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        Setup: Record "TMAC Logistic Units Setup";
        SetDefaulSelectedQuantity: Boolean;
        ExcludeLinesWODefQty: Boolean;
    begin
        if Setup.Get() then begin
            SetDefaulSelectedQuantity := Setup."Set Default Selected Quantity";
            ExcludeLinesWODefQty := Setup."Exclude Lines w/o Def. Qty.";
        end;

        // The first setting defines the operating mode for Selected Quantity
        if SetDefaulSelectedQuantity and ExcludeLinesWODefQty then
            if SourceDocumentLink."Default Selected Quantity" = 0 then
                exit;

        // in tracing, records may repeat, so it’s not a direct insert
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

            if SetDefaulSelectedQuantity then
                if SourceDocumentLink."Default Selected Quantity" <> 0 then
                    Rec.Validate("Selected Quantity", Rec."Selected Quantity" + SourceDocumentLink."Default Selected Quantity");

            Rec.Modify(true);
        end else begin
            Rec.Init();
            Rec.TransferFields(SourceDocumentLink);
            if SetDefaulSelectedQuantity then
                if SourceDocumentLink."Default Selected Quantity" <> 0 then
                    Rec.Validate("Selected Quantity", SourceDocumentLink."Default Selected Quantity");

            Rec.Insert(false);
        end;

        Rec.Calcfields("Distributed Quantity");
        if Rec.Quantity - Abs(Rec."Distributed Quantity") = 0 then begin //Quantity may contain the "Qty to Ship"... i.e., the remaining amount. But the distributed quantity is calculated by line, not by the amount.
            Rec.Select := true; //selection based on the principle of full allocation
            Rec.Modify(true);
        end;

        CalcTotals();
    end;

    local procedure CalcTotals()
    var
        PrevRec: Record "TMAC Source Document Link";
    begin
        TotalWeight := 0;
        TotalVolume := 0;

        PrevRec := Rec;
        if Rec.findset() then
            repeat
                TotalWeight += Round(Rec."Selected Quantity" * Rec."Weight (Base) per UoM", WeightRoundPrecision);
                TotalVolume += Round(Rec."Selected Quantity" * Rec."Volume (Base) per UoM", VolumeRoundPrecision);
            until Rec.next() = 0;
        Rec := PrevRec;
        if Rec.Find('=') then;
    end;

    internal procedure SetSelectedQty()
    var
        Setup: Record "TMAC Logistic Units Setup";
        SetDefaulSelectedQuantity: Boolean;
        View: Text;
    begin
        if Setup.Get() then
            SetDefaulSelectedQuantity := Setup."Set Default Selected Quantity";

        View := Rec.GetView();
        CurrPage.SetSelectionFilter(Rec);
        Rec.MarkedOnly(true);
        if Rec.Count = 1 then begin
            Rec.MarkedOnly(false);
            Rec.SetView(View);
            Rec.Setrange("Source Type");
            Rec.Setrange("Source Subtype");
            Rec.Setrange("Source ID");
            Rec.Setrange("Source Batch Name");
            Rec.Setrange("Source Prod. Order Line");
            Rec.Setrange("Source Ref. No.");
            Rec.Setrange("Package No.");
            Rec.Setrange("Lot No.");
            Rec.Setrange("Serial No.");
            Rec.Setrange("Selected Quantity");
        end;
        if Rec.findset(false) then
            repeat
                if SetDefaulSelectedQuantity then
                    Rec.Validate("Selected Quantity", Rec."Default Selected Quantity")
                else
                    Rec.Validate("Selected Quantity", 2147483647);

                Rec.Modify(true);
            until Rec.next() = 0;
        Rec.MarkedOnly(false);
        Rec.SetView(View)
    end;

    internal procedure ZeroLines()
    var
        View: Text;
    begin
        View := rec.GetView();
        Rec.Reset();
        CurrPage.SetSelectionFilter(Rec);
        Rec.MarkedOnly(true);
        if Rec.Count = 1 then begin
            Rec.MarkedOnly(false);
            Rec.SetView(View);
            Rec.Setrange("Source Type");
            Rec.Setrange("Source Subtype");
            Rec.Setrange("Source ID");
            Rec.Setrange("Source Batch Name");
            Rec.Setrange("Source Prod. Order Line");
            Rec.Setrange("Source Ref. No.");
            Rec.Setrange("Package No.");
            Rec.Setrange("Lot No.");
            Rec.Setrange("Serial No.");
            Rec.Setrange("Selected Quantity");
        end;
        if Rec.findset(false) then
            repeat
                Rec.Validate("Selected Quantity", 0);
                Rec.Modify(true);
            until Rec.next() = 0;
        Rec.MarkedOnly(false);
        Rec.SetView(View);
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
    begin
        Rec.Reset();
        if Rec.findset(false) then
            repeat
                SourceDocumentLink := Rec;
                SourceDocumentLink.Insert(false);
            until Rec.Next() = 0;
    end;

    internal procedure GetTotlaWeight(): Decimal
    begin
        exit(TotalWeight);
    end;

    internal procedure GetVolume(): Decimal
    begin
        exit(TotalVolume);
    end;

    var
        LogisticUnitSetup: Record "TMAC Logistic Units Setup";
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
        LineStyle: Text;

    var
        TotalWeight: Decimal;
        TotalVolume: Decimal;
        WeightRoundPrecision: Decimal;
        VolumeRoundPrecision: Decimal;
}
