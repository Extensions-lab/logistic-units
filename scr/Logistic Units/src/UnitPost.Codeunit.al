/// <summary>
/// Codeunit that performs accounting by logistics units.
/// </summary>
codeunit 71628581 "TMAC Unit Post"
{
    /// <summary>
    /// Accounting for a logistics unit, for example shipment accounting,  
    /// i.e., accounting for the items included in the logistics unit
    /// </summary>
    /// <param name="UnitNo">Logistics unit code</param>
    /// <param name="SourceType">Source table — determines which type of accounting is performed</param>
    /// <param name="Sourcesubtype">Source subtype</param>
    /// <param name="SourceID">Source document number</param>
    procedure Post(SourceType: Integer; SourceSubType: Integer; SourceID: Code[20]; OppositeSourceType: Integer; Positive: Boolean)
    var
        Location: Record Location;
        UnitLine: Record "TMAC Unit Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        UnitLineLinkSelect: Record "TMAC Unit Line Link";
        FullSourceDocumentLink: Record "TMAC Source Document Link";
        GroupedSourceDocumentLink: Record "TMAC Source Document Link";
        UnitSelectBySource: Record "TMAC Unit Select By Source";
        UnitManagement: Codeunit "TMAC Unit Management";
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
        UnitSelection: Page "TMAC Unit Selection";
        Units: List of [Code[20]];
        SentToPost: List of [Code[20]];
        UnitNo: Code[20];
    begin
        if SourceID = '' then
            exit;

        //showing those LUs for the document that can be posted for
        UnitLineLinkSelect.Reset();
        UnitLineLinkSelect.Setrange("Source Type", SourceType);
        UnitLineLinkSelect.SetRange("Source Subtype", SourceSubType);
        UnitLineLinkSelect.Setrange("Source ID", SourceID);
        UnitLineLinkSelect.Setfilter(Quantity, '<>0');
        UnitLineLinkSelect.Setrange(Positive, Positive); //only accounting of a specific type — relevant for transfers (shipment or recei
        UnitLineLinkSelect.SetRange(Posted, false);
        UnitLineLinkSelect.SetLoadFields("Unit No.");
        if UnitLineLinkSelect.findset(false) then
            repeat
                if not Units.Contains(UnitLineLinkSelect."Unit No.") then
                    Units.Add(UnitLineLinkSelect."Unit No.");
            until UnitLineLinkSelect.next() = 0;

        if Units.Count() = 0 then
            Error(AllLogisticUnitsAlreadyPostedErr);

        //filling the table for selecting logistics units (just a logistics unit selection page with additional fields)
        UnitManagement.CompleteUnitSelection(Units, UnitSelectBySource);
        UnitSelectBySource.Reset();
        if UnitSelectBySource.findset(false) then
            repeat
                UnitSelection.AddLine(UnitSelectBySource);
            until UnitSelectBySource.next() = 0;

        UnitSelection.LookupMode(true);
        if UnitSelection.RunModal() = Action::LookupOK then begin
            UnitSelection.SetSelectionFilter(UnitSelectBySource);
            UnitSelectBySource.MarkedOnly(true);

            //forced update (most likely unnecessary in normal operation...  
            //leftover from debugging to fill the Qty to Post field)  
            //for the posted document
            UnitLineLink.Reset();
            UnitLineLink.SetRange("Source Type", SourceType);
            UnitLineLink.SetRange("Source ID", SourceID); //only for the order from which it is called   
            if UnitLineLink.FindSet() then
                repeat
                    UnitLineLink."Qty. to Post" := 0;
                    UnitLineLink.Modify(true);
                    ZeroQtyToPostSourceLinks(UnitLineLink);
                until UnitLineLink.Next() = 0;

            if UnitSelectBySource.findset() then
                repeat
                    if not SentToPost.Contains(UnitSelectBySource."Unit No.") then begin
                        SentToPost.Add(UnitSelectBySource."Unit No.");

                        //control to ensure that a pallet can contain multiple orders
                        UnitLineLink.Reset();
                        UnitLineLink.SetRange("Unit No.", UnitSelectBySource."Unit No.");
                        UnitLineLink.SetRange("Source Type", SourceType);
                        UnitLineLink.SetRange("Source Subtype", SourceSubType);
                        UnitLineLink.SetFilter("Source ID", '<>%1', SourceID);
                        if not UnitLineLink.IsEmpty then
                            if not Confirm(StrSubstNo(SeveralSourceUnitPostQst, UnitSelectBySource."Unit No.")) then
                                exit;

                        UnitLine.Reset();
                        UnitLine.Setrange("Unit No.", UnitSelectBySource."Unit No.");
                        if UnitLine.findset(false) then
                            repeat
                                if Location.Get(UnitLine."Location Code") then
                                    if Location."TMAC Disable Negative Quantity" then begin
                                        UnitLine.CalcFields("Expected Quantity");
                                        if UnitLine."Expected Quantity" <> 0 then
                                            error(LocationNegQtyReqErr, UnitLine."Location Code", UnitLine."Unit No.");
                                    end;

                                UnitLineLink.Reset();
                                UnitLineLink.SetRange("Unit No.", UnitLine."Unit No.");
                                UnitLineLink.SetRange("Unit Line No.", UnitLine."Line No.");
                                UnitLineLink.SetRange("Source Type", SourceType);
                                UnitLineLink.SetRange("Source ID", SourceID); //only for the order from which we are calling
                                UnitLineLink.SetRange(Positive, Positive); //only accounting of a specific type — relevant for transfers (shipment or receipt)
                                if UnitLineLink.FindSet() then
                                    repeat
                                        UnitLineLink."Qty. to Post" := ABS(UnitLineLink.Quantity);  //without sign since documents have no sign
                                        UnitLineLink.Modify(true);
                                        ChangeSourceLinks(UnitLineLink, UnitLineLink."Qty. to Post"); //so that purchase or sales sources are posted for
                                        AddOrUpdateLink(GroupedSourceDocumentLink, FullSourceDocumentLink, UnitLineLink);
                                        if OppositeSourceType = Database::"Direct Trans. Line" then
                                            UnitLinkManagement.CreateReverseLink(UnitLineLink, false);
                                    until UnitLineLink.next() = 0;
                            until UnitLine.next() = 0;
                    end;
                until UnitSelectBySource.next() = 0;


            foreach UnitNo in SentToPost do
                AfterPostChangesInLogisticUnit(UnitNo, SourceType, OppositeSourceType);

            //FullSourceDocumentLink - all links for tracing  
            //GroupedSourceDocumentLink - artificial links grouped by document line

            case SourceType of
                Database::"Warehouse Shipment Line":
                    PostWarehouseShipmentLines(GroupedSourceDocumentLink, FullSourceDocumentLink);
                Database::"Sales Line":
                    PostSalesLines(GroupedSourceDocumentLink, FullSourceDocumentLink);
                Database::"Warehouse Receipt Line":
                    PostWarehouseReceiptLines(GroupedSourceDocumentLink, FullSourceDocumentLink);
                Database::"Purchase Line":
                    PostPurchaseLines(GroupedSourceDocumentLink, FullSourceDocumentLink);
                Database::"Transfer Line":
                    PostTransferLines(GroupedSourceDocumentLink, FullSourceDocumentLink, OppositeSourceType);
            //Database::"Invt. Document Line":
            //    PostInvtDocumentLines(GroupedSourceDocumentLink, FullSourceDocumentLink);
            end;
        end;
    end;


    /// <summary>
    /// Accounting for purchases or other documents by logistics unit.  
    /// SourceType — the table can be either a purchase line or a sales line.  
    /// OppositeSourceType — the table is a line of the accounted document.
    /// </summary>
    /// <param name="Unit">Logistics unit</param>
    procedure PostByLogisticUnit(UnitNo: Code[20]; SourceType: Integer; OppositeSourceType: Integer)
    var
        Location: Record Location;
        UnitLine: Record "TMAC Unit Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        FullSourceDocumentLink: Record "TMAC Source Document Link";
        GroupedSourceDocumentLink: Record "TMAC Source Document Link";
    begin
        UnitLineLink.Reset();
        UnitLineLink.SetRange("Unit No.", UnitNo);
        UnitLineLink.SetRange("Source Type", SourceType);
        UnitLineLink.SetFilter(Quantity, '<>0');
        if UnitLineLink.FindSet() then
            repeat
                UnitLine.Get(UnitLineLink."Unit No.", UnitLineLink."Unit Line No.");
                if Location.Get(UnitLine."Location Code") then
                    if Location."TMAC Disable Negative Quantity" then begin
                        UnitLine.CalcFields("Expected Quantity");
                        if UnitLine."Expected Quantity" <> 0 then
                            error(LocationNegQtyReqErr, UnitLine."Location Code", UnitLine."Unit No.");
                    end;

                UnitLineLink."Qty. to Post" := ABS(UnitLineLink.Quantity);
                UnitLineLink.Modify(true);
                AddOrUpdateLink(GroupedSourceDocumentLink, FullSourceDocumentLink, UnitLineLink);
                ChangeSourceLinks(UnitLineLink, UnitLineLink."Qty. to Post"); //so that purchase or sales sources are posted for
            until UnitLineLink.next() = 0;

        // FullSourceDocumentLink - all links  
        // GroupedSourceDocumentLink - artificial links grouped by document line

        AfterPostChangesInLogisticUnit(UnitNo, SourceType, OppositeSourceType);

        case SourceType of
            Database::"Warehouse Shipment Line":
                PostWarehouseShipmentLines(GroupedSourceDocumentLink, FullSourceDocumentLink);
            Database::"Sales Line":
                PostSalesLines(GroupedSourceDocumentLink, FullSourceDocumentLink);
            Database::"Warehouse Receipt Line":
                PostWarehouseReceiptLines(GroupedSourceDocumentLink, FullSourceDocumentLink);
            Database::"Purchase Line":
                PostPurchaseLines(GroupedSourceDocumentLink, FullSourceDocumentLink);
            Database::"Transfer Line":
                PostTransferLines(GroupedSourceDocumentLink, FullSourceDocumentLink, OppositeSourceType);
        end;
    end;

    local procedure ChangeSourceLinks(var UnitLineLink: Record "TMAC Unit Line Link"; QtyToPost: Decimal)
    var
        SourceUnitLineLink: Record "TMAC Unit Line Link";
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        Qty, CurrentQty : Decimal;
    begin
        Qty := QtyToPost;
        case UnitLineLink."Source Type" of
            Database::"Warehouse Shipment Line":
                begin
                    WarehouseShipmentLine.Get(UnitLineLink."Source ID", UnitLineLink."Source Ref. No.");
                    SourceUnitLineLink.Reset();
                    SourceUnitLineLink.Setrange("Unit No.", UnitLineLink."Unit No.");
                    SourceUnitLineLink.Setrange("Unit Line No.", UnitLineLink."Unit Line No.");
                    SourceUnitLineLink.Setrange("Source Type", WarehouseShipmentLine."Source Type");
                    SourceUnitLineLink.Setrange("Source Subtype", WarehouseShipmentLine."Source Subtype");
                    SourceUnitLineLink.Setrange("Source ID", WarehouseShipmentLine."Source No.");
                    SourceUnitLineLink.Setrange("Source Ref. No.", WarehouseShipmentLine."Source Line No.");
                    SourceUnitLineLink.Setrange("Lot No.", UnitLineLink."Lot No.");
                    SourceUnitLineLink.Setrange("Package No.", UnitLineLink."Package No.");
                    SourceUnitLineLink.SetRange("Serial No.", UnitLineLink."Serial No.");

                    if SourceUnitLineLink.findset() then
                        repeat
                            if Qty > 0 then begin
                                if Qty <= abs(SourceUnitLineLink.Quantity) then
                                    CurrentQty := Qty
                                else
                                    CurrentQty := abs(UnitLineLink.Quantity);
                                SourceUnitLineLink."Qty. to Post" := CurrentQty;
                                SourceUnitLineLink.Modify(false);
                                Qty := Qty - CurrentQty;
                            end;
                        until SourceUnitLineLink.next() = 0;
                end;
            Database::"Warehouse Receipt Line":
                begin
                    WarehouseReceiptLine.Get(UnitLineLink."Source ID", UnitLineLink."Source Ref. No.");
                    SourceUnitLineLink.Reset();
                    SourceUnitLineLink.Setrange("Unit No.", UnitLineLink."Unit No.");
                    SourceUnitLineLink.Setrange("Unit Line No.", UnitLineLink."Unit Line No.");
                    SourceUnitLineLink.Setrange("Source Type", WarehouseReceiptLine."Source Type");
                    SourceUnitLineLink.Setrange("Source Subtype", WarehouseReceiptLine."Source Subtype");
                    SourceUnitLineLink.Setrange("Source ID", WarehouseReceiptLine."Source No.");
                    SourceUnitLineLink.Setrange("Source Ref. No.", WarehouseReceiptLine."Source Line No.");
                    SourceUnitLineLink.Setrange("Lot No.", UnitLineLink."Lot No.");
                    SourceUnitLineLink.Setrange("Package No.", UnitLineLink."Package No.");
                    SourceUnitLineLink.SetRange("Serial No.", UnitLineLink."Serial No.");

                    if SourceUnitLineLink.findset() then
                        repeat
                            if Qty > 0 then begin
                                if Qty <= abs(SourceUnitLineLink.Quantity) then
                                    CurrentQty := Qty
                                else
                                    CurrentQty := abs(UnitLineLink.Quantity);
                                SourceUnitLineLink."Qty. to Post" := CurrentQty;
                                SourceUnitLineLink.Modify(false);
                                Qty := Qty - CurrentQty;
                            end;
                        until SourceUnitLineLink.next() = 0;
                end;
        end;
    end;

    local procedure ZeroQtyToPostSourceLinks(var UnitLineLink: Record "TMAC Unit Line Link")
    var
        SourceUnitLineLink: Record "TMAC Unit Line Link";
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
    begin
        case UnitLineLink."Source Type" of
            Database::"Warehouse Shipment Line":
                begin
                    WarehouseShipmentLine.Get(UnitLineLink."Source ID", UnitLineLink."Source Ref. No.");
                    SourceUnitLineLink.Reset();
                    SourceUnitLineLink.Setrange("Unit No.", UnitLineLink."Unit No.");
                    SourceUnitLineLink.Setrange("Unit Line No.", UnitLineLink."Unit Line No.");
                    SourceUnitLineLink.Setrange("Source Type", WarehouseShipmentLine."Source Type");
                    SourceUnitLineLink.Setrange("Source Subtype", WarehouseShipmentLine."Source Subtype");
                    SourceUnitLineLink.Setrange("Source ID", WarehouseShipmentLine."Source No.");
                    SourceUnitLineLink.Setrange("Source Ref. No.", WarehouseShipmentLine."Source Line No.");
                    SourceUnitLineLink.Setrange("Lot No.", UnitLineLink."Lot No.");
                    SourceUnitLineLink.Setrange("Package No.", UnitLineLink."Package No.");
                    SourceUnitLineLink.SetRange("Serial No.", UnitLineLink."Serial No.");
                    if SourceUnitLineLink.findset() then
                        repeat
                            SourceUnitLineLink."Qty. to Post" := 0;
                            SourceUnitLineLink.Modify(false);
                        until SourceUnitLineLink.next() = 0;
                end;
            Database::"Warehouse Receipt Line":
                begin
                    WarehouseReceiptLine.Get(UnitLineLink."Source ID", UnitLineLink."Source Ref. No.");
                    SourceUnitLineLink.Reset();
                    SourceUnitLineLink.Setrange("Unit No.", UnitLineLink."Unit No.");
                    SourceUnitLineLink.Setrange("Unit Line No.", UnitLineLink."Unit Line No.");
                    SourceUnitLineLink.Setrange("Source Type", WarehouseReceiptLine."Source Type");
                    SourceUnitLineLink.Setrange("Source Subtype", WarehouseReceiptLine."Source Subtype");
                    SourceUnitLineLink.Setrange("Source ID", WarehouseReceiptLine."Source No.");
                    SourceUnitLineLink.Setrange("Source Ref. No.", WarehouseReceiptLine."Source Line No.");
                    SourceUnitLineLink.Setrange("Lot No.", UnitLineLink."Lot No.");
                    SourceUnitLineLink.Setrange("Package No.", UnitLineLink."Package No.");
                    SourceUnitLineLink.SetRange("Serial No.", UnitLineLink."Serial No.");
                    if SourceUnitLineLink.findset() then
                        repeat
                            SourceUnitLineLink."Qty. to Post" := 0;
                            SourceUnitLineLink.Modify(false);
                        until SourceUnitLineLink.next() = 0;
                end;
        end;
    end;

    local procedure AfterPostChangesInLogisticUnit(UnitNo: Code[20]; SourceType: Integer; OppositeSourceType: Integer)
    var
        UnitAction: Record "TMAC Unit Action";
        UnitManagement: Codeunit "TMAC Unit Management";
        Found: Boolean;
    begin
        case SourceType of
            Database::"Sales Line":
                begin
                    UnitAction.Setrange("Sale", true);
                    if UnitAction.FindFirst() then
                        Found := true;
                end;
            Database::"Warehouse Shipment Line":
                begin
                    UnitAction.Setrange("Warehouse Shipment", true);
                    if UnitAction.FindFirst() then
                        Found := true;
                end;
            Database::"Purchase Line":
                begin
                    UnitAction.Setrange(Purchase, true);
                    if UnitAction.FindFirst() then
                        Found := true;
                end;
            Database::"Warehouse Receipt Line":
                begin
                    UnitAction.Setrange("Warehouse receipt", true);
                    if UnitAction.FindFirst() then
                        Found := true;
                end;
            Database::"Transfer Line":
                case OppositeSourceType of
                    Database::"Transfer Shipment Line":
                        begin
                            UnitAction.Setrange("Warehouse Shipment", true);
                            if UnitAction.FindFirst() then
                                Found := true;
                        end;
                    Database::"Transfer Receipt Line":
                        begin
                            UnitAction.Setrange("Warehouse Receipt", true);
                            if UnitAction.FindFirst() then
                                Found := true;
                        end;
                end;
        end;

        if Found then
            UnitManagement.CreateUnitEntry(UnitNo, UnitAction.Code);
    end;


    /// <summary>
    /// Link collection is done with breakdown by lot and serial numbers
    /// </summary>
    local procedure AddOrUpdateLink(var GroupedSourceDocumentLink: Record "TMAC Source Document Link"; var SourceDocumentLink: Record "TMAC Source Document Link"; var UnitLineLink: Record "TMAC Unit Line Link")
    begin
        //links grouped by document line
        GroupedSourceDocumentLink.Reset();
        GroupedSourceDocumentLink.SetRange("Source Type", UnitLineLink."Source Type");
        GroupedSourceDocumentLink.Setrange("Source Subtype", UnitLineLink."Source Subtype");
        GroupedSourceDocumentLink.Setrange("Source ID", UnitLineLink."Source ID");
        GroupedSourceDocumentLink.Setrange("Source Batch Name", UnitLineLink."Source Batch Name");
        GroupedSourceDocumentLink.Setrange("Source Prod. Order Line", UnitLineLink."Source Prod. Order Line");
        GroupedSourceDocumentLink.Setrange("Source Ref. No.", UnitLineLink."Source Ref. No.");
        if GroupedSourceDocumentLink.FindFirst() then begin
            GroupedSourceDocumentLink.Quantity += UnitLineLink."Qty. to Post";
            GroupedSourceDocumentLink.Modify(true);
        end else begin
            GroupedSourceDocumentLink.Init();
            GroupedSourceDocumentLink.Clear();
            GroupedSourceDocumentLink."Source Type" := UnitLineLink."Source Type";
            GroupedSourceDocumentLink."Source Subtype" := UnitLineLink."Source Subtype";
            GroupedSourceDocumentLink."Source ID" := UnitLineLink."Source ID";
            GroupedSourceDocumentLink."Source Batch Name" := UnitLineLink."Source Batch Name";
            GroupedSourceDocumentLink."Source Prod. Order Line" := UnitLineLink."Source Prod. Order Line";
            GroupedSourceDocumentLink."Source Ref. No." := UnitLineLink."Source Ref. No.";
            GroupedSourceDocumentLink.Quantity := UnitLineLink."Qty. to Post";
            GroupedSourceDocumentLink.Insert(true);
        end;

        //all links grouped by source
        SourceDocumentLink.Reset();
        SourceDocumentLink.SetRange("Source Type", UnitLineLink."Source Type");
        SourceDocumentLink.Setrange("Source Subtype", UnitLineLink."Source Subtype");
        SourceDocumentLink.Setrange("Source ID", UnitLineLink."Source ID");
        SourceDocumentLink.Setrange("Source Batch Name", UnitLineLink."Source Batch Name");
        SourceDocumentLink.Setrange("Source Prod. Order Line", UnitLineLink."Source Prod. Order Line");
        SourceDocumentLink.Setrange("Source Ref. No.", UnitLineLink."Source Ref. No.");
        SourceDocumentLink.Setrange("Package No.", UnitLineLink."Package No.");
        SourceDocumentLink.Setrange("Lot No.", UnitLineLink."Lot No.");
        SourceDocumentLink.Setrange("Serial No.", UnitLineLink."Serial No.");
        if SourceDocumentLink.FindFirst() then begin
            SourceDocumentLink.Quantity += UnitLineLink."Qty. to Post";
            SourceDocumentLink.Modify(true);
        end else begin
            SourceDocumentLink.Init();
            SourceDocumentLink.Clear();
            SourceDocumentLink."Source Type" := UnitLineLink."Source Type";
            SourceDocumentLink."Source Subtype" := UnitLineLink."Source Subtype";
            SourceDocumentLink."Source ID" := UnitLineLink."Source ID";
            SourceDocumentLink."Source Batch Name" := UnitLineLink."Source Batch Name";
            SourceDocumentLink."Source Prod. Order Line" := UnitLineLink."Source Prod. Order Line";
            SourceDocumentLink."Source Ref. No." := UnitLineLink."Source Ref. No.";
            SourceDocumentLink."Package No." := UnitLineLink."Package No.";
            SourceDocumentLink."Lot No." := UnitLineLink."Lot No.";
            SourceDocumentLink."Serial No." := UnitLineLink."Serial No.";
            SourceDocumentLink."Positive" := UnitLineLink.Positive;
            SourceDocumentLink."Quantity" := UnitLineLink."Qty. to Post";
            SourceDocumentLink.insert(true);
        end;
    end;

    /// <summary>
    /// Posting for sales lines
    /// </summary>
    /// <param name="SourceDocumentLink">Link to the source document</param>
    local procedure PostSalesLines(var GroupedSourceDocumentLink: Record "TMAC Source Document Link"; var FullSourceDocumentLink: Record "TMAC Source Document Link")
    var
        TempSalesHeader: Record "Sales Header" temporary;
        SalesHeader: Record "Sales Header";
        SalesLIne: Record "Sales Line";
    begin
        //set all quantities for shipment
        GroupedSourceDocumentLink.Reset();
        if GroupedSourceDocumentLink.FindSet() then
            repeat
                if not TempSalesHeader.Get(GroupedSourceDocumentLink."Source Subtype", GroupedSourceDocumentLink."Source ID") then begin
                    TempSalesHeader.init();
                    TempSalesHeader."Document Type" := "Sales Document Type".FromInteger(GroupedSourceDocumentLink."Source Subtype");
                    TempSalesHeader."No." := GroupedSourceDocumentLink."Source ID";
                    TempSalesHeader.Insert(false);

                    SalesLine.Reset();
                    SalesLine.Setrange("Document Type", GroupedSourceDocumentLink."Source Subtype");
                    SalesLine.Setrange("Document No.", GroupedSourceDocumentLink."Source ID");
                    if SalesLine.findset(true) then
                        repeat
                            case SalesLine."Document Type" of
                                "Purchase Document Type"::Order:
                                    SalesLine.Validate("Qty. to Ship", 0);
                                "Purchase Document Type"::"Return Order":
                                    SalesLine.Validate("Return Qty. to Receive", 0);
                            end;
                            SalesLine.Modify(true);
                        until SalesLine.next() = 0;
                end;
            until GroupedSourceDocumentLink.next() = 0;

        GroupedSourceDocumentLink.Reset();
        if GroupedSourceDocumentLink.FindSet() then
            repeat
                SalesLine.Get(GroupedSourceDocumentLink."Source Subtype", GroupedSourceDocumentLink."Source ID", GroupedSourceDocumentLink."Source Ref. No.");
                case SalesLine."Document Type" of
                    "Sales Document Type"::Order:
                        SalesLine.Validate("Qty. to Ship", GroupedSourceDocumentLink.Quantity);
                    "Sales Document Type"::"Return Order":
                        SalesLine.Validate("Return Qty. to Receive", GroupedSourceDocumentLink.Quantity);
                end;
                SalesLine.Modify(true);

                SetHandleQtyToZero(GroupedSourceDocumentLink."Source Type", GroupedSourceDocumentLink."Source Subtype", GroupedSourceDocumentLink."Source ID", GroupedSourceDocumentLink."Source Ref. No.");

                FullSourceDocumentLink.Reset();
                FullSourceDocumentLink.Setrange("Source Type", Database::"Sales Line");
                FullSourceDocumentLink.Setrange("Source Subtype", GroupedSourceDocumentLink."Source Subtype");
                FullSourceDocumentLink.Setrange("Source ID", GroupedSourceDocumentLink."Source ID");
                FullSourceDocumentLink.Setrange("Source Ref. No.", GroupedSourceDocumentLink."Source Ref. No.");
                if FullSourceDocumentLink.FindSet(false) then
                    repeat
                        SetTrackingHandledQty(FullSourceDocumentLink);
                    until FullSourceDocumentLink.Next() = 0;
            until GroupedSourceDocumentLink.next() = 0;

        //Posting
        TempSalesHeader.Reset();
        if TempSalesHeader.FindSet() then
            repeat
                SalesHeader.Get(TempSalesHeader."Document Type", TempSalesHeader."No.");
                SalesHeader.SendToPosting(CODEUNIT::"Sales-Post (Yes/No)");
            until TempSalesHeader.next() = 0;
    end;

    local procedure PostPurchaseLines(var GroupedSourceDocumentLink: Record "TMAC Source Document Link"; var FullSourceDocumentLink: Record "TMAC Source Document Link")
    var
        TempPurchaseHeader: Record "Purchase Header" temporary;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        GroupedSourceDocumentLink.Reset();
        if GroupedSourceDocumentLink.FindSet() then
            repeat
                if not TempPurchaseHeader.Get(GroupedSourceDocumentLink."Source Subtype", GroupedSourceDocumentLink."Source ID") then begin
                    TempPurchaseHeader.init();
                    TempPurchaseHeader."Document Type" := "Purchase Document Type".FromInteger(GroupedSourceDocumentLink."Source Subtype");
                    TempPurchaseHeader."No." := GroupedSourceDocumentLink."Source ID";
                    TempPurchaseHeader.Insert(false);

                    //set zero for all other lines to be accounted
                    PurchaseLine.Reset();
                    PurchaseLine.Setrange("Document Type", GroupedSourceDocumentLink."Source Subtype");
                    PurchaseLine.Setrange("Document No.", GroupedSourceDocumentLink."Source ID");
                    if PurchaseLine.findset(true) then
                        repeat
                            case PurchaseLine."Document Type" of
                                "Purchase Document Type"::Order:
                                    PurchaseLine.Validate("Qty. to Receive", 0);
                                "Purchase Document Type"::"Return Order":
                                    PurchaseLine.Validate("Return Qty. to Ship", 0);
                            end;
                            PurchaseLine.Modify(true);
                        until PurchaseLine.next() = 0;
                end;
            until GroupedSourceDocumentLink.next() = 0;

        GroupedSourceDocumentLink.Reset();
        if GroupedSourceDocumentLink.FindSet() then
            repeat
                PurchaseLine.Get(GroupedSourceDocumentLink."Source Subtype", GroupedSourceDocumentLink."Source ID", GroupedSourceDocumentLink."Source Ref. No.");
                case PurchaseLine."Document Type" of
                    "Purchase Document Type"::Order:
                        PurchaseLine.Validate("Qty. to Receive", GroupedSourceDocumentLink.Quantity);
                    "Purchase Document Type"::"Return Order":
                        PurchaseLine.Validate("Return Qty. to Ship", GroupedSourceDocumentLink.Quantity);
                end;
                PurchaseLine.Modify(true);

                SetHandleQtyToZero(GroupedSourceDocumentLink."Source Type", GroupedSourceDocumentLink."Source Subtype", GroupedSourceDocumentLink."Source ID", GroupedSourceDocumentLink."Source Ref. No.");

                FullSourceDocumentLink.Reset();
                FullSourceDocumentLink.Setrange("Source Type", Database::"Purchase Line");
                FullSourceDocumentLink.Setrange("Source Subtype", GroupedSourceDocumentLink."Source Subtype");
                FullSourceDocumentLink.Setrange("Source ID", GroupedSourceDocumentLink."Source ID");
                FullSourceDocumentLink.Setrange("Source Ref. No.", GroupedSourceDocumentLink."Source Ref. No.");
                if FullSourceDocumentLink.FindSet(false) then
                    repeat
                        SetTrackingHandledQty(FullSourceDocumentLink);
                    until FullSourceDocumentLink.Next() = 0;
            until GroupedSourceDocumentLink.next() = 0;

        //Posting
        TempPurchaseHeader.Reset();
        if TempPurchaseHeader.FindSet() then
            repeat
                PurchaseHeader.Get(TempPurchaseHeader."Document Type", TempPurchaseHeader."No.");
                PurchaseHeader.SendToPosting(CODEUNIT::"Purch.-Post (Yes/No)");
            until TempPurchaseHeader.next() = 0;
    end;

    local procedure PostWarehouseReceiptLines(var GroupedSourceDocumentLink: Record "TMAC Source Document Link"; var FullSourceDocumentLink: Record "TMAC Source Document Link")
    var
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
        PostingDocs: List of [Code[20]];
        CurrentDoc: code[20];
    begin
        //set all quantities for shipment
        GroupedSourceDocumentLink.Reset();
        if GroupedSourceDocumentLink.FindSet() then
            repeat
                if not PostingDocs.Contains(GroupedSourceDocumentLink."Source ID") then begin
                    PostingDocs.Add(GroupedSourceDocumentLink."Source ID");

                    WarehouseReceiptLine.Reset();
                    WarehouseReceiptLine.Setrange("No.", GroupedSourceDocumentLink."Source ID");
                    if WarehouseReceiptLine.findset(true) then
                        repeat
                            WarehouseReceiptLine.Validate("Qty. to Receive", 0);
                            WarehouseReceiptLine.Modify(true);
                        until WarehouseReceiptLine.next() = 0;
                end;
            until GroupedSourceDocumentLink.next() = 0;

        GroupedSourceDocumentLink.Reset();
        if GroupedSourceDocumentLink.FindSet() then
            repeat
                WarehouseReceiptLine.Get(GroupedSourceDocumentLink."Source ID", GroupedSourceDocumentLink."Source Ref. No.");
                WarehouseReceiptLine.Validate("Qty. to Receive", GroupedSourceDocumentLink.Quantity);
                WarehouseReceiptLine.Modify(true);

                SetHandleQtyToZero(WarehouseReceiptLine."Source Type", WarehouseReceiptLine."Source Subtype", WarehouseReceiptLine."Source No.", WarehouseReceiptLine."Source Line No.");

                FullSourceDocumentLink.Reset();
                FullSourceDocumentLink.Setrange("Source Type", GroupedSourceDocumentLink."Source Type");
                FullSourceDocumentLink.Setrange("Source Subtype", GroupedSourceDocumentLink."Source Subtype");
                FullSourceDocumentLink.Setrange("Source ID", GroupedSourceDocumentLink."Source ID");
                FullSourceDocumentLink.Setrange("Source Ref. No.", GroupedSourceDocumentLink."Source Ref. No.");
                if FullSourceDocumentLink.FindSet(false) then
                    repeat
                        SetTrackingHandledQtyWMS(FullSourceDocumentLink, WarehouseReceiptLine."Source Type", WarehouseReceiptLine."Source Subtype", WarehouseReceiptLine."Source No.", WarehouseReceiptLine."Source Line No.");
                    until FullSourceDocumentLink.Next() = 0;
            until GroupedSourceDocumentLink.next() = 0;

        foreach CurrentDoc in PostingDocs do begin
            WarehouseReceiptLine.Reset();
            WarehouseReceiptLine.Setrange("No.", CurrentDoc);
            CODEUNIT.Run(CODEUNIT::"Whse.-Post Receipt (Yes/No)", WarehouseReceiptLine);
        end;
    end;

    local procedure PostWarehouseShipmentLines(var GroupedSourceDocumentLink: Record "TMAC Source Document Link"; var FullSourceDocumentLink: Record "TMAC Source Document Link")
    var
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        PostingDocs: List of [Code[20]];
        CurrentDoc: code[20];
    begin
        //set all quantities for shipment
        GroupedSourceDocumentLink.Reset();
        if GroupedSourceDocumentLink.FindSet() then
            repeat
                if not PostingDocs.Contains(GroupedSourceDocumentLink."Source ID") then begin
                    PostingDocs.Add(GroupedSourceDocumentLink."Source ID");

                    WarehouseShipmentLine.Reset();
                    WarehouseShipmentLine.Setrange("No.", GroupedSourceDocumentLink."Source ID");
                    if WarehouseShipmentLine.findset(true) then
                        repeat
                            WarehouseShipmentLine.Validate("Qty. to Ship", 0);
                            WarehouseShipmentLine.Modify(true);
                        until WarehouseShipmentLine.next() = 0;
                end;
            until GroupedSourceDocumentLink.next() = 0;

        GroupedSourceDocumentLink.Reset();
        if GroupedSourceDocumentLink.FindSet() then
            repeat
                WarehouseShipmentLine.Get(GroupedSourceDocumentLink."Source ID", GroupedSourceDocumentLink."Source Ref. No.");
                WarehouseShipmentLine.Validate("Qty. to Ship", GroupedSourceDocumentLink.Quantity);
                WarehouseShipmentLine.Modify(true);

                SetHandleQtyToZero(WarehouseShipmentLine."Source Type", WarehouseShipmentLine."Source Subtype", WarehouseShipmentLine."Source No.", WarehouseShipmentLine."Source Line No.");

                FullSourceDocumentLink.Reset();
                FullSourceDocumentLink.Setrange("Source Type", GroupedSourceDocumentLink."Source Type");
                FullSourceDocumentLink.Setrange("Source Subtype", GroupedSourceDocumentLink."Source Subtype");
                FullSourceDocumentLink.Setrange("Source ID", GroupedSourceDocumentLink."Source ID");
                FullSourceDocumentLink.Setrange("Source Ref. No.", GroupedSourceDocumentLink."Source Ref. No.");
                if FullSourceDocumentLink.FindSet(false) then
                    repeat
                        SetTrackingHandledQtyWMS(FullSourceDocumentLink, WarehouseShipmentLine."Source Type", WarehouseShipmentLine."Source Subtype", WarehouseShipmentLine."Source No.", WarehouseShipmentLine."Source Line No.");
                    until FullSourceDocumentLink.Next() = 0;
            until GroupedSourceDocumentLink.next() = 0;

        foreach CurrentDoc in PostingDocs do begin
            WarehouseShipmentLine.Reset();
            WarehouseShipmentLine.Setrange("No.", CurrentDoc);
            CODEUNIT.Run(CODEUNIT::"Whse.-Post Shipment (Yes/No)", WarehouseShipmentLine);
        end;
    end;

    local procedure PostTransferLines(var GroupedSourceDocumentLink: Record "TMAC Source Document Link"; var FullSourceDocumentLink: Record "TMAC Source Document Link"; OppositeSourceType: Integer)
    var
        InventorySetup: Record "Inventory Setup";
        TransferLine: Record "Transfer Line";
        TransferHeader: Record "Transfer Header";
        TransferOrderPostShipment: Codeunit "TransferOrder-Post Shipment";
        TransferOrderPostReceipt: Codeunit "TransferOrder-Post Receipt";
        TransferOrderPostTransfer: Codeunit "TransferOrder-Post Transfer";
        PostingDocs: List of [Code[20]];
        CurrentDoc: code[20];
    begin
        case OppositeSourceType of
            Database::"Transfer Shipment Line":
                begin
                    GroupedSourceDocumentLink.Reset();
                    if GroupedSourceDocumentLink.FindSet() then
                        repeat
                            if not PostingDocs.Contains(GroupedSourceDocumentLink."Source ID") then begin
                                PostingDocs.Add(GroupedSourceDocumentLink."Source ID");

                                TransferLine.Reset();
                                TransferLine.Setrange("Document No.", GroupedSourceDocumentLink."Source ID");
                                TransferLine.Setrange("Derived From Line No.", 0);
                                if TransferLine.findset(true) then
                                    repeat
                                        TransferLine.Validate("Qty. to Ship", 0);
                                        TransferLine.Modify(true);
                                    until TransferLine.next() = 0;
                            end;
                        until GroupedSourceDocumentLink.next() = 0;

                    GroupedSourceDocumentLink.Reset();
                    if GroupedSourceDocumentLink.FindSet() then
                        repeat
                            TransferLine.Get(GroupedSourceDocumentLink."Source ID", GroupedSourceDocumentLink."Source Ref. No.");
                            TransferLine.Validate("Qty. to Ship", GroupedSourceDocumentLink.Quantity);
                            TransferLine.Modify(true);

                            SetHandleQtyToZero(GroupedSourceDocumentLink."Source Type", GroupedSourceDocumentLink."Source Subtype", GroupedSourceDocumentLink."Source ID", GroupedSourceDocumentLink."Source Ref. No.");

                            FullSourceDocumentLink.Reset();
                            FullSourceDocumentLink.Setrange("Source Type", Database::"Transfer Line");
                            FullSourceDocumentLink.Setrange("Source Subtype", GroupedSourceDocumentLink."Source Subtype");
                            FullSourceDocumentLink.Setrange("Source ID", GroupedSourceDocumentLink."Source ID");
                            FullSourceDocumentLink.Setrange("Source Ref. No.", GroupedSourceDocumentLink."Source Ref. No.");
                            FullSourceDocumentLink.SetRange(Positive, false);
                            if FullSourceDocumentLink.FindSet(false) then
                                repeat
                                    SetTrackingHandledQty(FullSourceDocumentLink);
                                until FullSourceDocumentLink.Next() = 0;
                        until GroupedSourceDocumentLink.next() = 0;

                    foreach CurrentDoc in PostingDocs do begin
                        TransferHeader.Get(CurrentDoc);
                        TransferOrderPostShipment.Run(TransferHeader);
                    end;
                end;
            Database::"Transfer Receipt Line":
                begin
                    GroupedSourceDocumentLink.Reset();
                    if GroupedSourceDocumentLink.FindSet() then
                        repeat
                            if not PostingDocs.Contains(GroupedSourceDocumentLink."Source ID") then begin
                                PostingDocs.Add(GroupedSourceDocumentLink."Source ID");

                                TransferLine.Reset();
                                TransferLine.Setrange("Document No.", GroupedSourceDocumentLink."Source ID");
                                TransferLine.Setrange("Derived From Line No.", 0);
                                if TransferLine.findset(true) then
                                    repeat
                                        TransferLine.Validate("Qty. to Receive", 0);
                                        TransferLine.Modify(true);
                                    until TransferLine.next() = 0;
                            end;
                        until GroupedSourceDocumentLink.next() = 0;

                    GroupedSourceDocumentLink.Reset();
                    if GroupedSourceDocumentLink.FindSet() then
                        repeat
                            TransferLine.Get(GroupedSourceDocumentLink."Source ID", GroupedSourceDocumentLink."Source Ref. No.");
                            TransferLine.Validate("Qty. to Receive", GroupedSourceDocumentLink.Quantity);
                            TransferLine.Modify(true);

                            SetHandleQtyToZero(GroupedSourceDocumentLink."Source Type", GroupedSourceDocumentLink."Source Subtype", GroupedSourceDocumentLink."Source ID", GroupedSourceDocumentLink."Source Ref. No.");

                            FullSourceDocumentLink.Reset();
                            FullSourceDocumentLink.Setrange("Source Type", Database::"Transfer Line");
                            FullSourceDocumentLink.Setrange("Source Subtype", GroupedSourceDocumentLink."Source Subtype");
                            FullSourceDocumentLink.Setrange("Source ID", GroupedSourceDocumentLink."Source ID");
                            FullSourceDocumentLink.Setrange("Source Ref. No.", GroupedSourceDocumentLink."Source Ref. No.");
                            FullSourceDocumentLink.SetRange(Positive, true);
                            if FullSourceDocumentLink.FindSet(false) then
                                repeat
                                    SetTrackingHandledQty(FullSourceDocumentLink);
                                until FullSourceDocumentLink.Next() = 0;
                        until GroupedSourceDocumentLink.next() = 0;

                    foreach CurrentDoc in PostingDocs do begin
                        TransferHeader.Get(CurrentDoc);
                        TransferOrderPostReceipt.Run(TransferHeader);
                    end;
                end;
            Database::"Direct Trans. Line":
                begin
                    GroupedSourceDocumentLink.Reset();
                    if GroupedSourceDocumentLink.FindSet() then
                        repeat
                            if not PostingDocs.Contains(GroupedSourceDocumentLink."Source ID") then begin
                                PostingDocs.Add(GroupedSourceDocumentLink."Source ID");

                                TransferLine.Reset();
                                TransferLine.Setrange("Document No.", GroupedSourceDocumentLink."Source ID");
                                if TransferLine.findset(true) then
                                    repeat
                                        TransferLine.Validate("Qty. to Ship", 0);
                                        TransferLine.Modify(true);
                                    until TransferLine.next() = 0;
                            end;
                        until GroupedSourceDocumentLink.next() = 0;

                    GroupedSourceDocumentLink.Reset();
                    if GroupedSourceDocumentLink.FindSet() then
                        repeat
                            TransferLine.Get(GroupedSourceDocumentLink."Source ID", GroupedSourceDocumentLink."Source Ref. No.");
                            TransferLine.Validate("Qty. to Ship", GroupedSourceDocumentLink.Quantity);
                            TransferLine.Modify(true);
                        until GroupedSourceDocumentLink.next() = 0;

                    InventorySetup.Get();

                    foreach CurrentDoc in PostingDocs do begin
                        TransferHeader.Get(CurrentDoc);
                        case InventorySetup."Direct Transfer Posting" of
                            InventorySetup."Direct Transfer Posting"::"Receipt and Shipment":
                                begin
                                    TransferOrderPostShipment.Run(TransferHeader);
                                    TransferOrderPostReceipt.Run(TransferHeader);
                                end;
                            InventorySetup."Direct Transfer Posting"::"Direct Transfer":
                                TransferOrderPostTransfer.Run(TransferHeader);
                        end;
                    end;
                end;
        end;
    end;

    local procedure SetTrackingHandledQty(var FullSourceDocumentLink: record "TMAC Source Document Link")
    var
        ReservationEntry: Record "Reservation Entry";
        Qty: Decimal;
        CurrentQty: Decimal;
        Sign: Decimal;
    begin
        Qty := FullSourceDocumentLink.Quantity;
        ReservationEntry.Reset();
        ReservationEntry.SetCurrentKey("Source ID", "Source Ref. No.", "Source Type", "Source Subtype", "Source Batch Name", "Source Prod. Order Line", "Reservation Status", "Shipment Date", "Expected Receipt Date");
        ReservationEntry.SetFilter("Reservation Status", '%1|%2', "Reservation Status"::Reservation, "Reservation Status"::Surplus);
        ReservationEntry.Setrange("Source Type", FullSourceDocumentLink."Source Type");
        ReservationEntry.Setrange("Source Subtype", FullSourceDocumentLink."Source Subtype");
        ReservationEntry.Setrange("Source ID", FullSourceDocumentLink."Source ID");
        ReservationEntry.Setrange("Source Ref. No.", FullSourceDocumentLink."Source Ref. No.");
        ReservationEntry.SetRange("Lot No.", FullSourceDocumentLink."Lot No.");
        ReservationEntry.SetRange("Package No.", FullSourceDocumentLink."Package No.");
        ReservationEntry.SetRange("Serial No.", FullSourceDocumentLink."Serial No.");
        ReservationEntry.SetRange(Positive, FullSourceDocumentLink.Positive);
        if ReservationEntry.FindSet(false) then
            repeat
                if Qty > 0 then begin
                    if Qty < abs(ReservationEntry.Quantity) then
                        CurrentQty := Qty
                    else
                        CurrentQty := abs(ReservationEntry.Quantity);
                    Sign := ReservationEntry.Quantity / abs(ReservationEntry.Quantity);
                    ReservationEntry."Qty. to Handle (Base)" := Sign * CurrentQty * ReservationEntry."Qty. per Unit of Measure";
                    ReservationEntry."Qty. to Invoice (Base)" := Sign * CurrentQty * ReservationEntry."Qty. per Unit of Measure";
                    ReservationEntry.Modify(true);
                    Qty := Qty - CurrentQty;
                end;
            until ReservationEntry.Next() = 0;
    end;

    local procedure SetTrackingHandledQtyWMS(var FullSourceDocumentLink: record "TMAC Source Document Link"; DocumentSourceType: Integer; DocumentSourceSubtype: Integer; DocumentSourceID: code[20]; DocumentSourceLineNo: Integer)
    var
        ReservationEntry: Record "Reservation Entry";
        Qty: Decimal;
        CurrentQty: Decimal;
        Sign: Decimal;
    begin
        Qty := FullSourceDocumentLink.Quantity;
        ReservationEntry.Reset();
        ReservationEntry.SetCurrentKey("Source ID", "Source Ref. No.", "Source Type", "Source Subtype", "Source Batch Name", "Source Prod. Order Line", "Reservation Status", "Shipment Date", "Expected Receipt Date");
        ReservationEntry.SetFilter("Reservation Status", '%1|%2', "Reservation Status"::Reservation, "Reservation Status"::Surplus);

        ReservationEntry.Setrange("Source Type", DocumentSourceType);
        ReservationEntry.Setrange("Source Subtype", DocumentSourceSubtype);
        ReservationEntry.Setrange("Source ID", DocumentSourceID);
        ReservationEntry.Setrange("Source Ref. No.", DocumentSourceLineNo);

        ReservationEntry.SetRange("Lot No.", FullSourceDocumentLink."Lot No.");
        ReservationEntry.SetRange("Package No.", FullSourceDocumentLink."Package No.");
        ReservationEntry.SetRange("Serial No.", FullSourceDocumentLink."Serial No.");
        ReservationEntry.SetRange(Positive, FullSourceDocumentLink.Positive);
        if ReservationEntry.FindSet(false) then
            repeat
                if Qty > 0 then begin
                    if Qty < abs(ReservationEntry.Quantity) then
                        CurrentQty := Qty
                    else
                        CurrentQty := abs(ReservationEntry.Quantity);
                    Sign := ReservationEntry.Quantity / abs(ReservationEntry.Quantity);
                    ReservationEntry."Qty. to Handle (Base)" := Sign * CurrentQty * ReservationEntry."Qty. per Unit of Measure";
                    ReservationEntry."Qty. to Invoice (Base)" := Sign * CurrentQty * ReservationEntry."Qty. per Unit of Measure";
                    ReservationEntry.Modify(true);
                    Qty := Qty - CurrentQty;
                end;
            until ReservationEntry.Next() = 0;
    end;

    local procedure SetHandleQtyToZero(DocumentSourceType: Integer; DocumentSourceSubtype: Integer; DocumentSourceID: code[20]; DocumentSourceLineNo: Integer)
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        ReservationEntry.Reset();
        ReservationEntry.SetCurrentKey("Source ID", "Source Ref. No.", "Source Type", "Source Subtype", "Source Batch Name", "Source Prod. Order Line", "Reservation Status", "Shipment Date", "Expected Receipt Date");
        ReservationEntry.SetFilter("Reservation Status", '%1|%2', "Reservation Status"::Reservation, "Reservation Status"::Surplus);
        ReservationEntry.Setrange("Source Type", DocumentSourceType);
        ReservationEntry.Setrange("Source Subtype", DocumentSourceSubtype);
        ReservationEntry.Setrange("Source ID", DocumentSourceID);
        ReservationEntry.Setrange("Source Ref. No.", DocumentSourceLineNo);
        if ReservationEntry.Findset(true) then
            repeat
                ReservationEntry."Qty. to Handle (Base)" := 0;
                ReservationEntry."Qty. to Invoice (Base)" := 0;
                ReservationEntry.Modify(false);
            until ReservationEntry.Next() = 0;
    end;

    #region Link Control for Posting

    /// <summary>
    /// Accounting for links with tracing
    /// </summary>
    internal procedure PostLinksWithItemTracking(SourceType: Integer; SourceSubtype: Integer; SourceID: code[20]; SourceLineNo: Integer; Positive: Boolean; PostedSourceType: Integer; PostedSourceSubtype: Integer; PostedSourceID: code[20]; PostedSourceLineNo: Integer) Result: Boolean
    var
        ItemEntryRelation: Record "Item Entry Relation";
        ItemLedgerEntry: Record "Item Ledger Entry";
        UnitLineLink: Record "TMAC Unit Line Link";
    begin
        ItemEntryRelation.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Ref. No.", "Source Prod. Order Line", "Source Batch Name");
        ItemEntryRelation.SetRange("Source Type", PostedSourceType);
        ItemEntryRelation.SetRange("Source Subtype", PostedSourceSubtype);
        ItemEntryRelation.SetRange("Source ID", PostedSourceID);
        ItemEntryRelation.SetRange("Source Batch Name", '');
        ItemEntryRelation.SetRange("Source Prod. Order Line", 0);
        ItemEntryRelation.SetRange("Source Ref. No.", PostedSourceLineNo);
        ItemEntryRelation.SetLoadFields("Item Entry No.");
        if ItemEntryRelation.FindSet() then begin
            repeat
                ItemLedgerEntry.get(ItemEntryRelation."Item Entry No.");

                UnitLineLink.Reset();
                UnitLineLink.Setrange("Source Type", SourceType);
                UnitLineLink.Setrange("Source Subtype", SourceSubtype);
                UnitLineLink.Setrange("Source ID", SourceID);
                UnitLineLink.Setrange("Source Ref. No.", SourceLineNo);

                UnitLineLink.Setrange("Package No.", ItemLedgerEntry."Package No.");
                UnitLineLink.Setrange("Lot No.", ItemLedgerEntry."Lot No.");  //one lot can be distributed across different logistics units
                UnitLineLink.Setrange("Serial No.", ItemLedgerEntry."Serial No.");
                UnitLineLink.SetRange(Positive, Positive);

                UnitLineLink.SetFilter("Qty. to Post", '>0'); //we know for sure that all links have the sum of "Qty. to Post" equal to the document line's Posting Qty

                if UnitLineLink.FindSet(true) then
                    repeat
                        SendToPosted(UnitLineLink."Qty. to Post", UnitLineLink, PostedSourceType, PostedSourceSubtype, PostedSourceID, PostedSourceLineNo);
                        UnitLineLink."Qty. to Post" := 0;
                        UnitLineLink.Modify(true);
                    until UnitLineLink.Next() = 0;
            until ItemEntryRelation.next() = 0;
            Result := true;
        end;
    end;

    internal procedure PostLinksWithItemTrackingWMS(SourceType: Integer; SourceSubtype: Integer; SourceID: code[20]; SourceLineNo: Integer; Positive: Boolean; PostedSourceType: Integer; PostedSourceSubtype: Integer; PostedSourceID: code[20]; PostedSourceLineNo: Integer) Result: Boolean
    var
        WhseItemEntryRelation: Record "Whse. Item Entry Relation";
        ItemLedgerEntry: Record "Item Ledger Entry";
        UnitLineLink: Record "TMAC Unit Line Link";
    begin
        WhseItemEntryRelation.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Ref. No.", "Source Prod. Order Line", "Source Batch Name");
        WhseItemEntryRelation.SetRange("Source Type", PostedSourceType);
        WhseItemEntryRelation.SetRange("Source Subtype", PostedSourceSubtype);
        WhseItemEntryRelation.SetRange("Source ID", PostedSourceID);
        WhseItemEntryRelation.SetRange("Source Batch Name", '');
        WhseItemEntryRelation.SetRange("Source Prod. Order Line", 0);
        WhseItemEntryRelation.SetRange("Source Ref. No.", PostedSourceLineNo);
        WhseItemEntryRelation.SetLoadFields("Item Entry No.");
        if WhseItemEntryRelation.FindSet(false) then begin
            repeat
                ItemLedgerEntry.get(WhseItemEntryRelation."Item Entry No.");

                UnitLineLink.Reset();
                UnitLineLink.Setrange("Source Type", SourceType);
                UnitLineLink.Setrange("Source Subtype", SourceSubtype);
                UnitLineLink.Setrange("Source ID", SourceID);
                UnitLineLink.Setrange("Source Ref. No.", SourceLineNo);

                UnitLineLink.Setrange("Package No.", ItemLedgerEntry."Package No.");
                UnitLineLink.Setrange("Lot No.", ItemLedgerEntry."Lot No.");
                UnitLineLink.Setrange("Serial No.", ItemLedgerEntry."Serial No.");
                UnitLineLink.SetRange(Positive, Positive);

                UnitLineLink.SetFilter("Qty. to Post", '>0'); //we know for sure that all links have the sum of "Qty. to Post" equal to the document line's Posting Qty

                if UnitLineLink.FindSet(true) then
                    repeat
                        SendToPosted(UnitLineLink."Qty. to Post", UnitLineLink, PostedSourceType, PostedSourceSubtype, PostedSourceID, PostedSourceLineNo);
                        UnitLineLink."Qty. to Post" := 0;
                        UnitLineLink.Modify(true);
                    until UnitLineLink.Next() = 0;
            until WhseItemEntryRelation.next() = 0;
            Result := true;
        end;
    end;

    /// <summary>
    /// Transfer Links to Posted for selected Qty.
    /// </summary>
    /// <param name="Qty">Quantity</param>
    /// <param name="SourceType">SourceType of the unaccounted link</param>
    /// <param name="SourceSubtype">SourceSubtype of the unaccounted link</param>
    /// <param name="SourceID">SourceID of the unaccounted link</param>
    /// <param name="SourceLineNo">SourceLineNo of the unaccounted link</param>
    /// <param name="Positive">Type of link to transfer to accounted. A line may have 2 links — positive and negative</param>
    /// <param name="PostedSourceType">SourceType of the accounted link</param>
    /// <param name="PostedSourceSubtype">SourceSubtype of the accounted link</param>
    /// <param name="PostedSourceID">SourceID of the accounted link</param>
    /// <param name="PostedSourceLineNo">SourceLineNo of the accounted link</param>

    procedure PostLinks(Qty: Decimal; SourceType: Integer; SourceSubtype: Integer; SourceID: code[20]; SourceLineNo: Integer; Positive: Boolean; PostedSourceType: Integer; PostedSourceSubtype: Integer; PostedSourceID: code[20]; PostedSourceLineNo: Integer)
    var
        UnitLineLink: Record "TMAC Unit Line Link";
        CurrentQty: Decimal;
    begin
        SetSourceFilters(UnitLineLink, SourceType, SourceSubtype, SourceID, SourceLineNo, Positive); //main check: if there are pallets, then accounting is only done by them
        if UnitLineLink.FindSet(true) then
            repeat
                if Qty > 0 then begin
                    if Qty <= UnitLineLink."Qty. to Post" then
                        CurrentQty := Qty
                    else
                        CurrentQty := UnitLineLink."Qty. to Post";
                    SendToPosted(CurrentQty, UnitLineLink, PostedSourceType, PostedSourceSubtype, PostedSourceID, PostedSourceLineNo);
                    UnitLineLink."Qty. to Post" := UnitLineLink."Qty. to Post" - Qty; //the main thing is to ensure the sorting doesn’t change in the loop, since the field is part of the key, such an update could cause the loop to break if ordered differently
                    UnitLineLink.Modify(true);
                    Qty := Qty - CurrentQty;

                end;
            until UnitLineLink.next() = 0;
    end;

    local procedure SendToPosted(Qty: Decimal; var UnitLineLink: Record "TMAC Unit Line Link"; PostedSourceType: Integer; PostedSourceSubtype: Integer; PostedSourceID: code[20]; PostedSourceLineNo: Integer)
    var
        Positive: Boolean;
    begin
        Positive := UnitLineLink.Positive;
        if Positive then begin
            InsertPostedLink(UnitLineLink, PostedSourceType, PostedSourceSubtype, PostedSourceID, PostedSourceLineNo, Qty);
            UnitLineLink.Quantity := UnitLineLink.Quantity - Qty;
            UnitLineLink."Quantity (Base)" := UnitLineLink."Quantity (Base)" - Qty * UnitLineLink."Qty. per UoM";
            UnitLineLink."Posted Quantity" := UnitLineLink."Posted Quantity" + Qty;
        end else begin
            InsertPostedLink(UnitLineLink, PostedSourceType, PostedSourceSubtype, PostedSourceID, PostedSourceLineNo, -Qty);
            UnitLineLink.Quantity := UnitLineLink.Quantity + Qty;
            UnitLineLink."Quantity (Base)" := UnitLineLink."Quantity (Base)" + Qty * UnitLineLink."Qty. per UoM";
            UnitLineLink."Posted Quantity" := UnitLineLink."Posted Quantity" - Qty;
        end;
    end;

    local procedure SetSourceFilters(var UnitLineLink: Record "TMAC Unit Line Link"; SourceType: Integer; SourceSubtype: Integer; SourceID: code[20]; SourceLineNo: Integer; Positive: Boolean)
    begin
        UnitLineLink.Reset();
        UnitLineLink.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.", "Package No.", "Lot No.", "Serial No.", "Positive", "Qty. to Post");
        UnitLineLink.SetRange("Source Type", SourceType);
        UnitLineLink.SetRange("Source Subtype", SourceSubtype);
        UnitLineLink.SetRange("Source ID", SourceID);
        UnitLineLink.SetRange("Source Ref. No.", SourceLineNo);
        UnitLineLink.SetRange("Positive", Positive);
        UnitLineLink.SetFilter("Qty. to Post", '>0'); //"Qty. to Post" > 0

        //sorting is no longer needed because we have a strict requirement:
        //the quantities in the links for posting must always equal the quantity being posted

        //UnitLineLink.Ascending(false); 

        //we use sorting rather than filtering by "Qty to Post" because the system must find link rows
        //when posting directly from the order, not just via pallets

        //under no circumstances change UnitLineLink.Ascending(false), because "Qty to Post" is zeroed here,
        //and due to that (since "Qty to Post" is part of the key) not all rows may be processed
    end;

    /// <summary>
    /// Если есть линки то учет только по логистрической единице
    /// </summary>
    internal procedure BlockPostingIfThereAreLinks(PostingQuantity: Decimal; SourceType: Integer; SourceSubtype: Integer; SourceID: code[20]; SourceLineNo: Integer; Positive: Boolean)
    var
        UnitLineLink: Record "TMAC Unit Line Link";
    begin
        //if there are links, then accounting is only by logistics units
        UnitLineLink.Reset();
        UnitLineLink.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.", "Package No.", "Lot No.", "Serial No.", "Positive", "Qty. to Post");
        UnitLineLink.SetRange("Source Type", SourceType);
        UnitLineLink.SetRange("Source Subtype", SourceSubtype);
        UnitLineLink.SetRange("Source ID", SourceID);
        UnitLineLink.SetRange("Source Ref. No.", SourceLineNo);
        UnitLineLink.SetRange("Positive", Positive);
        UnitLineLink.SetFilter("Quantity", '<>0'); //only unaccounted links... there may be links, but if they are all already accounted, they should not be included in this calculation
        if UnitLineLink.FindFirst() then begin
            UnitLineLink.CalcSums("Qty. to Post");
            if PostingQuantity <> UnitLineLink."Qty. to Post" then
                Error(PostByLogisticUnitRequirementErr, SourceID, SourceLineNo);
        end;
    end;

    internal procedure InsertPostedLink(var UnitLineLink: Record "TMAC Unit Line Link"; PostedSourceType: Integer; PostedSourceSubtype: Integer; PostedSourceID: code[20]; PostedSourceLineNo: Integer; PostedQty: Decimal)
    var
        UnitLine: Record "TMAC Unit Line";
        NewUnitLineLink: Record "TMAC Unit Line Link";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        ReturnShipmentLine: Record "Return Shipment Line";
        PostedWhseReceiptLine: Record "Posted Whse. Receipt Line";
        SalesShipmentLine: Record "Sales Shipment Line";
        ReturnReceiptLine: Record "Return Receipt Line";
        PostedWhseShipmentLine: Record "Posted Whse. Shipment Line";
        TransferShipmentLine: Record "Transfer Shipment Line";
        TransferReceiptLine: Record "Transfer Receipt Line";
    begin
        NewUnitLineLink.Init();
        NewUnitLineLink.TransferFields(UnitLineLink);
        NewUnitLineLink.Validate("Source Type", PostedSourceType);
        NewUnitLineLink.Validate("Source Subtype", PostedSourceSubtype);
        NewUnitLineLink.Validate("Source ID", PostedSourceID);
        NewUnitLineLink.Validate("Source Ref. No.", PostedSourceLineNo);
        NewUnitLineLink."Quantity" := PostedQty;
        NewUnitLineLink."Quantity (Base)" := PostedQty * UnitLineLink."Qty. per UoM";
        NewUnitLineLink."Posted" := true;
        NewUnitLineLink."Qty. to Post" := 0;
        NewUnitLineLink.Insert(true);

        case PostedSourceType of
            Database::"Purch. Rcpt. Line":
                begin
                    PurchRcptLine.Get(PostedSourceID, PostedSourceLineNo);
                    UnitLine.Get(NewUnitLineLink."Unit No.", NewUnitLineLink."Unit Line No.");
                    UnitLine.Validate("Location Code", PurchRcptLine."Location Code");
                    UnitLine.Validate("Bin Code", PurchRcptLine."Bin Code");
                    UnitLine.Modify();
                end;
            Database::"Return Shipment Line":
                begin
                    ReturnShipmentLine.Get(PostedSourceID, PostedSourceLineNo);
                    UnitLine.Get(NewUnitLineLink."Unit No.", NewUnitLineLink."Unit Line No.");
                    UnitLine.Validate("Location Code", ReturnShipmentLine."Location Code");
                    UnitLine.Validate("Bin Code", ReturnShipmentLine."Bin Code");
                    UnitLine.Modify();
                end;
            Database::"Posted Whse. Receipt Line":
                begin
                    PostedWhseReceiptLine.Get(PostedSourceID, PostedSourceLineNo);
                    UnitLine.Get(NewUnitLineLink."Unit No.", NewUnitLineLink."Unit Line No.");
                    UnitLine.Validate("Location Code", PostedWhseReceiptLine."Location Code");
                    UnitLine.Validate("Bin Code", PostedWhseReceiptLine."Bin Code");
                    UnitLine.Modify();
                end;
            Database::"Sales Shipment Line":
                begin
                    SalesShipmentLine.Get(PostedSourceID, PostedSourceLineNo);
                    UnitLine.Get(NewUnitLineLink."Unit No.", NewUnitLineLink."Unit Line No.");
                    UnitLine.Validate("Location Code", SalesShipmentLine."Location Code");
                    UnitLine.Validate("Bin Code", SalesShipmentLine."Bin Code");
                    UnitLine.Modify();
                end;
            Database::"Return Receipt Line":
                begin
                    ReturnReceiptLine.Get(PostedSourceID, PostedSourceLineNo);
                    UnitLine.Get(NewUnitLineLink."Unit No.", NewUnitLineLink."Unit Line No.");
                    UnitLine.Validate("Location Code", ReturnReceiptLine."Location Code");
                    UnitLine.Validate("Bin Code", ReturnReceiptLine."Bin Code");
                    UnitLine.Modify();
                end;
            Database::"Posted Whse. Shipment Line":
                begin
                    PostedWhseShipmentLine.Get(PostedSourceID, PostedSourceLineNo);
                    UnitLine.Get(NewUnitLineLink."Unit No.", NewUnitLineLink."Unit Line No.");
                    UnitLine.Validate("Location Code", PostedWhseShipmentLine."Location Code");
                    UnitLine.Validate("Bin Code", PostedWhseShipmentLine."Bin Code");
                    UnitLine.Modify();
                end;
            Database::"Transfer Shipment Line":
                begin
                    TransferShipmentLine.get(PostedSourceID, PostedSourceLineNo);
                    UnitLine.Get(NewUnitLineLink."Unit No.", NewUnitLineLink."Unit Line No.");
                    UnitLine.Validate("Location Code", TransferShipmentLine."Transfer-from Code");
                    UnitLine.Validate("Bin Code", TransferShipmentLine."Transfer-from Bin Code");
                    UnitLine.Modify();
                end;
            Database::"Transfer Receipt Line":
                begin
                    TransferReceiptLine.get(PostedSourceID, PostedSourceLineNo);
                    UnitLine.Get(NewUnitLineLink."Unit No.", NewUnitLineLink."Unit Line No.");
                    UnitLine.Validate("Location Code", TransferReceiptLine."Transfer-to Code");
                    UnitLine.Validate("Bin Code", TransferReceiptLine."Transfer-To Bin Code");
                    UnitLine.Modify();
                end;
        end;
    end;

    /// <summary>
    /// Warehouse requirements check in the logistics units module
    /// </summary>
    /// <param name="LocationCode">Warehouse where the operation takes place</param>
    /// <param name="Direction">Inbound / Outbound</param>
    internal procedure CheckLocationRequirements(LocationCode: Code[20]; Direction: enum "TMAC Direction"; SourceType: Integer; SourceSubtype: Integer; SourceID: code[20]; SourceLineNo: Integer)
    var
        Location: Record Location;
        UnitLineLink: Record "TMAC Unit Line Link";
    begin
        if not UnitLineLink.ReadPermission then
            Error(LogisticUnitModuleAccessErr);

        if Location.get(LocationCode) then
            case Direction of
                "TMAC Direction"::Inbound:
                    if Location."TMAC Require LU for Rcpt" then begin
                        UnitLineLink.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.", "Package No.", "Lot No.", "Serial No.", "Positive", "Qty. to Post");
                        UnitLineLink.Setrange("Source Type", SourceType);
                        UnitLineLink.Setrange("Source Subtype", SourceSubtype);
                        UnitLineLink.Setrange("Source ID", SourceID);
                        UnitLineLink.Setrange("Source Ref. No.", SourceLineNo);
                        UnitLineLink.Setrange("Positive", true);
                        if UnitLineLink.IsEmpty then
                            error(LocationRequirementsErr, LocationCode);
                    end;
                "TMAC Direction"::Outbound:
                    if Location."TMAC Require LU for Spmt" then begin
                        UnitLineLink.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.", "Package No.", "Lot No.", "Serial No.", "Positive", "Qty. to Post");
                        UnitLineLink.Setrange("Source Type", SourceType);
                        UnitLineLink.Setrange("Source Subtype", SourceSubtype);
                        UnitLineLink.Setrange("Source ID", SourceID);
                        UnitLineLink.Setrange("Source Ref. No.", SourceLineNo);
                        UnitLineLink.Setrange("Positive", false);
                        if UnitLineLink.IsEmpty then
                            error(LocationRequirementsErr, LocationCode);
                    end;
            end;
    end;
    #endregion

    /// <summary>
    /// Change the LU Location Code based on the source document.  
    /// Even if Warehouse Shipment/ Warehouse Receipt is accounted, the source document line will still be accounted.
    /// </summary>
    /// <param name="SourceType">Source type</param>
    /// <param name="SourceSubtype">Source subtype</param>
    /// <param name="SourceID">Source document ID</param>
    /// <param name="SourceLineNo">Source document line number</param>
    /// <param name="Positive">Indicates whether the link is positive</param>
    internal procedure UpdateLogisticUnitLocationCode(SourceType: Integer; SourceSubtype: Integer; SourceID: code[20]; SourceLineNo: Integer; Positive: Boolean)
    var
        UnitAction: Record "TMAC Unit Action";
        UnitLocation: Record "TMAC Unit Location";
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        TransferHeader: Record "Transfer Header";
        Location: Record Location;
        Customer: Record Customer;
        Unit: Record "TMAC Unit";
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
        UnitManagement: Codeunit "TMAC Unit Management";
        Units: list of [Code[20]];
        UnitNo: Code[20];
        Found: Boolean;
        ActionExist: Boolean;
    begin
        Units := UnitLinkManagement.GetUnitListBySource(SourceType, SourceSubtype, SourceID, SourceLineNo); //there should be no issues with transfers, since SourceSubtype now specifies whether the operation is positive or negative

        case SourceType of
            Database::"Sales Line":
                begin
                    SalesHeader.Setrange("No.", SourceID);
                    if SalesHeader.FindFirst() then
                        if Customer.Get(SalesHeader."Sell-to Customer No.") then
                            if Customer."TMAC LU Location Code" <> '' then
                                if UnitLocation.Get(Customer."TMAC LU Location Code") then
                                    Found := true;

                    if not Found then begin
                        UnitLocation.Setrange("Default Shipment Location", true);
                        if UnitLocation.FindFirst() then
                            Found := true;
                    end;
                end;
            Database::"Purchase Line":
                begin
                    PurchaseHeader.Setrange("No.", SourceID);
                    if PurchaseHeader.FindFirst() then
                        if PurchaseHeader."Location Code" <> '' then begin
                            if Location.Get(PurchaseHeader."Location Code") then
                                if Location."TMAC LU Location Code" <> '' then
                                    if UnitLocation.Get(Location."TMAC LU Location Code") then
                                        Found := true;
                        end else begin
                            PurchaseLine.SetRange("Document No.", SourceID);
                            PurchaseLine.SetFilter("Location Code", '<>''''');
                            if PurchaseLine.FindFirst() then
                                if Location.Get(PurchaseLine."Location Code") then
                                    if Location."TMAC LU Location Code" <> '' then
                                        if UnitLocation.Get(Location."TMAC LU Location Code") then
                                            Found := true;
                        end;

                    if not Found then begin
                        UnitLocation.Setrange("Default Receipt Location", true);
                        if UnitLocation.FindFirst() then
                            Found := true;
                    end;
                end;
            Database::"Transfer Line":

                case SourceSubtype of
                    1: // Receipt
                        begin
                            if TransferHeader.Get(SourceID) then
                                if TransferHeader."Transfer-to Code" <> '' then
                                    if Location.Get(TransferHeader."Transfer-to Code") then
                                        if Location."TMAC LU Location Code" <> '' then
                                            if UnitLocation.Get(Location."TMAC LU Location Code") then
                                                Found := true;

                            if not Found then begin
                                UnitLocation.Setrange("Default Receipt Location", true);
                                if UnitLocation.FindFirst() then
                                    Found := true;
                            end;
                        end;
                end;
        end;

        if Found then begin
            UnitAction.Setrange(Relocation, true);
            if UnitAction.FindFirst() then
                ActionExist := true;

            foreach UnitNo in Units do
                if Unit.GET(UnitNo) then begin
                    Unit."Inbound Logistics Enabled" := UnitLocation."Inbound Logistics Enabled";
                    Unit."Outbound Logistics Enabled" := UnitLocation."Outbound Logistics Enabled";
                    Unit."LU Location Code" := UnitLocation.Code;
                    Unit.Modify(true);

                    if ActionExist then
                        UnitManagement.CreateUnitEntry(UnitNo, UnitAction.Code, UnitLocation.Code);
                end;

        end;
    end;

    var
        LocationRequirementsErr: Label 'Settings of the %1 location require post by logistic unit. You must define a logistic unit (real or virtual) in order to post.', Comment = '%1 is a location code';
        PostByLogisticUnitRequirementErr: Label 'If a document line is linked to a logistic unit, the posting must be done by that logistic unit. Document: %1, Line: %2', Comment = '%1 is a document, %2 document line';
        LogisticUnitModuleAccessErr: Label 'The user does not have access permission to the logistics units management system. Please inform the administrator.';
        LocationNegQtyReqErr: Label 'Settings of the %1 location require post by logistic unit and appliction to real logistic unit. You must apply %2 logistic unit lines to another existing logistic unit.', Comment = '%1 is a location code, %2 is a logistic unit';
        AllLogisticUnitsAlreadyPostedErr: Label 'All logistic units have been posted.';
        SeveralSourceUnitPostQst: label 'Unit %1 contains lines from several source documents. Only selected ones will de posted. In this case, It is better to post from logistic unit card. Continue?', Comment = '%1 is a Unit No.';

}
