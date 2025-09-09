page 71628625 "TMAC Assisted Setup"
{
    Caption = 'Assisted Setup';
    UsageCategory = Administration;

    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = NavigatePage;
    ShowFilter = false;

    SourceTable = "TMAC Logistic Units Setup";

    layout
    {
        area(content)
        {
            group(BannerStandard)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible and (SecondPageVisible or ThirdPageVisible);

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
                group(Page1Group)
                {
                    Caption = 'Welcome to Logistics Units System';
                    field(MainText; MainTextLbl)
                    {
                        ApplicationArea = all;
                        MultiLine = true;
                        ShowCaption = false;
                    }
                }
            }
            group(SecondPage)
            {
                Caption = '';
                Visible = SecondPageVisible;
                group(Select)
                {
                    Caption = 'Select Base Units of Measure';
                    group(Description21)
                    {
                        Caption = '';
                        InstructionalText = 'The values of the other units of measure will be converted into the base unit of measure.';
                    }
                    field("Base Weight Unit of Measure"; Rec."Base Weight Unit of Measure")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Base Volume Unit of Measure"; Rec."Base Volume Unit of Measure")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Base Linear Unit of Measure"; Rec."Base Linear Unit of Measure")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Base Distance Unit of Measure"; Rec."Base Distance Unit of Measure")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
            }
            group(ThirdPage)
            {
                Caption = '';
                Visible = ThirdPageVisible;

                group("SSCC")
                {
                    Caption = 'SSCC';
                    InstructionalText = 'The Serial Shipping Container Code can be used by companies to identify a logistic unit, which can be any combination of trade items packaged together for storage and/or transport purposes; for example a case, pallet or parcel.';
                    group(DescriptionStep1)
                    {
                        Caption = '';
                        InstructionalText = 'The Global Company Prefix (GCP) is a unique, globally recognized identification number assigned to each company by GS1. It is used to identify and track products, services, and locations through the GS1 System of Standards.';
                        field("Global Company Prefix"; Rec."Global Company Prefix")
                        {
                            ApplicationArea = Basic, Suite;
                        }
                    }
                    group(SSCCSerialReference)
                    {
                        ShowCaption = false;
                        InstructionalText = 'The serial reference component of the SSCC provides virtually unlimited number capacity, simplifying number allocation and guaranteeing unique identification.';
                        field("SSCC Nos."; Rec."SSCC Nos.")
                        {
                            ApplicationArea = Basic, Suite;
                        }
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
                        InstructionalText = 'The initial setup has been completed. Click "Open" for manual configuration or "Finish" to close the wizard.';
                        Visible = FinalPageVisible;
                    }
                    group(ReminderMessage)
                    {
                        Caption = '';
                        InstructionalText = 'Don''t forget to assign a user with Logistic Units permissions to work!';
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
            action(ActionOpen)
            {
                ApplicationArea = All;
                Caption = 'Open';
                Enabled = OpenEnabled;
                Visible = OpenEnabled;
                Image = Open;
                InFooterBar = true;
                ToolTip = 'Open the manual setup.';

                trigger OnAction();
                begin
                    Page.Run(Page::"TMAC Logistic Units Setup");
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
        Defaults: Codeunit "TMAC Defaults";
    begin
        Step := Step::First;

        EnableControls();

        if not LogisticUnitsSetup.Get() then begin
            Defaults.Setup();
            LogisticUnitsSetup.Get();
        end;
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
        OpenEnabled := false;
    end;

    local procedure ShowSecondPage();
    begin
        SecondPageVisible := true;
        BackEnabled := true;
        NextEnabled := true;
        OpenEnabled := false;
    end;

    local procedure ShowThirdPage();
    begin
        ThirdPageVisible := true;
        BackEnabled := true;
        NextEnabled := true;
        OpenEnabled := false;
    end;

    local procedure ShowFinalPage();
    begin
        FinalPageVisible := true;
        BackEnabled := false;
        NextEnabled := false;
        OpenEnabled := true;
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
        SecondPageVisible := false;
        ThirdPageVisible := false;
        FinalPageVisible := false;
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

    end;

    local procedure BackOnSecondPage();
    begin

    end;

    local procedure NextFromSecondPage();
    begin
    end;

    local procedure BackOnThirdPage();
    begin

    end;

    local procedure NextFromThirdPage();
    begin
        Rec."Assisted Setup Completed" := true;
        Rec.Modify(true);
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

    var
        LogisticUnitsSetup: Record "TMAC Logistic Units Setup";
        MediaRepositoryStandard: Record "Media Repository";
        MediaRepositoryDone: Record "Media Repository";
        MediaResourcesStandard: Record "Media Resources";
        MediaResourcesDone: Record "Media Resources";

        Step: Option First,Second,Third,Finish;

        TopBannerVisible: Boolean;
        FirstPageVisible: Boolean;
        SecondPageVisible: Boolean;
        ThirdPageVisible: Boolean;

        FinalPageVisible: Boolean;
        OpenEnabled: Boolean;
        FinishEnabled: Boolean;
        BackEnabled: Boolean;
        NextEnabled: Boolean;

        MainTextLbl: Label 'Logistics Units Module provides a powerful tool to manage the supply chain and ensure that your goods are transported and stored safely and efficiently. The module makes it easy to track and manage single boxes, pallets, and intermodal containers containing multiple products. With this comprehensive solution, you can ensure the seamless and cost-effective transportation of goods from origin to destination.';
}