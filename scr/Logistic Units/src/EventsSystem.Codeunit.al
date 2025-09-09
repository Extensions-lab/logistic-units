/// <summary>
/// Subscription to events mainly related to the operation of logistics units
/// </summary>
codeunit 71628576 "TMAC Events System"
{

    #region Delete document lines
    [EventSubscriber(ObjectType::Table, DATABASE::"Purchase Line", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforePurchaseLineDeleteEvent(VAR Rec: Record "Purchase Line"; RunTrigger: Boolean);
    begin
        if Rec.IsTemporary then
            exit;
        UnitLinkManagement.DeleteExistingLinks(DATABASE::"Purchase Line", Rec."Document Type".AsInteger(), Rec."Document No.", Rec."Line No.");
    end;

    [EventSubscriber(ObjectType::Table, DATABASE::"Sales Line", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeSaleLineDeleteEvent(VAR Rec: Record "Sales Line"; RunTrigger: Boolean);
    begin
        if Rec.IsTemporary then
            exit;
        UnitLinkManagement.DeleteExistingLinks(DATABASE::"Sales Line", Rec."Document Type".AsInteger(), Rec."Document No.", Rec."Line No.");
    end;

    [EventSubscriber(ObjectType::Table, DATABASE::"Warehouse Shipment Line", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure BeforeWarehouseShipmentLineDeleteEvent(VAR Rec: Record "Warehouse Shipment Line"; RunTrigger: Boolean);
    begin
        if Rec.IsTemporary then
            exit;
        UnitLinkManagement.DeleteExistingLinks(DATABASE::"Warehouse Shipment Line", 0, Rec."No.", Rec."Line No.");
    end;

    [EventSubscriber(ObjectType::Table, DATABASE::"Warehouse Receipt Line", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure BeforeWarehouseReceiptLineDeleteEvent(VAR Rec: Record "Warehouse Receipt Line"; RunTrigger: Boolean);
    begin
        if Rec.IsTemporary then
            exit;
        UnitLinkManagement.DeleteExistingLinks(DATABASE::"Warehouse Receipt Line", 0, Rec."No.", Rec."Line No.");
    end;

    [EventSubscriber(ObjectType::Table, DATABASE::"Transfer Line", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure BeforeTransferLineDeleteEvent(VAR Rec: Record "Transfer Line"; RunTrigger: Boolean);
    begin
        if Rec.IsTemporary then
            exit;
        UnitLinkManagement.DeleteExistingLinks(DATABASE::"Transfer Line", 0, Rec."Document No.", Rec."Line No.");
        UnitLinkManagement.DeleteExistingLinks(DATABASE::"Transfer Line", 1, Rec."Document No.", Rec."Line No.");
    end;

    [EventSubscriber(ObjectType::Table, DATABASE::"Warehouse Activity Line", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure BeforeWarehouseActivityLineDeleteEvent(VAR Rec: Record "Warehouse Activity Line"; RunTrigger: Boolean);
    begin
        if Rec.IsTemporary then
            exit;

        UnitLinkManagement.DeleteExistingLinks(DATABASE::"Warehouse Activity Line", Rec."Activity Type".AsInteger(), Rec."No.", Rec."Line No.");
    end;

    [EventSubscriber(ObjectType::Table, DATABASE::"Invt. Document Line", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeInvtDocLineDeleteEvent(VAR Rec: Record "Invt. Document Line"; RunTrigger: Boolean);
    begin
        if Rec.IsTemporary then
            exit;
        UnitLinkManagement.DeleteExistingLinks(DATABASE::"Invt. Document Line", Rec."Document Type".AsInteger(), Rec."Document No.", Rec."Line No.");
    end;

    #endregion


    /// <summary>
    /// Drop Shipment
    /// </summary>
    /// <param name="PurchaseLine"></param>
    /// <param name="SalesLine"></param>
    /// <param name="NextLineNo"></param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Get Drop Shpt.", OnAfterPurchaseLineInsert, '', false, false)]
    local procedure OnAfterPurchaseLineInsert(var PurchaseLine: Record "Purchase Line"; SalesLine: Record "Sales Line"; var NextLineNo: Integer);
    var
        UnitLineLink: Record "TMAC Unit Line Link";
        NewUnitLineLink: Record "TMAC Unit Line Link";
    begin
        UnitLineLink.Reset();
        UnitLineLink.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.", "Package No.", "Lot No.", "Serial No.", "Positive", "Qty. to Post");
        UnitLineLink.Setrange("Source Type", Database::"Sales Line");
        UnitLineLink.Setrange("Source Subtype", SalesLine."Document Type".AsInteger());
        UnitLineLink.Setrange("Source ID", SalesLine."Document No.");
        UnitLineLink.Setrange("Source Ref. No.", SalesLine."Line No.");
        if UnitLineLink.findset(false) then
            repeat
                NewUnitLineLink.Init();
                NewUnitLineLink.TransferFields(UnitLineLink);
                NewUnitLineLink.Validate("Source Type", Database::"Purchase Line");
                NewUnitLineLink.Validate("Source Subtype", PurchaseLine."Document Type".AsInteger());
                NewUnitLineLink.Validate("Source ID", PurchaseLine."Document No.");
                NewUnitLineLink.Validate("Source Ref. No.", PurchaseLine."Line No.");
                NewUnitLineLink."Quantity" := -NewUnitLineLink."Quantity";
                NewUnitLineLink."Quantity (Base)" := -NewUnitLineLink."Quantity (Base)";
                NewUnitLineLink.Positive := not NewUnitLineLink.Positive;
                NewUnitLineLink.Insert(true);
            until UnitLineLink.next() = 0;
    end;




    #region Posting Events

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPurchRcptLineInsert', '', false, false)]
    local procedure AfterPurchRcptLineInsert(PurchaseLine: Record "Purchase Line"; var PurchRcptLine: Record "Purch. Rcpt. Line"; ItemLedgShptEntryNo: Integer; WhseShip: Boolean; WhseReceive: Boolean; CommitIsSupressed: Boolean; PurchInvHeader: Record "Purch. Inv. Header"; var TempTrackingSpecification: Record "Tracking Specification" temporary; PurchRcptHeader: Record "Purch. Rcpt. Header"; TempWhseRcptHeader: Record "Warehouse Receipt Header"; xPurchLine: Record "Purchase Line")
    Var
        Qty: Decimal;
    begin
        if PurchRcptLine.Quantity = 0 then
            exit;

        UnitPost.CheckLocationRequirements(
            PurchaseLine."Location Code",
            "TMAC Direction"::Inbound,
            Database::"Purchase Line", PurchaseLine."Document Type".AsInteger(), PurchaseLine."Document No.", PurchaseLine."Line No.");

        UnitPost.BlockPostingIfThereAreLinks(PurchRcptLine.Quantity, Database::"Purchase Line", PurchaseLine."Document Type".AsInteger(), PurchaseLine."Document No.", PurchaseLine."Line No.", true);

        Qty := PurchRcptLine.Quantity;

        if not UnitPost.PostLinksWithItemTracking(
                Database::"Purchase Line", PurchaseLine."Document Type".AsInteger(), PurchaseLine."Document No.", PurchaseLine."Line No.", true,
                Database::"Purch. Rcpt. Line", 0, PurchRcptLine."Document No.", PurchRcptLine."Line No.")
        then
            UnitPost.PostLinks(Qty,
                Database::"Purchase Line", PurchaseLine."Document Type".AsInteger(), PurchaseLine."Document No.", PurchaseLine."Line No.", true,
                Database::"Purch. Rcpt. Line", 0, PurchRcptLine."Document No.", PurchRcptLine."Line No.");

        UnitPost.UpdateLogisticUnitLocationCode(Database::"Purchase Line", PurchaseLine."Document Type".AsInteger(), PurchaseLine."Document No.", PurchaseLine."Line No.", true);
    end;

    /// <summary>
    /// Purchase Return
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterReturnShptLineInsert', '', false, false)]
    local procedure AfterReturnShptLineInsert(var ReturnShptLine: Record "Return Shipment Line"; ReturnShptHeader: Record "Return Shipment Header"; PurchLine: Record "Purchase Line"; ItemLedgShptEntryNo: Integer; WhseShip: Boolean; WhseReceive: Boolean; CommitIsSupressed: Boolean; var TempWhseShptHeader: Record "Warehouse Shipment Header" temporary; PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; xPurchLine: Record "Purchase Line")
    Var
        Qty: Decimal;
    begin
        if ReturnShptLine.Quantity = 0 then
            exit;

        UnitPost.CheckLocationRequirements(
            PurchLine."Location Code",
            "TMAC Direction"::Outbound,
            Database::"Purchase Line", PurchLine."Document Type".AsInteger(), PurchLine."Document No.", PurchLine."Line No.");

        UnitPost.BlockPostingIfThereAreLinks(ReturnShptLine.Quantity, Database::"Purchase Line", PurchLine."Document Type".AsInteger(), PurchLine."Document No.", PurchLine."Line No.", false);

        Qty := ReturnShptLine.Quantity;

        if not UnitPost.PostLinksWithItemTracking(
                Database::"Purchase Line", PurchLine."Document Type".AsInteger(), PurchLine."Document No.", PurchLine."Line No.", false,
                Database::"Return Shipment Line", 0, ReturnShptLine."Document No.", ReturnShptLine."Line No.")
        then
            UnitPost.PostLinks(Qty,
                Database::"Purchase Line", PurchLine."Document Type".AsInteger(), PurchLine."Document No.", PurchLine."Line No.", false,
                Database::"Return Shipment Line", 0, ReturnShptLine."Document No.", ReturnShptLine."Line No.");

        UnitPost.UpdateLogisticUnitLocationCode(Database::"Purchase Line", PurchLine."Document Type".AsInteger(), PurchLine."Document No.", PurchLine."Line No.", false);

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Receipt", 'OnPostWhseJnlLineOnAfterInsertWhseItemEntryRelation', '', false, false)]
    local procedure PostWhseJnlLineOnAfterInsertWhseItemEntryRelation(var PostedWhseRcptHeader: Record "Posted Whse. Receipt Header"; var PostedWhseRcptLine: Record "Posted Whse. Receipt Line"; var TempWhseSplitSpecification: Record "Tracking Specification" temporary; var IsHandled: Boolean; ReceivingNo: code[20]; PostingDate: date; var TempWhseJnlLine: Record "Warehouse Journal Line" temporary)
    var
        Qty: Decimal;
    begin
        if PostedWhseRcptLine.Quantity = 0 then
            exit;

        UnitPost.CheckLocationRequirements(
            PostedWhseRcptLine."Location Code",
            "TMAC Direction"::Inbound,
            Database::"Warehouse Receipt Line", 0, PostedWhseRcptLine."Whse. Receipt No.", PostedWhseRcptLine."Whse Receipt Line No.");

        UnitPost.BlockPostingIfThereAreLinks(PostedWhseRcptLine.Quantity, Database::"Warehouse Receipt Line", 0, PostedWhseRcptLine."Whse. Receipt No.", PostedWhseRcptLine."Whse Receipt Line No.", true);

        Qty := PostedWhseRcptLine.Quantity;

        if not UnitPost.PostLinksWithItemTrackingWMS(
              Database::"Warehouse Receipt Line", 0, PostedWhseRcptLine."Whse. Receipt No.", PostedWhseRcptLine."Whse Receipt Line No.", true,
              Database::"Posted Whse. Receipt Line", 0, PostedWhseRcptLine."No.", PostedWhseRcptLine."Line No.")
       then
            UnitPost.PostLinks(Qty,
                Database::"Warehouse Receipt Line", 0, PostedWhseRcptLine."Whse. Receipt No.", PostedWhseRcptLine."Line No.", true,
                Database::"Posted Whse. Receipt Line", 0, PostedWhseRcptLine."No.", PostedWhseRcptLine."Line No.");

    end;

    /// <summary>
    /// Standard shipment accounting for a sales order
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesShptLineInsert', '', false, false)]
    local procedure AfterSalesShptLineInsert(var SalesShipmentLine: Record "Sales Shipment Line"; SalesLine: Record "Sales Line"; ItemShptLedEntryNo: Integer; WhseShip: Boolean; WhseReceive: Boolean; CommitIsSuppressed: Boolean; SalesInvoiceHeader: Record "Sales Invoice Header"; var TempWhseShptHeader: Record "Warehouse Shipment Header" temporary; var TempWhseRcptHeader: Record "Warehouse Receipt Header" temporary)
    Var
        Qty: Decimal;
    begin
        if SalesShipmentLine.Quantity = 0 then
            exit;

        UnitPost.CheckLocationRequirements(
           SalesLine."Location Code",
           "TMAC Direction"::Outbound,
           Database::"Sales Line", SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.");

        UnitPost.BlockPostingIfThereAreLinks(SalesShipmentLine.Quantity, Database::"Sales Line", SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.", false);

        Qty := SalesShipmentLine.Quantity;

        if not UnitPost.PostLinksWithItemTracking(
                Database::"Sales Line", SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.", false,
                Database::"Sales Shipment Line", 0, SalesShipmentLine."Document No.", SalesShipmentLine."Line No.")
        then
            UnitPost.PostLinks(Qty,
                Database::"Sales Line", SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.", false,
                Database::"Sales Shipment Line", 0, SalesShipmentLine."Document No.", SalesShipmentLine."Line No.");


        UnitPost.UpdateLogisticUnitLocationCode(Database::"Sales Line", SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.", false);

    end;

    /// <summary>
    /// Accounting for Sales Return
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterReturnRcptLineInsert', '', false, false)]
    local procedure AfterReturnRcptLineInsert(var ReturnRcptLine: Record "Return Receipt Line"; ReturnRcptHeader: Record "Return Receipt Header"; SalesLine: Record "Sales Line"; ItemShptLedEntryNo: Integer; WhseShip: Boolean; WhseReceive: Boolean; CommitIsSuppressed: Boolean; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var TempWhseShptHeader: Record "Warehouse Shipment Header" temporary; var TempWhseRcptHeader: Record "Warehouse Receipt Header" temporary)
    Var
        Qty: Decimal;
    begin
        if ReturnRcptLine.Quantity = 0 then
            exit;

        UnitPost.CheckLocationRequirements(
           SalesLine."Location Code",
           "TMAC Direction"::Inbound,
           Database::"Sales Line", SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.");

        UnitPost.BlockPostingIfThereAreLinks(ReturnRcptLine.Quantity, Database::"Sales Line", SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.", true);

        Qty := ReturnRcptLine.Quantity;

        if not UnitPost.PostLinksWithItemTracking(
                Database::"Sales Line", SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.", true,
                Database::"Return Receipt Line", 0, ReturnRcptLine."Document No.", ReturnRcptLine."Line No.")
        then
            UnitPost.PostLinks(Qty,
                Database::"Sales Line", SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.", true,
                Database::"Return Receipt Line", 0, ReturnRcptLine."Document No.", ReturnRcptLine."Line No.");

        UnitPost.UpdateLogisticUnitLocationCode(Database::"Sales Line", SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.", true);

    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment", 'OnCreatePostedShptLineOnBeforePostWhseJnlLine', '', false, false)]
    local procedure CreatePostedShptLineOnBeforePostWhseJnlLine(var PostedWhseShipmentLine: Record "Posted Whse. Shipment Line"; var TempTrackingSpecification: Record "Tracking Specification" temporary; WarehouseShipmentLine: Record "Warehouse Shipment Line")
    var
        UnitLineLink: Record "TMAC Unit Line Link";
        Qty: Decimal;
        CurrentQty: Decimal;
    begin
        if PostedWhseShipmentLine.Quantity = 0 then
            exit;

        UnitPost.CheckLocationRequirements(
            WarehouseShipmentLine."Location Code",
            "TMAC Direction"::Outbound,
            Database::"Warehouse Shipment Line", 0, WarehouseShipmentLine."No.", WarehouseShipmentLine."Line No.");

        if TempTrackingSpecification.FindSet(false) then
            repeat
                UnitLineLink.Reset();
                UnitLineLink.Setrange("Source Type", Database::"Warehouse Shipment Line");
                UnitLineLink.Setrange("Source Subtype", 0);
                UnitLineLink.Setrange("Source ID", WarehouseShipmentLine."No.");
                UnitLineLink.Setrange("Source Ref. No.", WarehouseShipmentLine."Line No.");

                UnitLineLink.Setrange("Package No.", TempTrackingSpecification."Package No.");
                UnitLineLink.Setrange("Lot No.", TempTrackingSpecification."Lot No.");
                UnitLineLink.Setrange("Serial No.", TempTrackingSpecification."Serial No.");

                UnitLineLink.SetFilter("Qty. to Post", '>0');  //without this thing, the system would delete links from another pallet to the same line

                if UnitLineLink.FindSet(true) then
                    repeat
                        CurrentQty := Round(abs(TempTrackingSpecification."Quantity (Base)" / TempTrackingSpecification."Qty. per Unit of Measure"));
                        UnitPost.InsertPostedLink(UnitLineLink, Database::"Posted Whse. Shipment Line", 0, PostedWhseShipmentLine."No.", PostedWhseShipmentLine."Line No.", CurrentQty);
                        UnitLineLink.Quantity := UnitLineLink.Quantity + CurrentQty;
                        UnitLineLink."Posted Quantity" := UnitLineLink."Posted Quantity" - CurrentQty;
                        UnitLineLink.Modify(true);
                    until UnitLineLink.Next() = 0;
            until TempTrackingSpecification.next() = 0
        else begin
            Qty := PostedWhseShipmentLine.Quantity;
            UnitPost.PostLinks(Qty,
                Database::"Warehouse Shipment Line", 0, WarehouseShipmentLine."No.", WarehouseShipmentLine."Line No.", false,
                Database::"Posted Whse. Shipment Line", 0, PostedWhseShipmentLine."No.", PostedWhseShipmentLine."Line No.");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnAfterInsertTransShptLine', '', false, false)]
    local procedure AfterInsertTransShptLine(var TransShptLine: Record "Transfer Shipment Line"; TransLine: Record "Transfer Line"; CommitIsSuppressed: Boolean)
    Var
        Qty: Decimal;
    begin
        if TransShptLine.Quantity = 0 then
            exit;

        UnitPost.CheckLocationRequirements(TransShptLine."Transfer-from Code", "TMAC Direction"::Outbound,
            Database::"Transfer Line", 0, TransLine."Document No.", TransLine."Line No.");

        UnitPost.BlockPostingIfThereAreLinks(TransShptLine.Quantity, Database::"Transfer Line", 0, TransLine."Document No.", TransLine."Line No.", false);

        Qty := TransShptLine.Quantity;

        if not UnitPost.PostLinksWithItemTracking(
            Database::"Transfer Line", 0, TransLine."Document No.", TransLine."Line No.", false,
            Database::"Transfer Shipment Line", 0, TransShptLine."Document No.", TransShptLine."Line No.")
        then
            UnitPost.PostLinks(Qty,
                Database::"Transfer Line", 0, TransLine."Document No.", TransLine."Line No.", false,
                Database::"Transfer Shipment Line", 0, TransShptLine."Document No.", TransShptLine."Line No.");

        UnitPost.UpdateLogisticUnitLocationCode(Database::"Transfer Line", 0, TransLine."Document No.", TransLine."Line No.", false);

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnAfterInsertTransRcptLine', '', false, false)]
    local procedure AfterInsertTransRcptLine(var TransRcptLine: Record "Transfer Receipt Line"; TransLine: Record "Transfer Line"; CommitIsSuppressed: Boolean)
    Var
        Qty: Decimal;
    begin
        if TransRcptLine.Quantity = 0 then
            exit;

        UnitPost.CheckLocationRequirements(TransLine."Transfer-to Code", "TMAC Direction"::Inbound,
            Database::"Transfer Line", 1, TransLine."Document No.", TransLine."Line No.");

        UnitPost.BlockPostingIfThereAreLinks(TransRcptLine.Quantity, Database::"Transfer Line", 1, TransLine."Document No.", TransLine."Line No.", true);

        Qty := TransRcptLine.Quantity;

        if not UnitPost.PostLinksWithItemTracking(
            Database::"Transfer Line", 1, TransLine."Document No.", TransLine."Line No.", true,
            Database::"Transfer Receipt Line", 0, TransRcptLine."Document No.", TransRcptLine."Line No.")
        then
            UnitPost.PostLinks(Qty,
                Database::"Transfer Line", 1, TransLine."Document No.", TransLine."Line No.", true,
                Database::"Transfer Receipt Line", 0, TransRcptLine."Document No.", TransRcptLine."Line No.");

        UnitPost.UpdateLogisticUnitLocationCode(Database::"Transfer Line", 1, TransLine."Document No.", TransLine."Line No.", true);

    end;

    /// <summary>
    /// Direct Transfers
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Transfer", 'OnAfterInsertDirectTransLine', '', false, false)]
    local procedure AfterInsertDirectTransLine(var DirectTransLine: Record "Direct Trans. Line"; DirectTransHeader: Record "Direct Trans. Header"; TransLine: Record "Transfer Line")
    Var
        Qty: Decimal;
    begin
        if DirectTransLine.Quantity = 0 then
            exit;

        UnitPost.CheckLocationRequirements(
            TransLine."Transfer-from Code",
            "TMAC Direction"::Outbound,
            Database::"Transfer Line", 0, TransLine."Document No.", TransLine."Line No.");

        UnitPost.BlockPostingIfThereAreLinks(DirectTransLine.Quantity, Database::"Transfer Line", 0, TransLine."Document No.", TransLine."Line No.", false);

        if not UnitPost.PostLinksWithItemTracking(
            Database::"Transfer Line", 0, TransLine."Document No.", TransLine."Line No.", false,
            Database::"Direct Trans. Line", 0, DirectTransLine."Document No.", DirectTransLine."Line No.")
        then begin
            Qty := DirectTransLine.Quantity;
            UnitPost.PostLinks(Qty,
                Database::"Transfer Line", 0, TransLine."Document No.", TransLine."Line No.", false,
                Database::"Direct Trans. Line", 0, DirectTransLine."Document No.", DirectTransLine."Line No.");
            UnitPost.PostLinks(Qty,
                Database::"Transfer Line", 0, TransLine."Document No.", TransLine."Line No.", true,
                Database::"Direct Trans. Line", 0, DirectTransLine."Document No.", DirectTransLine."Line No.");
        end;

        UnitPost.UpdateLogisticUnitLocationCode(Database::"Transfer Line", 0, TransLine."Document No.", TransLine."Line No.", true);
    end;

    //Inventory Receipt Post
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Invt. Doc.-Post Receipt", 'OnRunOnBeforeInvtRcptHeaderInsert', '', false, false)]
    local procedure OnRunOnBeforeInvtRcptHeaderInsert(var InvtRcptHeader: Record "Invt. Receipt Header"; InvtDocHeader: Record "Invt. Document Header")
    begin
        InvtRcptHeader."TMAC Customer No." := InvtDocHeader."TMAC Customer No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Invt. Doc.-Post Receipt", 'OnRunOnAfterInvtRcptLineInsert', '', false, false)]
    local procedure OnRunOnAfterInvtRcptLineInsert(var InvtReceiptLine: Record "Invt. Receipt Line"; InvtDocumentLine: Record "Invt. Document Line"; var InvtReceiptHeader: Record "Invt. Receipt Header"; InvtDocumentHeader: Record "Invt. Document Header")
    var
        UnitLineLink: Record "TMAC Unit Line Link";
        Qty: Decimal;
    begin
        if InvtReceiptLine.Quantity = 0 then
            exit;

        UnitPost.CheckLocationRequirements(
            InvtDocumentLine."Location Code",
            "TMAC Direction"::Inbound,
            Database::"Invt. Document Line", InvtDocumentLine."Document Type".AsInteger(), InvtDocumentLine."Document No.", InvtDocumentLine."Line No.");

        //since there is no separate accounting, the entire document is taken into account

        UnitLineLink.Reset();
        UnitLineLink.SetRange("Source Type", Database::"Invt. Document Line");
        UnitLineLink.SetRange("Source Subtype", InvtDocumentLine."Document Type".AsInteger());
        UnitLineLink.SetRange("Source ID", InvtDocumentLine."Document No.");
        UnitLineLink.SetRange("Source Ref. No.", InvtDocumentLine."Line No.");
        UnitLineLink.SetRange("Positive", true);
        if UnitLineLink.FindSet() then
            repeat
                UnitLineLink."Qty. to Post" := UnitLineLink.Quantity;
                UnitLineLink.Modify();
            until UnitLineLink.Next() = 0;

        if not UnitPost.PostLinksWithItemTracking(
                Database::"Invt. Document Line", InvtDocumentLine."Document Type".AsInteger(), InvtDocumentLine."Document No.", InvtDocumentLine."Line No.", true,
                Database::"Invt. Receipt Line", 0, InvtReceiptLine."Document No.", InvtReceiptLine."Line No.")
        then begin
            Qty := InvtReceiptLine.Quantity;
            UnitPost.PostLinks(Qty,
                Database::"Invt. Document Line", InvtDocumentLine."Document Type".AsInteger(), InvtDocumentLine."Document No.", InvtDocumentLine."Line No.", true,
                Database::"Invt. Receipt Line", 0, InvtReceiptLine."Document No.", InvtReceiptLine."Line No.");
        end;
    end;

    // Inventroy Shipment Post
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Invt. Doc.-Post Shipment", 'OnRunOnAfterInvtShptLineInsert', '', false, false)]
    local procedure OnRunOnAfterInvtShptLineInsert(var InvtShipmentLine: Record "Invt. Shipment Line"; InvtDocumentLine: Record "Invt. Document Line"; var InvtShipmentHeader: Record "Invt. Shipment Header"; InvtDocumentHeader: Record "Invt. Document Header")
    var
        UnitLineLink: Record "TMAC Unit Line Link";
        Qty: Decimal;
    begin
        if InvtShipmentLine.Quantity = 0 then
            exit;

        UnitPost.CheckLocationRequirements(
            InvtDocumentLine."Location Code",
            "TMAC Direction"::Outbound,
            Database::"Invt. Document Line", InvtDocumentLine."Document Type".AsInteger(), InvtDocumentLine."Document No.", InvtDocumentLine."Line No.");

        UnitLineLink.Reset();
        UnitLineLink.SetRange("Source Type", Database::"Invt. Document Line");
        UnitLineLink.SetRange("Source Subtype", InvtDocumentLine."Document Type".AsInteger());
        UnitLineLink.SetRange("Source ID", InvtDocumentLine."Document No.");
        UnitLineLink.SetRange("Source Ref. No.", InvtDocumentLine."Line No.");
        UnitLineLink.SetRange("Positive", false);
        if UnitLineLink.FindSet() then
            repeat
                UnitLineLink."Qty. to Post" := -UnitLineLink.Quantity;
                UnitLineLink.Modify();
            until UnitLineLink.Next() = 0;

        if not UnitPost.PostLinksWithItemTracking(
                Database::"Invt. Document Line", InvtDocumentLine."Document Type".AsInteger(), InvtDocumentLine."Document No.", InvtDocumentLine."Line No.", false,
                Database::"Invt. Shipment Line", 0, InvtShipmentLine."Document No.", InvtShipmentLine."Line No.")
        then begin
            Qty := InvtShipmentLine.Quantity;
            UnitPost.PostLinks(Qty,
                Database::"Invt. Document Line", InvtDocumentLine."Document Type".AsInteger(), InvtDocumentLine."Document No.", InvtDocumentLine."Line No.", false,
                Database::"Invt. Shipment Line", 0, InvtShipmentLine."Document No.", InvtShipmentLine."Line No.");
        end;
    end;

    #endregion

    #region Undo Documents
    /// <summary>
    /// Undo shipment lines
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Undo Sales Shipment Line", 'OnAfterSalesShptLineModify', '', false, false)]
    local procedure AfterSalesShptLineModify(var SalesShptLine: Record "Sales Shipment Line"; DocLineNo: Integer)
    var
        UnitLineLink: Record "TMAC Unit Line Link";
        UnitLineLink2: Record "TMAC Unit Line Link";
        ReverseUnitLineLink: Record "TMAC Unit Line Link";
    begin
        if not UnitLineLink.ReadPermission then
            Error(LogisticUnitModuleAccessErr);

        UnitLineLink.SetRange("Source Type", Database::"Sales Shipment Line");
        UnitLineLink.SetRange("Source Subtype", 0);
        UnitLineLink.SetRange("Source ID", SalesShptLine."Document No.");
        UnitLineLink.SetRange("Source Ref. No.", SalesShptLine."Line No."); //reference to the line being canceled
        if UnitLineLink.FindSet() then
            repeat
                ReverseUnitLineLink.Init();
                ReverseUnitLineLink.TransferFields(UnitLineLink);
                ReverseUnitLineLink."Source Ref. No." := DocLineNo;
                ReverseUnitLineLink."Quantity" := -UnitLineLink.Quantity;
                ReverseUnitLineLink."Quantity (Base)" := -UnitLineLink."Quantity (Base)";
                ReverseUnitLineLink.Positive := not UnitLineLink.Positive;
                ReverseUnitLineLink.Insert(true);

                //deletion of the link to the unposted sales line...  
                //since an item was returned from the shipped pallet, and now you’ll have to deal without the pallet, it’s already shipped
                UnitLineLink2.Reset();
                UnitLineLink2.SetRange("Unit No.", UnitLineLink."Unit No.");
                UnitLineLink2.Setrange("Unit Line No.", UnitLineLink."Unit Line No.");
                UnitLineLink2.SetRange("Source Type", Database::"Sales Line");
                UnitLineLink2.Setrange("Source ID", SalesShptLine."Order No.");
                UnitLineLink2.Setrange("Source Ref. No.", SalesShptLine."Order Line No.");
                UnitLineLink2.DeleteAll(true);
            until UnitLineLink.Next() = 0;
    end;

    //updating posted shipment lines during Undo
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse. Undo Quantity", 'OnBeforePostedWhseShptLineInsert', '', false, false)]
    local procedure BeforePostedWhseShptLineInsert(var NewPostedWhseShipmentLine: Record "Posted Whse. Shipment Line"; OldPostedWhseShipmentLine: Record "Posted Whse. Shipment Line"; LineSpacing: Integer)
    var
        UnitLineLink: Record "TMAC Unit Line Link";
        UnitLineLink2: Record "TMAC Unit Line Link";
        ReverseUnitLineLink: Record "TMAC Unit Line Link";
    begin
        if not UnitLineLink.ReadPermission then
            Error(LogisticUnitModuleAccessErr);

        UnitLineLink.SetRange("Source Type", Database::"Posted Whse. Shipment Line");
        UnitLineLink.SetRange("Source Subtype", 0);
        UnitLineLink.SetRange("Source ID", OldPostedWhseShipmentLine."No.");
        UnitLineLink.SetRange("Source Ref. No.", OldPostedWhseShipmentLine."Line No."); //reference to the line being canceled
        if UnitLineLink.FindSet() then
            repeat
                ReverseUnitLineLink.Init();
                ReverseUnitLineLink.TransferFields(UnitLineLink);
                ReverseUnitLineLink."Source Ref. No." := NewPostedWhseShipmentLine."Line No.";
                ReverseUnitLineLink."Quantity" := -UnitLineLink.Quantity;
                ReverseUnitLineLink."Quantity (Base)" := -UnitLineLink."Quantity (Base)";
                ReverseUnitLineLink.Positive := not UnitLineLink.Positive;
                ReverseUnitLineLink.Insert(true);

                //same as in the main document — deleting the link to the unposted document... unbinding from the pallet
                UnitLineLink2.Reset();
                UnitLineLink2.SetRange("Unit No.", UnitLineLink."Unit No.");
                UnitLineLink2.Setrange("Unit Line No.", UnitLineLink."Unit Line No.");
                UnitLineLink2.SetRange("Source Type", Database::"Warehouse Shipment Line");
                UnitLineLink2.Setrange("Source ID", NewPostedWhseShipmentLine."Whse. Shipment No.");
                UnitLineLink2.Setrange("Source Ref. No.", NewPostedWhseShipmentLine."Whse Shipment Line No.");
                UnitLineLink2.DeleteAll(true);
            until UnitLineLink.Next() = 0;
    end;


    /// <summary>
    /// Undo receipt lines
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Undo Purchase Receipt Line", 'OnAfterPurchRcptLineModify', '', false, false)]
    local procedure AfterPurchRcptLineModify(var PurchRcptLine: Record "Purch. Rcpt. Line"; var TempWhseJnlLine: Record "Warehouse Journal Line" temporary; DocLineNo: Integer; var UndoPostingManagement: Codeunit "Undo Posting Management")
    var
        UnitLineLink: Record "TMAC Unit Line Link";
        UnitLineLink2: Record "TMAC Unit Line Link";
        ReverseUnitLineLink: Record "TMAC Unit Line Link";
    begin
        if not UnitLineLink.ReadPermission then
            Error(LogisticUnitModuleAccessErr);

        UnitLineLink.SetRange("Source Type", Database::"Purch. Rcpt. Line");
        UnitLineLink.SetRange("Source Subtype", 0);
        UnitLineLink.SetRange("Source ID", PurchRcptLine."Document No.");
        UnitLineLink.SetRange("Source Ref. No.", PurchRcptLine."Line No."); //reference to the line being canceled
        if UnitLineLink.FindSet() then
            repeat
                ReverseUnitLineLink.Init();
                ReverseUnitLineLink.TransferFields(UnitLineLink);
                ReverseUnitLineLink."Source Ref. No." := DocLineNo;
                ReverseUnitLineLink."Quantity" := -UnitLineLink.Quantity;
                ReverseUnitLineLink."Quantity (Base)" := -UnitLineLink."Quantity (Base)";
                ReverseUnitLineLink.Positive := not UnitLineLink.Positive;
                ReverseUnitLineLink.Insert(true);

                //deletion of the link to the unposted sales line...  
                //since an item was returned from the shipped pallet, and now you’ll have to handle it without the pallet, as it’s already shipped
                UnitLineLink2.Reset();
                UnitLineLink2.SetRange("Unit No.", UnitLineLink."Unit No.");
                UnitLineLink2.Setrange("Unit Line No.", UnitLineLink."Unit Line No.");
                UnitLineLink2.SetRange("Source Type", Database::"Purchase Line");
                UnitLineLink2.Setrange("Source ID", PurchRcptLine."Order No.");
                UnitLineLink2.Setrange("Source Ref. No.", PurchRcptLine."Order Line No.");
                UnitLineLink2.DeleteAll(true);
            until UnitLineLink.Next() = 0;
    end;


    //cancellation of posted warehouse receipt 
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse. Undo Quantity", 'OnBeforePostedWhseRcptLineInsert', '', false, false)]
    local procedure OnBeforePostedWhseRcptLineInsert(var NewPostedWhseReceiptLine: Record "Posted Whse. Receipt Line"; OldPostedWhseReceiptLine: Record "Posted Whse. Receipt Line"; LineSpacing: Integer)
    var
        UnitLineLink: Record "TMAC Unit Line Link";
        UnitLineLink2: Record "TMAC Unit Line Link";
        ReverseUnitLineLink: Record "TMAC Unit Line Link";
    begin
        if not UnitLineLink.ReadPermission then
            Error(LogisticUnitModuleAccessErr);

        UnitLineLink.SetRange("Source Type", Database::"Posted Whse. Receipt Line");
        UnitLineLink.SetRange("Source Subtype", 0);
        UnitLineLink.SetRange("Source ID", OldPostedWhseReceiptLine."No.");
        UnitLineLink.SetRange("Source Ref. No.", OldPostedWhseReceiptLine."Line No."); //ссылка на отменяемую строку
        if UnitLineLink.FindSet() then
            repeat
                ReverseUnitLineLink.Init();
                ReverseUnitLineLink.TransferFields(UnitLineLink);
                ReverseUnitLineLink."Source Ref. No." := NewPostedWhseReceiptLine."Line No.";
                ReverseUnitLineLink."Quantity" := -UnitLineLink.Quantity;
                ReverseUnitLineLink."Quantity (Base)" := -UnitLineLink."Quantity (Base)";
                ReverseUnitLineLink.Positive := not UnitLineLink.Positive;
                ReverseUnitLineLink.Insert(true);

                UnitLineLink2.Reset();
                UnitLineLink2.SetRange("Unit No.", UnitLineLink."Unit No.");
                UnitLineLink2.Setrange("Unit Line No.", UnitLineLink."Unit Line No.");
                UnitLineLink2.SetRange("Source Type", Database::"Warehouse Receipt Line");
                UnitLineLink2.Setrange("Source ID", OldPostedWhseReceiptLine."Whse. Receipt No.");
                UnitLineLink2.Setrange("Source Ref. No.", OldPostedWhseReceiptLine."Whse Receipt Line No.");
                UnitLineLink2.DeleteAll(true);
            until UnitLineLink.Next() = 0;
    end;

    /// <summary>
    /// Undo Return Shipment Line
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Undo Return Shipment Line", 'OnAfterReturnShptLineModify', '', false, false)]
    local procedure AfterReturnShptLineModify(var ReturnShptLine: Record "Return Shipment Line"; var TempWhseJnlLine: Record "Warehouse Journal Line" temporary; DocLineNo: Integer; var UndoPostingManagement: Codeunit "Undo Posting Management")
    var
        UnitLineLink: Record "TMAC Unit Line Link";
        UnitLineLink2: Record "TMAC Unit Line Link";
        ReverseUnitLineLink: Record "TMAC Unit Line Link";
    begin
        if not UnitLineLink.ReadPermission then
            Error(LogisticUnitModuleAccessErr);

        UnitLineLink.SetRange("Source Type", Database::"Return Shipment Line");
        UnitLineLink.SetRange("Source Subtype", 0);
        UnitLineLink.SetRange("Source ID", ReturnShptLine."Document No.");
        UnitLineLink.SetRange("Source Ref. No.", ReturnShptLine."Line No.");
        if UnitLineLink.FindSet() then
            repeat
                ReverseUnitLineLink.Init();
                ReverseUnitLineLink.TransferFields(UnitLineLink);
                ReverseUnitLineLink."Source Ref. No." := DocLineNo;
                ReverseUnitLineLink."Quantity" := -UnitLineLink.Quantity;
                ReverseUnitLineLink."Quantity (Base)" := -UnitLineLink."Quantity (Base)";
                ReverseUnitLineLink.Positive := not UnitLineLink.Positive;
                ReverseUnitLineLink.Insert(true);

                UnitLineLink2.Reset();
                UnitLineLink2.SetRange("Unit No.", UnitLineLink."Unit No.");
                UnitLineLink2.Setrange("Unit Line No.", UnitLineLink."Unit Line No.");
                UnitLineLink2.SetRange("Source Type", Database::"Purchase Line");
                UnitLineLink2.Setrange("Source ID", ReturnShptLine."Return Order No.");
                UnitLineLink2.Setrange("Source Ref. No.", ReturnShptLine."Return Order Line No.");
                UnitLineLink2.DeleteAll(true);
            until UnitLineLink.Next() = 0;
    end;

    /// <summary>
    /// Undo Return Shipment Line
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Undo Return Receipt Line", 'OnAfterReturnRcptLineModify', '', false, false)]
    local procedure AfterReturnRcptLineModify(var ReturnRcptLine: Record "Return Receipt Line"; var TempWhseJnlLine: Record "Warehouse Journal Line" temporary; DocLineNo: Integer; HideDialog: Boolean)
    var
        UnitLineLink: Record "TMAC Unit Line Link";
        UnitLineLink2: Record "TMAC Unit Line Link";
        ReverseUnitLineLink: Record "TMAC Unit Line Link";
    begin
        if not UnitLineLink.ReadPermission then
            Error(LogisticUnitModuleAccessErr);

        UnitLineLink.SetRange("Source Type", Database::"Return Receipt Line");
        UnitLineLink.SetRange("Source Subtype", 0);
        UnitLineLink.SetRange("Source ID", ReturnRcptLine."Document No.");
        UnitLineLink.SetRange("Source Ref. No.", ReturnRcptLine."Line No.");
        if UnitLineLink.FindSet() then
            repeat
                ReverseUnitLineLink.Init();
                ReverseUnitLineLink.TransferFields(UnitLineLink);
                ReverseUnitLineLink."Source Ref. No." := DocLineNo;
                ReverseUnitLineLink."Quantity" := -UnitLineLink.Quantity;
                ReverseUnitLineLink."Quantity (Base)" := -UnitLineLink."Quantity (Base)";
                ReverseUnitLineLink.Positive := not UnitLineLink.Positive;
                ReverseUnitLineLink.Insert(true);

                UnitLineLink2.Reset();
                UnitLineLink2.SetRange("Unit No.", UnitLineLink."Unit No.");
                UnitLineLink2.Setrange("Unit Line No.", UnitLineLink."Unit Line No.");
                UnitLineLink2.SetRange("Source Type", Database::"Sales Line");
                UnitLineLink2.Setrange("Source ID", ReturnRcptLine."Return Order No.");
                UnitLineLink2.Setrange("Source Ref. No.", ReturnRcptLine."Return Order Line No.");
                UnitLineLink2.DeleteAll(true);
            until UnitLineLink.Next() = 0;
    end;
    #endregion

    #region Inventory PutAway
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Inventory Put-away", OnBeforeInsertWhseActivLine, '', false, false)]
    local procedure OnBeforeInsertWhseActivLine(var WarehouseActivityLine: Record "Warehouse Activity Line");
    begin
        TransferLinksForInventoryPutawayPicks(
            WarehouseActivityLine."Source Type", WarehouseActivityLine."Source Subtype", WarehouseActivityLine."Source No.", WarehouseActivityLine."Source Line No.", WarehouseActivityLine."Lot No.", WarehouseActivityLine."Serial No.", WarehouseActivityLine."Package No.", true,
            Database::"Warehouse Activity Line", WarehouseActivityLine."Activity Type".AsInteger(), WarehouseActivityLine."No.", WarehouseActivityLine."Line No.", false);
    end;
    #endregion

    #region Creating a Warehouse Shipment line from different sources
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Warehouse Mgt.", 'OnAfterCreateShptLineFromSalesLine', '', false, false)]
    local procedure AfterCreateShptLineFromSalesLine(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; WarehouseShipmentHeader: Record "Warehouse Shipment Header"; SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    begin
        TransferLinksToNewDocument(
            Database::"Sales Line", SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.", false,
            Database::"Warehouse Shipment Line", 0, WarehouseShipmentLine."No.", WarehouseShipmentLine."Line No.", false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchases Warehouse Mgt.", 'OnAfterCreateShptLineFromPurchLine', '', false, false)]
    local procedure AfterCreateShptLineFromPurchLine(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; WarehouseShipmentHeader: Record "Warehouse Shipment Header"; PurchaseLine: Record "Purchase Line")
    begin
        TransferLinksToNewDocument(
            Database::"Purchase Line", PurchaseLine."Document Type".AsInteger(), PurchaseLine."Document No.", PurchaseLine."Line No.", false,
            Database::"Warehouse Shipment Line", 0, WarehouseShipmentLine."No.", WarehouseShipmentLine."Line No.", false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Transfer Warehouse Mgt.", 'OnAfterCreateShptLineFromTransLine', '', false, false)]
    local procedure AfterCreateShptLineFromTransLine(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; WarehouseShipmentHeader: Record "Warehouse Shipment Header"; TransferLine: Record "Transfer Line"; TransferHeader: Record "Transfer Header")
    begin
        TransferLinksToNewDocument(
            Database::"Transfer Line", 0, TransferLine."Document No.", TransferLine."Line No.", false,
            Database::"Warehouse Shipment Line", 0, WarehouseShipmentLine."No.", WarehouseShipmentLine."Line No.", false);
    end;
    #endregion

    #region Creating a Warehouse Receipt line from different sources
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Warehouse Mgt.", 'OnAfterCreateRcptLineFromSalesLine', '', false, false)]
    local procedure AfterCreateRcptLineFromSalesLine(var WarehouseReceiptLine: Record "Warehouse Receipt Line"; WarehouseReceiptHeader: Record "Warehouse Receipt Header"; SalesLine: Record "Sales Line")
    begin
        TransferLinksToNewDocument(
          Database::"Sales Line", SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.", true,
          Database::"Warehouse Receipt Line", 0, WarehouseReceiptLine."No.", WarehouseReceiptLine."Line No.", false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchases Warehouse Mgt.", 'OnAfterCreateRcptLineFromPurchLine', '', false, false)]
    local procedure AfterCreateRcptLineFromPurchLine(var WarehouseReceiptLine: Record "Warehouse Receipt Line"; WarehouseReceiptHeader: Record "Warehouse Receipt Header"; PurchaseLine: Record "Purchase Line")
    begin
        TransferLinksToNewDocument(
            Database::"Purchase Line", PurchaseLine."Document Type".AsInteger(), PurchaseLine."Document No.", PurchaseLine."Line No.", true,
            Database::"Warehouse Receipt Line", 0, WarehouseReceiptLine."No.", WarehouseReceiptLine."Line No.", false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Transfer Warehouse Mgt.", 'OnAfterCreateRcptLineFromTransLine', '', false, false)]
    local procedure AfterCreateRcptLineFromTransLine(var WarehouseReceiptLine: Record "Warehouse Receipt Line"; WarehouseReceiptHeader: Record "Warehouse Receipt Header"; TransferLine: Record "Transfer Line")
    begin
        TransferLinksToNewDocument(
            Database::"Transfer Line", 1, TransferLine."Document No.", TransferLine."Line No.", true,
            Database::"Warehouse Receipt Line", 0, WarehouseReceiptLine."No.", WarehouseReceiptLine."Line No.", false);
    end;

    local procedure TransferLinksToNewDocument(SourceType: Integer; SourceSubtype: Integer; SourceID: code[20]; SourceLineNo: Integer; Positive: Boolean; PostedSourceType: Integer; PostedSourceSubtype: Integer; PostedSourceID: code[20]; PostedSourceLineNo: Integer; Calculation: Boolean)
    var
        UnitLineLink: Record "TMAC Unit Line Link";
        NewUnitLineLink: Record "TMAC Unit Line Link";
    begin
        UnitLineLink.Reset();
        UnitLineLink.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.", "Package No.", "Lot No.", "Serial No.", "Positive", "Qty. to Post");
        UnitLineLink.Setrange("Source Type", SourceType);
        UnitLineLink.Setrange("Source Subtype", SourceSubtype);
        UnitLineLink.Setrange("Source ID", SourceID);
        UnitLineLink.Setrange("Source Ref. No.", SourceLineNo);
        UnitLineLink.Setrange(Positive, Positive);
        if UnitLineLink.findset(false) then
            repeat
                NewUnitLineLink.Init();
                NewUnitLineLink.TransferFields(UnitLineLink);
                NewUnitLineLink.Validate("Source Type", PostedSourceType);
                NewUnitLineLink.Validate("Source Subtype", PostedSourceSubtype);
                NewUnitLineLink.Validate("Source ID", PostedSourceID);
                NewUnitLineLink.Validate("Source Ref. No.", PostedSourceLineNo);
                NewUnitLineLink.Calculation := Calculation;
                NewUnitLineLink.Insert(true);
            until UnitLineLink.next() = 0;
    end;

    local procedure TransferLinksForInventoryPutawayPicks(SourceType: Integer; SourceSubtype: Integer; SourceID: code[20]; SourceLineNo: Integer; LotNo: Code[50]; SerialNo: Code[50]; PackageNo: Code[50]; Positive: Boolean; PostedSourceType: Integer; PostedSourceSubtype: Integer; PostedSourceID: code[20]; PostedSourceLineNo: Integer; Calculation: Boolean)
    var
        UnitLineLink: Record "TMAC Unit Line Link";
        NewUnitLineLink: Record "TMAC Unit Line Link";
    begin
        UnitLineLink.Reset();
        UnitLineLink.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.", "Package No.", "Lot No.", "Serial No.", "Positive", "Qty. to Post");
        UnitLineLink.Setrange("Source Type", SourceType);
        UnitLineLink.Setrange("Source Subtype", SourceSubtype);
        UnitLineLink.Setrange("Source ID", SourceID);
        UnitLineLink.Setrange("Source Ref. No.", SourceLineNo);
        UnitLineLink.SetRange("Lot No.", LotNo);
        UnitLineLink.SetRange("Serial No.", SerialNo);
        UnitLineLink.SetRange("Package No.", PackageNo);
        UnitLineLink.Setrange(Positive, Positive);
        if UnitLineLink.findset(false) then
            repeat
                NewUnitLineLink.Init();
                NewUnitLineLink.TransferFields(UnitLineLink);
                NewUnitLineLink.Validate("Source Type", PostedSourceType);
                NewUnitLineLink.Validate("Source Subtype", PostedSourceSubtype);
                NewUnitLineLink.Validate("Source ID", PostedSourceID);
                NewUnitLineLink.Validate("Source Ref. No.", PostedSourceLineNo);
                NewUnitLineLink.Calculation := Calculation;
                NewUnitLineLink.Insert(true);
            until UnitLineLink.next() = 0;
    end;
    #endregion


    var
        UnitPost: Codeunit "TMAC Unit Post";
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
        LogisticUnitModuleAccessErr: Label 'The user does not have access permission to the logistics units management system. Please inform the administrator.';
}