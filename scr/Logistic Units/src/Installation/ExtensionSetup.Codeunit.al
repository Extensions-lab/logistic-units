/// <summary>
/// Subscription to events and functions that help integrate the extension into BC
/// - integration with various BC modules
/// </summary>
codeunit 71628590 "TMAC Extension Setup"
{
    var
        ExtensionTitleTxt: Label 'Logistic Units';
        ExtensionDescriptionTxt: Label 'Set up the Logistic Units module';
        ExtensionShortTitleTxt: Label 'Logistic Units Setup';
        ExtensionSetupKeywordsTxt: Label 'Logistic Units, Transportation, TMS, WMS';


    [EventSubscriber(ObjectType::Codeunit, Codeunit::Video, 'OnRegisterVideo', '', false, false)]
    local procedure OnRegisterVideo(sender: Codeunit Video)
    begin
        Sender.Register(GetAppId(), AftershipSetupWizardTxt, AftershipVideoUrlTxt, "Video Category"::"TMAC Logistic Units");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterManualSetup', '', false, false)]
    local procedure OnRegisterManualSetup(var Sender: Codeunit "Guided Experience");
    var
        ManualSetupCategory: Enum "Manual Setup Category";
    begin
        Sender.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, PAGE::"TMAC Logistic Units Setup");
        Sender.InsertManualSetup(
          ExtensionTitleTxt, ExtensionShortTitleTxt, ExtensionDescriptionTxt, 0, ObjectType::Page,
          PAGE::"TMAC Logistic Units Setup", ManualSetupCategory::"TMAC Logistic Units", ExtensionSetupKeywordsTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterAssistedSetup', '', false, false)]
    local procedure AddAssistedSetupWizards()
    var
        GuidedExperience: Codeunit "Guided Experience";
        Language: Codeunit Language;
        VideoCategory: Enum "Video Category";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        GuidedExperienceType: Enum "Guided Experience Type";
        CurrentGlobalLanguage: Integer;
    begin
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, PAGE::"TMAC Assisted Setup");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, PAGE::"TMAC Aftership Setup Wizard");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, PAGE::"TMAC Trackingmore Setup Wizard");

        CurrentGlobalLanguage := GLOBALLANGUAGE();

        //Assisted Setup
        GuidedExperience.InsertAssistedSetup(
            SetupWizardTxt,
            CopyStr(SetupWizardTxt, 1, 50),
            SetupDescriptionTxt, 0,
            ObjectType::Page, PAGE::"TMAC Assisted Setup",
            AssistedSetupGroup::"TMAC Logistic Units", '',
            VideoCategory::"TMAC Logistic Units",
            ExtensionHelpLinkTxt);

        GLOBALLANGUAGE(Language.GetDefaultApplicationLanguageId());
        GuidedExperience.AddTranslationForSetupObjectTitle(GuidedExperienceType::"Assisted Setup", ObjectType::Page,
            PAGE::"TMAC Assisted Setup", Language.GetDefaultApplicationLanguageId(), SetupWizardTxt);
        GLOBALLANGUAGE(CurrentGlobalLanguage);

        //After ship
        GuidedExperience.InsertAssistedSetup(
            AftershipSetupWizardTxt,
            CopyStr(AftershipSetupWizardTxt, 1, 50),
            AftershipSetupDescriptionTxt, 0,
            ObjectType::Page, PAGE::"TMAC Aftership Setup Wizard",
            AssistedSetupGroup::"TMAC Logistic Units", AftershipVideoUrlTxt,
            VideoCategory::"TMAC Logistic Units",
            ExtensionHelpLinkTxt);

        GLOBALLANGUAGE(Language.GetDefaultApplicationLanguageId());
        GuidedExperience.AddTranslationForSetupObjectTitle(GuidedExperienceType::"Assisted Setup", ObjectType::Page,
          PAGE::"TMAC Aftership Setup Wizard", Language.GetDefaultApplicationLanguageId(), AftershipSetupWizardTxt);
        GLOBALLANGUAGE(CurrentGlobalLanguage);

        //Trackingmore
        GuidedExperience.InsertAssistedSetup(
            TrackingmoreSetupWizardTxt,
            CopyStr(TrackingmoreSetupWizardTxt, 1, 50),
            TrackingmoreSetupDescriptionTxt, 0,
            ObjectType::Page, PAGE::"TMAC Trackingmore Setup Wizard",
            AssistedSetupGroup::"TMAC Logistic Units", '',
            VideoCategory::"TMAC Logistic Units",
            ExtensionHelpLinkTxt);

        GLOBALLANGUAGE(Language.GetDefaultApplicationLanguageId());
        GuidedExperience.AddTranslationForSetupObjectTitle(GuidedExperienceType::"Assisted Setup", ObjectType::Page,
            PAGE::"TMAC Trackingmore Setup Wizard", Language.GetDefaultApplicationLanguageId(), TrackingmoreSetupWizardTxt);
        GLOBALLANGUAGE(CurrentGlobalLanguage);

        GetInformationSetupStatus();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnReRunOfCompletedAssistedSetup', '', false, false)]
    local procedure OnReRunOfCompletedAssistedSetup(ExtensionID: Guid; ObjectType: ObjectType; ObjectID: Integer; var Handled: Boolean);
    begin
        if ExtensionId <> GetAppId() then
            exit;
        case ObjectID of
            Page::"TMAC Assisted Setup":
                begin
                    Page.Run(Page::"TMAC Assisted Setup");
                    Handled := true;
                end;
            Page::"TMAC Aftership Setup Wizard":
                begin
                    Page.Run(Page::"TMAC Aftership Setup Wizard");
                    Handled := true;
                end;
            Page::"TMAC Trackingmore Setup Wizard":
                begin
                    Page.Run(Page::"TMAC Trackingmore Setup Wizard");
                    Handled := true;
                end;
        end;
    end;

    local procedure GetInformationSetupStatus()
    var
        TrackingSetup: Record "TMAC Tracking Setup";
        LogisticUnitsSetup: Record "TMAC Logistic Units Setup";
        GuidedExperience: Codeunit "Guided Experience";
    begin
        IF LogisticUnitsSetup.Get() then
            if LogisticUnitsSetup."Assisted Setup Completed" then
                GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"TMAC Assisted Setup");
        if TrackingSetup.Get() then begin
            if TrackingSetup."Aftership Setup Completed" then
                GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"TMAC Aftership Setup Wizard");
            if TrackingSetup."Trackingmore Setup Completed" then
                GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"TMAC Trackingmore Setup Wizard");
        end;
    end;

    local procedure GetAppId(): Guid
    var
        Info: ModuleInfo;
        EmptyGuid: Guid;
    begin
        if Info.Id() = EmptyGuid then
            NavApp.GetCurrentModuleInfo(Info);
        exit(Info.Id());
    end;

    var
        SetupWizardTxt: Label 'Setup Logistic Units Module';
        SetupDescriptionTxt: Label 'Provide basic settings of the Logistic Units Extension';
        ExtensionHelpLinkTxt: Label 'https://www.extensionsforce.com/logisticunits-help', Locked = true;


        AftershipSetupWizardTxt: Label 'Setup Aftership.com Integration';
        AftershipSetupDescriptionTxt: Label 'Aftership multi-courier tracking integration Setup';
        AftershipVideoUrlTxt: Label 'https://www.youtube.com/embed/KCjdBa8ySrU', Locked = true;

        TrackingmoreSetupWizardTxt: Label 'Setup Trackingmore.com Integration';
        TrackingmoreSetupDescriptionTxt: Label 'Trackingmore.com multi-courier tracking integration Setup';
}
