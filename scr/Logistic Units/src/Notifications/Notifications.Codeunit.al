codeunit 71628599 "TMAC Notifications"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Conf./Personalization Mgt.", 'OnRoleCenterOpen', '', true, true)]
    local procedure OnRoleCenterOpen();
    var
        LogisticUnits: record "TMAC Logistic Units Setup";
        LogisticUnitsNotification: Notification;
    begin
        if LogisticUnits.WritePermission then
            if LogisticUnits.Get() then
                if not LogisticUnits."Assisted Setup Completed" then begin
                    LogisticUnitsNotification.Scope(NotificationScope::LocalScope);
                    LogisticUnitsNotification.Message(ExtensionInstalledMsg);
                    LogisticUnitsNotification.AddAction(OpenAssitedSetupTok, Codeunit::"TMAC Notifications", 'HandleAssistedSetup');
                    LogisticUnitsNotification.AddAction(DontShowAgainTok, Codeunit::"TMAC Notifications", 'DontShow');
                    if NotificationsExist then
                        LogisticUnitsNotification.Recall()
                    else
                        if LogisticUnitsNotification.Send() then
                            NotificationsExist := true;
                end;
    end;

    procedure HandleAssistedSetup(Notification: Notification)
    var
        AssistedSetup: Page "TMAC Assisted Setup";
    begin
        AssistedSetup.Run();
    end;

    procedure DontShow(Notification: Notification)
    var
        LogisticUnitsSetup: record "TMAC Logistic Units Setup";
    begin
        LogisticUnitsSetup.Validate("Assisted Setup Completed", true);
        LogisticUnitsSetup.Modify(true);
    end;


    var
        NotificationsExist: Boolean;
        OpenAssitedSetupTok: label 'Open';
        ExtensionInstalledMsg: Label 'Logistic Units Management extension is installed. Run the Assisted Setup. ';
        DontShowAgainTok: Label 'Don''t show me again.';
}