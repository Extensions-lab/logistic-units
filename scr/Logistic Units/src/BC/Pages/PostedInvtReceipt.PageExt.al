pageextension 71628612 "TMAC Posted Invt. Receipt" extends "Posted Invt. Receipt"
{
    layout
    {
        addbefore("Posting Description")
        {
            field("TMAC Customer No."; Rec."TMAC Customer No.")
            {
                ApplicationArea = all;
                ToolTip = 'Customer number';
            }
        }
        addbefore(Control1905767507)
        {
            part("TMAC Logistic Units FactBox"; "TMAC Unit List FactBox")
            {
                Caption = 'Logistic Units';
                ApplicationArea = all;
            }
        }
    }

    trigger OnOpenPage()
    begin
        CheckPermissions();
    end;

    trigger OnAfterGetRecord()
    begin
        SourceType := Database::"Invt. Receipt Line";
        SourceSubtype := 0;
        SourceID := Rec."No.";
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateLogisticUnitsSubform();
    end;

    local procedure UpdateLogisticUnitsSubform()
    begin
        CurrPage."TMAC Logistic Units FactBox".PAGE.SetSource(SourceType, SourceSubtype, SourceID, 'Inbound', 'Outbound');     
    end;

    #region Permission -эти функции нельзя переносить в какой-то кодеюнит. т.к. на енго может не быть прав
    internal procedure CheckPermissions()
    var
        Unit: Record "TMAC Unit"; //по доступу к логистической единицы определяем есть ли права
    begin
        //не назначены права
        if not Unit.ReadPermission then
            error(ExtensionInstalledErr);

        //лицензии нет, только в купе с permissoin set дает право менять
        if not Unit.WritePermission then
            PermissonNotificaton();
    end;

    local procedure PermissonNotificaton()
        LogisticUnitsExtensionNotification: Notification;
    begin
        LogisticUnitsExtensionNotification.Scope(NotificationScope::LocalScope);
        LogisticUnitsExtensionNotification.Message(ExtensionInstalledMsg);
        if NotificationsExist then
            LogisticUnitsExtensionNotification.Recall()
        else
            if LogisticUnitsExtensionNotification.Send() then
                NotificationsExist := true;
    end;
    #endregion

    var
        SourceType: Integer;
        SourceSubtype: Integer;
        SourceID: Code[20];


        NotificationsExist: Boolean;
        ExtensionInstalledMsg: Label 'Logistic Units: You have no license to manage Logistic Units. Contact your system administrator. ';
        ExtensionInstalledErr: Label 'Logistic Units: Each user must have "Logistic Units - User" permission set. Contact your system administrator. ';
}
