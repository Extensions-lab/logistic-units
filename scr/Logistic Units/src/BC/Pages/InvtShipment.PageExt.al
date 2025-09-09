pageextension 71628613 "TMAC Invt. Shipment" extends "Invt. Shipment"
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
                AccessByPermission = tabledata "TMAC Unit" = r;
                Caption = 'Logistic Units';
                ApplicationArea = all;
            }
        }
    }
    actions
    {

        addafter(Category_Report)
        {
            group("TMAC Category LU Promoted")
            {
                Caption = 'Logistic Units';
                ToolTip = 'Manage Logistics Units';

                group("TMAC Add logistic Units")
                {
                    ShowAs = SplitButton;
                    actionref("TMAC Logistic Units New Promoted"; "TMAC New Logistics Units")
                    {
                    }
                }
                actionref("TMAC Logistic Units Add Promoted"; "TMAC Add To Logistic Unit")
                {
                }

                group("TMAC Include logistic Units")
                {
                    ShowAs = SplitButton;
                    actionref("TMAC Logistic Units Include Promoted"; "TMAC Include Logistics Units")
                    {
                    }
                }

                actionref("TMAC Logistic Units List Promoted"; "TMAC Logistic Units List")
                {
                }
            }
        }

        addbefore("F&unctions")
        {
            group("TMAC Logistic Units")
            {
                Caption = 'Logistic Units';
                ToolTip = 'Operations with logistics units';

                action("TMAC New Logistics Units")
                {
                    Caption = 'New Logistics Units';
                    Image = Item;
                    ApplicationArea = All;
                    ToolTip = 'Create a new logistic unit (box, pallet, container) and add the selected lines from this order.  Lines can be selected in the Lines section using the Ctrl or Shift keys. To automatically enter the selected quantity using the value from the “Quantity” field, activate the “Set Default Selected Quantity” setting in the Logistic Unit Setup. To ignore empty (or distributed) lines without a selected quantity, use the setting "Exclude Lines w/o Def. Qty.".';
                    AccessByPermission = tabledata "TMAC Unit" = rimd;

                    trigger OnAction()
                    begin
                        Rec.TestField(Status, Rec."Status"::Released);
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
                        Rec.TestField(Status, Rec."Status"::Released);
                        GetSelectedLineLinks();
                        UnitLinkManagement.AddToLogisticUnit(SourceDocumentLink, "TMAC Direction"::Outbound);
                        CurrPage.Update();
                        UpdateLogisticUnitsSubform();
                    end;
                }

                action("TMAC Include Logistics Units")
                {
                    Caption = 'Include in Order';
                    Image = Import;
                    ApplicationArea = All;
                    ToolTip = 'Include content on the selected logistic units into the purchase order.';
                    AccessByPermission = tabledata "TMAC Unit" = rimd;

                    trigger OnAction()
                    begin
                        UnitManagement.IncludeUnitInOrder(SourceType, SourceSubtype, SourceID, 0);//Database::"Invt. Receipt Line");
                        CurrPage.Update();
                        UpdateLogisticUnitsSubform();
                    end;
                }

                action("TMAC Logistic Units List")
                {
                    Caption = 'Loading Information';
                    Image = SelectMore;
                    ApplicationArea = All;
                    ToolTip = 'Show the linked logistics units.';
                    AccessByPermission = tabledata "TMAC Unit" = rimd;

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
            }
        }
    }

    trigger OnOpenPage()
    begin
        PermissonNotificaton();
    end;

    trigger OnAfterGetRecord()
    begin
        SourceType := Database::"Invt. Document Line";
        SourceSubtype := Rec."Document Type".AsInteger();
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

    local procedure PermissonNotificaton()
    var
        Unit: Record "TMAC Unit";
        LogisticUnitsExtensionNotification: Notification;
    begin
        if Unit.ReadPermission then
            exit;

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
        CurrPage.ShipmentLines.Page.GetSelectedLineLinks(SourceDocumentLink);
    end;

    var
        SourceDocumentLink: Record "TMAC Source Document Link";
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
        UnitManagement: Codeunit "TMAC Unit Management";

        SourceType: Integer;
        SourceSubtype: Integer;
        SourceID: Code[20];

        NotificationsExist: Boolean;
        ExtensionInstalledMsg: Label 'Logistic Units Management extension is installed. You do not have permission to manage Logistic Units. Contact your system administrator. ';
}
