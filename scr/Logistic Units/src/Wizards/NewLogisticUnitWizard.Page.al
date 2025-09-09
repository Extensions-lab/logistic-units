
page 71628610 "TMAC New Logistic Unit Wizard"
{
    PageType = NavigatePage;
    Caption = 'New Logistic Units Wizard';
    UsageCategory = Administration;

    InsertAllowed = false;
    DeleteAllowed = false;


    layout
    {
        area(content)
        {
            group(BannerStandard)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible and (FirstPageVisible OR SecondPageVisible OR ThirdPageVisible);

                field(MRS; MediaResourcesStandard."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Wizard''s step';
                }
            }
            group(BannerDone)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible and FinalPageVisible;

                field(MRD; MediaResourcesDone."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Wizard''s last step';
                }
            }

            group(FirstPage)
            {
                Caption = '';
                Visible = FirstPageVisible;

                group("Welcome")
                {
                    Caption = 'Welcome';

                    group(Description1)
                    {
                        Caption = '';
                        InstructionalText = 'Welcome to Create Logistic Units Wizard.';
                    }
                    group(Description2)
                    {
                        Caption = '';
                        InstructionalText = 'A logistic unit combines individual items or items in shipping containers (palletes, boxes) into single "units" that can be transported together. ';
                    }
                    group(Description3)
                    {
                        Caption = '';
                        InstructionalText = 'The Wizard will create logistic units manualy or by the build rules.';
                    }
                    group(Description4)
                    {
                        Caption = '';
                        InstructionalText =  '- To enable the functionality for automatic creation of logistic units based on predefined rules enable the "Auto Build Logistic Units" in Logistic Units Setup';
                    }
                    group(Description5)
                    {
                        Caption = '';
                        InstructionalText =  '- To automatically enter the selected quantity using the value from the “Quantity” field, activate the “Set Default Selected Quantity” setting in the "Logistic Unit Setup".';
                    }
                    group(Description6)
                    {
                        Caption = '';
                        InstructionalText =  '- To ignore empty (or distributed) lines without a selected quantity, use the setting "Exclude Lines w/o Def. Qty.".';
                    }
                    
                }
            }
            group(SecondPage)
            {
                Caption = '';
                Visible = SecondPageVisible;
                group(Detail)
                {
                    Caption = 'Step 1/2';
                    field(SecondPageCommentUI; SecondPageCommentTok)
                    {
                        ApplicationArea = all;
                        ShowCaption = false;
                        MultiLine = true;
                        Editable = false;
                    }
                }

                part(DocumentLines; "TMAC New Logistic Unit Sub")
                {
                    Caption = 'Document Lines';
                    ApplicationArea = all;
                    ShowFilter = false;
                }
            }


            group(ThirdPage)
            {
                Caption = '';
                Visible = ThirdPageVisible;


                field(TotalWeight; SelectedTotalWeightText)
                {
                    Caption = 'Weight';
                    CaptionClass = '71628575,2,Weight';
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = SelectedWeightTextStyle;
                    ToolTip = 'Specifies the total weight of the selected logistic units.';
                }
                field(TotalVolume; SelectedTotalVolumeText)
                {
                    Caption = 'Volume/Cubage';
                    CaptionClass = '71628575,1,Volume';
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = SelectedVolumeTextStyle;
                    ToolTip = 'Specifies the total cubage/volume of the selected logistic units.';
                }

                group(FourthPageSub)
                {
                    Caption = 'Select Logistic Unit Type';

                    field(UnitTypeCode; UnitTypeCode)
                    {
                        Caption = 'Unit Type';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the unit type of the logistic unit.';

                        trigger OnValidate()
                        begin
                            ValidateUnitTypeCode(UnitTypeCode);
                        end;

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            UnitType: Record "TMAC Unit Type";
                        begin
                            if UnitType.Get(UnitTypeCode) then;
                            IF Page.RunModal(0, UnitType) = Action::LookupOK then begin
                                UnitTypeCode := UnitType.Code;
                                ValidateUnitTypeCode(UnitTypeCode);
                            end;
                        end;
                    }
                    field(UnitTypeDescription; UnitTypeDescription)
                    {
                        Caption = 'Description';
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the unit type description of the logistic unit.';
                    }
                    field(WeightLimitVisualElement; WeightLimit)
                    {
                        Caption = 'Weight Limit';
                        CaptionClass = '71628575,2,Weight Limit';
                        ApplicationArea = All;
                        Editable = false;
                        MultiLine = true;
                        ToolTip = 'Specifies the weight limit for the logistic unit.';
                    }
                    field(VolumeLimitVisualElement; VolumeLimit)
                    {
                        Caption = 'Volume Limit';
                        CaptionClass = '71628575,1,Volume Limit';
                        ApplicationArea = All;
                        Editable = false;
                        MultiLine = true;
                        ToolTip = 'Specifies the volum limit for the logistic unit.';
                    }
                    field(Information; WarningInformation)
                    {
                        Caption = 'Information';
                        ShowCaption = false;
                        ApplicationArea = All;
                        Editable = false;
                        MultiLine = true;
                        StyleExpr = InformationTextStyle;
                        ToolTip = 'Specifies some additional information.';
                    }
                }
            }

            group(FinalPage)
            {
                Caption = '';
                Visible = FinalPageVisible;

                group("ActivationDone")
                {
                    Caption = 'Done!';
                    Visible = FinalPageVisible;

                    field(CreatedUnitNoUI; CreatedUnitNo)
                    {
                        Caption = 'Created Logistic Unit';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the created logistic unit';
                        Editable = false;
                        trigger OnAssistEdit()
                        var
                            Unit: Record "TMAC Unit";
                        begin
                            if Unit.Get(CreatedUnitNo) then
                                Page.RunModal(Page::"TMAC Unit Card", Unit);
                        end;
                    }
                    group(DoneMessage)
                    {
                        Caption = '';
                        InstructionalText = 'The logistics unit has been created. Click "Finish" to close the wizard, or "Create New" to repeat the process and create a new one.';
                        Visible = FinalPageVisible;
                    }


                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionBack)
            {
                ApplicationArea = All;
                Caption = 'Back';
                Enabled = BackEnabled;
                Visible = BackEnabled;
                Image = PreviousRecord;
                InFooterBar = true;
                ToolTip = 'Return to previous step of the wizard.';

                trigger OnAction();
                begin
                    CheckBack();
                    NextStep(true);
                end;
            }

            action(ActionNext)
            {
                ApplicationArea = All;
                Caption = 'Next';
                Enabled = NextEnabled;
                Visible = NextEnabled;
                Image = NextRecord;
                InFooterBar = true;
                ToolTip = 'Go to next step of the wizard.';

                trigger OnAction();
                begin
                    CheckNext();
                    NextStep(false);
                end;
            }
            action(ActionCreate)
            {
                ApplicationArea = All;
                Caption = 'Create';
                Enabled = CreateEnabled;
                Visible = CreateEnabled;
                Image = NextRecord;
                InFooterBar = true;
                ToolTip = 'Go to next step of the wizard.';

                trigger OnAction();
                begin
                    CheckNext();
                    NextStep(false);
                end;
            }

            action(ActionFinish)
            {
                ApplicationArea = All;
                Caption = 'Finish';
                Enabled = FinishEnabled;
                Visible = FinishEnabled;
                Image = Approve;
                InFooterBar = true;
                ToolTip = 'Close the wizard.';

                trigger OnAction();
                begin
                    FinishAndCloseWizard()
                end;
            }

            action(Scan)
            {
                ApplicationArea = All;
                Caption = 'Scan';
                InFooterBar = true;
                Visible = IsScanVisible;
                Image = BarCode;
                ToolTip = 'Scan items to fill the selected quantity field.';
                trigger OnAction()
                begin
                    CurrPage.DocumentLines.Page.StartScan();
                end;
            }
            action(AutoBuild)
            {
                ApplicationArea = All;
                Caption = 'Auto Build Logistic Units';
                Visible = IsAutoBuildVisible;
                InFooterBar = true;
                Image = AutofillQtyToHandle;
                ToolTip = 'Auto Build Logistic units by build rules.';

                trigger OnAction();
                var
                    SourceDocumentLink: Record "TMAC Source Document Link";
                    ConfirmManagement: Codeunit "Confirm Management";
                begin
                    if ConfirmManagement.GetResponse(RunAutoBuildQst, true) then begin
                        CurrPage.DocumentLines.Page.GetSelectedLines(SourceDocumentLink);
                        CreatedUnits := UnitBuildManagement.AutoBuildLogisticUnits(SourceDocumentLink);
                        CurrPage.DocumentLines.Page.UpdateLines();
                    end;
                end;
            }
            action(CreateNew)
            {

                ApplicationArea = All;
                Caption = 'Create New';
                Visible = IsCreateNewVisible;
                InFooterBar = true;
                Image = AutofillQtyToHandle;
                ToolTip = 'Create new logistic unit.';
                trigger OnAction()
                begin
                    Step := Step::Second;
                    EnableControls();
                    FillDocumentLinesSubform();
                end;
            }
        }
    }

    trigger OnInit();
    begin
        LoadTopBanners();
    end;

    trigger OnOpenPage();
    begin
        Step := Step::First;
        EnableControls();
        DeleteScannedValues();
        LogisticUnitsSetup.Get();
    end;

    local procedure EnableControls();
    begin
        ResetControls();
        case Step of
            Step::First:
                ShowFirstPage();
            Step::Second:
                ShowSecondPage();
            Step::Third:
                ShowThirdPage();
            Step::Finish:
                ShowFinalPage();
        END;
    end;

    local procedure NextStep(Backwards: Boolean);
    begin
        if Backwards then
            Step := Step - 1
        ELSE
            Step := Step + 1;
        EnableControls();
    end;

    local procedure ShowFirstPage();
    begin
        FirstPageVisible := true;
        BackEnabled := false;
        NextEnabled := true;
        FinishEnabled := true;
    end;

    local procedure ShowSecondPage();
    begin
        SecondPageVisible := true;
        BackEnabled := true;
        NextEnabled := true;
        FinishEnabled := true;

        IsScanVisible := true;
        IsAutoBuildVisible := LogisticUnitsSetup."Auto Build Logistic Units";
    end;

    local procedure ShowThirdPage();
    begin
        ThirdPageVisible := true;
        BackEnabled := true;
        NextEnabled := false;
        CreateEnabled := true;
        FinishEnabled := true;
    end;

    local procedure ShowFinalPage();
    begin
        FinalPageVisible := true;
        BackEnabled := false;
        NextEnabled := false;
        IsCreateNewVisible := true;
    end;

    local procedure FinishAndCloseWizard()
    begin
        CurrPage.Close();
    end;

    local procedure ResetControls();
    begin
        FinishEnabled := true;
        BackEnabled := true;
        NextEnabled := true;
        CreateEnabled := false;

        FirstPageVisible := false;
        SecondPageVisible := false;
        ThirdPageVisible := false;
        FinalPageVisible := false;

        IsAutoBuildVisible := false;
        IsCreateNewVisible := false;
        IsScanVisible := false;
    end;

    local procedure CheckBack()
    begin
        case Step of
            Step::First:
                BackOnFirstPage();
            Step::Second:
                BackOnSecondPage();
            Step::Third:
                BackOnThirdPage();
            Step::Finish:
                BackOnFinalPage();
        END;
    end;

    local procedure CheckNext()
    begin
        case Step of
            Step::First:
                NextFromFirstPage();
            Step::Second:
                NextFromSecondPage();
            Step::Third:
                NextFromThirdPage();
            Step::Finish:
                NextFromFinalPage();
        END;
    end;

    local procedure BackOnFirstPage();
    begin
    end;

    local procedure NextFromFirstPage();
    begin
        FillDocumentLinesSubform();
    end;

    local procedure BackOnSecondPage();
    begin

    end;

    local procedure NextFromSecondPage();
    var
        UnitType: Record "TMAC Unit Type";
    begin
        if CurrPage.DocumentLines.Page.GetSelectedQty() = 0 then
            Error(SelectQtyErr);

        SelectedTotalWeight := CurrPage.DocumentLines.Page.GetSelectedWeight();
        SelectedTotalVolume := CurrPage.DocumentLines.Page.GetSelectedVolume();

        SelectedTotalWeightText := Format(SelectedTotalWeight);
        SelectedTotalVolumeText := Format(SelectedTotalVolume);

        LinesFromDiffrentDocuments := CurrPage.DocumentLines.Page.HasDiffrentDocumentSource();
        LinesFromDiffrentLocations := CurrPage.DocumentLines.Page.HasDiffrentLocations();

        InformationTextStyle := '';
        WarningInformation := '';
        WeightLimit := 0;
        VolumeLimit := 0;

        UnitTypeCode := '';
        UnitTypeDescription := '';

        LogisticUnitsSetup.Get();
        if LogisticUnitsSetup."Def. Unit Type" <> '' then
            if UnitType.Get(LogisticUnitsSetup."Def. Unit Type") then begin
                UnitTypeCode := UnitType.Code;
                UnitTypeDescription := UnitType.Description;
                ValidateUnitTypeCode(UnitTypeCode);
            end;
    end;

    local procedure BackOnThirdPage();
    begin

    end;

    local procedure NextFromThirdPage();
    var
        SourceDocumentLink: Record "TMAC Source Document Link";
    begin
        if UnitTypeCode = '' then
            Error(UnitTypeCodeIsEmptyErr);

        CurrPage.DocumentLines.Page.GetSelectedLines(SourceDocumentLink);
        CreatedUnitNo := UnitBuildManagement.BuildLogisticUnit(UnitTypeCode, SourceDocumentLink);

        if UnitTypeCode <> '' then
            ValidateUnitTypeCode(UnitTypeCode);
    end;

    local procedure BackOnFinalPage();
    begin
    end;

    local procedure NextFromFinalPage();
    begin
    end;


    local procedure LoadTopBanners();
    begin
        if MediaRepositoryStandard.GET('AssistedSetup-NoText-400px.png', FORMAT(CURRENTCLIENTTYPE())) and
            MediaRepositoryDone.GET('AssistedSetupDone-NoText-400px.png', FORMAT(CURRENTCLIENTTYPE()))
        then
            if MediaResourcesStandard.GET(MediaRepositoryStandard."Media Resources Ref") and
                MediaResourcesDone.GET(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResourcesDone."Media Reference".HASVALUE();
    end;

    internal procedure FillDocumentLinesSubform()
    begin
        CurrPage.DocumentLines.PAGE.DeleteLines();
        if GlobalSourceDocumentLink.findset(false) then
            repeat
                CurrPage.DocumentLines.PAGE.AddLine(GlobalSourceDocumentLink);
            until GlobalSourceDocumentLink.next() = 0;
    end;


    internal procedure ValidateUnitTypeCode(UnitTypeCode1: code[20])
    var
        UnitType: Record "TMAC Unit Type";
    begin
        InformationTextStyle := '';
        WarningInformation := '';
        WeightLimit := 0;
        VolumeLimit := 0;
        UnitTypeDescription := '';

        SelectedTotalWeightText := Format(SelectedTotalWeight);
        SelectedTotalVolumeText := Format(SelectedTotalVolume);
        SelectedWeightTextStyle := '';
        SelectedVolumeTextStyle := '';

        if UnitType.Get(UnitTypeCode1) then begin
            UnitTypeDescription := UnitType.Description;

            if UnitType."Limit Filling Weight Control" then begin
                WeightLimit := UnitType."Limit Filling Weight";

                if SelectedTotalWeight > WeightLimit then begin
                    WarningInformation := LimitControlMsg;
                    SelectedTotalWeightText := StrSubstNo(OverWeightMsg, SelectedTotalWeight, UnitTypeDescription, WeightLimit);
                    SelectedWeightTextStyle := 'Unfavorable';
                    InformationTextStyle := 'Unfavorable';
                end;
            end;

            if UnitType."Limit Filling Volume Control" then begin
                VolumeLimit := UnitType."Limit Filling Volume";

                if SelectedTotalVolume > VolumeLimit then begin
                    WarningInformation := LimitControlMsg;
                    SelectedTotalVolumeText := StrSubstNo(OverVolumeMsg, SelectedTotalVolume, UnitTypeDescription, VolumeLimit);
                    SelectedVolumeTextStyle := 'Unfavorable';
                    InformationTextStyle := 'Unfavorable';
                end;
            end;

            if LinesFromDiffrentDocuments then
                if not UnitType."Mix Source Document Allowed" then begin
                    if WarningInformation <> '' then
                        WarningInformation := '\';
                    WarningInformation += StrSubstNo(MixSourceDocumentErr, UnitTypeCode1);
                    InformationTextStyle := 'Unfavorable';
                end;
            if LinesFromDiffrentLocations then
                if not UnitType."Mix Location/Bin Allowed" then begin
                    if WarningInformation <> '' then
                        WarningInformation := '\';
                    WarningInformation += StrSubstNo(MixLocationsErr, UnitTypeCode1);
                    InformationTextStyle := 'Unfavorable';
                end;
        end;
    end;

    internal procedure SetDocumentLinks(var SourceDocumentLink: Record "TMAC Source Document Link"; Direction1: enum "TMAC Direction")
    begin
        if SourceDocumentLink.findset(false) then
            repeat
                GlobalSourceDocumentLink.TransferFields(SourceDocumentLink);
                GlobalSourceDocumentLink.Insert(true);
            until SourceDocumentLink.next() = 0;
        LogicticDirection := Direction1;
    end;

    internal procedure DeleteScannedValues()
    var
        ScannedValue: Record "TMAC Scanned Value";
    begin
        ScannedValue.SetRange("User ID", UserId);
        ScannedValue.DeleteAll(false);
    end;

    var
        LogisticUnitsSetup: Record "TMAC Logistic Units Setup";
        GlobalSourceDocumentLink: Record "TMAC Source Document Link";

        MediaRepositoryStandard: Record "Media Repository";
        MediaRepositoryDone: Record "Media Repository";
        MediaResourcesStandard: Record "Media Resources";
        MediaResourcesDone: Record "Media Resources";
        UnitBuildManagement: Codeunit "TMAC Unit Build Management";

        Step: Option First,Second,Third,Finish;

        LogicticDirection: enum "TMAC Direction";

        TopBannerVisible: Boolean;
        FirstPageVisible: Boolean;
        SecondPageVisible: Boolean;
        ThirdPageVisible: Boolean;
        FinalPageVisible: Boolean;

        FinishEnabled: Boolean;
        BackEnabled: Boolean;
        NextEnabled: Boolean;
        CreateEnabled: Boolean;
        IsAutoBuildVisible: Boolean;
        IsCreateNewVisible: Boolean;
        IsScanVisible: Boolean;

        CreatedUnits: List of [Code[20]];
        CreatedUnitNo: Code[20];
        UnitTypeCode: Code[20];
        UnitTypeDescription: Text[100];

        SelectedTotalWeight: Decimal;
        SelectedTotalVolume: Decimal;
        SelectedTotalWeightText: Text;
        SelectedTotalVolumeText: Text;
        SelectedWeightTextStyle: Text;
        SelectedVolumeTextStyle: Text;

        LinesFromDiffrentDocuments: Boolean;
        LinesFromDiffrentLocations: Boolean;
        WeightLimit: Decimal;
        VolumeLimit: Decimal;
        InformationTextStyle: Text;
        WarningInformation: Text;

        LimitControlMsg: Label 'Limit control warning!';
        OverWeightMsg: Label '%1 exceeds the weight limit of "%2" , which is %3', Comment = '%1 is an weight, %2 is a logistic unit name, %3 is an weight limit';
        OverVolumeMsg: Label '%1 exceeds the volume limit of "%2" , which is %3', Comment = '%1 is an volume, %2 is a logistic unit name, %3 is an volume limit';
        UnitTypeCodeIsEmptyErr: Label 'Unit type code is empty!';
        SelectQtyErr: Label 'Select lines for the new logistic unit by completing the "Selected Quantity" field. To automatically enter the selected quantity in the "Qty. to Ship" field, activate the "Set Default Selected Quantity" setting in "Logistic Units Setup".';
        RunAutoBuildQst: Label 'Run Auto Build process? Function creates logistic units by build rules.';
        SecondPageCommentTok: Label 'Complete the "Selected Quantity" field for the lines to be included in the new logistics unit and click Next button.';
        MixSourceDocumentErr: Label 'Unit Type %1 does not allow to mix source documents for the content. Select lines for one Source Document on the previous step.', Comment = '%1 is Unit Type';
        MixLocationsErr: Label 'Unit Type %1 does not allow to mix location codes for the content. ', Comment = '%1 is Unit Type';

}
