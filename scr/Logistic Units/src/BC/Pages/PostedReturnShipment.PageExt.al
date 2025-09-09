pageextension 71628587 "TMAC Posted Return Shipment" extends "Posted Return Shipment"
{
    layout
    {
        addbefore(Control1900383207)
        {
            part("TMAC Logistic Units FactBox"; "TMAC Unit List FactBox")
            {
                Caption = 'Logistic Units';
                ApplicationArea = all;
            }
        }
    }
    actions
    {
        addafter(Category_Report)
        {
            group("TMAC Logistic Units Promoted")
            {
                Caption = 'Logistic Units';
                ToolTip = 'Logistic Units is a module that enables users to manage and track inventory and shipments, generate reports/alerts, and customize their inventory/shipment tracking. It provides an intuitive interface and comprehensive overview of the supply chain, allowing users to make informed decisions and optimize operations.';


                actionref("TMAC Logistic Units New Promoted"; "TMAC New Logistics Units")
                {
                }
                actionref("TMAC Logistic Units Add Promoted"; "TMAC Add To Logistic Unit")
                {
                }
                actionref("TMAC Logistic Units List Promoted"; "TMAC Logisitc Units List")
                {
                }
                actionref("TMAC Print SSCC Promoted"; "TMAC Print")
                {
                }
            }
        }

        addbefore("&Print")
        {
            group("TMAC Logistic Units")
            {
                Caption = 'Logistic Units';
                ToolTip = 'Logistics Units is a module that enables users to manage and track inventory and shipments, generate reports/alerts, and customize their inventory/shipment tracking. It provides an intuitive interface and comprehensive overview of the supply chain, allowing users to make informed decisions and optimize operations.';


                action("TMAC New Logistics Units")
                {
                    Caption = 'New Logistic Units';
                    Image = Item;
                    ApplicationArea = All;
                    ToolTip = 'Create a new logistic unit (box, pallet, container) and add the selected lines from this order.  Lines can be selected in the Lines section using the Ctrl or Shift keys. To automatically enter the selected quantity using the value from the “Quantity” field, activate the “Set Default Selected Quantity” setting in the Logistic Unit Setup. To ignore empty (or distributed) lines without a selected quantity, use the setting "Exclude Lines w/o Def. Qty.".';
                    AccessByPermission = tabledata "TMAC Unit" = I;

                    trigger OnAction()
                    begin
                        GetSelectedLineLinks();
                        UnitLinkManagement.CreateNewLogisticUnits(SourceDocumentLink, "TMAC Direction"::Outbound);
                        UpdateLogisticUnitsSubform();
                    end;
                }

                action("TMAC Add To Logistic Unit")
                {
                    Caption = 'Add To Logistics Unit';
                    Image = ItemGroup;
                    ApplicationArea = All;
                    ToolTip = 'Place the selected lines from this order into an existing logistics unit (box, pallet, container, logistics unit compartment). Lines can be selected in the Lines section using the Ctrl or Shift keys. To automatically enter the selected quantity using the value from the "Quantity” field, activate the “Set Default Selected Quantity” setting in the Logistic Unit Setup. To ignore empty (or distributed) lines without a selected quantity, use the setting "Exclude Lines w/o Def. Qty.".';
                    AccessByPermission = tabledata "TMAC Unit" = I;

                    trigger OnAction()
                    begin
                        GetSelectedLineLinks();
                        UnitLinkManagement.AddToLogisticUnit(SourceDocumentLink, "TMAC Direction"::Outbound);
                        CurrPage.Update();
                        UpdateLogisticUnitsSubform();
                    end;
                }

                action("TMAC Logisitc Units List")
                {
                    Caption = 'Loading Information';
                    Image = ItemLines;
                    ApplicationArea = All;
                    ToolTip = 'Show the linked logistic units.';
                    Enabled = IsLogiticUnits;

                    trigger OnAction()
                    var
                        UnitLinkManagemenent: Codeunit "TMAC Unit Link Management";
                        UnitsLoadDetails: Page "TMAC Unit Load Details";
                        Units: List of [Code[20]];
                    begin
                        Units := UnitLinkManagemenent.GetUnitsListByDocument(SourceType, SourceSubtype, SourceID, 0);
                        UnitsLoadDetails.SetUnits(Units);
                        UnitsLoadDetails.Run();
                    end;
                }

                action("TMAC Print")
                {
                    Caption = 'Print';
                    Image = Print;
                    ApplicationArea = All;
                    ToolTip = 'This function will generate and print SSCC (Serial Shipping Container Code) labels that can be used to track logistic units. They contain important information such as the origin, destination, and contents of the shipment. This function will ensure that all logistic units have the correct labels printed, making it easier to track shipments.';
                    AccessByPermission = tabledata "TMAC Unit" = I;

                    trigger OnAction()
                    var
                        SSCCManagement: Codeunit "TMAC SSCC Management";
                    begin
                        SSCCManagement.PrintSSCCByDocument(SourceType, SourceSubtype, SourceID, 0);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        CheckPermissions();
    end;

    trigger OnAfterGetRecord()
    begin
        SourceType := Database::"Return Shipment Line";
        SourceSubtype := 0;
        SourceID := Rec."No.";
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateLogisticUnitsSubform();
    end;

    local procedure UpdateLogisticUnitsSubform()
    var
        NoOfLogisticUnit: Integer;
    begin
        NoOfLogisticUnit := CurrPage."TMAC Logistic Units Factbox".PAGE.SetSource(SourceType, SourceSubtype, SourceID, 'Inbound', 'Outbound');
        IsLogiticUnits := NoOfLogisticUnit <> 0;
    end;

    internal procedure CheckPermissions()
    var
        Unit: Record "TMAC Unit";
    begin
        if not Unit.ReadPermission then
            error(ExtensionInstalledErr);

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
    
    local procedure GetSelectedLineLinks()
    begin
        SourceDocumentLink.Reset();
        SourceDocumentLink.DeleteAll(false);
        CurrPage.ReturnShptLines.Page.GetSelectedLineLinks(SourceDocumentLink);
    end;

    var
        SourceDocumentLink: Record "TMAC Source Document Link";

        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
        IsLogiticUnits: Boolean;

        SourceType: Integer;
        SourceSubtype: Integer;
        SourceID: Code[20];

        NotificationsExist: Boolean;
        ExtensionInstalledMsg: Label 'Logistic Units: You have no license to manage Logistic Units. Contact your system administrator. ';
        ExtensionInstalledErr: Label 'Logistic Units: Each user must have "Logistic Units - User" permission set. Contact your system administrator. ';

}
