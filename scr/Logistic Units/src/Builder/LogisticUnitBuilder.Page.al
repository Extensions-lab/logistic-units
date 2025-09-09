page 71628620 "TMAC Logistic Unit Builder"
{
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Logistic Unit Builder';
    PageType = ListPlus;
    SaveValues = false;

    InsertAllowed = false;
    DeleteAllowed = false;


    layout
    {
        area(Content)
        {
            group(Control8)
            {
                ShowCaption = false;

                part(LinePlanningSubform; "TMAC New Logistic Unit Sub")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Source Document Lines';
                }

                part(UnitPlanningSubform; "TMAC Logistic Unit Build Units")
                {
                    Caption = 'Logistic Units';
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group("Functions")
            {
                Caption = 'Functions';
                Image = "Action";

                action(Planning)
                {
                    Caption = 'New Logistic Units';
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    Image = WorkCenter;
                    ToolTip = 'Creates new logistic units and adds the selected row to it.';

                    trigger OnAction();
                    var
                        SourceDocumentLink: Record "TMAC Source Document Link";
                        LogisticUnitWizard2: Page "TMAC Logistic Unit Wizard";
                    begin
                        CurrPage.LinePlanningSubform.Page.GetSelectedLines(SourceDocumentLink);

                        SourceDocumentLink.Reset();
                        SourceDocumentLink.SetCurrentKey("Item No.", "Variant Code", "Unit of Measure Code");
                        if SourceDocumentLink.Count() = 0 then
                            error(ThereAreNoSelectedLinesErr);

                        if SourceDocumentLink.findset(false) then
                            repeat
                                LogisticUnitWizard2.AddLine(SourceDocumentLink);
                            until SourceDocumentLink.next() = 0;
                       
                       LogisticUnitWizard2.RunModal();
                        if LogisticUnitWizard2.LogisticUnitWasCreated() then
                            UpdatePage();
                    end;
                }

                action(AddItems)
                {
                    Caption = 'Put to Logistic Unit';
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    Image = Item;
                    ToolTip = 'The function includes the selected lines into the logistic unit. Fill in "Selected Quantity" field to define the quantity to add.';
                    trigger OnAction();
                    var
                        LogisticUnitSelect: Record "TMAC Unit Select By Source";
                        LogisticUnitSelectPage: Page "TMAC Unit Selection";
                    begin
                        case Units.Count() of
                            0:
                                Error(ThereIsNoUnitsErr);
                            1:
                                begin
                                    AddLinesToUnit(Units.Get(1));
                                    CurrPage.LinePlanningSubform.Page.UpdateTotals();
                                    UpdatePage();
                                end
                            else begin
                                UnitManagement.CompleteUnitSelection(Units, LogisticUnitSelect);
                                LogisticUnitSelect.Reset();
                                if LogisticUnitSelect.findset(false) then
                                    repeat
                                        LogisticUnitSelectPage.AddLine(LogisticUnitSelect);
                                    until LogisticUnitSelect.next() = 0;

                                LogisticUnitSelectPage.LookupMode(true);
                                if LogisticUnitSelectPage.RunModal() = Action::LookupOK then begin
                                    LogisticUnitSelectPage.GetRecord(LogisticUnitSelect);
                                    AddLinesToUnit(LogisticUnitSelect."Unit No.");
                                    CurrPage.LinePlanningSubform.Page.UpdateTotals();
                                    UpdatePage();
                                end;
                            end;
                        end;
                    end;
                }

                action(Build)
                {
                    Caption = 'Auto Build Logistic Units';
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    Image = ItemGroup;
                    ToolTip = 'Automatically create logistic units according to unit build rules.';

                    trigger OnAction();
                    var
                        SourceDocumentLink: Record "TMAC Source Document Link";
                        ConfirmManagement: Codeunit "Confirm Management";
                    begin
                        if ConfirmManagement.GetResponse(RunAutoBuildQst, true) then begin
                            CurrPage.LinePlanningSubform.Page.GetSelectedLines(SourceDocumentLink);
                            UnitBuildManagement.AutoBuildLogisticUnits(SourceDocumentLink);
                            CurrPage.LinePlanningSubform.Page.UpdateLines();
                            UpdatePage();
                        end;
                    end;
                }


                action(BuildRules)
                {
                    Caption = 'Build Rules';
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    Image = Setup;
                    ToolTip = 'Build Rule for selected source document line';

                    trigger OnAction();
                    begin
                        CurrPage.LinePlanningSubform.Page.ShowBuildRules();
                    end;
                }

                action(Update)
                {
                    Caption = 'Update';
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    Image = Refresh;
                    ToolTip = 'Update page';
                    trigger OnAction();
                    begin
                        UpdatePage();
                    end;
                }
                action(Scan)
                {
                    ApplicationArea = All;
                    Caption = 'Scan';
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    Image = BarCode;
                    ToolTip = 'Scan items to fill the selected quantity field.';
                    trigger OnAction()
                    begin
                        CurrPage.LinePlanningSubform.Page.StartScan();
                    end;
                }

            }
        }
    }

    trigger OnOpenPage()
    begin
        FillSourceDocumentLinesSubform();
        CurrPage.LinePlanningSubform.Page.SetTotalVisible(true);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdatePage();
    end;

    local procedure UpdatePage()
    begin
        FillSourceDocumentLinesSubform();
    end;


    internal procedure FillSourceDocumentLinesSubform()
    var
        UnitLineLink: Record "TMAC Unit Line Link";
        SelectedUnits: List of [Code[20]];
    begin
        CurrPage.LinePlanningSubform.PAGE.DeleteLines();

        Clear(Units);
        Clear(SourceTypeList);

        GlobalSourceDocumentLink.Reset();
        if GlobalSourceDocumentLink.findset(false) then
            repeat
                CurrPage.LinePlanningSubform.PAGE.AddLine(GlobalSourceDocumentLink); //передаем дальше

                UnitLineLink.Reset();
                UnitLineLink.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.", "Package No.", "Lot No.", "Serial No.", "Positive", "Qty. to Post");
                UnitLineLink.Setrange("Source Type", GlobalSourceDocumentLink."Source Type");
                UnitLineLink.Setrange("Source Subtype", GlobalSourceDocumentLink."Source Subtype");
                UnitLineLink.SetRange("Source ID", GlobalSourceDocumentLink."Source ID");
                UnitLineLink.SetRange("Source Ref. No.", GlobalSourceDocumentLink."Source Ref. No.");
                UnitLineLink.SetLoadFields("Unit No.");
                if UnitLineLink.findset(false) then
                    repeat
                        if not SelectedUnits.Contains(UnitLineLink."Unit No.") then
                            SelectedUnits.Add(UnitLineLink."Unit No.");
                    until UnitLineLink.Next() = 0;

            until GlobalSourceDocumentLink.next() = 0;

        Units := GetTopUnits(SelectedUnits);

        CurrPage.LinePlanningSubform.Page.UpdateTotals();
        CurrPage.UnitPlanningSubform.Page.UpdateSubpage(Units);
    end;

    /// <summary>
    /// Check what the given LUs are nested in.
    /// Only high-level logistic units should be present here.
    /// </summary>
    /// <param name="SourceUnits"></param>
    /// <returns></returns>
    local procedure GetTopUnits(SourceUnits: List of [Code[20]]) Result: List of [Code[20]]
    var
        Unit: Record "TMAC Unit";
        AddUnits: List of [Code[20]];
        NextCheckUnits: List of [Code[20]];
        UnitNo: Code[20];
        UnitNo2: Code[20];
    begin
        foreach UnitNo in SourceUnits do begin
            Unit.Get(UnitNo);
            if Unit."Parent Unit No." = '' then begin
                if not Result.Contains(UnitNo) then
                    Result.Add(UnitNo);
            end else begin
                NextCheckUnits.Add(Unit."Parent Unit No.");
                AddUnits := GetTopUnits(NextCheckUnits);
                foreach UnitNo2 in AddUnits do
                    if not Result.Contains(UnitNo2) then
                        Result.Add(UnitNo2);
            end;
        end;
    end;

    internal procedure AddLinesToUnit(UnitNo: Code[20])
    var
        Unit: Record "TMAC Unit";
        UnitType: Record "TMAC Unit Type";
        SelectedSourceDocumentLink: Record "TMAC Source Document Link";
        LocationCode: Code[20];
    begin
        Unit.Get(UnitNo);

        if CurrPage.LinePlanningSubform.Page.GetSelectedQty() = 0 then
            Error(SelectQtyErr);

        if CurrPage.LinePlanningSubform.Page.HasDiffrentDocumentSource() then begin
            UnitType.GET(Unit."Type Code");
            if not UnitType."Mix Source Document Allowed" then
                error(MixSourceDocumentErr, Unit."Type Code");
        end;

        if CurrPage.LinePlanningSubform.Page.HasDiffrentLocations() then begin
            UnitType.GET(Unit."Type Code");
            if not UnitType."Mix Location/Bin Allowed" then
                error(MixLocationCodeErr, Unit."Type Code");
        end;

        CurrPage.LinePlanningSubform.Page.GetSelectedLines(SelectedSourceDocumentLink);

        SelectedSourceDocumentLink.Reset();
        SelectedSourceDocumentLink.SetCurrentKey("Item No.", "Variant Code", "Unit of Measure Code");
        if SelectedSourceDocumentLink.findset(false) then
            repeat
                LocationCode := SelectedSourceDocumentLink."Location Code";
                SelectedSourceDocumentLink.Validate("Selected Quantity");
                UnitManagement.AddItemToLogisticUnit(Unit."No.", SelectedSourceDocumentLink."Selected Quantity", SelectedSourceDocumentLink);
            until SelectedSourceDocumentLink.next() = 0;

        if LocationCode <> '' then begin
            Unit.Get(UnitNo); // re-reading the Rec, i.e. now there's a function that updates the pallet weight in UnitManagement.AddItemToLogisticUnit
            Unit.Validate("Location Code", LocationCode);
            Unit.Modify(true);
        end;

        UnitManagement.UpdateUnitWeightAndVolume(UnitNo, 0, 0, 0);

        FillSourceDocumentLinesSubform();
    end;

    procedure SetSource(SourceType: Integer; SourceDocumentType: Integer; SourceDocumentNo: Code[20]; SourceLineNo: Integer)
    var
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
    begin
        UnitLinkManagement.FillSourceDocumentTable(
            GlobalSourceDocumentLink,
            SourceType,
            SourceDocumentType,
            SourceDocumentNo,
            SourceLineNo, 0, 0, false);
    end;

    procedure SetDocumentLinks(var SourceDocumentLink: Record "TMAC Source Document Link"; LogisticDirection: enum "TMAC Direction")
    begin
        if SourceDocumentLink.findset(false) then
            repeat
                GlobalSourceDocumentLink.TransferFields(SourceDocumentLink);
                GlobalSourceDocumentLink.Insert(true);
            until SourceDocumentLink.next() = 0;
    end;

    /// <summary>
    /// Filling in the main link table for the document lines in the main window of the builder.
    /// </summary>
    procedure AddLink(SourceType: Integer; SourceDocumentType: Integer; SourceDocumentNo: Code[20]; SourceLineNo: Integer; Positive: Boolean)
    var
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
    begin
        UnitLinkManagement.FillSourceDocumentTable(
            GlobalSourceDocumentLink,
            SourceType,
            SourceDocumentType,
            SourceDocumentNo,
            SourceLineNo, 0, 0, Positive);
    end;

    var
        GlobalSourceDocumentLink: Record "TMAC Source Document Link";
        UnitManagement: Codeunit "TMAC Unit Management";
        UnitBuildManagement: Codeunit "TMAC Unit Build Management";

        Units: List of [Code[20]];
        SourceTypeList: List of [Integer];

        ThereIsNoUnitsErr: Label 'There is no logistic units in this forwarding order. You need to build logistic units.';
        RunAutoBuildQst: Label 'Run Auto Build process? Function creates logistic units by build rules.';
        MixSourceDocumentErr: Label 'Unit Type %1 does not allow to mix source documents for the content. Select lines for one Source Document on the previous step.', Comment = '%1 is Unit Type';
        MixLocationCodeErr: Label 'Unit Type %1 does not allow to mix location codes for the content. ', Comment = '%1 is Unit Type';

        SelectQtyErr: Label 'Select lines for the new logistic unit by completing the "Selected Quantity" field.';
        ThereAreNoSelectedLinesErr: Label 'There are no selected lines. Define the "selected quantity" field to select lines.';
}