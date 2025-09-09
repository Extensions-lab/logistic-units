page 71628611 "TMAC New Logistic Unit Sub"
{
    Caption = 'New Logistic Unit Sub';
    PageType = ListPart;
    SourceTable = "TMAC Source Document Link";
    SourceTableView = sorting("Document Source Type", "Document Source SubType", "Document Source ID");
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            usercontrol(BarcodeControl; CameraBarcodeScannerProviderAddIn)
            {
                ApplicationArea = All;

                trigger ControlAddInReady(IsSupported: Boolean)
                begin
                    CameraBarcodeScannerAvailable := IsSupported;
                end;

                trigger BarcodeAvailable(Barcode: Text; Format: Text)
                begin
                    if not CameraContinuousScanningMode then
                        exit;

                    AfterScanValue(Barcode, Format);

                    if ContinueScanning() then
                        CurrPage.BarcodeControl.RequestBarcodeAsync();

                    CurrPage.Update(false);
                end;

                trigger BarcodeFailure(Reason: Enum BarcodeFailure)
                begin
                    Error(BarcodeFailureErr, Reason.AsInteger());
                end;
            }

            repeater(General)
            {
                ShowAsTree = true;
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the Item';
                    ApplicationArea = All;
                    Editable = false;
                }

                field(DocumentQuantity; Rec."Control Quantity")
                {
                    Caption = 'Document Line Qty.';
                    ToolTip = 'Specifies the document line quantity of the item.';
                    ApplicationArea = All;
                    Editable = false;
                }

                field(Quantity; Rec.Quantity - Abs(Rec."Distributed Quantity"))
                {
                    Caption = 'Available Qty.';
                    ToolTip = 'Specify the quantity available for assignment to a logistics unit. The value is calculated as the "document line quantity" - "posted quantity" - "the distributed quantity" among other logistic units. Detailing shows the links of distribution with other logistics units.';
                    ApplicationArea = All;
                    Editable = false;
                    BlankZero = true;
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
                    ToolTip = 'Specifies the default selected qty. "Qty. to ship" for sale, "Qty. to Receive" for purchase.';
                    Editable = false;
                    Visible = false;
                }

                field("Selected Quantity"; Rec."Selected Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the document line quantity to be distributed to the new logistic unit.';
                    Style = Strong;
                    BlankZero = true;
                }

                field("Distributed Quantity"; Rec."Distributed Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity that has already been distributed between logistic untis. A negative value indicates an expense transaction.';
                    Editable = false;
                    BlankZero = true;
                    Visible = false;
                }

                field("Document Source ID"; Rec."Document Source ID")
                {
                    Caption = 'Source Document No.';
                    ToolTip = 'Identifies the ID of source of the document.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Document Source Information"; Rec."Document Source Information")
                {
                    Caption = 'Source Document Information';
                    ToolTip = 'Specifies the additional information from source dcoument';
                    ApplicationArea = All;
                    Editable = false;
                    Width = 15;
                }

                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = ItemTracking;
                    Editable = false;
                    ToolTip = 'Specifies the serial number of the item.';
                    Visible = false;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = ItemTracking;
                    Editable = false;
                    ToolTip = 'Specifies the lot number of the item.';
                }
                field("Package No."; Rec."Package No.")
                {
                    ApplicationArea = ItemTracking;
                    Editable = false;
                    ToolTip = 'Specifies the package number of the item.';
                }

                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies the variant of the item.';
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ToolTip = 'Specifies the unit of measure.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                    ToolTip = 'Specifies the quantity (Base) in base units of measure.';
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("No. of Build Rules"; Rec."No. of Build Rules")
                {
                    ToolTip = 'Specifies the quantity of logistic units build rules.';
                    ApplicationArea = All;
                    Editable = false;
                    Style = Strong;
                    Visible = IsAutoBuildVisible;
                }

                field("Distributed Weight (base)"; Rec."Distributed Weight (base)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the weight that has already been distributed between logistic untis.';
                }
            }


            group(Totals)
            {
                ShowCaption = false;
                Visible = IsTotalVisible;

                grid(TotalsInner)
                {
                    field(TotalRemainingQty; TotalRemainingQty)
                    {
                        Caption = 'Remaining Qty.';
                        ApplicationArea = Basic, Suite;
                        DrillDown = false;
                        Editable = false;
                        ToolTip = 'Specifies the total remaining quantity on all lines.';
                    }

                    field(TotalDistributedQty; TotalDistributedQty)
                    {
                        Caption = 'Distributed Qty.';
                        ApplicationArea = Basic, Suite;
                        DrillDown = false;
                        Editable = false;
                        ToolTip = 'Specifies the total distibuted quantity of hte all lines.';
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
            action(HideDistributedLines)
            {
                Caption = 'Show/Hide Distributed Lines';
                Image = FilterLines;
                ApplicationArea = All;
                ToolTip = 'Hide lines that have "quantity" = "Distributed Qty."';
                trigger OnAction()
                begin
                    ShowHideDistributedLines();
                end;
            }

            action(FilterBySourceNo)
            {
                Caption = 'Filter by Source Doc. No.';
                Image = FilterLines;
                ApplicationArea = All;
                ToolTip = 'Defines the filter for lines by current source no field value.';
                trigger OnAction()
                begin
                    Rec.Setrange("Document Source Information");

                    if Rec.GetFilter("Document Source ID") <> '' then
                        Rec.SetRange("Document Source ID")
                    else
                        Rec.SetRange("Document Source ID", Rec."Document Source ID");
                end;
            }

            action(FilterBySourceInformation)
            {
                Caption = 'Filter by Source Doc. Information';
                Image = FilterLines;
                ApplicationArea = All;
                ToolTip = 'Defines the filter for lines by current source no field value.';
                trigger OnAction()
                begin
                    Rec.SetRange("Document Source ID");
                    if Rec.GetFilter("Document Source Information") <> '' then
                        Rec.SetRange("Document Source Information")
                    else
                        Rec.SetRange("Document Source Information", Rec."Document Source Information");
                end;
            }
            action("Scan multiple")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Scan multiple';
                Ellipsis = true;
                Image = BarCode;
                ToolTip = 'Scan 1D or 2D barcodes codes with bar coder readers.';

                trigger OnAction()
                begin
                    StartScan();
                end;
            }

        }

    }
    trigger OnOpenPage()
    begin
        LogisticUnitsSetup.Get();
        IsAutoBuildVisible := LogisticUnitsSetup."Auto Build Logistic Units";
    end;

    internal procedure DeleteLines()
    begin
        Rec.Reset();
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

        // Первая настройа задает режим работы по Selected Quantity
        if SetDefaulSelectedQuantity and ExcludeLinesWODefQty then
            if SourceDocumentLink."Default Selected Quantity" = 0 then
                exit;

        //в трассировке можут повторятся записи поэтому не прямая вставка
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

            Rec."Default Selected Quantity" := 0;
            Rec.Modify(true);

        end else begin
            Rec.Init();
            Rec.TransferFields(SourceDocumentLink);

            if SetDefaulSelectedQuantity then
                if SourceDocumentLink."Default Selected Quantity" <> 0 then begin //here it may be Qty to Shipment
                    Rec.Validate("Selected Quantity", SourceDocumentLink."Default Selected Quantity");
                    Rec."Default Selected Quantity" := SourceDocumentLink."Default Selected Quantity";
                end;

            Rec.Insert(false);
        end;

        // "Distributed Quantity" is calculated when validating Selected Quantity
        Rec.Calcfields("Distributed Quantity");
        if Rec.Quantity - Abs(Rec."Distributed Quantity") = 0 then begin // Quantity may contain the Qty to Ship... i.e., the remaining amount. But the distributed quantity is calculated by line, not by the amount.
            Rec.Select := true; //selection according to the principle of full allocation
            Rec.Modify(true);
        end;
    end;

    internal procedure HasDiffrentDocumentSource() returnvalue: Boolean
    var
        UnitBuildManagement: Codeunit "TMAC Unit Build Management";
        Position: Text;
    begin
        Position := Rec.GetPosition();
        ReturnValue := UnitBuildManagement.HasDiffrentDocumentSource(Rec);
        Rec.SetPosition(Position);
    end;

    internal procedure HasDiffrentLocations() returnvalue: Boolean
    var
        UnitBuildManagement: Codeunit "TMAC Unit Build Management";
        Position: Text;
    begin
        Position := Rec.GetPosition();
        ReturnValue := UnitBuildManagement.HasDifferentLocations(Rec);
        Rec.SetPosition(Position);
    end;

    internal procedure GetSelectedQty() Quantity: Decimal
    var
        Position: Text;
    begin
        Position := Rec.GetPosition();
        if Rec.Findfirst() then
            repeat
                if Rec."Selected Quantity" > 0 then
                    Quantity += Rec."Selected Quantity";
            until Rec.Next() = 0;
        Rec.SetPosition(Position);
    end;

    internal procedure GetSelectedWeight() Weight: Decimal
    var
        Position: Text;
    begin
        Position := Rec.GetPosition();
        if Rec.Findfirst() then
            repeat
                if Rec."Selected Quantity" > 0 then
                    Weight += Round(Rec."Selected Quantity" * rec."Weight (Base) per UoM", 0.01);
            until Rec.Next() = 0;
        Rec.SetPosition(Position);
    end;

    internal procedure GetSelectedVolume() Volume: Decimal
    var
        Position: Text;
    begin
        Position := Rec.GetPosition();
        if Rec.findset(false) then
            repeat
                if Rec."Selected Quantity" > 0 then
                    Volume += Round(Rec."Selected Quantity" * rec."Volume (Base) per UoM", 0.01);
            until Rec.Next() = 0;
        Rec.SetPosition(Position);
    end;

    internal procedure GetSelectedLines(var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        Position: Text;
    begin
        Position := Rec.GetPosition();
        if Rec.findset(false) then
            repeat
                if Rec."Selected Quantity" > 0 then begin
                    SourceDocumentLink := Rec;
                    SourceDocumentLink.Insert(false);
                end;
            until Rec.Next() = 0;
        Rec.SetPosition(Position);
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

    internal procedure UpdateLines()
    var
        View: Text;
    begin
        View := Rec.GetView();
        Rec.Reset();
        if Rec.findset(false) then
            repeat
                Rec.Validate("Selected Quantity", 2147483647);
                Rec.Modify(true);
            until Rec.next() = 0;
        Rec.SetView(View);
        if Rec.FindFirst() then;
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


    internal procedure ShowBuildRules()
    var
        UnitBuildRule: Record "TMAC Unit Build Rule";
        UnitBuildRuleList: Page "TMAC Unit Build Rule List";
    begin
        UnitBuildRule.FilterGroup(2);
        UnitBuildRule.Setrange("Type", "TMAC Content Type"::Item);
        UnitBuildRule.Setrange("No.", Rec."Item No.");
        UnitBuildRule.Setrange("Variant Code", Rec."Variant Code");
        UnitBuildRule.Setrange("Unit of Measure Code", Rec."Unit of Measure Code");
        UnitBuildRule.FilterGroup(0);
        UnitBuildRuleList.SetTableView(UnitBuildRule);
        UnitBuildRuleList.Run();
    end;

    internal procedure UpdateTotals()
    var
        FilterSet: Text;
    begin
        TotalDistributedQty := 0;
        TotalRemainingQty := 0;

        FilterSet := Rec.GetView();

        Rec.Reset();
        Rec.SetAutoCalcFields("Distributed Quantity");
        if Rec.findset(false) then
            repeat
                TotalDistributedQty += abs(Rec."Distributed Quantity");
                TotalRemainingQty += Rec.Quantity - abs(Rec."Distributed Quantity");
            until Rec.Next() = 0;

        Rec.SetView(FilterSet);
        if Rec.FindFirst() then;
    end;

    local procedure ShowHideDistributedLines()
    begin
        if Rec.GetFilter(Select) <> '' then
            Rec.Setrange(Select)
        else
            Rec.Setrange(Select, false);
    end;

    internal procedure SetTotalVisible(Value: Boolean)
    begin
        IsTotalVisible := Value;
    end;


    #region Scan

    internal procedure StartScan()
    begin
        if CameraBarcodeScannerAvailable then
            ScanMultipleOnMobileDevice()
        else
            ScanMultipleOnWebClient();
    end;

    /// <summary>
    /// Условие выхода из режима сканирования
    /// </summary>
    /// <returns></returns>
    local procedure ContinueScanning(): Boolean
    begin
        //нужно прописать какието условия выхода
        exit(false);
    end;

    local procedure ScanMultipleOnMobileDevice()
    begin
        // if not ContinueScanning() then
        //     exit;
        CameraContinuousScanningMode := true;
        CurrPage.BarcodeControl.RequestBarcodeAsync();
    end;

    local procedure ScanMultipleOnWebClient()
    var
        ScanValues: Page "TMAC Scan Values";
    begin
        System.Clear(ScanValues);
        ScanValues.LookupMode(true);
        ScanValues.RunModal();
        if (ScanValues.GetInput() = '') then
            exit;
        AfterScanValue(ScanValues.GetInput(), '');
    end;

    local procedure AfterScanValue(Barcode: Text; Format: Text)
    var
        ItemIdentifier: Record "Item Identifier";
        ScannedValue: Record "TMAC Scanned Value";
        Item: Record Item;
        Result: Text;
        ItemNo: Code[20];
        Handled: Boolean;
    begin
        ScannedValue.Init();
        ScannedValue."User ID" := CopyStr(UserId(), 1, 50);
        ScannedValue."Entry No." := 0;
        ScannedValue.Barcode := CopyStr(Barcode, 1, 1000);
        ScannedValue.Format := CopyStr(Format, 1, 100);
        ScannedValue.Insert(true);
        Commit();

        OnAfterScanValue(Barcode, Format, Rec, Result, Handled);
        if Handled then begin
            ScannedValue.Result := CopyStr(Result, 1, 50);
            if Result = '' then
                ScannedValue.Result := 'External processing';
            ScannedValue.Modify(true);
            exit;
        end;

        ItemIdentifier.SetFilter(Code, '%1', Barcode);
        if ItemIdentifier.FindFirst() then begin
            ScannedValue.Result := CopyStr(StrSubstNo(ItemIdentifierForMsg, ItemIdentifier."Item No."), 1, 50);
            ItemNo := ItemIdentifier."Item No.";
        end else
            if Item.Get(Barcode) then begin
                ScannedValue.Result := CopyStr(StrSubstNo(ItemMsg, Item."No."), 1, 50);
                ItemNo := Item."No.";
            end;

        if Item.Get(ItemNo) then begin
            Rec.Setrange("Item No.", Item."No.");
            Rec.Setrange("Selected Quantity", 0);
            if Rec.FindFirst() then begin
                Rec.Validate("Selected Quantity", 2147483647);
                Rec.Modify(true);
            end;
            Rec.Setrange("Selected Quantity");
            Rec.Setrange("Item No.");
        end;

        ScannedValue.Modify(true);
    end;
    #endregion

    var
        LogisticUnitsSetup: Record "TMAC Logistic Units Setup";
        TotalRemainingQty: Decimal;
        TotalDistributedQty: Decimal;
        IsTotalVisible: Boolean;
        IsAutoBuildVisible: Boolean;
        CameraBarcodeScannerAvailable: Boolean;
        CameraContinuousScanningMode: Boolean;
        BarcodeFailureErr: Label 'Barcode Failure with code %1', Comment = '%1 = failure reason code';
        ItemIdentifierForMsg: Label 'Item Identifier For %1', Comment = '%1 is a item no.';
        ItemMsg: Label 'Item %1', Comment = '%1 is a item no.';


    [IntegrationEvent(false, false)]
    local procedure OnAfterScanValue(Barcode: Text; Format: Text; var SourceDocumentLink: Record "TMAC Source Document Link"; var Result: Text; var Handled: Boolean)
    begin
    end;

}
