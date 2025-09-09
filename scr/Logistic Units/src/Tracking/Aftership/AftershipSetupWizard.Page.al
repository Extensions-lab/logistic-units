
page 71628650 "TMAC Aftership Setup Wizard"
{
    Caption = 'Aftership.com Integration';
    UsageCategory = Administration;

    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = NavigatePage;
    ShowFilter = false;

    SourceTable = "TMAC Tracking Setup";

    layout
    {
        area(content)
        {
            group(BannerStandard)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible and (SecondPageVisible or ThirdPageVisible or FourthPageVisible);

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

                field(Image1; Rec."Aftership Picture")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Image';
                    Editable = false;
                    ShowCaption = false;
                }

                group(Page1Group)
                {
                    Caption = 'Welcome to Aftership.com Integration Setup';
                    field(MainText; FirstPageTextLbl)
                    {
                        ApplicationArea = all;
                        MultiLine = true;
                        ShowCaption = false;
                    }
                }
                group(Page1Group2)
                {
                    ShowCaption = false;
                    field(AdditionalText; FirstPageText2Lbl)
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

                group(current)
                {
                    Caption = 'Steps';

                    field(SecondPageTextLbl; SecondPageTextLbl)
                    {
                        ApplicationArea = all;
                        MultiLine = true;
                        ShowCaption = false;
                    }

                    field(SecondPageURL1; SecondPageURL1Tok)
                    {
                        Caption = 'Register';
                        ApplicationArea = all;
                        ExtendedDatatype = URL;
                        Editable = false;
                        ToolTip = 'URL link to Aftership.com site.';
                    }
                    field(SecondPageDetailTextLbl; SecondPageDetailTextLbl)
                    {
                        ApplicationArea = all;
                        MultiLine = true;
                        ShowCaption = false;
                    }
                    field(SecondPageURL2; SecondPageURL2Tok)
                    {
                        Caption = 'Get API Key';
                        ApplicationArea = all;
                        ExtendedDatatype = URL;
                        Editable = false;
                        ToolTip = 'URL link to Aftership.com site.';
                    }
                }
            }

            group(ThirdPage)
            {
                Caption = '';
                Visible = ThirdPageVisible;

                group(thirdsubgroup)
                {
                    Caption = 'Enter';

                    field("AfterShip API Key"; rec."AfterShip API Key")
                    {
                        Caption = 'API Key';
                        ApplicationArea = all;
                        ToolTip = 'Specifies API Key to access Aftership.com services.';
                        ShowMandatory = true;
                    }
                    field(ThirdPageInfoTextLbl; ThirdPageInfoTextLbl)
                    {
                        ApplicationArea = all;
                        MultiLine = true;
                        ShowCaption = false;
                    }
                    field(ChangeDefaultSettings; ChangeDefaultSettings)
                    {
                        Caption = 'Change Default Settings';
                        ToolTip = 'Specified the needs to change default settings. It''s no nessisary by default';
                        ApplicationArea = all;
                    }

                    field("AfterShip All Courier URL"; rec."AfterShip All Courier URL")
                    {
                        Caption = 'Link to all couriers';
                        ApplicationArea = all;
                        ToolTip = 'URL to API Service';
                        Editable = ChangeDefaultSettings;
                    }

                    field("Aftership Active Couriers URL"; rec."Aftership Active Couriers URL")
                    {
                        Caption = 'Link to active couriers';
                        ApplicationArea = all;
                        ToolTip = 'URL to API Service';
                        Editable = ChangeDefaultSettings;
                    }
                    field("AfterShip GetTracking URL"; rec."AfterShip GetTracking URL")
                    {
                        Caption = 'GetTracking URL';
                        ApplicationArea = all;
                        ToolTip = 'URL to API Service';
                        Editable = ChangeDefaultSettings;
                    }
                }
            }
            group(FourthPage)
            {
                Caption = '';
                Visible = FourthPageVisible;

                group(fourthsubgroup)
                {
                    Caption = 'Loaded data ...';
                    field(AllCouriers; AllCouriers)
                    {
                        Caption = 'Total available couriers';
                        ApplicationArea = all;
                        ToolTip = 'Total quantity of the couriers in Aftership.com service.';
                        Editable = false;
                        trigger OnDrillDown()
                        var
                            AftershipCourier: Record "TMAC Aftership Courier";
                        begin
                            AftershipCourier.Reset();
                            Page.RunModal(0, AftershipCourier);
                        end;
                    }

                    field(ActivatedCouriers; ActivatedCouriers)
                    {
                        Caption = 'Activated couriers';
                        ApplicationArea = all;
                        ToolTip = 'Total quantity of ther couriers in Aftership.com service.';
                        Editable = false;
                        trigger OnDrillDown()
                        var
                            AftershipCourier: Record "TMAC Aftership Courier";
                        begin
                            AftershipCourier.Reset();
                            AftershipCourier.SetRange(Activated, true);
                            Page.RunModal(0, AftershipCourier);
                        end;
                    }
                    field(ActivatedCouriersLink; ActivatedCouriersLinkTok)
                    {
                        Caption = 'Activate couriers';
                        ApplicationArea = all;
                        ExtendedDatatype = URL;
                        Editable = false;
                        ToolTip = 'Activate another couriers on Aftership.com site.';
                    }
                }
            }
            group(FinalPage)
            {
                Caption = '';
                Visible = FinalPageVisible;

                group("Done")
                {
                    Caption = 'Done!';
                    Visible = FinalPageVisible;


                    field(FinalText; SetupProcessResultLbl)
                    {
                        ApplicationArea = all;
                        MultiLine = true;
                        ShowCaption = false;
                        Editable = false;
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
    begin
        Step := Step::First;
        EnableControls();
        IF not Rec.Get() then begin
            Rec.Init();
            Rec.Insert(true);
        end;
    end;

    local procedure GotoStep(NewStep: Integer)
    begin
        Step := NewStep;
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
            Step::Third:
                ShowThirdPage();
            Step::Fourth:
                ShowFourthPage();
            Step::Finish:
                ShowFinalPage();
        END;
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
    end;

    local procedure ShowThirdPage();
    begin
        ThirdPageVisible := true;
        BackEnabled := true;
        NextEnabled := true;
        FinishEnabled := true;
    end;

    local procedure ShowFourthPage();
    begin
        FourthPageVisible := true;
        BackEnabled := true;
        NextEnabled := true;
        FinishEnabled := true;
    end;

    local procedure ShowFinalPage();
    begin
        FinalPageVisible := true;
        BackEnabled := true;
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
        SecondPageVisible := false;
        ThirdPageVisible := false;
        FourthPageVisible := false;
        FinalPageVisible := false;
    end;

    local procedure CheckBack()
    begin
        case Step of
            Step::Second:
                SecondPageBack();
            Step::Third:
                ThirdPageBack();
            Step::Fourth:
                FourthPageBack();
            Step::Finish:
                FinalPageBack();
        END;
    end;

    local procedure CheckNext()
    begin
        case Step of
            Step::First:
                FirstPageNext();
            Step::Second:
                SecondPageNext();
            Step::Third:
                ThirdPageNext();
            Step::Fourth:
                FourthPageNext();
            Step::Finish:
                FinalPageNext();
        END;
    end;

    local procedure FirstPageNext();
    begin
        Step := Step::Second;
        EnableControls();
    end;

    local procedure SecondPageNext();
    begin
        GotoStep(Step::Third);
    end;

    local procedure SecondPageBack()
    begin
        GotoStep(Step::First);
    end;

    local procedure ThirdPageNext()
    var
        AftershipCourier: Record "TMAC Aftership Courier";
        AfterShipAPI: Codeunit "TMAC AfterShip API";
    begin
        if Rec."AfterShip API Key" = '' then
            Error(DefineAPIKeyErr);

        if AfterShipAPI.GetAllCouriers() <> 0 then
            Message(AfterShipAPI.GetLastError())
        else
            if AfterShipAPI.GetActiveCouriers() <> 0 then
                Message(AfterShipAPI.GetLastError())
            else begin
                AftershipCourier.Reset();
                AftershipCourier.SetRange(Activated, true);
                ActivatedCouriers := AftershipCourier.Count();
                AftershipCourier.SetRange(Activated);
                AllCouriers := AftershipCourier.Count();
                Rec."Aftership Setup Completed" := true;
                Rec.Modify(true);
                GotoStep(Step::Fourth);
            end;
    end;

    local procedure ThirdPageBack()
    begin
        GotoStep(Step::Second);
    end;

    local procedure FourthPageNext()
    begin
        GotoStep(Step::Finish);
    end;

    local procedure FourthPageBack()
    begin
        GotoStep(Step::Third);
    end;

    local procedure FinalPageNext()
    begin
    end;

    local procedure FinalPageBack()
    begin
        GotoStep(Step::Fourth);
    end;


    local procedure LoadTopBanners()
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
        MediaRepositoryStandard: Record "Media Repository";
        MediaRepositoryDone: Record "Media Repository";
        MediaResourcesStandard: Record "Media Resources";
        MediaResourcesDone: Record "Media Resources";

        Step: Option First,Second,Third,Fourth,Finish;

        TopBannerVisible: Boolean;
        FirstPageVisible: Boolean;
        SecondPageVisible: Boolean;
        ThirdPageVisible: Boolean;
        FourthPageVisible: Boolean;
        FinalPageVisible: Boolean;

        FinishEnabled: Boolean;
        BackEnabled: Boolean;
        NextEnabled: Boolean;
        AllCouriers: Integer;
        ActivatedCouriers: Integer;
        ChangeDefaultSettings: Boolean;
        SetupProcessResultLbl: Label 'Completed';

        FirstPageTextLbl: Label 'AfterShip''s global shipping API, allows companies to scale and adapt to an ongoing and post retail environment. The multi-carrier tracking solution. Afteship support more 700 carriers worldwide.', Comment = '%1 nothing';
        FirstPageText2Lbl: label 'AfterShip.com is a paid external service.';
        SecondPageTextLbl: Label 'To set up the integration, you need to register at Aftership.com';
        SecondPageDetailTextLbl: Label 'and receive the API key.';
        SecondPageURL1Tok: Label 'https://www.aftership.com/', Locked = true;
        SecondPageURL2Tok: Label 'https://admin.aftership.com/settings/api-keys', Locked = true;
        ActivatedCouriersLinkTok: Label 'https://admin.aftership.com/settings/couriers?page=1&tab=enabled', Locked = true;
        ThirdPageInfoTextLbl: Label 'Default API Settings';
        DefineAPIKeyErr: Label 'Define AfterShip API Key.';


}
