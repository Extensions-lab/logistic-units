
/// <summary>
/// Creating a logistic unit for the Unit Builder.
/// </summary>
page 71628623 "TMAC Logistic Unit Wizard"
{
    PageType = NavigatePage;
    Caption = 'Create Logistic Units Wizard';

    SourceTable = "TMAC Source Document Link";
    SourceTableView = sorting("Document Source Type", "Document Source SubType", "Document Source ID");
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
                Visible = TopBannerVisible and (FirstPageVisible);

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
                        InstructionalText = 'A logistic unit combines individual items or items in shipping containers into single "units" that can be transported together. ';
                    }
                    group(Separator)
                    {
                        Caption = '';
                        InstructionalText = '';
                    }

                    field(UnitTypeCode; UnitTypeCode)
                    {
                        Caption = 'Type';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the logistic unit type of the creating logistic unit.';
                        trigger OnLookup(var Text: Text): Boolean
                        var
                            UnitType: Record "TMAC Unit Type";
                        begin
                            IF Page.RunModal(0, UnitType) = Action::LookupOK then begin
                                UnitTypeCode := UnitType.Code;
                                UnitTypeDescription := UnitType.Description;
                            end;
                        end;
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

                    group(DoneMessage)
                    {
                        Caption = '';
                        InstructionalText = 'Units has been created. Click Finish to close wizard.';
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
        LoadTopBanners();
    end;

    trigger OnOpenPage();
    var
        LogisticUnitsSetup: Record "TMAC Logistic Units Setup";
        UnitType: Record "TMAC Unit Type";
    begin
        Step := Step::First;
        EnableControls();
        
        // Default logistic unit type
        LogisticUnitsSetup.Get();
        if LogisticUnitsSetup."Def. Unit Type" <> '' then
            if UnitType.Get(LogisticUnitsSetup."Def. Unit Type") then begin
                UnitTypeCode := UnitType.Code;
                UnitTypeDescription := UnitType.Description;
            end;
    end;

    local procedure EnableControls();
    begin
        ResetControls();
        case Step of
            Step::First:
                ShowFirstPage();
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

    local procedure ShowFinalPage();
    begin
        FinalPageVisible := true;
        BackEnabled := false;
        NextEnabled := false;
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
        FirstPageVisible := false;
        FinalPageVisible := false;
    end;

    local procedure CheckBack()
    begin
        case Step of
            Step::First:
                BackOnFirstPage();
            Step::Finish:
                BackOnFinalPage();
        END;
    end;

    local procedure CheckNext()
    begin
        case Step of
            Step::First:
                NextFromFirstPage();
            Step::Finish:
                NextFromFinalPage();
        END;
    end;

    local procedure BackOnFirstPage();
    begin
    end;

    local procedure NextFromFirstPage();
    begin
        CreatedUnitNo := UnitBuildManagement.BuildLogisticUnit(UnitTypeCode, Rec);
        if CreatedUnitNo <> '' then
            LogisticUnitCreated := true;
    end;

    local procedure BackOnFinalPage();
    begin

    end;

    local procedure NextFromFinalPage();
    begin

    end;


    internal procedure DeleteLines()
    begin
        Rec.Reset();
        Rec.DeleteAll();
    end;

    internal procedure AddLine(var SourceDocumentLink: Record "TMAC Source Document Link")
    begin
        Rec.Init();
        Rec.TransferFields(SourceDocumentLink);
        Rec.Insert(false);
    end;

    internal procedure GetCreatedUnitNo(): Code[20]
    begin
        exit(CreatedUnitNo);
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

    internal procedure LogisticUnitWasCreated(): Boolean
    begin
        exit(LogisticUnitCreated);
    end;

    var
        MediaRepositoryStandard: Record "Media Repository";
        MediaRepositoryDone: Record "Media Repository";
        MediaResourcesStandard: Record "Media Resources";
        MediaResourcesDone: Record "Media Resources";
        UnitBuildManagement: Codeunit "TMAC Unit Build Management";
        Step: Option First,Finish;
        CreatedUnitNo: Code[20];
        TopBannerVisible: Boolean;
        FirstPageVisible: Boolean;

        FinalPageVisible: Boolean;

        FinishEnabled: Boolean;
        BackEnabled: Boolean;
        NextEnabled: Boolean;

        UnitTypeCode: Code[20];
        UnitTypeDescription: Text[100];

        LogisticUnitCreated: Boolean;
}
