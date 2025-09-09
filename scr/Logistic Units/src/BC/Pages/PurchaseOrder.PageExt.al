pageextension 71628575 "TMAC Purchase Order" extends "Purchase Order"
{
    layout
    {
        addafter(Control3)
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
            group("TMAC Category LU Promoted")
            {
                Caption = 'Logistic Units';
                ToolTip = 'Manage Logistics Units';

                group("TMAC Add logistic Units")
                {
                    ShowAs = SplitButton;
                    Visible = false;
                }
                actionref("TMAC Logistic Units New Promoted"; "TMAC New Logistics Units")
                {
                }
                actionref("TMAC Logistic Units Add Promoted"; "TMAC Add To Logistic Unit")
                {
                }

                group("TMAC Include logistic Units")
                {
                    Caption = 'Include/Exclude';
                    ShowAs = SplitButton;
                    actionref("TMAC Logistic Units Include Promoted"; "TMAC Include Logistics Units")
                    {
                    }
                    actionref("TMAC Logistic Units Exclude Promoted"; "TMAC Exclude Logistics Units")
                    {
                    }
                }

                actionref("TMAC Logistic Units List Promoted"; "TMAC Logistic Units List")
                {
                }
                actionref("TMAC Print SSCC Promoted"; "TMAC Print")
                {
                }
            }
        }

        addafter(Post_Promoted)
        {
            actionref("TMAC Logistic Units Post Promoted"; "TMAC Post Logistic Unit")
            {
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
                    ToolTip = 'Create a new logistic unit (box, pallet, container) and add the selected lines from this order.  Lines can be selected in the Lines section using the Ctrl or Shift keys. To automatically enter the selected quantity using the value from the “Qty. to Receive” field, activate the “Set Default Selected Quantity” setting in the Logistic Unit Setup. To ignore empty (or distributed) lines without a selected quantity, use the setting "Exclude Lines w/o Def. Qty.".';
                    AccessByPermission = tabledata "TMAC Unit" = I;

                    trigger OnAction()
                    begin
                        Rec.TestField(Status, "Sales Document Status"::Released);
                        GetSelectedLineLinks();
                        UnitLinkManagement.CreateNewLogisticUnits(SourceDocumentLink, "TMAC Direction"::Inbound);
                        UpdateLogisticUnitsSubform();
                    end;
                }

                action("TMAC Add To Logistic Unit")
                {
                    Caption = 'Add To Logistics Unit';
                    Image = ItemGroup;
                    ApplicationArea = All;
                    ToolTip = 'Place the selected lines from this order into an existing logistics unit (box, pallet, container, logistics unit compartment). Lines can be selected in the Lines section using the Ctrl or Shift keys. To automatically enter the selected quantity using the value from the "Qty. to Receive” field, activate the “Set Default Selected Quantity” setting in the Logistic Unit Setup. To ignore empty (or distributed) lines without a selected quantity, use the setting "Exclude Lines w/o Def. Qty.".';
                    AccessByPermission = tabledata "TMAC Unit" = I;

                    trigger OnAction()
                    begin
                        Rec.TestField(Status, "Sales Document Status"::Released);
                        GetSelectedLineLinks();
                        UnitLinkManagement.AddToLogisticUnit(SourceDocumentLink, "TMAC Direction"::Inbound);
                        CurrPage.Update();
                        UpdateLogisticUnitsSubform();
                    end;
                }

                action("TMAC Include Logistics Units")
                {
                    Caption = 'Include in Order';
                    Image = Import;
                    ApplicationArea = All;
                    ToolTip = 'This function allows you to add lines (all items) from the selected logistic unit to the purchase order. In doing so, links between the lines of this document and the logistic unit will be established.';
                    AccessByPermission = tabledata "TMAC Unit" = I;

                    trigger OnAction()
                    begin
                        UnitManagement.IncludeUnitInOrder(SourceType, SourceSubtype, SourceID, Database::"Purch. Rcpt. Line");
                        CurrPage.Update();
                        UpdateLogisticUnitsSubform();
                    end;
                }

                action("TMAC Exclude Logistics Units")
                {
                    Caption = 'Exclude from Order';
                    Image = Export;
                    ApplicationArea = All;
                    ToolTip = 'Exclude content on the selected logistic units from the purchase order.';
                    AccessByPermission = tabledata "TMAC Unit" = I;

                    trigger OnAction()
                    begin
                        UnitManagement.ExcludeUnitInOrder(SourceType, SourceSubtype, SourceID);
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
        addafter(Post)
        {
            action("TMAC Post Logistic Unit")
            {
                ApplicationArea = All;
                Caption = 'P&ost by Logistics Units';
                Image = PostOrder;
                Enabled = IsLogiticUnits;
                ToolTip = 'Post the logistic unit as received. Related documents are registered automatically.';
                AccessByPermission = tabledata "TMAC Unit" = I;

                trigger OnAction()
                var
                    UnitPost: Codeunit "TMAC Unit Post";
                begin
                    UnitPost.Post(SourceType, SourceSubtype, SourceID, Database::"Purch. Rcpt. Line", true);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        CheckPermissions();
    end;

    trigger OnAfterGetRecord()
    begin
        SourceType := Database::"Purchase Line";
        SourceSubtype := Rec."Document Type".AsInteger();
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
        NoOfLogisticUnit := CurrPage."TMAC Logistic Units FactBox".PAGE.SetSource(SourceType, SourceSubtype, SourceID, 'Inbound', 'Outbound');
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
        CurrPage.PurchLines.Page.GetSelectedLineLinks(SourceDocumentLink);
    end;

    var
        SourceDocumentLink: Record "TMAC Source Document Link";
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
        UnitManagement: Codeunit "TMAC Unit Management";
        IsLogiticUnits: Boolean;

        SourceType: Integer;
        SourceSubtype: Integer;
        SourceID: Code[20];


        NotificationsExist: Boolean;

        ExtensionInstalledMsg: Label 'Logistic Units: You have no license to manage Logistic Units. Contact your system administrator. ';
        ExtensionInstalledErr: Label 'Logistic Units: Each user must have "Logistic Units - User" permission set. Contact your system administrator. ';
}