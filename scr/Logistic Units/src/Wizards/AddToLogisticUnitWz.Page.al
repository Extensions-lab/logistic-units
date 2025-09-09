
page 71628614 "TMAC Add To Logistic Unit Wz."
{
    PageType = NavigatePage;
    Caption = 'Add to Logistic Unit. Wizard';
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
                Visible = TopBannerVisible and (FirstPageVisible OR SecondPageVisible);

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
                    Caption = 'Step 1/2. Select lines by filling out the "Selected Quantity" field. Change the "Selected Quantity" field if you need to perform a partial load into the logistic unit.';

                    group(Description2)
                    {
                        Caption = '';
                        InstructionalText = 'Select the lines. Change the "Selected Quantity"';
                        Visible = false;
                    }
                }

                part(DocumentLines; "TMAC Add To Logistic Unit Sub2")
                {
                    Caption = 'Selected Document Lines';
                    ApplicationArea = all;
                    ShowFilter = false;
                }
            }
            group(SecondPage)
            {
                Caption = '';
                Visible = SecondPageVisible;

                group(Detail)
                {
                    Caption = 'Step 2/2. Select the logistic unit and click "Add".';

                    group(DescriptionStep2)
                    {
                        Caption = '';
                        InstructionalText = 'Select the logistic unit and click "Add".';
                        Visible = false;
                    }

                    field(CargoInformation; CargoInformation)
                    {
                        ShowCaption = false;
                        ApplicationArea = all;
                        Editable = false;
                    }
                }

                part(LogisticUnitList; "TMAC Unit Selection Subf.")
                {
                    Caption = 'Available Logistic Units';
                    ApplicationArea = all;
                    ShowFilter = false;
                }


                field(UnitNo; UnitRemove."No.")
                {
                    Caption = 'Unit No.';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit no of the logistic unit.';
                    Visible = false;
                    Editable = false;
                }
            }

            group(ThirdPage)
            {
                Caption = '';
                Visible = false;

                group(FourthPageSub)
                {
                    Caption = 'Add Logistic Unit Type';
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

                    group(DoneMessage)
                    {
                        Caption = '';
                        InstructionalText = 'Document lines were added. Click Finish to close the wizard.';
                        Visible = FinalPageVisible;
                    }

                    field(CreatedUnitNoUI; CreatedUnitNo)
                    {
                        Caption = 'Logistic Unit';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the changed logistic unit.';
                        Editable = false;
                        trigger OnAssistEdit()
                        var
                            Unit: Record "TMAC Unit";
                        begin
                            if Unit.Get(CreatedUnitNo) then
                                Page.RunModal(Page::"TMAC Unit Card", Unit);
                        end;
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
                ToolTip = 'Return to the previous step of the wizard.';

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
            action(ActionCreateLink)
            {
                ApplicationArea = All;
                Caption = 'Add';
                Enabled = LoadButtonEnabled;
                Visible = LoadButtonEnabled;
                Image = NextRecord;
                InFooterBar = true;
                ToolTip = 'Go to next step of the wizard.';

                trigger OnAction();
                begin
                    Load();
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

        }
    }

    trigger OnInit();
    begin
        LogisticUnitSetup.Get();
        LoadTopBanners();
    end;

    trigger OnOpenPage();
    begin
        Step := Step::First;
        EnableControls();
    end;

    local procedure EnableControls();
    begin
        ResetControls();
        case Step of
            Step::First:
                ShowFirstPage();
            Step::Second:
                ShowSecondPage();
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
        LoadButtonEnabled := true;
        FinishEnabled := true;
    end;

    local procedure ShowFinalPage();
    begin
        FinalPageVisible := true;
        BackEnabled := false;
        NextEnabled := false;
        LoadButtonEnabled := false;
        FinishEnabled := true;
    end;

    local procedure FinishAndCloseWizard()
    begin
        CurrPage.Close();
    end;

    local procedure ResetControls();
    begin
        FinishEnabled := false;
        BackEnabled := false;
        NextEnabled := false;
        LoadButtonEnabled := false;

        FirstPageVisible := false;
        SecondPageVisible := false;
        FinalPageVisible := false;
    end;

    local procedure CheckBack()
    begin
        case Step of
            Step::First:
                BackOnFirstPage();
            Step::Second:
                BackOnSecondPage();
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
            Step::Finish:
                NextFromFinalPage();
        END;
    end;

    local procedure BackOnFirstPage();
    begin
    end;

    local procedure NextFromFirstPage();
    begin
        CargoInformation := CargoParametersLbl + Format(CurrPage.DocumentLines.Page.GetTotlaWeight()) + ' ' + LogisticUnitSetup."Base Weight UoM Caption" + '    ' + Format(CurrPage.DocumentLines.Page.GetVolume()) + ' ' + LogisticUnitSetup."Base Volume UoM Caption";
        CurrPage.LogisticUnitList.Page.ShowLogisticUnits(FillLogisticUnitList(), CurrPage.DocumentLines.Page.GetTotlaWeight(), CurrPage.DocumentLines.Page.GetVolume());
    end;

    local procedure BackOnSecondPage();
    begin
    end;

    local procedure NextFromSecondPage();
    begin

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

    /// <summary>
    /// Отбор паллет по какому то принципу для выбора (пока выбираются все подряд)
    /// </summary>
    /// <returns></returns>
    local procedure FillLogisticUnitList() Units: List of [Code[20]]
    var
        Unit: Record "TMAC Unit";
    begin
        Unit.Reset();

        case LogicticDirection of
            "TMAC Direction"::Outbound:
                Unit.Setrange("Outbound Logistics Enabled", true);
            "TMAC Direction"::Inbound:
                Unit.Setrange("Inbound Logistics Enabled", true);
        end;

        Unit.SetLoadFields("No.");
        if Unit.FindSet() then
            repeat
                Units.add(Unit."No.");
            until Unit.Next() = 0;

        Unit.Reset();
    end;

    internal procedure SetDocumentLinks(var SourceDocumentLink: Record "TMAC Source Document Link"; Direction1: enum "TMAC Direction")
    begin
        CurrPage.DocumentLines.PAGE.DeleteLines();
        if SourceDocumentLink.findset(false) then
            repeat
                CurrPage.DocumentLines.PAGE.AddLine(SourceDocumentLink);
            until SourceDocumentLink.next() = 0;
        LogicticDirection := Direction1;
    end;

    local procedure Load()
    var
        SourceDocumentLink: Record "TMAC Source Document Link";
    begin
        CurrPage.DocumentLines.Page.GetSelectedLines(SourceDocumentLink);
        SourceDocumentLink.SetFilter("Selected Quantity", '>0');

        CreatedUnitNo := CurrPage.LogisticUnitList.Page.GetSelected();

        if SourceDocumentLink.findset(false) then
            repeat
                SourceDocumentLink.Validate("Selected Quantity");
                UnitManagement.AddItemToLogisticUnit(CreatedUnitNo, SourceDocumentLink."Selected Quantity", SourceDocumentLink);
            until SourceDocumentLink.next() = 0;
    end;

    var
        MediaRepositoryStandard: Record "Media Repository";
        MediaRepositoryDone: Record "Media Repository";
        MediaResourcesStandard: Record "Media Resources";
        MediaResourcesDone: Record "Media Resources";
        LogisticUnitSetup: Record "TMAC Logistic Units Setup";
        UnitRemove: Record "TMAC Unit";

        UnitManagement: Codeunit "TMAC Unit Management";

        LogicticDirection: enum "TMAC Direction";
        CargoInformation: Text;
        Step: Option First,Second,Finish;

        TopBannerVisible: Boolean;
        FirstPageVisible: Boolean;
        SecondPageVisible: Boolean;
        FinalPageVisible: Boolean;

        FinishEnabled: Boolean;
        BackEnabled: Boolean;
        NextEnabled: Boolean;
        LoadButtonEnabled: Boolean;

        CreatedUnitNo: Code[20];
        CargoParametersLbl: Label 'Cargo parameters: ';
}
