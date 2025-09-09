
page 71628660 "TMAC Trackingmore Setup Wizard"
{
    Caption = 'Trackingmore Integration';
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
                Visible = TopBannerVisible and (SecondPageVisible or ThirdPageVisible or FourthPageVisible or FifthPageVisible);

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

                field(Image1; Rec."Trackingmore Picture")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Image';
                    Editable = false;
                    ShowCaption = false;
                }

                group(Page1Group)
                {
                    Caption = 'Welcome to Trackingmore.com Integration Setup';
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
                        ToolTip = 'URL link to trackingmore.com site.';
                    }
                    field(SecondPageDetailTextLbl; SecondPageDetailTextLbl)
                    {
                        ApplicationArea = all;
                        MultiLine = true;
                        ShowCaption = false;
                    }
                    field(SecondPageURL2; SecondPageURL2Tok)
                    {
                        Caption = 'Generate API Key';
                        ApplicationArea = all;
                        ExtendedDatatype = URL;
                        Editable = false;
                        ToolTip = 'URL link to trackingmore.com site.';
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

                    field("Trackingmore API Key"; rec."Trackingmore API Key")
                    {
                        Caption = 'API Key';
                        ApplicationArea = all;
                        ToolTip = 'Specifies API Key to access trackingmore.com services.';
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

                    field("Trackingmore All Courier URL"; rec."Trackingmore All Courier URL")
                    {
                        Caption = 'API to receive all couriers';
                        ApplicationArea = all;
                        ToolTip = 'URL to API Service';
                        Editable = ChangeDefaultSettings;
                    }

                    field("Trackingmore AirCargo URL"; rec."Trackingmore AirCargo URL")
                    {
                        Caption = 'API to air cargo';
                        ApplicationArea = all;
                        ToolTip = 'URL to API Service';
                        Editable = ChangeDefaultSettings;
                    }
                    field("Trackingmore Ger User Info URL"; rec."Trackingmore Ger User Info URL")
                    {
                        Caption = 'API to user info';
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
                    Caption = 'Trackingmore user information';

                    field("email"; email)
                    {
                        Caption = 'Email';
                        ApplicationArea = all;
                        ToolTip = 'URL to API Service';
                        Editable = ChangeDefaultSettings;
                    }

                    field(phone; phone)
                    {
                        Caption = 'Phone';
                        ApplicationArea = all;
                        ToolTip = 'Phone number';
                        Editable = ChangeDefaultSettings;
                    }

                    field(money; money)
                    {
                        Caption = 'Money';
                        ApplicationArea = all;
                        ToolTip = 'Money';
                        Editable = ChangeDefaultSettings;
                    }
                }
            }

            group(FifthPage)
            {
                Caption = '';
                Visible = FifthPageVisible;

                group(fifthsubgroup)
                {
                    Caption = 'Loaded data ...';
                    field(AllCouriers; AllCouriers)
                    {
                        Caption = 'Carriers';
                        ApplicationArea = all;
                        ToolTip = 'Total quantity of the couriers in Trackigmore.com service.';
                        Editable = false;
                        trigger OnDrillDown()
                        var
                            TrackingmoreCarrier: Record "TMAC Trackingmore Carrier";
                        begin
                            TrackingmoreCarrier.Reset();
                            Page.RunModal(0, TrackingmoreCarrier);
                        end;
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

    trigger OnClosePage()
    begin

    end;

    trigger OnAfterGetRecord()
    begin

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
            Step::Fifth:
                ShowFifthPage();
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

    local procedure ShowFifthPage();
    begin
        FifthPageVisible := true;
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
        FifthPageVisible := false;
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
            Step::Fifth:
                FifthPageBack();
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
            Step::Fifth:
                FifthPageNext();
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
        if Rec."Trackingmore All Courier URL" = '' then
            Rec."Trackingmore All Courier URL" := 'https://api.trackingmore.com/v2/carriers/';

        if Rec."Trackingmore AirCargo URL" = '' then
            Rec."Trackingmore AirCargo URL" := 'https://api.trackingmore.com/v2/trackings/aircargo';

        if Rec."Trackingmore Ger User Info URL" = '' then
            Rec."Trackingmore Ger User Info URL" := 'https://api.trackingmore.com/v2/trackings/getuserinfo';

        if Rec."Trackingmore Create Tracking" = '' then
            Rec."Trackingmore Create Tracking" := 'https://api.trackingmore.com/v2/trackings/post';

        if Rec."Trackingmore Delete Tracking" = '' then
            Rec."Trackingmore Delete Tracking" := 'https://api.trackingmore.com/v2/trackings';

        CurrPage.SaveRecord();

        GotoStep(Step::Third);
    end;

    local procedure SecondPageBack()
    begin
        GotoStep(Step::First);
    end;

    local procedure ThirdPageNext()
    var
        TrackingmoreAPI: Codeunit "TMAC Trackingmore API";
    begin
        if Rec."Trackingmore API Key" = '' then
            Error(DefineAPIKeyErr);

        if TrackingmoreAPI.GetUserInfo(Email, Phone, Money) <> 0 then
            Message(TrackingmoreAPI.GetLastError())
        else
            GotoStep(Step::Fourth);
    end;

    local procedure ThirdPageBack()
    begin
        GotoStep(Step::Second);
    end;

    local procedure FourthPageNext()
    var
        TrackingmoreCarrier: Record "TMAC Trackingmore Carrier";
        TrackingmoreAPI: Codeunit "TMAC Trackingmore API";
    begin
        if Rec."Trackingmore API Key" = '' then
            Error(DefineAPIKeyErr);

        if TrackingmoreAPI.GetAllCouriers() <> 0 then
            Message(TrackingmoreAPI.GetLastError())
        else begin
            AllCouriers := TrackingmoreCarrier.Count();
            Rec."Trackingmore Setup Completed" := true;
            Rec.Modify(true);
            GotoStep(Step::Fifth);
        end;
    end;

    local procedure FourthPageBack()
    begin
        GotoStep(Step::Third);
    end;

    local procedure FifthPageNext()
    begin
        GotoStep(Step::Finish);
    end;

    local procedure FifthPageBack()
    begin
        GotoStep(Step::Fourth);
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

        Step: Option First,Second,Third,Fourth,Fifth,Finish;

        TopBannerVisible: Boolean;
        FirstPageVisible: Boolean;
        SecondPageVisible: Boolean;
        ThirdPageVisible: Boolean;
        FourthPageVisible: Boolean;
        FifthPageVisible: Boolean;
        FinalPageVisible: Boolean;

        FinishEnabled: Boolean;
        BackEnabled: Boolean;
        NextEnabled: Boolean;
        AllCouriers: Integer;
        ChangeDefaultSettings: Boolean;
        SetupProcessResultLbl: Label 'Completed';
        Email: Text;
        Phone: Text;
        Money: text;

        FirstPageTextLbl: Label 'The World Leading E-commerce Tracking Solution. Support tracking > 700 carriers worldwide. Air cargo tracking.';
        FirstPageText2Lbl: label 'Trackingmore is a paid external service.';
        SecondPageTextLbl: Label 'To set up the integration, you need to register at Trackingmore.com';
        SecondPageDetailTextLbl: Label 'and generate and copy a API key.';
        SecondPageURL1Tok: Label 'https://www.trackingmore.com/', Locked = true;
        SecondPageURL2Tok: Label 'https://my.trackingmore.com/get_apikey.php?lang=en', Locked = true;

        ThirdPageInfoTextLbl: Label 'Default API Settings';
        DefineAPIKeyErr: Label 'Define Trackingmore API Key.';


}
