/// <summary>
/// Manages linking logistic units with applicable documents, lines, and item tracking data.
/// </summary>
/// <remarks>
/// This codeunit supports reading lines from sales, purchase, warehouse, or other documents,
/// then populating references in the "TMAC Source Document Link" record.
/// </remarks>
codeunit 71628578 "TMAC Unit Link Management"
{
    /// <summary>
    /// Fills the "TMAC Source Document Link" table based on a specified source document (type, number, etc.).
    /// </summary>
    /// <remarks>
    /// Examines different AL record types (Sales, Purchase, Warehouse lines) and calls the relevant
    /// CreateFrom_ function to populate link data.
    /// </remarks>
    /// <param name="SourceDocumentLink">Target record in which link data is inserted.</param>
    /// <param name="SourceType">Integer referencing the AL table e.g. Purchase Line, Sales Line, etc.</param>
    /// <param name="SourceDocumentType">Specifies the document subtype (e.g. sales order type).</param>
    /// <param name="SourceDocumentNo">Document number to filter by.</param>
    /// <param name="SourceLineNo">Specific line number, if needed.</param>
    /// <param name="OppositeSourceType">Additional parameter for cross-referencing two document types.</param>
    /// <param name="OppositeSourceSubType">Sub classification for OppositeSourceType.</param>
    /// <param name="Positive">Indicates whether the lines represent an inbound or outbound movement.
    /// Setting to true may denote a positive quantity scenario.
    /// </param>
    procedure FillSourceDocumentTable(
        var SourceDocumentLink: Record "TMAC Source Document Link";
        SourceType: Integer;
        SourceDocumentType: Integer;
        SourceDocumentNo: Code[20];
        SourceLineNo: Integer;
        OppositeSourceType: Integer;
        OppositeSourceSubType: Integer;
        Positive: Boolean)
    var
        SalesLIne: Record "Sales Line";
        SalesShipmentLine: Record "Sales Shipment Line";
        SalesHeader: Record "Sales Header";
        PurchaseLine: Record "Purchase Line";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        PurchaseHeader: Record "Purchase Header";
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        PostedWhseShipmentLine: Record "Posted Whse. Shipment Line";
        PostedWhseReceiptLine: Record "Posted Whse. Receipt Line";
        ReturnShipmentLine: Record "Return Shipment Line";
        ReturnReceiptLine: Record "Return Receipt Line";
        TransferLine: Record "Transfer Line";
        WarehouseActivityLine: Record "Warehouse Activity Line";
        RegisteredWhseActivityLine: Record "Registered Whse. Activity Line";
        PostedInvtPutawayLine: Record "Posted Invt. Put-away Line";
        InvtDocumentHeader: Record "Invt. Document Header";
        InvtDocumentLine: Record "Invt. Document Line";
    begin
        case SourceType of
            Database::"Purchase Line":
                begin
                    PurchaseHeader.Get(SourceDocumentType, SourceDocumentNo);
                    PurchaseHeader.TestField(Status, "Purchase Document Status"::Released);

                    PurchaseLine.Reset();
                    PurchaseLine.Setrange("Document Type", SourceDocumentType);
                    PurchaseLine.Setrange("Document No.", SourceDocumentNo);
                    if SourceLineNo <> 0 then
                        PurchaseLine.Setrange("Line No.", SourceLineNo);
                    PurchaseLine.Setrange(Type, "Purchase Line Type"::Item);
                    PurchaseLine.Setfilter(Quantity, '>0');
                    if PurchaseLine.findset(false) then
                        repeat
                            CreateFrom_PurchLine(SourceDocumentLink, PurchaseLine, OppositeSourceType, OppositeSourceSubType);
                        until PurchaseLine.next() = 0;
                end;
            Database::"Purch. Rcpt. Line":
                begin
                    PurchRcptLine.Reset();
                    PurchRcptLine.SetRange("Document No.", SourceDocumentNo);
                    if SourceLineNo <> 0 then
                        PurchRcptLine.Setrange("Line No.", SourceLineNo);
                    PurchRcptLine.Setrange(Type, "Purchase Line Type"::Item);
                    PurchRcptLine.Setfilter(Quantity, '>0');
                    PurchRcptLine.SetRange(Correction, false);
                    if PurchRcptLine.findset(false) then
                        repeat
                            CreateFrom_PurchRcptLine(SourceDocumentLink, PurchRcptLine, OppositeSourceType, OppositeSourceSubType);
                        until PurchRcptLine.next() = 0;
                end;
            Database::"Warehouse Receipt Line":
                begin
                    WarehouseReceiptLine.Reset();
                    WarehouseReceiptLine.SetRange("No.", SourceDocumentNo);
                    if SourceLineNo <> 0 then
                        WarehouseReceiptLine.Setrange("Line No.", SourceLineNo);
                    WarehouseReceiptLine.Setfilter(Quantity, '>0');
                    if WarehouseReceiptLine.findset(false) then
                        repeat
                            CreateFrom_WarehouseReceiptLine(SourceDocumentLink, WarehouseReceiptLine, OppositeSourceType, OppositeSourceSubType);
                        until WarehouseReceiptLine.next() = 0;
                end;

            Database::"Posted Whse. Receipt Line":
                begin
                    PostedWhseReceiptLine.Reset();
                    PostedWhseReceiptLine.SetRange("No.", SourceDocumentNo);
                    if SourceLineNo <> 0 then
                        PostedWhseReceiptLine.Setrange("Line No.", SourceLineNo);
                    PostedWhseReceiptLine.Setfilter(Quantity, '>0');
                    if PostedWhseReceiptLine.findset(false) then
                        repeat
                            CreateFrom_PostedWhsReceiptLine(SourceDocumentLink, PostedWhseReceiptLine, OppositeSourceType, OppositeSourceSubType);
                        until PostedWhseReceiptLine.next() = 0;
                end;
            Database::"Sales Line":
                begin
                    SalesHeader.Get(SourceDocumentType, SourceDocumentNo);
                    SalesHeader.TestField(Status, "Purchase Document Status"::Released);

                    SalesLine.Reset();
                    SalesLine.Setrange("Document Type", SourceDocumentType);
                    SalesLine.SetRange("Document No.", SourceDocumentNo);
                    if SourceLineNo <> 0 then
                        SalesLine.Setrange("Line No.", SourceLineNo);
                    SalesLine.Setrange(Type, "Sales Line Type"::Item);
                    SalesLine.Setfilter(Quantity, '>0');
                    if SalesLine.findset(false) then
                        repeat
                            CreateFrom_SalesLine(SourceDocumentLink, SalesLine, OppositeSourceType, OppositeSourceSubType);
                        until SalesLine.next() = 0;
                end;
            Database::"Sales Shipment Line":
                begin
                    SalesShipmentLine.Reset();
                    SalesShipmentLine.SetRange("Document No.", SourceDocumentNo);
                    if SourceLineNo <> 0 then
                        SalesShipmentLine.Setrange("Line No.", SourceLineNo);
                    SalesShipmentLine.Setrange(Type, "Sales Line Type"::Item);
                    SalesShipmentLine.Setfilter(Quantity, '>0');
                    SalesShipmentLine.SetRange(Correction, false);
                    if SalesShipmentLine.findset(false) then
                        repeat
                            CreateFrom_SalesShipmentLine(SourceDocumentLink, SalesShipmentLine, OppositeSourceType, OppositeSourceSubType);
                        until SalesShipmentLine.next() = 0;
                end;
            Database::"Warehouse Shipment Line":
                begin
                    WarehouseShipmentLine.Reset();
                    WarehouseShipmentLine.SetRange("No.", SourceDocumentNo);
                    if SourceLineNo <> 0 then
                        WarehouseShipmentLine.Setrange("Line No.", SourceLineNo);
                    WarehouseShipmentLine.Setfilter(Quantity, '>0');
                    if WarehouseShipmentLine.findset(false) then
                        repeat
                            CreateFrom_WarehouseShipmentLine(SourceDocumentLink, WarehouseShipmentLine, OppositeSourceType, OppositeSourceSubType);
                        until WarehouseShipmentLine.next() = 0;
                end;
            Database::"Posted Whse. Shipment Line":
                begin
                    PostedWhseShipmentLine.Reset();
                    PostedWhseShipmentLine.SetRange("No.", SourceDocumentNo);
                    if SourceLineNo <> 0 then
                        PostedWhseShipmentLine.Setrange("Line No.", SourceLineNo);
                    PostedWhseShipmentLine.Setfilter(Quantity, '>0');
                    if PostedWhseShipmentLine.findset(false) then
                        repeat
                            CreateFrom_PostedWhsShipmentLine(SourceDocumentLink, PostedWhseShipmentLine, OppositeSourceType, OppositeSourceSubType);
                        until PostedWhseShipmentLine.next() = 0;
                end;
            //возврат продажи
            Database::"Return Receipt Line":
                begin
                    ReturnReceiptLine.Reset();
                    ReturnReceiptLine.SetRange("Document No.", SourceDocumentNo);
                    if SourceLineNo <> 0 then
                        ReturnReceiptLine.Setrange("Line No.", SourceLineNo);
                    ReturnReceiptLine.Setfilter(Quantity, '>0');
                    ReturnReceiptLine.SetRange(Correction, false);
                    if ReturnReceiptLine.findset(false) then
                        repeat
                            CreateFrom_ReturnReceiptLine(SourceDocumentLink, ReturnReceiptLine, OppositeSourceType, OppositeSourceSubType);
                        until ReturnReceiptLine.next() = 0;
                end;
            //возврат покупки
            Database::"Return Shipment Line":
                begin
                    ReturnShipmentLine.Reset();
                    ReturnShipmentLine.SetRange("Document No.", SourceDocumentNo);
                    if SourceLineNo <> 0 then
                        ReturnShipmentLine.Setrange("Line No.", SourceLineNo);
                    ReturnShipmentLine.Setfilter(Quantity, '>0');
                    ReturnShipmentLine.SetRange(Correction, false);
                    if ReturnShipmentLine.findset(false) then
                        repeat
                            CreateFrom_ReturnShipmentLine(SourceDocumentLink, ReturnShipmentLine, OppositeSourceType, OppositeSourceSubType);
                        until ReturnShipmentLine.next() = 0;
                end;
            Database::"Transfer Line":
                begin
                    TransferLine.Reset();
                    TransferLine.SetRange("Document No.", SourceDocumentNo);
                    if SourceLineNo <> 0 then
                        TransferLine.Setrange("Line No.", SourceLineNo);
                    TransferLine.Setrange("Derived From Line No.", 0);
                    TransferLine.Setfilter(Quantity, '>0');
                    if TransferLine.findset(false) then
                        repeat
                            CreateFrom_TransferLine(SourceDocumentLink, TransferLine, OppositeSourceType, OppositeSourceSubType, Positive);
                        until TransferLine.next() = 0;
                end;

            Database::"Warehouse Activity Line":
                begin
                    WarehouseActivityLine.Reset();
                    WarehouseActivityLine.SetRange("Activity Type", SourceDocumentType);
                    WarehouseActivityLine.SetRange("No.", SourceDocumentNo);
                    if SourceLineNo <> 0 then
                        WarehouseActivityLine.SetRange("Line No.", SourceLineNo);
                    if Positive then
                        WarehouseActivityLine.SetRange("Action Type", WarehouseActivityLine."Action Type"::Place)
                    else
                        WarehouseActivityLine.SetRange("Action Type", WarehouseActivityLine."Action Type"::Take);
                    if WarehouseActivityLine.FindSet() then
                        repeat
                            CreateFrom_WarehouseActivityLine(SourceDocumentLink, WarehouseActivityLine, OppositeSourceType, OppositeSourceSubType);
                        until WarehouseActivityLine.Next() = 0;
                end;
            Database::"Registered Whse. Activity Line":
                begin
                    RegisteredWhseActivityLine.Reset();
                    RegisteredWhseActivityLine.SetRange("Activity Type", SourceDocumentType);
                    RegisteredWhseActivityLine.SetRange("No.", SourceDocumentNo);
                    if SourceLineNo <> 0 then
                        RegisteredWhseActivityLine.SetRange("Line No.", SourceLineNo);
                    if RegisteredWhseActivityLine.FindSet() then
                        repeat
                            CreateFrom_RegisteredWhseActivityLine(SourceDocumentLink, RegisteredWhseActivityLine, OppositeSourceType, OppositeSourceSubType);
                        until RegisteredWhseActivityLine.Next() = 0;
                end;

            Database::"Posted Invt. Put-away Line":
                begin
                    PostedInvtPutawayLine.Reset();
                    PostedInvtPutawayLine.SetRange("No.", SourceDocumentNo);
                    if SourceLineNo <> 0 then
                        PostedInvtPutawayLine.SetRange("Line No.", SourceLineNo);
                    if PostedInvtPutawayLine.FindSet() then
                        repeat
                            CreateFrom_RegisteredPostedInvtPutawayLine(SourceDocumentLink, PostedInvtPutawayLine, OppositeSourceType, OppositeSourceSubType);
                        until PostedInvtPutawayLine.Next() = 0;
                end;
            Database::"Invt. Document Line":
                begin
                    InvtDocumentHeader.Get(SourceDocumentType, SourceDocumentNo);
                    InvtDocumentHeader.TestField(Status, InvtDocumentHeader.Status::Released);

                    InvtDocumentLine.Reset();
                    InvtDocumentLine.Setrange("Document Type", SourceDocumentType);
                    InvtDocumentLine.Setrange("Document No.", SourceDocumentNo);
                    if SourceLineNo <> 0 then
                        InvtDocumentLine.Setrange("Line No.", SourceLineNo);
                    InvtDocumentLine.Setfilter(Quantity, '>0');
                    if InvtDocumentLine.findset(false) then
                        repeat
                            CreateFrom_InvtDocumentLine(SourceDocumentLink, InvtDocumentLine, OppositeSourceType, OppositeSourceSubType);
                        until InvtDocumentLine.next() = 0;
                end;
        end;
        OnAfterFillSourceDocumentTable(SourceDocumentLink, SourceType, SourceDocumentType, SourceDocumentNo, SourceLineNo, OppositeSourceType, OppositeSourceSubType, Positive);
    end;

    #region Заполнение источников


    /// <summary>
    /// Для TMS
    /// </summary>
    /// <param name="SourceDocumentLink"></param>
    /// <param name="SalesLine"></param>
    procedure SalesLineToSourceDocumentLink(var SalesLine: Record "Sales Line"; var SourceDocumentLink: Record "TMAC Source Document Link")
    begin
        CreateFrom_SalesLine(SourceDocumentLink, SalesLine, 0, 0);
    end;

    procedure PurchaseLineToSourceDocumentLink(var PurchaseLine: Record "Purchase Line"; var SourceDocumentLink: Record "TMAC Source Document Link")
    begin
        CreateFrom_PurchLine(SourceDocumentLink, PurchaseLine, 0, 0);
    end;

    /// <summary>
    /// Заполняет таблицу источников на строки документа по строке документа
    /// </summary>
    /// <param name="SourceDocumentLink"></param>
    /// <param name="SalesLine"></param>
    /// <param name="AddPostedSourceType"></param>
    internal procedure CreateFrom_SalesLine(var SourceDocumentLink: Record "TMAC Source Document Link"; var SalesLine: Record "Sales Line"; OppositeSourceType: Integer; OppositeSourceSubType: Integer)
    var
        ReservationEntry: Record "Reservation Entry";
        Item: Record Item;
        CompareQty: Decimal;
    begin
        if SalesLine.Type <> "Sales Line Type"::Item then
            exit;

        Item.Get(SalesLine."No.");
        if Item."Item Tracking Code" <> '' then begin
            ReservationEntry.Reset();
            ReservationEntry.SetCurrentKey("Source ID", "Source Ref. No.", "Source Type", "Source Subtype", "Source Batch Name", "Source Prod. Order Line", "Reservation Status", "Shipment Date", "Expected Receipt Date");
            ReservationEntry.SetFilter("Reservation Status", '%1|%2', "Reservation Status"::Reservation, "Reservation Status"::Surplus);
            ReservationEntry.Setrange("Source Type", Database::"Sales Line");
            ReservationEntry.Setrange("Source Subtype", SalesLine."Document Type".AsInteger());
            ReservationEntry.Setrange("Source ID", SalesLine."Document No.");
            ReservationEntry.Setrange("Source Ref. No.", SalesLine."Line No.");
            ReservationEntry.CalcSums("Quantity (Base)");

            //сравниваем с "Qty. to Ship (Base)" т.к. количество по трассировке должно быть равно кол-ву в "Qty. to Ship (Base)"
            //но "Qty. to Ship (Base)"  не заполняется в случае склада с Warehouse Shipment
            //и соответственно "Qty. to Ship (Base)" = 0 и трассировка должна быть на все "Quantity (Base)"
            CompareQty := SalesLine."Qty. to Ship (Base)";
            if CompareQty = 0 then
                CompareQty := SalesLine."Quantity (Base)";

            if -CompareQty <> ReservationEntry."Quantity (Base)" then
                error(TrackingQuantityErr, CompareQty, ReservationEntry."Quantity (Base)", SalesLine."No.");

            if ReservationEntry.FindSet() then
                repeat
                    SourceDocumentLink.Init();
                    SourceDocumentLink.Clear();
                    CompleteSourceDocumentLinkFromReservationEntry(SourceDocumentLink, ReservationEntry);
                    SourceDocumentLink.Description := SalesLine.Description;
                    SourceDocumentLink."Unit of Measure Code" := SalesLine."Unit of Measure Code";
                    SourceDocumentLink."Weight (Base) per UoM" := GetWeight(SalesLine."Gross Weight", SalesLine."No.", SalesLine."Unit of Measure Code");
                    SourceDocumentLink."Volume (Base) per UoM" := GetVolume(SalesLine."Unit Volume", SalesLine."No.", SalesLine."Unit of Measure Code");

                    SourceDocumentLink."Document Source Type" := Database::"Sales Header";
                    SourceDocumentLink."Document Source SubType" := SalesLine."Document Type".AsInteger();
                    SourceDocumentLink."Document Source ID" := SalesLine."Document No.";
                    SourceDocumentLink."Document Source Information" := GetSourceInformation(SourceDocumentLink."Document Source Type", SourceDocumentLink."Document Source SubType", SourceDocumentLink."Document Source ID");

                    SourceDocumentLink."Control Quantity" := SalesLine.Quantity;

                    SourceDocumentLink."Opposite Source Type" := OppositeSourceType;
                    SourceDocumentLink."Opposite Source Subtype" := OppositeSourceSubType;

                    case SalesLine."Document Type" of
                        "Sales Document Type"::Order,
                        "Sales Document Type"::Invoice:
                            SourceDocumentLink.Positive := false;
                        "Sales Document Type"::"Credit Memo",
                        "Sales Document Type"::"Return Order":
                            SourceDocumentLink.Positive := true;
                    end;
                    //в таблице резервирования записей может быть несколько на одну партию или лот но разные кол-ва, поэтому запись может уже ьыть 
                    InsertOrAddQuantity(SourceDocumentLink, SourceDocumentLink.Quantity, SourceDocumentLink."Quantity (Base)");

                until ReservationEntry.next() = 0;
        end else begin
            SourceDocumentLink.Init();
            SourceDocumentLink.Clear();
            SourceDocumentLink."Source Type" := Database::"Sales Line";
            SourceDocumentLink."Source Subtype" := SalesLine."Document Type".AsInteger();
            SourceDocumentLink."Source ID" := SalesLine."Document No.";
            SourceDocumentLink."Source Ref. No." := SalesLine."Line No.";
            SourceDocumentLink."Package No." := '';
            SourceDocumentLink."Lot No." := '';
            SourceDocumentLink."Serial No." := '';
            SourceDocumentLink."Item No." := SalesLine."No.";
            SourceDocumentLink."Variant Code" := SalesLine."Variant Code";
            SourceDocumentLink.Description := SalesLine.Description;
            SourceDocumentLink.Quantity := SalesLine.Quantity - SalesLine."Quantity Shipped";
            SourceDocumentLink."Unit of Measure Code" := SalesLine."Unit of Measure Code";
            SourceDocumentLink."Quantity (Base)" := SalesLine."Quantity (Base)" - SalesLine."Qty. Shipped (Base)";
            SourceDocumentLink."Weight (Base) per UoM" := GetWeight(SalesLine."Gross Weight", SalesLine."No.", SalesLine."Unit of Measure Code");
            SourceDocumentLink."Volume (Base) per UoM" := GetVolume(SalesLine."Unit Volume", SalesLine."No.", SalesLine."Unit of Measure Code");
            SourceDocumentLink."Qty. per UoM" := SalesLine."Qty. per Unit of Measure";
            SourceDocumentLink."Location Code" := SalesLine."Location Code";
            SourceDocumentLink."Bin Code" := SalesLine."Bin Code";

            SourceDocumentLink."Document Source Type" := Database::"Sales Header";
            SourceDocumentLink."Document Source SubType" := SalesLine."Document Type".AsInteger();
            SourceDocumentLink."Document Source ID" := SalesLine."Document No.";
            SourceDocumentLink."Document Source Information" := GetSourceInformation(SourceDocumentLink."Document Source Type", SourceDocumentLink."Document Source SubType", SourceDocumentLink."Document Source ID");

            SourceDocumentLink."Control Quantity" := SourceDocumentLink.Quantity;
            SourceDocumentLink."Default Selected Quantity" := abs(SalesLine."Qty. to Ship");

            SourceDocumentLink."Opposite Source Type" := OppositeSourceType;
            SourceDocumentLink."Opposite Source Subtype" := OppositeSourceSubType;

            case SalesLine."Document Type" of
                "Sales Document Type"::Order,
                "Sales Document Type"::Invoice:
                    SourceDocumentLink.Positive := false;
                "Sales Document Type"::"Credit Memo",
                "Sales Document Type"::"Return Order":
                    SourceDocumentLink.Positive := true;
            end;

            if SourceDocumentLink.Quantity <> 0 then
                SourceDocumentLink.Insert(true);
        end;
    end;

    /// <summary>
    /// Creates link data from a posted or partially posted shipment.
    /// </summary>
    /// <remarks>
    /// May handle item tracking by referencing item ledger relations.
    /// </remarks>
    internal procedure CreateFrom_SalesShipmentLine(
        var SourceDocumentLink: Record "TMAC Source Document Link";
        var SalesShipmentLine: Record "Sales Shipment Line";
        OppositeSourceType: Integer;
        OppositeSourceSubType: Integer)
    var
        ItemEntryRelation: Record "Item Entry Relation";
        ItemLedgerEntry: Record "Item Ledger Entry";
        Item: Record Item;
    begin
        if SalesShipmentLine.Type <> "Sales Line Type"::Item then
            exit;

        Item.Get(SalesShipmentLine."No.");

        if Item."Item Tracking Code" <> '' then begin
            ItemEntryRelation.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Ref. No.", "Source Prod. Order Line", "Source Batch Name");
            ItemEntryRelation.SetRange("Source Type", Database::"Sales Shipment Line");
            ItemEntryRelation.SetRange("Source Subtype", 0);
            ItemEntryRelation.SetRange("Source ID", SalesShipmentLine."Document No.");
            ItemEntryRelation.SetRange("Source Batch Name", '');
            ItemEntryRelation.SetRange("Source Prod. Order Line", 0);
            ItemEntryRelation.SetRange("Source Ref. No.", SalesShipmentLine."Line No.");
            ItemEntryRelation.SetLoadFields("Item Entry No.");
            if ItemEntryRelation.FindSet() then
                repeat
                    ItemLedgerEntry.get(ItemEntryRelation."Item Entry No.");
                    SourceDocumentLink.Init();
                    SourceDocumentLink.Clear();
                    SourceDocumentLink."Source Type" := Database::"Sales Shipment Line";
                    SourceDocumentLink."Source Subtype" := 0;
                    SourceDocumentLink."Source ID" := SalesShipmentLine."Document No.";
                    SourceDocumentLink."Source Ref. No." := SalesShipmentLine."Line No.";
                    SourceDocumentLink.Description := SalesShipmentLine.Description;
                    SourceDocumentLink."Package No." := ItemLedgerEntry."Package No.";
                    SourceDocumentLink."Lot No." := ItemLedgerEntry."Lot No.";
                    SourceDocumentLink."Serial No." := ItemLedgerEntry."Serial No.";
                    SourceDocumentLink."Item No." := ItemLedgerEntry."Item No.";
                    SourceDocumentLink."Variant Code" := ItemLedgerEntry."Variant Code";
                    SourceDocumentLink.Description := ItemLedgerEntry.Description;
                    SourceDocumentLink."Quantity" := Round(abs(ItemLedgerEntry.Quantity) / ItemLedgerEntry."Qty. per Unit of Measure");
                    SourceDocumentLink."Quantity (Base)" := abs(ItemLedgerEntry.Quantity); //в ILE все в базовой единице
                    SourceDocumentLink."Qty. per UoM" := SalesShipmentLine."Qty. per Unit of Measure";
                    SourceDocumentLink."Location Code" := ItemLedgerEntry."Location Code";

                    SourceDocumentLink."Unit of Measure Code" := SalesShipmentLine."Unit of Measure Code";
                    SourceDocumentLink."Weight (Base) per UoM" := GetWeight(SalesShipmentLine."Gross Weight", SalesShipmentLine."No.", SalesShipmentLine."Unit of Measure Code");
                    SourceDocumentLink."Volume (Base) per UoM" := GetVolume(SalesShipmentLine."Unit Volume", SalesShipmentLine."No.", SalesShipmentLine."Unit of Measure Code");

                    SourceDocumentLink."Document Source Type" := Database::"Sales Shipment Header";
                    SourceDocumentLink."Document Source SubType" := 0;
                    SourceDocumentLink."Document Source ID" := SalesShipmentLine."Document No.";
                    SourceDocumentLink."Document Source Information" := GetSourceInformation(SourceDocumentLink."Document Source Type", SourceDocumentLink."Document Source SubType", SourceDocumentLink."Document Source ID");

                    SourceDocumentLink."Control Quantity" := SalesShipmentLine.Quantity;

                    SourceDocumentLink."Opposite Source Type" := OppositeSourceType;
                    SourceDocumentLink."Opposite Source Subtype" := OppositeSourceSubType;

                    SourceDocumentLink.Positive := false;

                    //в таблице резервирования записей может быть несколько на одну партию или лот но разные кол-ва, поэтому запись может уже ьыть 
                    InsertOrAddQuantity(SourceDocumentLink, SourceDocumentLink.Quantity, SourceDocumentLink."Quantity (Base)");

                until ItemEntryRelation.next() = 0;
        end else begin
            SourceDocumentLink.Init();
            SourceDocumentLink.Clear();
            SourceDocumentLink."Source Type" := Database::"Sales Shipment Line";
            SourceDocumentLink."Source Subtype" := 0;
            SourceDocumentLink."Source ID" := SalesShipmentLine."Document No.";
            SourceDocumentLink."Source Ref. No." := SalesShipmentLine."Line No.";
            SourceDocumentLink."Package No." := '';
            SourceDocumentLink."Lot No." := '';
            SourceDocumentLink."Serial No." := '';
            SourceDocumentLink."Item No." := SalesShipmentLine."No.";
            SourceDocumentLink."Variant Code" := SalesShipmentLine."Variant Code";
            SourceDocumentLink.Description := SalesShipmentLine.Description;
            SourceDocumentLink.Quantity := SalesShipmentLine.Quantity;
            SourceDocumentLink."Unit of Measure Code" := SalesShipmentLine."Unit of Measure Code";
            SourceDocumentLink."Quantity (Base)" := SalesShipmentLine."Quantity (Base)";
            SourceDocumentLink."Weight (Base) per UoM" := GetWeight(SalesShipmentLine."Gross Weight", SalesShipmentLine."No.", SalesShipmentLine."Unit of Measure Code");
            SourceDocumentLink."Volume (Base) per UoM" := GetVolume(SalesShipmentLine."Unit Volume", SalesShipmentLine."No.", SalesShipmentLine."Unit of Measure Code");
            SourceDocumentLink."Qty. per UoM" := SalesShipmentLine."Qty. per Unit of Measure";
            SourceDocumentLink."Location Code" := SalesShipmentLine."Location Code";
            SourceDocumentLink."Bin Code" := SalesShipmentLine."Bin Code";

            SourceDocumentLink."Document Source Type" := Database::"Sales Shipment Header";
            SourceDocumentLink."Document Source SubType" := 0;
            SourceDocumentLink."Document Source ID" := SalesShipmentLine."Document No.";
            SourceDocumentLink."Document Source Information" := GetSourceInformation(SourceDocumentLink."Document Source Type", SourceDocumentLink."Document Source SubType", SourceDocumentLink."Document Source ID");

            SourceDocumentLink."Control Quantity" := SourceDocumentLink.Quantity;

            SourceDocumentLink."Opposite Source Type" := OppositeSourceType;
            SourceDocumentLink."Opposite Source Subtype" := OppositeSourceSubType;

            SourceDocumentLink.Positive := false;

            if SourceDocumentLink.Quantity <> 0 then
                SourceDocumentLink.Insert(true);
        end;
    end;

    /// <summary>
    /// Заполняет таблицу источников на строки документа по строке документа
    /// </summary>
    /// <param name="SourceDocumentLink"></param>
    /// <param name="WarehouseShipmentLine"></param>
    internal procedure CreateFrom_WarehouseShipmentLine(var SourceDocumentLink: Record "TMAC Source Document Link"; var WarehouseShipmentLine: Record "Warehouse Shipment Line"; OppositeSourceType: Integer; OppositeSourceSubType: Integer)
    var
        ReservationEntry: Record "Reservation Entry";
        Item: Record Item;
    begin
        Item.Get(WarehouseShipmentLine."Item No.");
        if Item."Item Tracking Code" <> '' then begin
            ReservationEntry.Reset();
            ReservationEntry.SetCurrentKey("Source ID", "Source Ref. No.", "Source Type", "Source Subtype", "Source Batch Name", "Source Prod. Order Line", "Reservation Status", "Shipment Date", "Expected Receipt Date");
            ReservationEntry.SetFilter("Reservation Status", '%1|%2', "Reservation Status"::Reservation, "Reservation Status"::Surplus);
            ReservationEntry.Setrange("Source Type", WarehouseShipmentLine."Source Type");
            ReservationEntry.Setrange("Source Subtype", WarehouseShipmentLine."Source Subtype");
            ReservationEntry.Setrange("Source ID", WarehouseShipmentLine."Source No.");
            ReservationEntry.Setrange("Source Ref. No.", WarehouseShipmentLine."Source Line No.");
            if ReservationEntry.FindSet() then
                repeat
                    SourceDocumentLink.Init();
                    SourceDocumentLink.Clear();
                    CompleteSourceDocumentLinkFromReservationEntry(SourceDocumentLink, ReservationEntry);
                    SourceDocumentLink."Source Type" := Database::"Warehouse Shipment Line";
                    SourceDocumentLink."Source Subtype" := 0;
                    SourceDocumentLink."Source ID" := WarehouseShipmentLine."No.";
                    SourceDocumentLink."Source Ref. No." := WarehouseShipmentLine."Line No.";
                    SourceDocumentLink.Description := WarehouseShipmentLine.Description;
                    SourceDocumentLink."Unit of Measure Code" := WarehouseShipmentLine."Unit of Measure Code";
                    SourceDocumentLink."Weight (Base) per UoM" := GetWeight(WarehouseShipmentLine.Weight, WarehouseShipmentLine."Item No.", WarehouseShipmentLine."Unit of Measure Code");
                    SourceDocumentLink."Volume (Base) per UoM" := GetVolume(WarehouseShipmentLine.Cubage, WarehouseShipmentLine."Item No.", WarehouseShipmentLine."Unit of Measure Code");

                    SourceDocumentLink."Document Source Type" := WarehouseShipmentLine."Source Type";
                    SourceDocumentLink."Document Source SubType" := WarehouseShipmentLine."Source Subtype";
                    SourceDocumentLink."Document Source ID" := WarehouseShipmentLine."Source No.";
                    SourceDocumentLink."Document Source Information" := GetSourceInformation(SourceDocumentLink."Document Source Type", SourceDocumentLink."Document Source SubType", SourceDocumentLink."Document Source ID");

                    SourceDocumentLink."Control Quantity" := WarehouseShipmentLine.Quantity;
                    SourceDocumentLink."Default Selected Quantity" := abs(WarehouseShipmentLine."Qty. to Ship");

                    SourceDocumentLink."Opposite Source Type" := OppositeSourceType;
                    SourceDocumentLink."Opposite Source Subtype" := OppositeSourceSubType;
                    SourceDocumentLink.Positive := false;

                    //в таблице резервирования записей может быть несколько на одну партию или лот но разные кол-ва, поэтому запись может уже ьыть 
                    InsertOrAddQuantity(SourceDocumentLink, SourceDocumentLink.Quantity, SourceDocumentLink."Quantity (Base)");

                until ReservationEntry.next() = 0;
        end else begin
            SourceDocumentLink.Init();
            SourceDocumentLink.Clear();
            SourceDocumentLink."Source Type" := Database::"Warehouse Shipment Line";
            SourceDocumentLink."Source Subtype" := 0;
            SourceDocumentLink."Source ID" := WarehouseShipmentLine."No.";
            SourceDocumentLink."Source Ref. No." := WarehouseShipmentLine."Line No.";
            SourceDocumentLink."Package No." := '';
            SourceDocumentLink."Lot No." := '';
            SourceDocumentLink."Serial No." := '';
            SourceDocumentLink."Item No." := WarehouseShipmentLine."Item No.";
            SourceDocumentLink."Variant Code" := WarehouseShipmentLine."Variant Code";
            SourceDocumentLink.Description := WarehouseShipmentLine.Description;
            SourceDocumentLink.Quantity := WarehouseShipmentLine.Quantity - WarehouseShipmentLine."Qty. Shipped";
            SourceDocumentLink."Unit of Measure Code" := WarehouseShipmentLine."Unit of Measure Code";
            SourceDocumentLink."Quantity (Base)" := WarehouseShipmentLine."Qty. (Base)" - WarehouseShipmentLine."Qty. Shipped (Base)";
            SourceDocumentLink."Weight (Base) per UoM" := GetWeight(WarehouseShipmentLine.Weight, WarehouseShipmentLine."Item No.", WarehouseShipmentLine."Unit of Measure Code");
            SourceDocumentLink."Volume (Base) per UoM" := GetVolume(WarehouseShipmentLine.Cubage, WarehouseShipmentLine."Item No.", WarehouseShipmentLine."Unit of Measure Code");
            SourceDocumentLink."Qty. per UoM" := WarehouseShipmentLine."Qty. per Unit of Measure";
            SourceDocumentLink."Location Code" := WarehouseShipmentLine."Location Code";
            SourceDocumentLink."Bin Code" := WarehouseShipmentLine."Bin Code";

            SourceDocumentLink."Document Source Type" := WarehouseShipmentLine."Source Type";
            SourceDocumentLink."Document Source SubType" := WarehouseShipmentLine."Source Subtype";
            SourceDocumentLink."Document Source ID" := WarehouseShipmentLine."Source No.";
            SourceDocumentLink."Document Source Information" := GetSourceInformation(SourceDocumentLink."Document Source Type", SourceDocumentLink."Document Source SubType", SourceDocumentLink."Document Source ID");

            SourceDocumentLink."Control Quantity" := SourceDocumentLink.Quantity;
            SourceDocumentLink."Default Selected Quantity" := abs(WarehouseShipmentLine."Qty. to Ship");

            SourceDocumentLink."Opposite Source Type" := OppositeSourceType;
            SourceDocumentLink."Opposite Source Subtype" := OppositeSourceSubType;

            SourceDocumentLink.Positive := false;

            if SourceDocumentLink.Quantity <> 0 then
                SourceDocumentLink.Insert(true);
        end;
    end;

    /// <summary>
    /// 
    /// </summary>
    /// <param name="SourceDocumentLink"></param>
    /// <param name="WarehouseShipmentLine"></param>
    /// <param name="AddPostedSourceType"></param>
    internal procedure CreateFrom_PostedWhsShipmentLine(var SourceDocumentLink: Record "TMAC Source Document Link"; var PostedWhseShipmentLine: Record "Posted Whse. Shipment Line"; OppositeSourceType: Integer; OppositeSourceSubType: Integer)
    var
        ItemEntryRelation: Record "Item Entry Relation";
        ItemLedgerEntry: Record "Item Ledger Entry";
        SalesShipmentLine: Record "Sales Shipment Line";
        Item: Record Item;
    begin
        Item.Get(PostedWhseShipmentLine."Item No.");
        if Item."Item Tracking Code" <> '' then
            case PostedWhseShipmentLine."Posted Source Document" of
                "Warehouse Shipment Posted Source Document"::"Posted Shipment":
                    begin
                        SalesShipmentLine.Reset();
                        SalesShipmentLine.SetCurrentKey("Order No.", "Order Line No.", "Posting Date");
                        SalesShipmentLine.SetRange("Order No.", PostedWhseShipmentLine."Source No.");
                        SalesShipmentLine.SetRange("Order Line No.", PostedWhseShipmentLine."Source Line No.");
                        if SalesShipmentLine.FindSet(false) then
                            repeat
                                ItemEntryRelation.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Ref. No.", "Source Prod. Order Line", "Source Batch Name");
                                ItemEntryRelation.SetRange("Source Type", Database::"Sales Shipment Line");
                                ItemEntryRelation.SetRange("Source Subtype", 0);
                                ItemEntryRelation.SetRange("Source ID", SalesShipmentLine."Document No.");
                                ItemEntryRelation.SetRange("Source Ref. No.", SalesShipmentLine."Line No.");
                                ItemEntryRelation.SetLoadFields("Item Entry No.");
                                if ItemEntryRelation.FindSet() then
                                    repeat
                                        ItemLedgerEntry.get(ItemEntryRelation."Item Entry No.");

                                        SourceDocumentLink.Init();
                                        SourceDocumentLink.Clear();
                                        SourceDocumentLink."Source Type" := Database::"Posted Whse. Shipment Line";
                                        SourceDocumentLink."Source Subtype" := 0;
                                        SourceDocumentLink."Source ID" := PostedWhseShipmentLine."No.";
                                        SourceDocumentLink."Source Ref. No." := PostedWhseShipmentLine."Line No.";
                                        SourceDocumentLink.Description := PostedWhseShipmentLine.Description;

                                        SourceDocumentLink."Package No." := ItemLedgerEntry."Package No.";
                                        SourceDocumentLink."Lot No." := ItemLedgerEntry."Lot No.";
                                        SourceDocumentLink."Serial No." := ItemLedgerEntry."Serial No.";

                                        SourceDocumentLink."Item No." := ItemLedgerEntry."Item No.";
                                        SourceDocumentLink."Variant Code" := ItemLedgerEntry."Variant Code";
                                        SourceDocumentLink.Description := ItemLedgerEntry.Description;

                                        SourceDocumentLink."Quantity" := Round(abs(ItemLedgerEntry.Quantity) / ItemLedgerEntry."Qty. per Unit of Measure");
                                        SourceDocumentLink."Quantity (Base)" := abs(ItemLedgerEntry.Quantity); //в ILE все в базовой единице

                                        SourceDocumentLink."Qty. per UoM" := PostedWhseShipmentLine."Qty. per Unit of Measure";
                                        SourceDocumentLink."Location Code" := ItemLedgerEntry."Location Code";

                                        SourceDocumentLink."Unit of Measure Code" := PostedWhseShipmentLine."Unit of Measure Code";
                                        SourceDocumentLink."Weight (Base) per UoM" := GetWeight(0, PostedWhseShipmentLine."Item No.", PostedWhseShipmentLine."Unit of Measure Code");
                                        SourceDocumentLink."Volume (Base) per UoM" := GetVolume(0, PostedWhseShipmentLine."Item No.", PostedWhseShipmentLine."Unit of Measure Code");

                                        SourceDocumentLink."Document Source Type" := PostedWhseShipmentLine."Source Type";
                                        SourceDocumentLink."Document Source SubType" := PostedWhseShipmentLine."Source Subtype";
                                        SourceDocumentLink."Document Source ID" := PostedWhseShipmentLine."Source No.";
                                        SourceDocumentLink."Document Source Information" := GetSourceInformation(SourceDocumentLink."Document Source Type", SourceDocumentLink."Document Source SubType", SourceDocumentLink."Document Source ID");

                                        SourceDocumentLink."Control Quantity" := SalesShipmentLine.Quantity;

                                        SourceDocumentLink."Opposite Source Type" := OppositeSourceType;
                                        SourceDocumentLink."Opposite Source Subtype" := OppositeSourceSubType;

                                        SourceDocumentLink.Positive := false;
                                        InsertOrAddQuantity(SourceDocumentLink, SourceDocumentLink.Quantity, SourceDocumentLink."Quantity (Base)");

                                    until ItemEntryRelation.next() = 0;
                            until SalesShipmentLine.Next() = 0;
                    end
            end else begin
            SourceDocumentLink.Init();
            SourceDocumentLink.Clear();
            SourceDocumentLink."Source Type" := Database::"Posted Whse. Shipment Line";
            SourceDocumentLink."Source Subtype" := 0;
            SourceDocumentLink."Source ID" := PostedWhseShipmentLine."No.";
            SourceDocumentLink."Source Ref. No." := PostedWhseShipmentLine."Line No.";
            SourceDocumentLink."Package No." := '';
            SourceDocumentLink."Lot No." := '';
            SourceDocumentLink."Serial No." := '';
            SourceDocumentLink."Item No." := PostedWhseShipmentLine."Item No.";
            SourceDocumentLink."Variant Code" := PostedWhseShipmentLine."Variant Code";
            SourceDocumentLink.Description := PostedWhseShipmentLine.Description;
            SourceDocumentLink.Quantity := PostedWhseShipmentLine.Quantity;
            SourceDocumentLink."Unit of Measure Code" := PostedWhseShipmentLine."Unit of Measure Code";
            SourceDocumentLink."Quantity (Base)" := PostedWhseShipmentLine."Qty. (Base)";
            SourceDocumentLink."Weight (Base) per UoM" := GetWeight(0, PostedWhseShipmentLine."Item No.", PostedWhseShipmentLine."Unit of Measure Code");
            SourceDocumentLink."Volume (Base) per UoM" := GetVolume(0, PostedWhseShipmentLine."Item No.", PostedWhseShipmentLine."Unit of Measure Code");
            SourceDocumentLink."Qty. per UoM" := PostedWhseShipmentLine."Qty. per Unit of Measure";
            SourceDocumentLink."Location Code" := PostedWhseShipmentLine."Location Code";
            SourceDocumentLink."Bin Code" := PostedWhseShipmentLine."Bin Code";

            SourceDocumentLink."Document Source Type" := PostedWhseShipmentLine."Source Type";
            SourceDocumentLink."Document Source SubType" := PostedWhseShipmentLine."Source Subtype";
            SourceDocumentLink."Document Source ID" := PostedWhseShipmentLine."Source No.";
            SourceDocumentLink."Document Source Information" := GetSourceInformation(SourceDocumentLink."Document Source Type", SourceDocumentLink."Document Source SubType", SourceDocumentLink."Document Source ID");

            SourceDocumentLink."Control Quantity" := SourceDocumentLink.Quantity;

            SourceDocumentLink."Opposite Source Type" := OppositeSourceType;
            SourceDocumentLink."Opposite Source Subtype" := OppositeSourceSubType;

            SourceDocumentLink.Positive := false;

            if SourceDocumentLink.Quantity <> 0 then
                SourceDocumentLink.Insert(true);
        end;
    end;


    /// <summary>
    /// Заполняет таблицу источников на строки документа по строке документа
    /// </summary>
    /// <param name="SourceDocumentLink"></param>
    internal procedure CreateFrom_PurchLine(var SourceDocumentLink: Record "TMAC Source Document Link"; var PurchaseLine: Record "Purchase Line"; OppositeSourceType: Integer; OppositeSourceSubType: Integer)
    var
        ReservationEntry: Record "Reservation Entry";
        Item: Record Item;
        CompareQty: Decimal;
    begin
        if PurchaseLine.Type <> "Sales Line Type"::Item then
            exit;

        Item.Get(PurchaseLine."No.");
        if Item."Item Tracking Code" <> '' then begin
            ReservationEntry.Reset();
            ReservationEntry.SetCurrentKey("Source ID", "Source Ref. No.", "Source Type", "Source Subtype", "Source Batch Name", "Source Prod. Order Line", "Reservation Status", "Shipment Date", "Expected Receipt Date");
            ReservationEntry.SetFilter("Reservation Status", '%1|%2', "Reservation Status"::Reservation, "Reservation Status"::Surplus);
            ReservationEntry.Setrange("Source Type", Database::"Purchase Line");
            ReservationEntry.Setrange("Source Subtype", PurchaseLine."Document Type".AsInteger());
            ReservationEntry.Setrange("Source ID", PurchaseLine."Document No.");
            ReservationEntry.Setrange("Source Ref. No.", PurchaseLine."Line No.");
            ReservationEntry.CalcSums("Quantity (Base)");

            //сравниваем с "Qty. to Receive (Base)" т.к. количество по трассировке должно быть равно кол-ву в "Qty. to Receive (Base)"
            //но "Qty. to Receive (Base)"  не заполняется в случае склада с Warehouse Shipment
            //и соответственно "Qty. to Receive (Base)" = 0 и трассировка должна быть на все "Quantity (Base)"

            CompareQty := PurchaseLine."Qty. to Receive (Base)";
            if CompareQty = 0 then
                CompareQty := PurchaseLine."Quantity (Base)";

            if CompareQty <> ReservationEntry."Quantity (Base)" then
                error(TrackingQuantityErr, CompareQty, ReservationEntry."Quantity (Base)", PurchaseLine."No.");

            //if PurchaseLine."Qty. to Receive (Base)" <> ReservationEntry."Quantity (Base)" then
            //    error(TrackingQuantityErr, PurchaseLine."Qty. to Receive (Base)", ReservationEntry."Quantity (Base)", PurchaseLine."No.");

            if ReservationEntry.FindSet() then
                repeat
                    SourceDocumentLink.Init();
                    SourceDocumentLink.Clear();
                    CompleteSourceDocumentLinkFromReservationEntry(SourceDocumentLink, ReservationEntry);
                    SourceDocumentLink.Description := PurchaseLine.Description;
                    SourceDocumentLink."Unit of Measure Code" := PurchaseLine."Unit of Measure Code";
                    SourceDocumentLink."Weight (Base) per UoM" := GetWeight(PurchaseLine."Gross Weight", PurchaseLine."No.", PurchaseLine."Unit of Measure Code");
                    SourceDocumentLink."Volume (Base) per UoM" := GetVolume(PurchaseLine."Unit Volume", PurchaseLine."No.", PurchaseLine."Unit of Measure Code");

                    //SourceDocumentLink."Control Quantity" := PurchaseLine.Quantity;

                    SourceDocumentLink."Document Source Type" := Database::"Purchase Header";
                    SourceDocumentLink."Document Source SubType" := PurchaseLine."Document Type".AsInteger();
                    SourceDocumentLink."Document Source ID" := PurchaseLine."Document No.";
                    SourceDocumentLink."Document Source Information" := GetSourceInformation(SourceDocumentLink."Document Source Type", SourceDocumentLink."Document Source SubType", SourceDocumentLink."Document Source ID");

                    SourceDocumentLink."Control Quantity" := PurchaseLine.Quantity;
                    SourceDocumentLink."Default Selected Quantity" := abs(SourceDocumentLink.Quantity);

                    SourceDocumentLink."Opposite Source Type" := OppositeSourceType;
                    SourceDocumentLink."Opposite Source Subtype" := OppositeSourceSubType;

                    case PurchaseLine."Document Type" of
                        "Purchase Document Type"::Order,
                        "Purchase Document Type"::Invoice:
                            SourceDocumentLink.Positive := true;
                        "Purchase Document Type"::"Credit Memo",
                        "Purchase Document Type"::"Return Order":
                            SourceDocumentLink.Positive := false;
                    end;

                    //в таблице резервирования записей может быть несколько на одну партию или лот но разные кол-ва, поэтому запись может уже ьыть 
                    InsertOrAddQuantity(SourceDocumentLink, SourceDocumentLink.Quantity, SourceDocumentLink."Quantity (Base)");

                until ReservationEntry.next() = 0;
        end else begin
            SourceDocumentLink.Init();
            SourceDocumentLink.Clear();
            SourceDocumentLink."Source Type" := Database::"Purchase Line";
            SourceDocumentLink."Source Subtype" := PurchaseLine."Document Type".AsInteger();
            SourceDocumentLink."Source ID" := PurchaseLine."Document No.";
            SourceDocumentLink."Source Ref. No." := PurchaseLine."Line No.";
            SourceDocumentLink."Package No." := '';
            SourceDocumentLink."Lot No." := '';
            SourceDocumentLink."Serial No." := '';
            SourceDocumentLink."Item No." := PurchaseLine."No.";
            SourceDocumentLink."Variant Code" := PurchaseLine."Variant Code";
            SourceDocumentLink.Description := PurchaseLine.Description;
            SourceDocumentLink.Quantity := PurchaseLine.Quantity - PurchaseLine."Quantity Received"; //могли учеть без полеты а на ост. кольво запихнуть в паллету
            SourceDocumentLink."Unit of Measure Code" := PurchaseLine."Unit of Measure Code";
            SourceDocumentLink."Quantity (Base)" := PurchaseLine."Quantity (Base)" - PurchaseLine."Qty. Received (Base)";
            SourceDocumentLink."Weight (Base) per UoM" := GetWeight(PurchaseLine."Gross Weight", PurchaseLine."No.", PurchaseLine."Unit of Measure Code");
            SourceDocumentLink."Volume (Base) per UoM" := GetVolume(PurchaseLine."Unit Volume", PurchaseLine."No.", PurchaseLine."Unit of Measure Code");
            SourceDocumentLink."Qty. per UoM" := PurchaseLine."Qty. per Unit of Measure";
            SourceDocumentLink."Location Code" := PurchaseLine."Location Code";
            SourceDocumentLink."Bin Code" := PurchaseLine."Bin Code";

            SourceDocumentLink."Document Source Type" := Database::"Purchase Header";
            SourceDocumentLink."Document Source SubType" := PurchaseLine."Document Type".AsInteger();
            SourceDocumentLink."Document Source ID" := PurchaseLine."Document No.";
            SourceDocumentLink."Document Source Information" := GetSourceInformation(SourceDocumentLink."Document Source Type", SourceDocumentLink."Document Source SubType", SourceDocumentLink."Document Source ID");

            SourceDocumentLink."Control Quantity" := SourceDocumentLink.Quantity;
            SourceDocumentLink."Default Selected Quantity" := abs(PurchaseLine."Qty. to Receive"); //некорректно для возвратов

            SourceDocumentLink."Opposite Source Type" := OppositeSourceType;
            SourceDocumentLink."Opposite Source Subtype" := OppositeSourceSubType;

            case PurchaseLine."Document Type" of
                "Purchase Document Type"::Order,
                "Purchase Document Type"::Invoice:
                    SourceDocumentLink.Positive := true;
                "Purchase Document Type"::"Credit Memo",
                "Purchase Document Type"::"Return Order":
                    SourceDocumentLink.Positive := false;
            end;

            if SourceDocumentLink.Quantity <> 0 then
                SourceDocumentLink.Insert(true);
        end;
    end;

    internal procedure CreateFrom_PurchRcptLine(var SourceDocumentLink: Record "TMAC Source Document Link"; var PurchRcptLine: Record "Purch. Rcpt. Line"; OppositeSourceType: Integer; OppositeSourceSubType: Integer)
    var
        ItemEntryRelation: Record "Item Entry Relation";
        ItemLedgerEntry: Record "Item Ledger Entry";
        Item: Record Item;
    begin
        if PurchRcptLine.Type <> "Sales Line Type"::Item then
            exit;

        Item.Get(PurchRcptLine."No.");

        if Item."Item Tracking Code" <> '' then begin
            ItemEntryRelation.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Ref. No.", "Source Prod. Order Line", "Source Batch Name");
            ItemEntryRelation.SetRange("Source Type", Database::"Purch. Rcpt. Line");
            ItemEntryRelation.SetRange("Source Subtype", 0);
            ItemEntryRelation.SetRange("Source ID", PurchRcptLine."Document No.");
            ItemEntryRelation.SetRange("Source Batch Name", '');
            ItemEntryRelation.SetRange("Source Prod. Order Line", 0);
            ItemEntryRelation.SetRange("Source Ref. No.", PurchRcptLine."Line No.");
            ItemEntryRelation.SetLoadFields("Item Entry No.");
            if ItemEntryRelation.FindSet() then
                repeat
                    ItemLedgerEntry.get(ItemEntryRelation."Item Entry No.");

                    SourceDocumentLink.Init();
                    SourceDocumentLink.Clear();
                    SourceDocumentLink."Source Type" := Database::"Purch. Rcpt. Line";
                    SourceDocumentLink."Source Subtype" := 0;
                    SourceDocumentLink."Source ID" := PurchRcptLine."Document No.";
                    SourceDocumentLink."Source Ref. No." := PurchRcptLine."Line No.";
                    SourceDocumentLink.Description := PurchRcptLine.Description;

                    SourceDocumentLink."Package No." := ItemLedgerEntry."Package No.";
                    SourceDocumentLink."Lot No." := ItemLedgerEntry."Lot No.";
                    SourceDocumentLink."Serial No." := ItemLedgerEntry."Serial No.";

                    SourceDocumentLink."Item No." := ItemLedgerEntry."Item No.";
                    SourceDocumentLink."Variant Code" := ItemLedgerEntry."Variant Code";
                    SourceDocumentLink.Description := ItemLedgerEntry.Description;

                    SourceDocumentLink."Quantity" := Round(abs(ItemLedgerEntry.Quantity) / ItemLedgerEntry."Qty. per Unit of Measure");
                    SourceDocumentLink."Quantity (Base)" := abs(ItemLedgerEntry.Quantity); //в ILE все в базовой единице

                    SourceDocumentLink."Qty. per UoM" := PurchRcptLine."Qty. per Unit of Measure";
                    SourceDocumentLink."Location Code" := ItemLedgerEntry."Location Code";

                    SourceDocumentLink."Unit of Measure Code" := PurchRcptLine."Unit of Measure Code";
                    SourceDocumentLink."Weight (Base) per UoM" := GetWeight(PurchRcptLine."Gross Weight", PurchRcptLine."No.", PurchRcptLine."Unit of Measure Code");
                    SourceDocumentLink."Volume (Base) per UoM" := GetVolume(PurchRcptLine."Unit Volume", PurchRcptLine."No.", PurchRcptLine."Unit of Measure Code");

                    SourceDocumentLink."Document Source Type" := Database::"Purch. Rcpt. Header";
                    SourceDocumentLink."Document Source SubType" := 0;
                    SourceDocumentLink."Document Source ID" := PurchRcptLine."Document No.";
                    SourceDocumentLink."Document Source Information" := GetSourceInformation(SourceDocumentLink."Document Source Type", SourceDocumentLink."Document Source SubType", SourceDocumentLink."Document Source ID");

                    SourceDocumentLink."Control Quantity" := PurchRcptLine.Quantity;
                    SourceDocumentLink."Default Selected Quantity" := abs(SourceDocumentLink.Quantity);

                    SourceDocumentLink."Opposite Source Type" := OppositeSourceType;
                    SourceDocumentLink."Opposite Source Subtype" := OppositeSourceSubType;

                    SourceDocumentLink.Positive := true;

                    InsertOrAddQuantity(SourceDocumentLink, SourceDocumentLink.Quantity, SourceDocumentLink."Quantity (Base)");


                until ItemEntryRelation.next() = 0;
        end else begin
            SourceDocumentLink.Init();
            SourceDocumentLink.Clear();
            SourceDocumentLink."Source Type" := Database::"Purch. Rcpt. Line";
            SourceDocumentLink."Source Subtype" := 0;
            SourceDocumentLink."Source ID" := PurchRcptLine."Document No.";
            SourceDocumentLink."Source Ref. No." := PurchRcptLine."Line No.";
            SourceDocumentLink."Package No." := '';
            SourceDocumentLink."Lot No." := '';
            SourceDocumentLink."Serial No." := '';

            SourceDocumentLink."Item No." := PurchRcptLine."No.";
            SourceDocumentLink."Variant Code" := PurchRcptLine."Variant Code";
            SourceDocumentLink.Description := PurchRcptLine.Description;
            SourceDocumentLink.Quantity := PurchRcptLine.Quantity;
            SourceDocumentLink."Unit of Measure Code" := PurchRcptLine."Unit of Measure Code";
            SourceDocumentLink."Quantity (Base)" := PurchRcptLine."Quantity (Base)";
            SourceDocumentLink."Weight (Base) per UoM" := GetWeight(PurchRcptLine."Gross Weight", PurchRcptLine."No.", PurchRcptLine."Unit of Measure Code");
            SourceDocumentLink."Volume (Base) per UoM" := GetVolume(PurchRcptLine."Unit Volume", PurchRcptLine."No.", PurchRcptLine."Unit of Measure Code");
            SourceDocumentLink."Qty. per UoM" := PurchRcptLine."Qty. per Unit of Measure";
            SourceDocumentLink."Location Code" := PurchRcptLine."Location Code";
            SourceDocumentLink."Bin Code" := PurchRcptLine."Bin Code";

            SourceDocumentLink."Document Source Type" := Database::"Purch. Rcpt. Header";
            SourceDocumentLink."Document Source SubType" := 0;
            SourceDocumentLink."Document Source ID" := PurchRcptLine."Document No.";
            SourceDocumentLink."Document Source Information" := GetSourceInformation(SourceDocumentLink."Document Source Type", SourceDocumentLink."Document Source SubType", SourceDocumentLink."Document Source ID");

            SourceDocumentLink."Control Quantity" := PurchRcptLine.Quantity;
            SourceDocumentLink."Default Selected Quantity" := abs(SourceDocumentLink.Quantity);

            SourceDocumentLink."Opposite Source Type" := OppositeSourceType;
            SourceDocumentLink."Opposite Source Subtype" := OppositeSourceSubType;
            SourceDocumentLink.Positive := true;

            if SourceDocumentLink.Quantity <> 0 then
                SourceDocumentLink.Insert(true);
        end;
    end;

    /// <summary>
    /// Заполняет таблицу источников на строки документа по строке документа
    /// </summary>
    /// <param name="SourceDocumentLink"></param>
    /// <param name="WarehouseShipmentLine"></param>
    internal procedure CreateFrom_WarehouseReceiptLine(var SourceDocumentLink: Record "TMAC Source Document Link"; var WarehouseReceiptLine: Record "Warehouse Receipt Line"; OppositeSourceType: Integer; OppositeSourceSubType: Integer)
    var
        ReservationEntry: Record "Reservation Entry";
        Item: Record Item;
    begin
        Item.Get(WarehouseReceiptLine."Item No.");
        if Item."Item Tracking Code" <> '' then begin
            ReservationEntry.Reset();
            ReservationEntry.SetCurrentKey("Source ID", "Source Ref. No.", "Source Type", "Source Subtype", "Source Batch Name", "Source Prod. Order Line", "Reservation Status", "Shipment Date", "Expected Receipt Date");
            ReservationEntry.SetFilter("Reservation Status", '%1|%2', "Reservation Status"::Reservation, "Reservation Status"::Surplus);
            ReservationEntry.Setrange("Source Type", WarehouseReceiptLine."Source Type");
            ReservationEntry.Setrange("Source Subtype", WarehouseReceiptLine."Source Subtype");
            ReservationEntry.Setrange("Source ID", WarehouseReceiptLine."Source No.");
            ReservationEntry.Setrange("Source Ref. No.", WarehouseReceiptLine."Source Line No.");
            if ReservationEntry.FindSet() then
                repeat
                    SourceDocumentLink.Init();
                    SourceDocumentLink.Clear();
                    CompleteSourceDocumentLinkFromReservationEntry(SourceDocumentLink, ReservationEntry);
                    SourceDocumentLink."Source Type" := Database::"Warehouse Receipt Line";
                    SourceDocumentLink."Source Subtype" := 0;
                    SourceDocumentLink."Source ID" := WarehouseReceiptLine."No.";
                    SourceDocumentLink."Source Ref. No." := WarehouseReceiptLine."Line No.";
                    SourceDocumentLink.Description := WarehouseReceiptLine.Description;
                    SourceDocumentLink."Unit of Measure Code" := WarehouseReceiptLine."Unit of Measure Code";

                    SourceDocumentLink."Weight (Base) per UoM" := GetWeight(WarehouseReceiptLine.Weight, WarehouseReceiptLine."Item No.", WarehouseReceiptLine."Unit of Measure Code");
                    SourceDocumentLink."Volume (Base) per UoM" := GetVolume(WarehouseReceiptLine.Cubage, WarehouseReceiptLine."Item No.", WarehouseReceiptLine."Unit of Measure Code");

                    SourceDocumentLink."Document Source Type" := WarehouseReceiptLine."Source Type";
                    SourceDocumentLink."Document Source SubType" := WarehouseReceiptLine."Source Subtype";
                    SourceDocumentLink."Document Source ID" := WarehouseReceiptLine."Source No.";
                    SourceDocumentLink."Document Source Information" := GetSourceInformation(SourceDocumentLink."Document Source Type", SourceDocumentLink."Document Source SubType", SourceDocumentLink."Document Source ID");

                    SourceDocumentLink."Control Quantity" := WarehouseReceiptLine.Quantity;
                    SourceDocumentLink."Default Selected Quantity" := abs(SourceDocumentLink.Quantity);

                    SourceDocumentLink."Opposite Source Type" := OppositeSourceType;
                    SourceDocumentLink."Opposite Source Subtype" := OppositeSourceSubType;

                    SourceDocumentLink.Positive := true;

                    InsertOrAddQuantity(SourceDocumentLink, SourceDocumentLink.Quantity, SourceDocumentLink."Quantity (Base)");

                until ReservationEntry.next() = 0;
        end else begin
            SourceDocumentLink.Init();
            SourceDocumentLink.Clear();
            SourceDocumentLink."Source Type" := Database::"Warehouse Receipt Line";
            SourceDocumentLink."Source Subtype" := 0;
            SourceDocumentLink."Source ID" := WarehouseReceiptLine."No.";
            SourceDocumentLink."Source Ref. No." := WarehouseReceiptLine."Line No.";
            SourceDocumentLink."Package No." := '';
            SourceDocumentLink."Lot No." := '';
            SourceDocumentLink."Serial No." := '';

            SourceDocumentLink."Item No." := WarehouseReceiptLine."Item No.";
            SourceDocumentLink."Variant Code" := WarehouseReceiptLine."Variant Code";
            SourceDocumentLink.Description := WarehouseReceiptLine.Description;
            SourceDocumentLink.Quantity := WarehouseReceiptLine.Quantity - WarehouseReceiptLine."Qty. Received";
            SourceDocumentLink."Unit of Measure Code" := WarehouseReceiptLine."Unit of Measure Code";
            SourceDocumentLink."Quantity (Base)" := WarehouseReceiptLine."Qty. (Base)" - WarehouseReceiptLine."Qty. Received (Base)";
            SourceDocumentLink."Weight (Base) per UoM" := GetWeight(WarehouseReceiptLine.Weight, WarehouseReceiptLine."Item No.", WarehouseReceiptLine."Unit of Measure Code");
            SourceDocumentLink."Volume (Base) per UoM" := GetVolume(WarehouseReceiptLine.Cubage, WarehouseReceiptLine."Item No.", WarehouseReceiptLine."Unit of Measure Code");
            SourceDocumentLink."Qty. per UoM" := WarehouseReceiptLine."Qty. per Unit of Measure";
            SourceDocumentLink."Location Code" := WarehouseReceiptLine."Location Code";
            SourceDocumentLink."Bin Code" := WarehouseReceiptLine."Bin Code";

            SourceDocumentLink."Document Source Type" := WarehouseReceiptLine."Source Type";
            SourceDocumentLink."Document Source SubType" := WarehouseReceiptLine."Source Subtype";
            SourceDocumentLink."Document Source ID" := WarehouseReceiptLine."Source No.";
            SourceDocumentLink."Document Source Information" := GetSourceInformation(SourceDocumentLink."Document Source Type", SourceDocumentLink."Document Source SubType", SourceDocumentLink."Document Source ID");

            SourceDocumentLink."Control Quantity" := WarehouseReceiptLine.Quantity;
            SourceDocumentLink."Default Selected Quantity" := abs(WarehouseReceiptLine."Qty. to Receive");

            SourceDocumentLink."Opposite Source Type" := OppositeSourceType;
            SourceDocumentLink."Opposite Source Subtype" := OppositeSourceSubType;

            SourceDocumentLink.Positive := true;

            if SourceDocumentLink.Quantity <> 0 then
                SourceDocumentLink.Insert(true);
        end;
    end;

    internal procedure CreateFrom_PostedWhsReceiptLine(var SourceDocumentLink: Record "TMAC Source Document Link"; var PostedWhseReceiptLine: Record "Posted Whse. Receipt Line"; OppositeSourceType: Integer; OppositeSourceSubType: Integer)
    var
        ItemEntryRelation: Record "Item Entry Relation";
        ItemLedgerEntry: Record "Item Ledger Entry";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        Item: Record Item;
    begin
        Item.Get(PostedWhseReceiptLine."Item No.");
        if Item."Item Tracking Code" <> '' then
            case PostedWhseReceiptLine."Posted Source Document" of
                "Warehouse Shipment Posted Source Document"::"Posted Receipt":
                    begin
                        PurchRcptLine.Reset();
                        PurchRcptLine.SetCurrentKey("Order No.", "Order Line No.", "Posting Date");
                        PurchRcptLine.SetRange("Order No.", PostedWhseReceiptLine."Source No.");
                        PurchRcptLine.SetRange("Order Line No.", PostedWhseReceiptLine."Source Line No.");
                        if PurchRcptLine.FindSet(false) then
                            repeat
                                ItemEntryRelation.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Ref. No.", "Source Prod. Order Line", "Source Batch Name");
                                ItemEntryRelation.SetRange("Source Type", Database::"Purch. Rcpt. Line");
                                ItemEntryRelation.SetRange("Source Subtype", 0);
                                ItemEntryRelation.SetRange("Source ID", PurchRcptLine."Document No.");
                                ItemEntryRelation.SetRange("Source Ref. No.", PurchRcptLine."Line No.");
                                ItemEntryRelation.SetLoadFields("Item Entry No.");
                                if ItemEntryRelation.FindSet() then
                                    repeat
                                        ItemLedgerEntry.get(ItemEntryRelation."Item Entry No.");

                                        SourceDocumentLink.Init();
                                        SourceDocumentLink.Clear();
                                        SourceDocumentLink."Source Type" := Database::"Posted Whse. Receipt Line";
                                        SourceDocumentLink."Source Subtype" := 0;
                                        SourceDocumentLink."Source ID" := PostedWhseReceiptLine."No.";
                                        SourceDocumentLink."Source Ref. No." := PostedWhseReceiptLine."Line No.";
                                        SourceDocumentLink.Description := PostedWhseReceiptLine.Description;

                                        SourceDocumentLink."Package No." := ItemLedgerEntry."Package No.";
                                        SourceDocumentLink."Lot No." := ItemLedgerEntry."Lot No.";
                                        SourceDocumentLink."Serial No." := ItemLedgerEntry."Serial No.";

                                        SourceDocumentLink."Item No." := ItemLedgerEntry."Item No.";
                                        SourceDocumentLink."Variant Code" := ItemLedgerEntry."Variant Code";
                                        SourceDocumentLink.Description := ItemLedgerEntry.Description;

                                        SourceDocumentLink."Quantity" := Round(abs(ItemLedgerEntry.Quantity) / ItemLedgerEntry."Qty. per Unit of Measure");
                                        SourceDocumentLink."Quantity (Base)" := abs(ItemLedgerEntry.Quantity); //в ILE все в базовой единице

                                        SourceDocumentLink."Qty. per UoM" := PurchRcptLine."Qty. per Unit of Measure";
                                        SourceDocumentLink."Location Code" := ItemLedgerEntry."Location Code";

                                        SourceDocumentLink."Unit of Measure Code" := PostedWhseReceiptLine."Unit of Measure Code";
                                        SourceDocumentLink."Weight (Base) per UoM" := GetWeight(0, PostedWhseReceiptLine."Item No.", PostedWhseReceiptLine."Unit of Measure Code");
                                        SourceDocumentLink."Volume (Base) per UoM" := GetVolume(0, PostedWhseReceiptLine."Item No.", PostedWhseReceiptLine."Unit of Measure Code");

                                        SourceDocumentLink."Document Source Type" := PostedWhseReceiptLine."Source Type";
                                        SourceDocumentLink."Document Source SubType" := PostedWhseReceiptLine."Source Subtype";
                                        SourceDocumentLink."Document Source ID" := PostedWhseReceiptLine."Source No.";
                                        SourceDocumentLink."Document Source Information" := GetSourceInformation(SourceDocumentLink."Document Source Type", SourceDocumentLink."Document Source SubType", SourceDocumentLink."Document Source ID");

                                        SourceDocumentLink."Control Quantity" := PostedWhseReceiptLine.Quantity;
                                        SourceDocumentLink."Default Selected Quantity" := abs(SourceDocumentLink.Quantity);

                                        SourceDocumentLink."Opposite Source Type" := OppositeSourceType;
                                        SourceDocumentLink."Opposite Source Subtype" := OppositeSourceSubType;

                                        SourceDocumentLink.Positive := true;

                                        InsertOrAddQuantity(SourceDocumentLink, SourceDocumentLink.Quantity, SourceDocumentLink."Quantity (Base)");

                                    until ItemEntryRelation.next() = 0;
                            until PurchRcptLine.Next() = 0;
                    end
            end
        else begin
            SourceDocumentLink.Init();
            SourceDocumentLink.Clear();
            SourceDocumentLink."Source Type" := Database::"Posted Whse. Receipt Line";
            SourceDocumentLink."Source Subtype" := 0;
            SourceDocumentLink."Source ID" := PostedWhseReceiptLine."No.";
            SourceDocumentLink."Source Ref. No." := PostedWhseReceiptLine."Line No.";
            SourceDocumentLink."Package No." := '';
            SourceDocumentLink."Lot No." := '';
            SourceDocumentLink."Serial No." := '';

            SourceDocumentLink."Item No." := PostedWhseReceiptLine."Item No.";
            SourceDocumentLink."Variant Code" := PostedWhseReceiptLine."Variant Code";
            SourceDocumentLink.Description := PostedWhseReceiptLine.Description;
            SourceDocumentLink.Quantity := PostedWhseReceiptLine.Quantity;
            SourceDocumentLink."Unit of Measure Code" := PostedWhseReceiptLine."Unit of Measure Code";
            SourceDocumentLink."Quantity (Base)" := PostedWhseReceiptLine."Qty. (Base)";
            SourceDocumentLink."Weight (Base) per UoM" := GetWeight(0, PostedWhseReceiptLine."Item No.", PostedWhseReceiptLine."Unit of Measure Code");
            SourceDocumentLink."Volume (Base) per UoM" := GetVolume(0, PostedWhseReceiptLine."Item No.", PostedWhseReceiptLine."Unit of Measure Code");
            SourceDocumentLink."Qty. per UoM" := PostedWhseReceiptLine."Qty. per Unit of Measure";
            SourceDocumentLink."Location Code" := PostedWhseReceiptLine."Location Code";
            SourceDocumentLink."Bin Code" := PostedWhseReceiptLine."Bin Code";

            SourceDocumentLink."Document Source Type" := PostedWhseReceiptLine."Source Type";
            SourceDocumentLink."Document Source SubType" := PostedWhseReceiptLine."Source Subtype";
            SourceDocumentLink."Document Source ID" := PostedWhseReceiptLine."Source No.";
            SourceDocumentLink."Document Source Information" := GetSourceInformation(SourceDocumentLink."Document Source Type", SourceDocumentLink."Document Source SubType", SourceDocumentLink."Document Source ID");

            SourceDocumentLink."Control Quantity" := PostedWhseReceiptLine.Quantity;
            SourceDocumentLink."Default Selected Quantity" := abs(SourceDocumentLink.Quantity);

            SourceDocumentLink."Opposite Source Type" := OppositeSourceType;
            SourceDocumentLink."Opposite Source Subtype" := OppositeSourceSubType;
            SourceDocumentLink.Positive := true;

            if SourceDocumentLink.Quantity <> 0 then
                SourceDocumentLink.Insert(true);
        end;
    end;

    /// <summary>
    /// ВОзврат продажи
    /// </summary>
    /// <param name="SourceDocumentLink"></param>
    /// <param name="ReturnReceiptLineP"></param>
    /// <param name="OppositeSourceType"></param>
    /// <param name="OppositeSourceSubType"></param>
    internal procedure CreateFrom_ReturnReceiptLine(var SourceDocumentLink: Record "TMAC Source Document Link"; var ReturnReceiptLine: Record "Return Receipt Line"; OppositeSourceType: Integer; OppositeSourceSubType: Integer)
    var
        ItemEntryRelation: Record "Item Entry Relation";
        ItemLedgerEntry: Record "Item Ledger Entry";
        Item: Record Item;
    begin
        if ReturnReceiptLine.Type <> "Sales Line Type"::Item then
            exit;

        Item.Get(ReturnReceiptLine."No.");

        if Item."Item Tracking Code" <> '' then begin
            ItemEntryRelation.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Ref. No.", "Source Prod. Order Line", "Source Batch Name");
            ItemEntryRelation.SetRange("Source Type", Database::"Return Receipt Line");
            ItemEntryRelation.SetRange("Source Subtype", 0);
            ItemEntryRelation.SetRange("Source ID", ReturnReceiptLine."Document No.");
            ItemEntryRelation.SetRange("Source Batch Name", '');
            ItemEntryRelation.SetRange("Source Prod. Order Line", 0);
            ItemEntryRelation.SetRange("Source Ref. No.", ReturnReceiptLine."Line No.");
            ItemEntryRelation.SetLoadFields("Item Entry No.");
            if ItemEntryRelation.FindSet() then
                repeat
                    ItemLedgerEntry.get(ItemEntryRelation."Item Entry No.");

                    SourceDocumentLink.Init();
                    SourceDocumentLink.Clear();
                    SourceDocumentLink."Source Type" := Database::"Return Receipt Line";
                    SourceDocumentLink."Source Subtype" := 0;
                    SourceDocumentLink."Source ID" := ReturnReceiptLine."Document No.";
                    SourceDocumentLink."Source Ref. No." := ReturnReceiptLine."Line No.";
                    SourceDocumentLink.Description := ReturnReceiptLine.Description;
                    SourceDocumentLink."Package No." := ItemLedgerEntry."Package No.";
                    SourceDocumentLink."Lot No." := ItemLedgerEntry."Lot No.";
                    SourceDocumentLink."Serial No." := ItemLedgerEntry."Serial No.";
                    SourceDocumentLink."Item No." := ItemLedgerEntry."Item No.";
                    SourceDocumentLink."Variant Code" := ItemLedgerEntry."Variant Code";
                    SourceDocumentLink.Description := ItemLedgerEntry.Description;
                    SourceDocumentLink."Quantity" := Round(abs(ItemLedgerEntry.Quantity) / ItemLedgerEntry."Qty. per Unit of Measure");
                    SourceDocumentLink."Quantity (Base)" := abs(ItemLedgerEntry.Quantity); //в ILE все в базовой единице
                    SourceDocumentLink."Qty. per UoM" := ReturnReceiptLine."Qty. per Unit of Measure";
                    SourceDocumentLink."Location Code" := ItemLedgerEntry."Location Code";
                    SourceDocumentLink."Unit of Measure Code" := ReturnReceiptLine."Unit of Measure Code";
                    SourceDocumentLink."Weight (Base) per UoM" := GetWeight(ReturnReceiptLine."Gross Weight", ReturnReceiptLine."No.", ReturnReceiptLine."Unit of Measure Code");
                    SourceDocumentLink."Volume (Base) per UoM" := GetVolume(ReturnReceiptLine."Unit Volume", ReturnReceiptLine."No.", ReturnReceiptLine."Unit of Measure Code");

                    SourceDocumentLink."Document Source Type" := Database::"Return Receipt Header";
                    SourceDocumentLink."Document Source SubType" := 0;
                    SourceDocumentLink."Document Source ID" := ReturnReceiptLine."Document No.";
                    SourceDocumentLink."Document Source Information" := GetSourceInformation(SourceDocumentLink."Document Source Type", SourceDocumentLink."Document Source SubType", SourceDocumentLink."Document Source ID");

                    SourceDocumentLink."Control Quantity" := ReturnReceiptLine.Quantity;
                    SourceDocumentLink."Default Selected Quantity" := abs(SourceDocumentLink.Quantity);

                    SourceDocumentLink."Opposite Source Type" := OppositeSourceType;
                    SourceDocumentLink."Opposite Source Subtype" := OppositeSourceSubType;

                    SourceDocumentLink.Positive := true;

                    InsertOrAddQuantity(SourceDocumentLink, SourceDocumentLink.Quantity, SourceDocumentLink."Quantity (Base)");

                until ItemEntryRelation.next() = 0;
        end else begin
            SourceDocumentLink.Init();
            SourceDocumentLink.Clear();
            SourceDocumentLink."Source Type" := Database::"Return Receipt Line";
            SourceDocumentLink."Source Subtype" := 0;
            SourceDocumentLink."Source ID" := ReturnReceiptLine."Document No.";
            SourceDocumentLink."Source Ref. No." := ReturnReceiptLine."Line No.";
            SourceDocumentLink."Package No." := '';
            SourceDocumentLink."Lot No." := '';
            SourceDocumentLink."Serial No." := '';

            SourceDocumentLink."Item No." := ReturnReceiptLine."No.";
            SourceDocumentLink."Variant Code" := ReturnReceiptLine."Variant Code";
            SourceDocumentLink.Description := ReturnReceiptLine.Description;
            SourceDocumentLink.Quantity := ReturnReceiptLine.Quantity;
            SourceDocumentLink."Unit of Measure Code" := ReturnReceiptLine."Unit of Measure Code";
            SourceDocumentLink."Quantity (Base)" := ReturnReceiptLine."Quantity (Base)";
            SourceDocumentLink."Weight (Base) per UoM" := GetWeight(ReturnReceiptLine."Gross Weight", ReturnReceiptLine."No.", ReturnReceiptLine."Unit of Measure Code");
            SourceDocumentLink."Volume (Base) per UoM" := GetVolume(ReturnReceiptLine."Unit Volume", ReturnReceiptLine."No.", ReturnReceiptLine."Unit of Measure Code");
            SourceDocumentLink."Qty. per UoM" := ReturnReceiptLine."Qty. per Unit of Measure";
            SourceDocumentLink."Location Code" := ReturnReceiptLine."Location Code";
            SourceDocumentLink."Bin Code" := ReturnReceiptLine."Bin Code";

            SourceDocumentLink."Document Source Type" := Database::"Return Receipt Header";
            SourceDocumentLink."Document Source SubType" := 0;
            SourceDocumentLink."Document Source ID" := ReturnReceiptLine."Document No.";
            SourceDocumentLink."Document Source Information" := GetSourceInformation(SourceDocumentLink."Document Source Type", SourceDocumentLink."Document Source SubType", SourceDocumentLink."Document Source ID");

            SourceDocumentLink."Control Quantity" := ReturnReceiptLine.Quantity;
            SourceDocumentLink."Default Selected Quantity" := abs(SourceDocumentLink.Quantity);

            SourceDocumentLink."Opposite Source Type" := OppositeSourceType;
            SourceDocumentLink."Opposite Source Subtype" := OppositeSourceSubType;

            SourceDocumentLink.Positive := true;

            if SourceDocumentLink.Quantity <> 0 then
                SourceDocumentLink.Insert(true);
        end;
    end;

    /// <summary>
    /// ВОзврат покупки
    /// </summary>
    /// <param name="SourceDocumentLink"></param>
    /// <param name="ReturnReceiptLine"></param>
    /// <param name="OppositeSourceType"></param>
    /// <param name="OppositeSourceSubType"></param>
    internal procedure CreateFrom_ReturnShipmentLine(var SourceDocumentLink: Record "TMAC Source Document Link"; var ReturnShipmentLine: Record "Return Shipment Line"; OppositeSourceType: Integer; OppositeSourceSubType: Integer)
    var
        ItemEntryRelation: Record "Item Entry Relation";
        ItemLedgerEntry: Record "Item Ledger Entry";
        Item: Record Item;
    begin
        if ReturnShipmentLine.Type <> "Purchase Line Type"::Item then
            exit;

        Item.Get(ReturnShipmentLine."No.");

        if Item."Item Tracking Code" <> '' then begin
            ItemEntryRelation.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Ref. No.", "Source Prod. Order Line", "Source Batch Name");
            ItemEntryRelation.SetRange("Source Type", Database::"Return Shipment Line");
            ItemEntryRelation.SetRange("Source Subtype", 0);
            ItemEntryRelation.SetRange("Source ID", ReturnShipmentLine."Document No.");
            ItemEntryRelation.SetRange("Source Batch Name", '');
            ItemEntryRelation.SetRange("Source Prod. Order Line", 0);
            ItemEntryRelation.SetRange("Source Ref. No.", ReturnShipmentLine."Line No.");
            ItemEntryRelation.SetLoadFields("Item Entry No.");
            if ItemEntryRelation.FindSet() then
                repeat
                    ItemLedgerEntry.get(ItemEntryRelation."Item Entry No.");

                    SourceDocumentLink.Init();
                    SourceDocumentLink.Clear();
                    SourceDocumentLink."Source Type" := Database::"Return Shipment Line";
                    SourceDocumentLink."Source Subtype" := 0;
                    SourceDocumentLink."Source ID" := ReturnShipmentLine."Document No.";
                    SourceDocumentLink."Source Ref. No." := ReturnShipmentLine."Line No.";
                    SourceDocumentLink.Description := ReturnShipmentLine.Description;
                    SourceDocumentLink."Package No." := ItemLedgerEntry."Package No.";
                    SourceDocumentLink."Lot No." := ItemLedgerEntry."Lot No.";
                    SourceDocumentLink."Serial No." := ItemLedgerEntry."Serial No.";
                    SourceDocumentLink."Item No." := ItemLedgerEntry."Item No.";
                    SourceDocumentLink."Variant Code" := ItemLedgerEntry."Variant Code";
                    SourceDocumentLink.Description := ItemLedgerEntry.Description;
                    SourceDocumentLink."Quantity" := Round(abs(ItemLedgerEntry.Quantity) / ItemLedgerEntry."Qty. per Unit of Measure");
                    SourceDocumentLink."Quantity (Base)" := abs(ItemLedgerEntry.Quantity); //в ILE все в базовой единице
                    SourceDocumentLink."Qty. per UoM" := ReturnShipmentLine."Qty. per Unit of Measure";
                    SourceDocumentLink."Location Code" := ItemLedgerEntry."Location Code";
                    SourceDocumentLink."Unit of Measure Code" := ReturnShipmentLine."Unit of Measure Code";
                    SourceDocumentLink."Weight (Base) per UoM" := GetWeight(ReturnShipmentLine."Gross Weight", ReturnShipmentLine."No.", ReturnShipmentLine."Unit of Measure Code");
                    SourceDocumentLink."Volume (Base) per UoM" := GetVolume(ReturnShipmentLine."Unit Volume", ReturnShipmentLine."No.", ReturnShipmentLine."Unit of Measure Code");

                    SourceDocumentLink."Document Source Type" := Database::"Return Shipment Header";
                    SourceDocumentLink."Document Source SubType" := 0;
                    SourceDocumentLink."Document Source ID" := ReturnShipmentLine."Document No.";
                    SourceDocumentLink."Document Source Information" := GetSourceInformation(SourceDocumentLink."Document Source Type", SourceDocumentLink."Document Source SubType", SourceDocumentLink."Document Source ID");

                    SourceDocumentLink."Control Quantity" := ReturnShipmentLine.Quantity;
                    SourceDocumentLink."Default Selected Quantity" := abs(SourceDocumentLink.Quantity);

                    SourceDocumentLink."Opposite Source Type" := OppositeSourceType;
                    SourceDocumentLink."Opposite Source Subtype" := OppositeSourceSubType;

                    SourceDocumentLink.Positive := false;

                    InsertOrAddQuantity(SourceDocumentLink, SourceDocumentLink.Quantity, SourceDocumentLink."Quantity (Base)");

                until ItemEntryRelation.next() = 0;
        end else begin
            SourceDocumentLink.Init();
            SourceDocumentLink.Clear();
            SourceDocumentLink."Source Type" := Database::"Return Shipment Line";
            SourceDocumentLink."Source Subtype" := 0;
            SourceDocumentLink."Source ID" := ReturnShipmentLine."Document No.";
            SourceDocumentLink."Source Ref. No." := ReturnShipmentLine."Line No.";
            SourceDocumentLink."Package No." := '';
            SourceDocumentLink."Lot No." := '';
            SourceDocumentLink."Serial No." := '';

            SourceDocumentLink."Item No." := ReturnShipmentLine."No.";
            SourceDocumentLink."Variant Code" := ReturnShipmentLine."Variant Code";
            SourceDocumentLink.Description := ReturnShipmentLine.Description;
            SourceDocumentLink.Quantity := ReturnShipmentLine.Quantity;
            SourceDocumentLink."Unit of Measure Code" := ReturnShipmentLine."Unit of Measure Code";
            SourceDocumentLink."Quantity (Base)" := ReturnShipmentLine."Quantity (Base)";
            SourceDocumentLink."Weight (Base) per UoM" := GetWeight(ReturnShipmentLine."Gross Weight", ReturnShipmentLine."No.", ReturnShipmentLine."Unit of Measure Code");
            SourceDocumentLink."Volume (Base) per UoM" := GetVolume(ReturnShipmentLine."Unit Volume", ReturnShipmentLine."No.", ReturnShipmentLine."Unit of Measure Code");
            SourceDocumentLink."Qty. per UoM" := ReturnShipmentLine."Qty. per Unit of Measure";
            SourceDocumentLink."Location Code" := ReturnShipmentLine."Location Code";
            SourceDocumentLink."Bin Code" := ReturnShipmentLine."Bin Code";

            SourceDocumentLink."Document Source Type" := Database::"Return Shipment Header";
            SourceDocumentLink."Document Source SubType" := 0;
            SourceDocumentLink."Document Source ID" := ReturnShipmentLine."Document No.";
            SourceDocumentLink."Document Source Information" := GetSourceInformation(SourceDocumentLink."Document Source Type", SourceDocumentLink."Document Source SubType", SourceDocumentLink."Document Source ID");

            SourceDocumentLink."Control Quantity" := ReturnShipmentLine.Quantity;
            SourceDocumentLink."Default Selected Quantity" := abs(SourceDocumentLink.Quantity);

            SourceDocumentLink."Opposite Source Type" := OppositeSourceType;
            SourceDocumentLink."Opposite Source Subtype" := OppositeSourceSubType;

            SourceDocumentLink.Positive := false;

            if SourceDocumentLink.Quantity <> 0 then
                SourceDocumentLink.Insert(true);
        end;
    end;

    /// <summary>
    /// Заполняет таблицу источников на строки документа по строке документа
    /// </summary>
    /// <param name="SourceDocumentLink"></param>
    /// <param name="WarehouseShipmentLine"></param>
    internal procedure CreateFrom_TransferLine(var SourceDocumentLink: Record "TMAC Source Document Link"; var TransferLine: Record "Transfer Line"; OppositeSourceType: Integer; OppositeSourceSubType: Integer; Positive: Boolean)
    var
        ReservationEntry: Record "Reservation Entry";
        Item: Record Item;
    begin
        Item.Get(TransferLine."Item No.");
        if Item."Item Tracking Code" <> '' then begin
            ReservationEntry.Reset();
            ReservationEntry.SetCurrentKey("Source ID", "Source Ref. No.", "Source Type", "Source Subtype", "Source Batch Name", "Source Prod. Order Line", "Reservation Status", "Shipment Date", "Expected Receipt Date");
            ReservationEntry.SetFilter("Reservation Status", '%1|%2', "Reservation Status"::Reservation, "Reservation Status"::Surplus);
            ReservationEntry.Setrange("Source Type", Database::"Transfer Line");
            //ReservationEntry.Setrange("Source Subtype", 0); //лол 0 это признак минусовой операции тут для перемезений
            ReservationEntry.Setrange("Source ID", TransferLine."Document No.");
            ReservationEntry.Setrange("Source Ref. No.", TransferLine."Line No.");
            ReservationEntry.Setrange(Positive, Positive);
            if ReservationEntry.FindSet() then
                repeat
                    SourceDocumentLink.Init();
                    SourceDocumentLink.Clear();
                    CompleteSourceDocumentLinkFromReservationEntry(SourceDocumentLink, ReservationEntry);
                    SourceDocumentLink."Source Type" := Database::"Transfer Line";

                    if Positive then
                        SourceDocumentLink."Source Subtype" := 1
                    else
                        SourceDocumentLink."Source Subtype" := 0; //сам BC в строках WS WR использует это поле как признак что это плюсовая или нминсовая операция

                    SourceDocumentLink."Source ID" := TransferLine."Document No.";
                    SourceDocumentLink."Source Ref. No." := TransferLine."Line No.";
                    SourceDocumentLink.Description := TransferLine.Description;
                    SourceDocumentLink."Unit of Measure Code" := TransferLine."Unit of Measure Code";
                    SourceDocumentLink."Weight (Base) per UoM" := GetWeight(TransferLine."Gross Weight", TransferLine."Item No.", TransferLine."Unit of Measure Code");
                    SourceDocumentLink."Volume (Base) per UoM" := GetVolume(TransferLine."Unit Volume", TransferLine."Item No.", TransferLine."Unit of Measure Code");
                    SourceDocumentLink."Location Code" := ReservationEntry."Location Code";
                    SourceDocumentLink."Bin Code" := '';

                    SourceDocumentLink."Document Source Type" := Database::"Transfer Header";
                    SourceDocumentLink."Document Source SubType" := 0;
                    SourceDocumentLink."Document Source ID" := TransferLine."Document No.";
                    SourceDocumentLink."Document Source Information" := GetSourceInformation(SourceDocumentLink."Document Source Type", SourceDocumentLink."Document Source SubType", SourceDocumentLink."Document Source ID");

                    SourceDocumentLink."Control Quantity" := TransferLine.Quantity;
                    SourceDocumentLink."Default Selected Quantity" := abs(SourceDocumentLink.Quantity);

                    SourceDocumentLink."Opposite Source Type" := OppositeSourceType;
                    SourceDocumentLink."Opposite Source Subtype" := OppositeSourceSubType;

                    SourceDocumentLink.Positive := ReservationEntry.Positive;

                    InsertOrAddQuantity(SourceDocumentLink, SourceDocumentLink.Quantity, SourceDocumentLink."Quantity (Base)");

                until ReservationEntry.next() = 0;
        end else begin
            SourceDocumentLink.Init();
            SourceDocumentLink.Clear();
            SourceDocumentLink."Source Type" := Database::"Transfer Line";

            if Positive then
                SourceDocumentLink."Source Subtype" := 1
            else
                SourceDocumentLink."Source Subtype" := 0; //сам BC  в WS WR использует это поле как признак что это плюсовая или нминсовая операция

            SourceDocumentLink."Source ID" := TransferLine."Document No.";
            SourceDocumentLink."Source Ref. No." := TransferLine."Line No.";
            SourceDocumentLink."Package No." := '';
            SourceDocumentLink."Lot No." := '';
            SourceDocumentLink."Serial No." := '';

            SourceDocumentLink."Item No." := TransferLine."Item No.";
            SourceDocumentLink."Variant Code" := TransferLine."Variant Code";
            SourceDocumentLink.Description := TransferLine.Description;

            SourceDocumentLink."Weight (Base) per UoM" := GetWeight(TransferLine."Gross Weight", TransferLine."Item No.", TransferLine."Unit of Measure Code");
            SourceDocumentLink."Volume (Base) per UoM" := GetVolume(TransferLine."Unit Volume", TransferLine."Item No.", TransferLine."Unit of Measure Code");
            SourceDocumentLink."Qty. per UoM" := TransferLine."Qty. per Unit of Measure";

            SourceDocumentLink."Document Source Type" := Database::"Transfer Header";
            SourceDocumentLink."Document Source SubType" := 0;
            SourceDocumentLink."Document Source ID" := TransferLine."Document No.";
            SourceDocumentLink."Document Source Information" := GetSourceInformation(SourceDocumentLink."Document Source Type", SourceDocumentLink."Document Source SubType", SourceDocumentLink."Document Source ID");

            SourceDocumentLink."Control Quantity" := TransferLine.Quantity;

            SourceDocumentLink."Opposite Source Type" := OppositeSourceType;
            SourceDocumentLink."Opposite Source Subtype" := OppositeSourceSubType;

            SourceDocumentLink.Positive := Positive;

            if Positive then begin
                SourceDocumentLink."Location Code" := TransferLine."Transfer-to Code";
                SourceDocumentLink."Bin Code" := '';
                SourceDocumentLink."Quantity" := TransferLine.Quantity - TransferLine."Quantity Received";
                SourceDocumentLink."Unit of Measure Code" := TransferLine."Unit of Measure Code";
                SourceDocumentLink."Quantity (Base)" := TransferLine."Quantity (Base)" - TransferLine."Qty. Received (Base)";
            end else begin
                SourceDocumentLink."Location Code" := TransferLine."Transfer-from Code";
                SourceDocumentLink."Bin Code" := '';
                SourceDocumentLink."Quantity" := TransferLine.Quantity - TransferLine."Quantity Shipped";
                SourceDocumentLink."Unit of Measure Code" := TransferLine."Unit of Measure Code";
                SourceDocumentLink."Quantity (Base)" := TransferLine."Quantity (Base)" - TransferLine."Qty. Shipped (Base)";
            end;

            SourceDocumentLink."Default Selected Quantity" := abs(SourceDocumentLink.Quantity);

            if SourceDocumentLink.Quantity <> 0 then
                SourceDocumentLink.Insert(true);
        end;
    end;

    /// <summary>
    /// Заполняет Activity Line 
    /// </summary>
    /// <param name="SourceDocumentLink"></param>
    /// <param name="WarehouseShipmentLine"></param>
    procedure CreateFrom_WarehouseActivityLine(var SourceDocumentLink: Record "TMAC Source Document Link"; WarehouseActivityLine: Record "Warehouse Activity Line"; OppositeSourceType: Integer; OppositeSourceSubType: Integer)
    begin
        SourceDocumentLink.Init();
        SourceDocumentLink.Clear();
        SourceDocumentLink."Source Type" := Database::"Warehouse Activity Line";
        SourceDocumentLink."Source Subtype" := WarehouseActivityLine."Activity Type".AsInteger();
        SourceDocumentLink."Source ID" := WarehouseActivityLine."No.";
        SourceDocumentLink."Source Ref. No." := WarehouseActivityLine."Line No.";
        SourceDocumentLink."Package No." := '';
        SourceDocumentLink."Lot No." := '';
        SourceDocumentLink."Serial No." := '';

        SourceDocumentLink."Item No." := WarehouseActivityLine."Item No.";
        SourceDocumentLink."Variant Code" := WarehouseActivityLine."Variant Code";
        SourceDocumentLink.Description := WarehouseActivityLine.Description;
        SourceDocumentLink.Quantity := abs(WarehouseActivityLine."Qty. Outstanding");
        SourceDocumentLink."Unit of Measure Code" := WarehouseActivityLine."Unit of Measure Code";
        SourceDocumentLink."Quantity (Base)" := abs(WarehouseActivityLine."Qty. Outstanding (Base)");
        SourceDocumentLink."Weight (Base) per UoM" := GetWeight(0, WarehouseActivityLine."Item No.", WarehouseActivityLine."Unit of Measure Code");
        SourceDocumentLink."Volume (Base) per UoM" := GetVolume(0, WarehouseActivityLine."Item No.", WarehouseActivityLine."Unit of Measure Code");
        SourceDocumentLink."Qty. per UoM" := WarehouseActivityLine."Qty. per Unit of Measure";
        SourceDocumentLink."Location Code" := WarehouseActivityLine."Location Code";

        SourceDocumentLink."Document Source Type" := WarehouseActivityLine."Source Type";
        SourceDocumentLink."Document Source SubType" := WarehouseActivityLine."Source Subtype";
        SourceDocumentLink."Document Source ID" := WarehouseActivityLine."Source No.";
        SourceDocumentLink."Document Source Information" := GetSourceInformation(SourceDocumentLink."Document Source Type", SourceDocumentLink."Document Source SubType", SourceDocumentLink."Document Source ID");

        SourceDocumentLink."Control Quantity" := ABS(WarehouseActivityLine."Qty. Outstanding");
        SourceDocumentLink."Default Selected Quantity" := abs(SourceDocumentLink.Quantity);

        SourceDocumentLink."Opposite Source Type" := OppositeSourceType;
        SourceDocumentLink."Opposite Source Subtype" := OppositeSourceSubType;

        SourceDocumentLink."Lot No." := WarehouseActivityLine."Lot No.";
        SourceDocumentLink."Package No." := WarehouseActivityLine."Package No.";
        SourceDocumentLink."Serial No." := WarehouseActivityLine."Serial No.";

        case WarehouseActivityLine."Action Type" of
            "Warehouse Action Type"::Take:
                SourceDocumentLink.Positive := false;
            "Warehouse Action Type"::Place:
                SourceDocumentLink.Positive := true;
        end;

        if SourceDocumentLink.Insert() then;
        //InsertOrAddQuantity(SourceDocumentLink, abs(WarehouseActivityLine."Qty. Outstanding"), abs(WarehouseActivityLine."Qty. Outstanding (Base)"));

        //if SourceDocumentLink.Quantity = 0 then
        //    SourceDocumentLink.Quantity := abs(WarehouseActivityLine."Qty. Outstanding");
        //if SourceDocumentLink."Quantity (Base)" = 0 then
        //    SourceDocumentLink."Quantity (Base)" := abs(WarehouseActivityLine."Qty. Outstanding (Base)");
        //SourceDocumentLink.Modify();
    end;

    /// <summary>
    /// Заполняет зарегистрированные Activity Line 
    /// </summary>
    /// <param name="SourceDocumentLink"></param>
    /// <param name="WarehouseShipmentLine"></param>
    procedure CreateFrom_RegisteredWhseActivityLine(var SourceDocumentLink: Record "TMAC Source Document Link"; RegisteredWhseActivityLine: Record "Registered Whse. Activity Line"; OppositeSourceType: Integer; OppositeSourceSubType: Integer)
    begin
        SourceDocumentLink.Init();
        SourceDocumentLink.Clear();
        SourceDocumentLink."Source Type" := Database::"Registered Whse. Activity Line";
        SourceDocumentLink."Source Subtype" := RegisteredWhseActivityLine."Activity Type".AsInteger();
        SourceDocumentLink."Source ID" := RegisteredWhseActivityLine."No.";
        SourceDocumentLink."Source Ref. No." := RegisteredWhseActivityLine."Line No.";
        SourceDocumentLink."Item No." := RegisteredWhseActivityLine."Item No.";
        SourceDocumentLink."Variant Code" := RegisteredWhseActivityLine."Variant Code";
        SourceDocumentLink.Description := RegisteredWhseActivityLine.Description;
        SourceDocumentLink.Quantity := abs(RegisteredWhseActivityLine.Quantity);
        SourceDocumentLink."Unit of Measure Code" := RegisteredWhseActivityLine."Unit of Measure Code";
        SourceDocumentLink."Quantity (Base)" := abs(RegisteredWhseActivityLine."Qty. (Base)");
        SourceDocumentLink."Weight (Base) per UoM" := GetWeight(0, RegisteredWhseActivityLine."Item No.", RegisteredWhseActivityLine."Unit of Measure Code");
        SourceDocumentLink."Volume (Base) per UoM" := GetVolume(0, RegisteredWhseActivityLine."Item No.", RegisteredWhseActivityLine."Unit of Measure Code");
        SourceDocumentLink."Qty. per UoM" := RegisteredWhseActivityLine."Qty. per Unit of Measure";
        SourceDocumentLink."Location Code" := RegisteredWhseActivityLine."Location Code";

        SourceDocumentLink."Document Source Type" := RegisteredWhseActivityLine."Source Type";
        SourceDocumentLink."Document Source SubType" := RegisteredWhseActivityLine."Source Subtype";
        SourceDocumentLink."Document Source ID" := RegisteredWhseActivityLine."Source No.";
        SourceDocumentLink."Document Source Information" := GetSourceInformation(SourceDocumentLink."Document Source Type", SourceDocumentLink."Document Source SubType", SourceDocumentLink."Document Source ID");

        SourceDocumentLink."Control Quantity" := ABS(RegisteredWhseActivityLine.Quantity);
        SourceDocumentLink."Default Selected Quantity" := abs(SourceDocumentLink.Quantity);

        SourceDocumentLink."Opposite Source Type" := OppositeSourceType;
        SourceDocumentLink."Opposite Source Subtype" := OppositeSourceSubType;

        SourceDocumentLink."Lot No." := RegisteredWhseActivityLine."Lot No.";
        SourceDocumentLink."Package No." := RegisteredWhseActivityLine."Package No.";
        SourceDocumentLink."Serial No." := RegisteredWhseActivityLine."Serial No.";

        case RegisteredWhseActivityLine."Action Type" of
            "Warehouse Action Type"::Take:
                SourceDocumentLink.Positive := false;
            "Warehouse Action Type"::Place:
                SourceDocumentLink.Positive := true;
        end;

        InsertOrAddQuantity(SourceDocumentLink, SourceDocumentLink.Quantity, SourceDocumentLink."Quantity (Base)");

    end;

    procedure CreateFrom_RegisteredPostedInvtPutawayLine(var SourceDocumentLink: Record "TMAC Source Document Link"; PostedInvtPutawayLine: Record "Posted Invt. Put-away Line"; OppositeSourceType: Integer; OppositeSourceSubType: Integer)
    begin
        SourceDocumentLink.Init();
        SourceDocumentLink.Clear();
        SourceDocumentLink."Source Type" := Database::"Posted Invt. Put-away Line";
        SourceDocumentLink."Source Subtype" := 0;
        SourceDocumentLink."Source ID" := PostedInvtPutawayLine."No.";
        SourceDocumentLink."Source Ref. No." := PostedInvtPutawayLine."Line No.";
        SourceDocumentLink."Item No." := PostedInvtPutawayLine."Item No.";
        SourceDocumentLink."Variant Code" := PostedInvtPutawayLine."Variant Code";
        SourceDocumentLink.Description := PostedInvtPutawayLine.Description;
        SourceDocumentLink.Quantity := abs(PostedInvtPutawayLine.Quantity);
        SourceDocumentLink."Unit of Measure Code" := PostedInvtPutawayLine."Unit of Measure Code";
        SourceDocumentLink."Quantity (Base)" := abs(PostedInvtPutawayLine."Qty. (Base)");
        SourceDocumentLink."Weight (Base) per UoM" := GetWeight(0, PostedInvtPutawayLine."Item No.", PostedInvtPutawayLine."Unit of Measure Code");
        SourceDocumentLink."Volume (Base) per UoM" := GetVolume(0, PostedInvtPutawayLine."Item No.", PostedInvtPutawayLine."Unit of Measure Code");
        SourceDocumentLink."Qty. per UoM" := PostedInvtPutawayLine."Qty. per Unit of Measure";
        SourceDocumentLink."Location Code" := PostedInvtPutawayLine."Location Code";

        SourceDocumentLink."Document Source Type" := PostedInvtPutawayLine."Source Type";
        SourceDocumentLink."Document Source SubType" := PostedInvtPutawayLine."Source Subtype";
        SourceDocumentLink."Document Source ID" := PostedInvtPutawayLine."Source No.";
        SourceDocumentLink."Document Source Information" := GetSourceInformation(SourceDocumentLink."Document Source Type", SourceDocumentLink."Document Source SubType", SourceDocumentLink."Document Source ID");

        SourceDocumentLink."Control Quantity" := ABS(PostedInvtPutawayLine.Quantity);
        SourceDocumentLink."Default Selected Quantity" := abs(SourceDocumentLink.Quantity);

        SourceDocumentLink."Opposite Source Type" := OppositeSourceType;
        SourceDocumentLink."Opposite Source Subtype" := OppositeSourceSubType;

        SourceDocumentLink."Lot No." := PostedInvtPutawayLine."Lot No.";
        SourceDocumentLink."Package No." := PostedInvtPutawayLine."Package No.";
        SourceDocumentLink."Serial No." := PostedInvtPutawayLine."Serial No.";


        SourceDocumentLink.Positive := PostedInvtPutawayLine.Quantity > 0;

        InsertOrAddQuantity(SourceDocumentLink, SourceDocumentLink.Quantity, SourceDocumentLink."Quantity (Base)");

    end;

    /// <summary>
    /// Заполняет таблицу источников на строки документа по строке документа
    /// </summary>
    /// <param name="SourceDocumentLink"></param>
    internal procedure CreateFrom_InvtDocumentLine(var SourceDocumentLink: Record "TMAC Source Document Link"; var InvtDocumentLine: Record "Invt. Document Line"; OppositeSourceType: Integer; OppositeSourceSubType: Integer)
    var
        ReservationEntry: Record "Reservation Entry";
        Item: Record Item;
    begin
        Item.Get(InvtDocumentLine."Item No.");
        if Item."Item Tracking Code" <> '' then begin
            ReservationEntry.Reset();
            ReservationEntry.SetCurrentKey("Source ID", "Source Ref. No.", "Source Type", "Source Subtype", "Source Batch Name", "Source Prod. Order Line", "Reservation Status", "Shipment Date", "Expected Receipt Date");
            ReservationEntry.SetFilter("Reservation Status", '%1|%2|%3', "Reservation Status"::Reservation, "Reservation Status"::Surplus, "Reservation Status"::Prospect);
            ReservationEntry.Setrange("Source Type", Database::"Invt. Document Line");
            ReservationEntry.Setrange("Source Subtype", InvtDocumentLine."Document Type".AsInteger());
            ReservationEntry.Setrange("Source ID", InvtDocumentLine."Document No.");
            ReservationEntry.Setrange("Source Ref. No.", InvtDocumentLine."Line No.");
            ReservationEntry.CalcSums("Quantity (Base)");
            if InvtDocumentLine."Quantity (Base)" <> Abs(ReservationEntry."Quantity (Base)") then
                error(TrackingQuantityErr, InvtDocumentLine."Quantity (Base)", ReservationEntry."Quantity (Base)", InvtDocumentLine."Item No.");
            if ReservationEntry.FindSet() then
                repeat
                    SourceDocumentLink.Init();
                    SourceDocumentLink.Clear();
                    CompleteSourceDocumentLinkFromReservationEntry(SourceDocumentLink, ReservationEntry);
                    SourceDocumentLink.Description := InvtDocumentLine.Description;
                    SourceDocumentLink."Unit of Measure Code" := InvtDocumentLine."Unit of Measure Code";
                    SourceDocumentLink."Weight (Base) per UoM" := GetWeight(InvtDocumentLine."Gross Weight", InvtDocumentLine."Item No.", InvtDocumentLine."Unit of Measure Code");
                    SourceDocumentLink."Volume (Base) per UoM" := GetVolume(InvtDocumentLine."Unit Volume", InvtDocumentLine."Item No.", InvtDocumentLine."Unit of Measure Code");
                    SourceDocumentLink."Location Code" := InvtDocumentLine."Location Code";
                    SourceDocumentLink."Bin Code" := InvtDocumentLine."Bin Code";
                    SourceDocumentLink."Control Quantity" := InvtDocumentLine.Quantity;

                    SourceDocumentLink."Document Source Type" := Database::"Invt. Document Line";
                    SourceDocumentLink."Document Source SubType" := InvtDocumentLine."Document Type".AsInteger();
                    SourceDocumentLink."Document Source ID" := InvtDocumentLine."Document No.";
                    SourceDocumentLink."Document Source Information" := GetSourceInformation(SourceDocumentLink."Document Source Type", SourceDocumentLink."Document Source SubType", SourceDocumentLink."Document Source ID");

                    SourceDocumentLink."Control Quantity" := InvtDocumentLine.Quantity;
                    SourceDocumentLink."Default Selected Quantity" := abs(SourceDocumentLink.Quantity);

                    SourceDocumentLink."Opposite Source Type" := OppositeSourceType;
                    SourceDocumentLink."Opposite Source Subtype" := OppositeSourceSubType;

                    case InvtDocumentLine."Document Type" of
                        "Invt. Doc. Document Type"::Receipt:
                            SourceDocumentLink.Positive := true;
                        "Invt. Doc. Document Type"::Shipment:
                            SourceDocumentLink.Positive := false;
                    end;

                    //в таблице резервирования записей может быть несколько на одну партию или лот но разные кол-ва, поэтому запись может уже ьыть 
                    InsertOrAddQuantity(SourceDocumentLink, SourceDocumentLink.Quantity, SourceDocumentLink."Quantity (Base)");

                until ReservationEntry.next() = 0;
        end else begin
            SourceDocumentLink.Init();
            SourceDocumentLink.Clear();
            SourceDocumentLink."Source Type" := Database::"Invt. Document Line";
            SourceDocumentLink."Source Subtype" := InvtDocumentLine."Document Type".AsInteger();
            SourceDocumentLink."Source ID" := InvtDocumentLine."Document No.";
            SourceDocumentLink."Source Ref. No." := InvtDocumentLine."Line No.";
            SourceDocumentLink."Package No." := '';
            SourceDocumentLink."Lot No." := '';
            SourceDocumentLink."Serial No." := '';
            SourceDocumentLink."Item No." := InvtDocumentLine."Item No.";
            SourceDocumentLink."Variant Code" := InvtDocumentLine."Variant Code";
            SourceDocumentLink.Description := InvtDocumentLine.Description;
            SourceDocumentLink.Quantity := InvtDocumentLine.Quantity;
            SourceDocumentLink."Unit of Measure Code" := InvtDocumentLine."Unit of Measure Code";
            SourceDocumentLink."Quantity (Base)" := InvtDocumentLine."Quantity (Base)";
            SourceDocumentLink."Weight (Base) per UoM" := GetWeight(InvtDocumentLine."Gross Weight", InvtDocumentLine."Item No.", InvtDocumentLine."Unit of Measure Code");
            SourceDocumentLink."Volume (Base) per UoM" := GetVolume(InvtDocumentLine."Unit Volume", InvtDocumentLine."Item No.", InvtDocumentLine."Unit of Measure Code");
            SourceDocumentLink."Qty. per UoM" := InvtDocumentLine."Qty. per Unit of Measure";
            SourceDocumentLink."Location Code" := InvtDocumentLine."Location Code";
            SourceDocumentLink."Bin Code" := InvtDocumentLine."Bin Code";

            SourceDocumentLink."Document Source Type" := Database::"Invt. Document Line";
            SourceDocumentLink."Document Source SubType" := InvtDocumentLine."Document Type".AsInteger();
            SourceDocumentLink."Document Source ID" := InvtDocumentLine."Document No.";
            SourceDocumentLink."Document Source Information" := GetSourceInformation(SourceDocumentLink."Document Source Type", SourceDocumentLink."Document Source SubType", SourceDocumentLink."Document Source ID");

            SourceDocumentLink."Control Quantity" := SourceDocumentLink.Quantity;
            SourceDocumentLink."Default Selected Quantity" := abs(SourceDocumentLink.Quantity);

            SourceDocumentLink."Opposite Source Type" := OppositeSourceType;
            SourceDocumentLink."Opposite Source Subtype" := OppositeSourceSubType;

            case InvtDocumentLine."Document Type" of
                "Invt. Doc. Document Type"::Receipt:
                    SourceDocumentLink.Positive := true;
                "Invt. Doc. Document Type"::Shipment:
                    SourceDocumentLink.Positive := false;
            end;

            SourceDocumentLink.Insert(true);
        end;
    end;

    internal procedure CreateFrom_UnitLine(var SourceDocumentLink: Record "TMAC Source Document Link"; UnitLine: Record "TMAC Unit Line")
    begin
        UnitLine.CalcFields("Expected Quantity", "Expected Quantity (Base)");
        SourceDocumentLink.Init();
        SourceDocumentLink.Clear();
        SourceDocumentLink."Source Type" := Database::"TMAC Unit Line";
        SourceDocumentLink."Source Subtype" := 0;
        SourceDocumentLink."Source ID" := UnitLine."Unit No.";
        SourceDocumentLink."Source Ref. No." := UnitLine."Line No.";
        SourceDocumentLink."Package No." := '';
        SourceDocumentLink."Lot No." := '';
        SourceDocumentLink."Serial No." := '';

        SourceDocumentLink."Item No." := UnitLine."No.";
        SourceDocumentLink."Variant Code" := UnitLine."Variant Code";
        SourceDocumentLink.Description := UnitLine.Description;
        SourceDocumentLink.Quantity := UnitLine."Expected Quantity";
        SourceDocumentLink."Unit of Measure Code" := UnitLine."Unit of Measure Code";
        SourceDocumentLink."Quantity (Base)" := UnitLine."Expected Quantity (Base)";
        SourceDocumentLink."Weight (Base) per UoM" := UnitLine."Gross Weight (base)";
        SourceDocumentLink."Volume (Base) per UoM" := UnitLine."Volume (base)";
        SourceDocumentLink."Qty. per UoM" := UnitLine."Qty. per Unit of Measure";
        SourceDocumentLink."Location Code" := UnitLine."Location Code";
        SourceDocumentLink."Bin Code" := UnitLine."Bin Code";

        SourceDocumentLink."Document Source Type" := Database::"TMAC Unit Line";
        SourceDocumentLink."Document Source SubType" := 0;
        SourceDocumentLink."Document Source ID" := UnitLine."Unit No.";
        SourceDocumentLink."Document Source Information" := 'Logistic Unit';

        SourceDocumentLink."Control Quantity" := UnitLine.Quantity;
        SourceDocumentLink."Default Selected Quantity" := abs(SourceDocumentLink.Quantity);

        SourceDocumentLink."Opposite Source Type" := 0;
        SourceDocumentLink."Opposite Source Subtype" := 0;

        SourceDocumentLink.Positive := SourceDocumentLink.Quantity > 0;

        InsertOrAddQuantity(SourceDocumentLink, SourceDocumentLink.Quantity, SourceDocumentLink."Quantity (Base)");
    end;
    #endregion

    internal procedure CompleteSourceDocumentLinkFromReservationEntry(var SourceDocumentLink: Record "TMAC Source Document Link"; var ReservationEntry: Record "Reservation Entry")
    var
        ReservationEntry2: Record "Reservation Entry";
    begin
        SourceDocumentLink."Source Type" := ReservationEntry."Source Type";
        SourceDocumentLink."Source Subtype" := ReservationEntry."Source Subtype";
        SourceDocumentLink."Source ID" := ReservationEntry."Source ID";
        SourceDocumentLink."Source Ref. No." := ReservationEntry."Source Ref. No.";
        SourceDocumentLink."Item No." := ReservationEntry."Item No.";
        SourceDocumentLink."Variant Code" := ReservationEntry."Variant Code";
        SourceDocumentLink.Description := ReservationEntry.Description;
        SourceDocumentLink.Quantity := abs(ReservationEntry.Quantity);
        SourceDocumentLink."Unit of Measure Code" := '';
        SourceDocumentLink."Quantity (Base)" := abs(ReservationEntry."Quantity (Base)");
        SourceDocumentLink."Qty. per UoM" := ReservationEntry."Qty. per Unit of Measure";
        SourceDocumentLink."Location Code" := ReservationEntry."Location Code";
        Case ReservationEntry."Reservation Status" of
            "Reservation Status"::Surplus:
                begin
                    SourceDocumentLink."Package No." := ReservationEntry."Package No.";
                    SourceDocumentLink."Lot No." := ReservationEntry."Lot No.";
                    SourceDocumentLink."Serial No." := ReservationEntry."Serial No.";
                end;
            "Reservation Status"::Reservation:
                begin
                    ReservationEntry2.SetRange("Entry No.", ReservationEntry."Entry No.");
                    ReservationEntry2.Setrange(Positive, not ReservationEntry.Positive);
                    ReservationEntry2.FindFirst();
                    SourceDocumentLink."Package No." := ReservationEntry2."Package No.";
                    SourceDocumentLink."Lot No." := ReservationEntry2."Lot No.";
                    SourceDocumentLink."Serial No." := ReservationEntry2."Serial No.";
                end;
            "Reservation Status"::Prospect:
                begin
                    SourceDocumentLink."Package No." := ReservationEntry."Package No.";
                    SourceDocumentLink."Lot No." := ReservationEntry."Lot No.";
                    SourceDocumentLink."Serial No." := ReservationEntry."Serial No.";
                end;
        end;
    end;

    /// <summary>
    /// Inserts a new record or increments the quantity if a matching record already exists.
    /// </summary>
    /// <remarks>
    /// Used to handle multiple item-tracking splits (lot/serial) that share the same basic keys.
    /// If found, the quantity is updated, otherwise a new link is inserted.
    /// </remarks>
    /// <param name="SourceDocumentLink">Temporarily holds the link data. Merged or inserted into the DB.</param>
    /// <param name="Qty">The item quantity in sales/purchase units.</param>
    /// <param name="Qtybase">The item quantity in base units.</param>
    local procedure InsertOrAddQuantity(var SourceDocumentLink: Record "TMAC Source Document Link"; Qty: Decimal; Qtybase: Decimal)
    begin
        if not SourceDocumentLink.Insert(true) then begin
            SourceDocumentLink.Get(
                SourceDocumentLink."Source Type",
                SourceDocumentLink."Source Subtype",
                SourceDocumentLink."Source ID",
                SourceDocumentLink."Source Batch Name",
                SourceDocumentLink."Source Prod. Order Line",
                SourceDocumentLink."Source Ref. No.",
                SourceDocumentLink."Package No.",
                SourceDocumentLink."Lot No.",
                SourceDocumentLink."Serial No.",
                SourceDocumentLink.Positive);

            SourceDocumentLink.Quantity += abs(Qty);
            SourceDocumentLink."Quantity (Base)" += abs(Qtybase);
            SourceDocumentLink.Modify(false);
        end;
    end;

    /// <summary>
    /// Calculates the volume of the line, falling back to the item or item UoM if not provided by the line.
    /// </summary>
    /// <remarks>
    /// Merges document line volume with item defaults.
    /// </remarks>
    /// <param name="DocumentLineVolume">Volume from the document line if any.</param>
    /// <param name="ItemNo">Which item is being measured.</param>
    /// <param name="UnitOfMeasureCode">Which UoM is used.</param>
    /// <returns>The volume in base measure if found, or zero otherwise.</returns>
    procedure GetVolume(DocumentLineVolume: Decimal; ItemNo: Code[20]; UnitOfMeasureCode: Code[10]): Decimal
    var
        Item: Record Item;
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        if (DocumentLineVolume <> 0) then
            exit(DocumentLineVolume)
        else
            if Item.Get(ItemNo) then
                if Item."Unit Volume" <> 0 then
                    exit(Item."Unit Volume")
                else
                    if ItemUnitOfMeasure.Get(ItemNo, UnitOfMeasureCode) then
                        exit(ItemUnitOfMeasure.Cubage);
        exit(0);
    end;

    /// <summary>
    /// Calculates the weight of the line, falling back to the item or item UoM if not provided.
    /// </summary>
    /// <remarks>
    /// Merges document line weight with item defaults.
    /// </remarks>
    /// <param name="DocumentLineWeight">Weight from the document line if any.</param>
    /// <param name="ItemNo">Which item is being measured.</param>
    /// <param name="UnitOfMeasureCode">Which UoM is used.</param>
    /// <returns>The weight in base measure if found, or zero otherwise.</returns>
    procedure GetWeight(DocumentLineWeight: Decimal; ItemNo: Code[20]; UnitOfMeasureCode: Code[10]): Decimal
    var
        Item: Record Item;
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        if (DocumentLineWeight <> 0) then
            exit(DocumentLineWeight)
        else
            if Item.Get(ItemNo) then
                if Item."Gross Weight" <> 0 then
                    exit(Item."Gross Weight")
                else
                    if ItemUnitOfMeasure.Get(ItemNo, UnitOfMeasureCode) then
                        exit(ItemUnitOfMeasure.Weight);
        exit(0);
    end;

    /// <summary>
    /// Looks up a logistic unit to link to from the source document link.
    /// </summary>
    /// <remarks>
    /// This procedure can be called in a context where the user selects or the system finds an available unit.
    /// Uses filters on SourceDocumentLink to propose or choose one.
    /// </remarks>
    /// <param name="SourceDocumentLink">Specifies item or document constraints for the lookup.</param>
    /// <returns>The logistic unit number selected for linking.</returns>
    internal procedure LookupForSelectLogisticUnitForLink(var SourceDocumentLink: Record "TMAC Source Document Link"): Code[20]
    var
        //TempUnitLine: Record "TMAC Unit Line" temporary;
        UnitLine: Record "TMAC Unit Line";
        UnitLine2: Record "TMAC Unit Line";
        //UnitLineLink: Record "TMAC Unit Line Link";
        UnitLinesSelect: Page "TMAC Unit Lines Select";
        LinkedQuantity: Decimal;
    //AvlbQty: Decimal;
    begin
        clear(UnitLinesSelect);

        SourceDocumentLink.TestField("Opposite Source Type");
        //проверка что строка уже связана с LU на все количество
        LinkedQuantity := GetLinkedQuantity(SourceDocumentLink);
        if LinkedQuantity = SourceDocumentLink.Quantity then
            Error(UnitLineLinkExistErr);

        //исходно отбираем строки у которые не все кол-во перешло на учтенные документы
        UnitLine.Reset();
        UnitLine.SetCurrentKey("Type", "No.");
        UnitLine.SetRange(Type, "TMAC Unit Line Type"::Item);
        UnitLine.SetRange("No.", SourceDocumentLink."Item No.");
        UnitLine.SetRange("Variant Code", SourceDocumentLink."Variant Code");
        UnitLine.Setrange("Unit of Measure Code", SourceDocumentLink."Unit of Measure Code");
        UnitLine.Setrange("Location Code", SourceDocumentLink."Location Code");

        UnitLine.SetAutoCalcFields("Linked Quantity");
        UnitLine.SetRange("Linked Type Filter", SourceDocumentLink."Opposite Source Type");
        UnitLine.SetRange("Linked Subtype Filter", SourceDocumentLink."Opposite Source Subtype");
        if UnitLine.findset(false) then
            repeat
                if UnitLine.Quantity > UnitLine."Linked Quantity" then begin
                    //связи на неучт.документы по кол-ву не должны
                    // UnitLine.Quantity - количество по строке LU
                    // UnitLine."Source Quantity" - кол-во по другому источнику (учтенные) напримет Posted Warehouse SHipment Line
                    // UnitLine2."Source Quantity" -  -кол-во по тому же типу источника (например Wreahouse Shipment Line)
                    UnitLine2.Get(UnitLine."Unit No.", UnitLine."Line No.");
                    UnitLine2.SetRange("Linked Type Filter", SourceDocumentLink."Source Type");
                    UnitLine2.SetRange("Linked Subtype Filter", SourceDocumentLink."Source Subtype");
                    UnitLine2.CalcFields("Linked Quantity");
                    if UnitLine.Quantity - UnitLine."Linked Quantity" - UnitLine2."Linked Quantity" > 0 then
                        UnitLinesSelect.AddLine(UnitLine2);
                end;
            until UnitLine.next() = 0;

        UnitLinesSelect.SetSourceTypeFilter(SourceDocumentLink."Source Type");
        UnitLinesSelect.LookupMode(true);
        if UnitLinesSelect.RunModal() = Action::LookupOK then begin
            UnitLinesSelect.GetRecord(UnitLine2);
            exit(UnitLine2."Unit No.");
        end;
        exit('');
    end;

    /// <summary>
    /// Gets the available quantity for the selected logistic unit, considering contents and constraints.
    /// </summary>
    /// <remarks>
    /// This might cross-check how many items can be placed or must be removed, depending on the scenario.
    /// </remarks>
    /// <param name="SourceDocumentLink">Reference to the item or lines being linked.</param>
    /// <returns>The numeric capacity or leftover quantity for that logistic unit.</returns>
    procedure GetQtyAvlbForSelectedUnit(var SourceDocumentLink: Record "TMAC Source Document Link"): Decimal
    var
        UnitLine: Record "TMAC Unit Line";
        UnitLine2: Record "TMAC Unit Line";
        LinkedQuantity: Decimal;
        AvlbQty: Decimal;
        DestAvlbQty: Decimal;
    begin
        LinkedQuantity := SourceDocumentLink."Selected Quantity";

        if SourceDocumentLink."Selected Logistic Unit No." = '' then
            exit(SourceDocumentLink."Selected Quantity");

        LinkedQuantity := GetLinkedQuantity(SourceDocumentLink);
        AvlbQty := SourceDocumentLink.Quantity - LinkedQuantity; //кол-во которое может быть распределено по данной строке источника

        if AvlbQty = 0 then //все распределено
            exit(0);

        if SourceDocumentLink."Opposite Source Type" <> 0 then begin
            UnitLine.Reset();
            UnitLine.Setrange("Unit No.", SourceDocumentLink."Selected Logistic Unit No.");
            UnitLine.SetRange(Type, "TMAC Unit Line Type"::Item);
            UnitLine.SetRange("No.", SourceDocumentLink."Item No.");
            UnitLine.SetRange("Variant Code", SourceDocumentLink."Variant Code");
            UnitLine.Setrange("Unit of Measure Code", SourceDocumentLink."Unit of Measure Code");
            UnitLine.SetRange("Linked Type Filter", SourceDocumentLink."Opposite Source Type");
            UnitLine.SetRange("Linked Subtype Filter", SourceDocumentLink."Opposite Source Subtype");
            UnitLine.SetAutoCalcFields("Linked Quantity");
            UnitLine.SetLoadFields(Quantity, "Linked Quantity");
            if UnitLine.findset(false) then
                repeat
                    //связи на неучт.документы по кол-ву 
                    // UnitLine.Quantity - количество по строке LU
                    // UnitLine."Linked Quantity" - кол-во по другому источнику (учтенные) напримет Posted Warehouse SHipment Line
                    // UnitLine2."Linked Quantity" -кол-во по тому же типу источника (например Wreahouse Shipment Line)
                    UnitLine2.Get(UnitLine."Unit No.", UnitLine."Line No.");
                    UnitLine2.SetRange("Linked Type Filter", SourceDocumentLink."Source Type");
                    UnitLine2.SetRange("Linked Subtype Filter", SourceDocumentLink."Source Subtype");
                    UnitLine2.CalcFields("Linked Quantity");
                    DestAvlbQty += UnitLine.Quantity - UnitLine."Linked Quantity" - UnitLine2."Linked Quantity";
                until UnitLine.next() = 0;
            if AvlbQty > DestAvlbQty then
                exit(DestAvlbQty)
            else
                exit(AvlbQty);
        end else
            exit(AvlbQty);

    end;

    /// <summary>
    /// Creates link records in TMAC Unit Line for a purchase line.
    /// </summary>
    /// <remarks>
    /// One of several overloaded CreateLink procedures, specialized for Purchase lines. Maps relevant purchase data,
    /// such as item number, location code, and quantity, to the logistic unit line.
    /// </remarks>
    /// <param name="UnitLine">The logistic unit line record to link to the item data.</param>
    /// <param name="PurchaseLine">The purchase line record providing item details.</param>
    procedure CreateLink(var UnitLine: Record "TMAC Unit Line"; var PurchaseLine: Record "Purchase Line")
    var
        SourceDocumentLink: Record "TMAC Source Document Link";
    begin
        CreateFrom_PurchLine(SourceDocumentLink, PurchaseLine, Database::"Purch. Rcpt. Line", 0);
        CreateLinks(UnitLine, SourceDocumentLink);
    end;

    /// <summary>
    /// Creates link records in TMAC Unit Line for a sales line.
    /// </summary>
    /// <remarks>
    /// Another specialized CreateLink that extracts item data from the sales line and populates the logistic unit line.
    /// </remarks>
    /// <param name="UnitLine">The logistic unit line to link to.</param>
    /// <param name="SalesLine">The sales line containing item, quantity, etc.</param>
    procedure CreateLink(var UnitLine: Record "TMAC Unit Line"; var SalesLine: Record "Sales Line")
    var
        SourceDocumentLink: Record "TMAC Source Document Link";
    begin
        CreateFrom_SalesLine(SourceDocumentLink, SalesLine, Database::"Sales Shipment Line", 0);
        CreateLinks(UnitLine, SourceDocumentLink);
    end;

    /// <summary>
    /// Creates link records in TMAC Unit Line for a transfer line.
    /// </summary>
    /// <remarks>
    /// This is used when an item is being transferred in or out of the logistic unit. The Positive parameter helps
    /// indicate direction.
    /// </remarks>
    /// <param name="UnitLine">The logistic unit line to link to.</param>
    /// <param name="TransferLine">The line with item details for the transfer.</param>
    /// <param name="Positive">Indicates item movement direction: true for inbound, false for outbound.</param>
    procedure CreateLink(var UnitLine: Record "TMAC Unit Line"; var TransferLine: Record "Transfer Line"; Positive: Boolean)
    var
        SourceDocumentLink: Record "TMAC Source Document Link";
    begin
        CreateFrom_TransferLine(SourceDocumentLink, TransferLine, Database::"Transfer Shipment Line", 0, Positive);
        CreateLinks(UnitLine, SourceDocumentLink);
    end;

    /// <summary>
    /// Creates link records in TMAC Unit Line for an inventory document line.
    /// </summary>
    /// <remarks>
    /// Typically used in physical inventory or adjustments.
    /// </remarks>
    /// <param name="UnitLine">The logistic unit line to link to.</param>
    /// <param name="InvtDocumentLine">The inventory document line referencing items.</param>
    procedure CreateLink(var UnitLine: Record "TMAC Unit Line"; var InvtDocumentLine: Record "Invt. Document Line")
    var
        SourceDocumentLink: Record "TMAC Source Document Link";
    begin
        CreateFrom_InvtDocumentLine(SourceDocumentLink, InvtDocumentLine, Database::"Invt. Shipment Line", 0);
        CreateLinks(UnitLine, SourceDocumentLink);
    end;
    /// <summary>
    /// Creates multiple link records for a single logistic unit line from a multi-lot or multi-serial source.
    /// </summary>
    /// <remarks>
    /// If there are multiple item tracking lines in SourceDocumentLink, each one is turned into a link.
    /// </remarks>
    /// <param name="UnitLine">The logistic unit line to link with these details.</param>
    /// <param name="SourceDocumentLink">The record containing multiple lot or serial splits.
    /// </param>
    procedure CreateLinks(var UnitLine: Record "TMAC Unit Line"; var SourceDocumentLink: Record "TMAC Source Document Link")
    begin
        SourceDocumentLink.Reset();
        if SourceDocumentLink.FindSet() then
            repeat
                CreateLink(UnitLine, SourceDocumentLink, SourceDocumentLink.Quantity, false);
            until SourceDocumentLink.next() = 0;
    end;

    /// <summary>
    /// Creates link records with a specified quantity, supporting partial postings.
    /// </summary>
    /// <remarks>
    /// Similar to other CreateLink overloads but used when only a portion of the total quantity is being posted.
    /// </remarks>
    /// <param name="UnitLine">The logistic unit line for linking.</param>
    /// <param name="SourceDocumentLink">Source doc lines being linked.</param>
    /// <param name="Qty">Exact quantity to link in that operation.</param>
    /// <param name="Posted">Indicates whether the link is already posted or in progress.
    /// </param>
    procedure CreateLink(var UnitLine: Record "TMAC Unit Line"; var SourceDocumentLink: Record "TMAC Source Document Link"; Qty: Decimal; Posted: Boolean)
    var
        CheckUnitLineLink: Record "TMAC Unit Line Link";
        UnitLineLink: Record "TMAC Unit Line Link";
    //UnitLineLink2: Record "TMAC Unit Line Link";
    begin
        //общие проверки контролирующие целостность системы если гдето в другом месте ошибки
        //нельзя чтобы строка паллеты была распределена на большее кол-во чем поле кол-во строки паллеты в разрезе какогото типа документов
        //нельзя чтобы в паллете было 5 а линков на покупки больше чем на 5
        CheckUnitLineLink.SetRange("Unit No.", UnitLine."Unit No.");
        CheckUnitLineLink.SetRange("Unit Line No.", UnitLine."Line No.");
        CheckUnitLineLink.SetRange("Source Type", SourceDocumentLink."Source Type");
        CheckUnitLineLink.SetRange("Source SubType", SourceDocumentLink."Source SubType");
        CheckUnitLineLink.SetRange(Positive, SourceDocumentLink.Positive);
        CheckUnitLineLink.CalcSums(Quantity);
        if abs(CheckUnitLineLink.Quantity) + Qty > UnitLine.Quantity then
            Error(SystemErrorUnitLineErr, abs(CheckUnitLineLink.Quantity) + Qty);

        //нельзя чтобы распределенное кол-во по той строке к торой мы применяемся было превышено
        //например заказ покупки уже имеет линков на все кол-во
        CheckUnitLineLink.Reset();
        CheckUnitLineLink.SetRange("Source Type", SourceDocumentLink."Source Type");
        CheckUnitLineLink.SetRange("Source SubType", SourceDocumentLink."Source SubType");
        CheckUnitLineLink.SetRange("Source ID", SourceDocumentLink."Source ID");
        CheckUnitLineLink.SetRange("Source Ref. No.", SourceDocumentLink."Source Ref. No.");
        CheckUnitLineLink.SetRange("Positive", SourceDocumentLink.Positive);
        CheckUnitLineLink.CalcSums(Quantity);
        if abs(CheckUnitLineLink.Quantity) + Qty > SourceDocumentLink."Control Quantity" then
            Error(SystemErrorDocumentLineErr, abs(CheckUnitLineLink.Quantity) + Qty);

        UnitLineLink.Init();
        UnitLineLink."Unit No." := UnitLine."Unit No.";
        UnitLineLink."Unit Line No." := UnitLine."Line No.";
        UnitLineLink."Source Type" := SourceDocumentLink."Source Type";
        UnitLineLink."Source Subtype" := SourceDocumentLink."Source Subtype";
        UnitLineLink."Source ID" := SourceDocumentLink."Source ID";
        UnitLineLink."Source Batch Name" := SourceDocumentLink."Source Batch Name";
        UnitLineLink."Source Prod. Order Line" := SourceDocumentLink."Source Prod. Order Line";
        UnitLineLink."Source Ref. No." := SourceDocumentLink."Source Ref. No.";
        UnitLineLink."Package No." := SourceDocumentLink."Package No.";
        UnitLineLink."Lot No." := SourceDocumentLink."Lot No.";
        UnitLineLink."Serial No." := SourceDocumentLink."Serial No.";
        UnitLineLink."Item No." := SourceDocumentLink."Item No.";
        UnitLineLink."Variant Code" := SourceDocumentLink."Variant Code";
        UnitLineLink.Description := SourceDocumentLink.Description;
        if SourceDocumentLink.Positive then begin
            UnitLineLink.Quantity := Abs(Qty);
            UnitLineLink."Quantity (Base)" := Abs(Qty) * SourceDocumentLink."Qty. per UoM";
        end else begin
            UnitLineLink.Quantity := -Abs(Qty);
            UnitLineLink."Quantity (Base)" := -Abs(Qty) * SourceDocumentLink."Qty. per UoM";
        end;
        UnitLineLink."Positive" := SourceDocumentLink.Positive;
        UnitLineLink."Unit of Measure Code" := SourceDocumentLink."Unit of Measure Code";
        UnitLineLink."Qty. per UoM" := SourceDocumentLink."Qty. per UoM";
        UnitLineLink."Weight (Base)" := Qty * SourceDocumentLink."Weight (Base) per UoM";
        UnitLineLInk."Volume (Base)" := Qty * SourceDocumentLink."Volume (Base) per UoM";
        UnitLineLink."Unit Type" := UnitLine."Unit Type Code";
        UnitLineLink.Calculation := true;
        UnitLineLink.Posted := Posted;
        UnitLineLink.Insert(true);

        // if SourceDocumentLink."Source Type" = Database::"Transfer Line" then begin //создаем второй линк
        //     UnitLineLink2.Init();
        //     UnitLineLink2.TransferFields(UnitLineLink);
        //     UnitLineLink2.Positive := not UnitLineLink.Positive;
        //     UnitLineLink2.Quantity := -UnitLineLink.Quantity;
        //     UnitLineLink2."Quantity (Base)" := -UnitLineLink."Quantity (Base)";
        //     UnitLineLink2.Insert(true);
        //     AddAdditionalLinkForTransfer(UnitLineLink, SourceDocumentLink);
        //     AddAdditionalLinkForTransfer(UnitLineLink2, SourceDocumentLink);
        //     UnitLineLink.Modify(true);
        //     UnitLineLink2.Modify(true);
        // end else begin
        // доп. ссылка на исходный документ, если создали из производного документа
        AddAdditionalLink(UnitLineLink, SourceDocumentLink);
        UnitLineLink.Modify(true);
        //end;
    end;

    /// <summary>
    /// Retrieves how many items are already linked in the TMAC Unit Line Link table for the given source doc.
    /// </summary>
    /// <remarks>
    /// Sums up the relevant line links to determine existing linked quantity.
    /// </remarks>
    /// <param name="SourceDocumentLink">The record identifying the doc lines or item track to measure.</param>
    /// <returns>The total quantity already linked.</returns>
    procedure GetLinkedQuantity(var SourceDocumentLink: Record "TMAC Source Document Link") LinkedQuantity: Decimal
    var
        UnitLineLink: Record "TMAC Unit Line Link";
    begin
        UnitLineLink.SetRange("Source Type", SourceDocumentLink."Source Type");
        UnitLineLink.SetRange("Source Subtype", SourceDocumentLink."Source Subtype");
        UnitLineLink.SetRange("Source ID", SourceDocumentLink."Source ID");
        UnitLineLink.SetRange("Source Ref. No.", SourceDocumentLink."Source Ref. No.");
        UnitLineLink.Setrange("Source Batch Name", SourceDocumentLink."Source Batch Name");
        UnitLineLink.SetRange("Source Prod. Order Line", SourceDocumentLink."Source Prod. Order Line");
        UnitLineLink.setrange("Package No.", SourceDocumentLink."Package No.");
        UnitLineLink.SetRange("Lot No.", SourceDocumentLink."Lot No.");
        UnitLineLink.SetRange("Serial No.", SourceDocumentLink."Serial No.");
        UnitLineLink.CalcSums(Quantity);
        LinkedQuantity := Abs(UnitLineLink.Quantity); //т.е. в SourceDocumentLink.Quantity всегда +, и тут под фильтром не могут быть разные документы и разные знаки
    end;

    procedure Deletelinks(var SourceDocumentLink: Record "TMAC Source Document Link");
    var
        UnitLineLink: Record "TMAC Unit Line Link";
    begin
        UnitLineLink.SetRange("Source Type", SourceDocumentLink."Source Type");
        UnitLineLink.SetRange("Source Subtype", SourceDocumentLink."Source Subtype");
        UnitLineLink.SetRange("Source ID", SourceDocumentLink."Source ID");
        UnitLineLink.SetRange("Source Ref. No.", SourceDocumentLink."Source Ref. No.");
        UnitLineLink.Setrange("Source Batch Name", SourceDocumentLink."Source Batch Name");
        UnitLineLink.SetRange("Source Prod. Order Line", SourceDocumentLink."Source Prod. Order Line");
        UnitLineLink.setrange("Package No.", SourceDocumentLink."Package No.");
        UnitLineLink.SetRange("Lot No.", SourceDocumentLink."Lot No.");
        UnitLineLink.SetRange("Serial No.", SourceDocumentLink."Serial No.");
        UnitLineLink.DeleteAll();
    end;

    procedure DeletelinksByUnitLine(var SourceDocumentLink: Record "TMAC Source Document Link"; UnitLine: Record "TMAC Unit Line");
    var
        UnitLineLink: Record "TMAC Unit Line Link";
    begin
        UnitLineLink.SetRange("Unit No.", UnitLine."Unit No.");
        UnitLineLink.SetRange("Unit Line No.", UnitLine."Line No.");
        UnitLineLink.SetRange("Source Type", SourceDocumentLink."Source Type");
        UnitLineLink.SetRange("Source Subtype", SourceDocumentLink."Source Subtype");
        UnitLineLink.SetRange("Source ID", SourceDocumentLink."Source ID");
        UnitLineLink.SetRange("Source Ref. No.", SourceDocumentLink."Source Ref. No.");
        UnitLineLink.Setrange("Source Batch Name", SourceDocumentLink."Source Batch Name");
        UnitLineLink.SetRange("Source Prod. Order Line", SourceDocumentLink."Source Prod. Order Line");
        UnitLineLink.setrange("Package No.", SourceDocumentLink."Package No.");
        UnitLineLink.SetRange("Lot No.", SourceDocumentLink."Lot No.");
        UnitLineLink.SetRange("Serial No.", SourceDocumentLink."Serial No.");
        UnitLineLink.DeleteAll();
    end;

    /// <summary>
    /// Adds additional link data to an existing Unit Line Link using the source document.
    /// </summary>
    /// <remarks>
    /// This is used if a second or third partial link is needed for the same line or item.
    /// </remarks>
    /// <param name="UnitLineLink">The existing link record to update.</param>
    /// <param name="SourceDocumentLink">The doc link containing new or appended data (quantity, lot, etc.).
    /// </param>
    internal procedure AddAdditionalLink(var UnitLineLink: Record "TMAC Unit Line Link"; var SourceDocumentLink: Record "TMAC Source Document Link")
    var
        AdditionalUnitLineLink: Record "TMAC Unit Line Link";
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        WarehouseActivityLine: Record "Warehouse Activity Line";
        SalesShipmentLine: Record "Sales Shipment Line";
        PostedWhseShipmentLine: Record "Posted Whse. Shipment Line";
        PostedWhseReceiptLine: Record "Posted Whse. Receipt Line";
        PurchaseLine: Record "Purchase Line";
        SalesLine: Record "Sales Line";
        ReturnShipmentLine: Record "Return Shipment Line"; //возврат покупки
        ReturnReceiptLine: Record "Return Receipt Line"; //возврат продажи
        PurchRcptLine: Record "Purch. Rcpt. Line";
        TransferLine: Record "Transfer Line";
        InvtDocumentLine: Record "Invt. Document Line";
    begin
        case SourceDocumentLink."Source Type" of
            Database::"Warehouse Shipment Line":
                begin
                    WarehouseShipmentLine.Get(SourceDocumentLink."Source ID", SourceDocumentLink."Source Ref. No.");
                    AdditionalUnitLineLink.Init();
                    AdditionalUnitLineLink.TransferFields(UnitLineLink);
                    AdditionalUnitLineLink."Source Type" := WarehouseShipmentLine."Source Type";
                    AdditionalUnitLineLink."Source Subtype" := WarehouseShipmentLine."Source Subtype";
                    AdditionalUnitLineLink."Source ID" := WarehouseShipmentLine."Source No.";
                    AdditionalUnitLineLink."Source Batch Name" := '';
                    AdditionalUnitLineLink."Source Prod. Order Line" := 0;
                    AdditionalUnitLineLink."Source Ref. No." := WarehouseShipmentLine."Source Line No.";
                    AdditionalUnitLineLink.Calculation := true;
                    UnitLineLink.Calculation := false;
                    InsertUnitLineLink(AdditionalUnitLineLink);
                end;
            Database::"Posted Whse. Shipment Line":
                begin
                    PostedWhseShipmentLine.Get(SourceDocumentLink."Source ID", SourceDocumentLink."Source Ref. No.");
                    case PostedWhseShipmentLine."Posted Source Document" of
                        "Warehouse Shipment Posted Source Document"::"Posted Shipment":
                            begin
                                SalesShipmentLine.Reset();
                                SalesShipmentLine.SetCurrentKey("Order No.", "Order Line No.", "Posting Date");
                                SalesShipmentLine.SetRange("Order No.", PostedWhseShipmentLine."Source No.");
                                SalesShipmentLine.SetRange("Order Line No.", PostedWhseShipmentLine."Source Line No.");
                                SalesShipmentLine.Setrange("Document No.", PostedWhseShipmentLine."Posted Source No.");
                                SalesShipmentLine.SetRange("Quantity", PostedWhseShipmentLine.Quantity); //ищем на тоже кол-во ?
                                if SalesShipmentLine.findset(false) then
                                    repeat
                                        AdditionalUnitLineLink.Init();
                                        AdditionalUnitLineLink.TransferFields(UnitLineLink);
                                        AdditionalUnitLineLink."Source Type" := Database::"Sales Shipment Line";
                                        AdditionalUnitLineLink."Source Subtype" := 0;
                                        AdditionalUnitLineLink."Source ID" := SalesShipmentLine."Document No.";
                                        AdditionalUnitLineLink."Source Batch Name" := '';
                                        AdditionalUnitLineLink."Source Prod. Order Line" := 0;
                                        AdditionalUnitLineLink."Source Ref. No." := SalesShipmentLine."Line No.";
                                        AdditionalUnitLineLink.Calculation := true;
                                        UnitLineLink.Calculation := false;
                                        InsertUnitLineLink(AdditionalUnitLineLink);
                                    until SalesShipmentLine.next() = 0;
                            end;
                        "Warehouse Shipment Posted Source Document"::"Posted Return Shipment": //возврат покупки
                            begin
                                ReturnShipmentLine.Reset();
                                ReturnShipmentLine.SetRange("Return Order No.", PostedWhseShipmentLine."Source No.");
                                ReturnShipmentLine.SetRange("Return Order Line No.", PostedWhseShipmentLine."Source Line No.");
                                ReturnShipmentLine.Setrange("Document No.", PostedWhseShipmentLine."Posted Source No.");
                                ReturnShipmentLine.SetRange("Quantity", PostedWhseShipmentLine.Quantity); //ищем на тоже кол-во ?
                                if ReturnShipmentLine.findset(false) then
                                    repeat
                                        AdditionalUnitLineLink.Init();
                                        AdditionalUnitLineLink.TransferFields(UnitLineLink);
                                        AdditionalUnitLineLink."Source Type" := Database::"Return Shipment Line";
                                        AdditionalUnitLineLink."Source Subtype" := 0;
                                        AdditionalUnitLineLink."Source ID" := ReturnShipmentLine."Document No.";
                                        AdditionalUnitLineLink."Source Batch Name" := '';
                                        AdditionalUnitLineLink."Source Prod. Order Line" := 0;
                                        AdditionalUnitLineLink."Source Ref. No." := ReturnShipmentLine."Line No.";
                                        AdditionalUnitLineLink.Calculation := true;
                                        UnitLineLink.Calculation := false;
                                        InsertUnitLineLink(AdditionalUnitLineLink);
                                    until ReturnShipmentLine.next() = 0;
                            end;
                    end;
                end;
            Database::"Sales Line":
                begin
                    SalesLine.Get(SourceDocumentLink."Source Subtype", SourceDocumentLink."Source ID", SourceDocumentLink."Source Ref. No.");
                    case SalesLine."Document Type" of
                        "Sales Document Type"::Order:
                            begin
                                WarehouseShipmentLine.Reset();
                                WarehouseShipmentLine.Setrange("Source Type", SourceDocumentLink."Source Type");
                                WarehouseShipmentLine.Setrange("Source Subtype", SourceDocumentLink."Source Subtype");
                                WarehouseShipmentLine.Setrange("Source No.", SourceDocumentLink."Source ID");
                                WarehouseShipmentLine.Setrange("Source Line No.", SourceDocumentLink."Source Ref. No.");
                                if WarehouseShipmentLine.findset(false) then
                                    repeat
                                        AdditionalUnitLineLink.Init();
                                        AdditionalUnitLineLink.TransferFields(UnitLineLink);
                                        AdditionalUnitLineLink."Source Type" := Database::"Warehouse Shipment Line";
                                        AdditionalUnitLineLink."Source Subtype" := 0;
                                        AdditionalUnitLineLink."Source ID" := WarehouseShipmentLine."No.";
                                        AdditionalUnitLineLink."Source Batch Name" := '';
                                        AdditionalUnitLineLink."Source Prod. Order Line" := 0;
                                        AdditionalUnitLineLink."Source Ref. No." := WarehouseShipmentLine."Source Line No.";
                                        AdditionalUnitLineLink.Calculation := false;
                                        InsertUnitLineLink(AdditionalUnitLineLink);
                                    until WarehouseShipmentLine.Next() = 0;

                                //Inventory pick
                                WarehouseActivityLine.Reset();
                                WarehouseActivityLine.Setrange("Source Type", SourceDocumentLink."Source Type");
                                WarehouseActivityLine.Setrange("Source Subtype", SourceDocumentLink."Source Subtype");
                                WarehouseActivityLine.Setrange("Source No.", SourceDocumentLink."Source ID");
                                WarehouseActivityLine.Setrange("Source Line No.", SourceDocumentLink."Source Ref. No.");
                                WarehouseActivityLine.Setrange("Lot No.", SourceDocumentLink."Lot No.");
                                WarehouseActivityLine.Setrange("Serial No.", SourceDocumentLink."Serial No.");
                                WarehouseActivityLine.Setrange("Package No.", SourceDocumentLink."Package No.");
                                if WarehouseActivityLine.findset(false) then
                                    repeat
                                        AdditionalUnitLineLink.Init();
                                        AdditionalUnitLineLink.TransferFields(UnitLineLink);
                                        AdditionalUnitLineLink."Source Type" := Database::"Warehouse Activity Line";
                                        AdditionalUnitLineLink."Source Subtype" := WarehouseActivityLine."Activity Type".AsInteger();
                                        AdditionalUnitLineLink."Source ID" := WarehouseActivityLine."No.";
                                        AdditionalUnitLineLink."Source Batch Name" := '';
                                        AdditionalUnitLineLink."Source Prod. Order Line" := 0;
                                        AdditionalUnitLineLink."Source Ref. No." := WarehouseActivityLine."Source Line No.";
                                        AdditionalUnitLineLink.Calculation := false;
                                        UnitLineLink.Calculation := true;
                                        InsertUnitLineLink(AdditionalUnitLineLink);
                                    until WarehouseActivityLine.Next() = 0;
                            end;
                        "Sales Document Type"::"Return Order":
                            begin
                                WarehouseReceiptLine.Reset();
                                WarehouseReceiptLine.Setrange("Source Type", SourceDocumentLink."Source Type");
                                WarehouseReceiptLine.Setrange("Source Subtype", SourceDocumentLink."Source Subtype");
                                WarehouseReceiptLine.Setrange("Source No.", SourceDocumentLink."Source ID");
                                WarehouseReceiptLine.Setrange("Source Line No.", SourceDocumentLink."Source Ref. No.");
                                if WarehouseReceiptLine.findset(false) then
                                    repeat
                                        AdditionalUnitLineLink.Init();
                                        AdditionalUnitLineLink.TransferFields(UnitLineLink);
                                        AdditionalUnitLineLink."Source Type" := Database::"Warehouse Receipt Line";
                                        AdditionalUnitLineLink."Source Subtype" := 0;
                                        AdditionalUnitLineLink."Source ID" := WarehouseReceiptLine."No.";
                                        AdditionalUnitLineLink."Source Batch Name" := '';
                                        AdditionalUnitLineLink."Source Prod. Order Line" := 0;
                                        AdditionalUnitLineLink."Source Ref. No." := WarehouseReceiptLine."Source Line No.";
                                        AdditionalUnitLineLink.Calculation := false;
                                        InsertUnitLineLink(AdditionalUnitLineLink);
                                    until WarehouseReceiptLine.Next() = 0;
                            end;
                    end;
                end;
            Database::"Sales Shipment Line":
                begin
                    SalesShipmentLine.Get(SourceDocumentLink."Source ID", SourceDocumentLink."Source Ref. No.");
                    PostedWhseShipmentLine.Reset();
                    PostedWhseShipmentLine.SetCurrentKey("Source Type", "Source Subtype", "Source No.", "Source Line No.");
                    PostedWhseShipmentLine.Setrange("Source Type", Database::"Sales Line");
                    PostedWhseShipmentLine.Setrange("Source Subtype", "Sales Document Type"::Order.AsInteger());
                    PostedWhseShipmentLine.SetRange("Source No.", SalesShipmentLine."Order No.");
                    PostedWhseShipmentLine.SetRange("Source Line No.", SalesShipmentLine."Order Line No.");
                    PostedWhseShipmentLine.SetRange(Quantity, SalesShipmentLine.Quantity); //ищем на тоже кол-во
                    if PostedWhseShipmentLine.FindSet(false) then
                        repeat
                            AdditionalUnitLineLink.Init();
                            AdditionalUnitLineLink.TransferFields(UnitLineLink);
                            AdditionalUnitLineLink."Source Type" := Database::"Posted Whse. Shipment Line";
                            AdditionalUnitLineLink."Source Subtype" := 0;
                            AdditionalUnitLineLink."Source ID" := PostedWhseShipmentLine."No.";
                            AdditionalUnitLineLink."Source Batch Name" := '';
                            AdditionalUnitLineLink."Source Prod. Order Line" := 0;
                            AdditionalUnitLineLink."Source Ref. No." := PostedWhseShipmentLine."Line No.";
                            AdditionalUnitLineLink.Calculation := false;
                            UnitLineLink.Calculation := true;
                            InsertUnitLineLink(AdditionalUnitLineLink);
                        until PostedWhseShipmentLine.next() = 0;
                end;
            Database::"Purchase Line":
                begin
                    PurchaseLine.Get(SourceDocumentLink."Source Subtype", SourceDocumentLink."Source ID", SourceDocumentLink."Source Ref. No.");
                    case PurchaseLine."Document Type" of
                        "Purchase Document Type"::Order:
                            begin
                                WarehouseReceiptLine.Reset();
                                WarehouseReceiptLine.Setrange("Source Type", SourceDocumentLink."Source Type");
                                WarehouseReceiptLine.Setrange("Source Subtype", SourceDocumentLink."Source Subtype");
                                WarehouseReceiptLine.Setrange("Source No.", SourceDocumentLink."Source ID");
                                WarehouseReceiptLine.Setrange("Source Line No.", SourceDocumentLink."Source Ref. No.");
                                if WarehouseReceiptLine.findset(false) then
                                    repeat
                                        AdditionalUnitLineLink.Init();
                                        AdditionalUnitLineLink.TransferFields(UnitLineLink);
                                        AdditionalUnitLineLink."Source Type" := Database::"Warehouse Receipt Line";
                                        AdditionalUnitLineLink."Source Subtype" := 0;
                                        AdditionalUnitLineLink."Source ID" := WarehouseReceiptLine."No.";
                                        AdditionalUnitLineLink."Source Batch Name" := '';
                                        AdditionalUnitLineLink."Source Prod. Order Line" := 0;
                                        AdditionalUnitLineLink."Source Ref. No." := WarehouseReceiptLine."Source Line No.";
                                        AdditionalUnitLineLink.Calculation := false;
                                        UnitLineLink.Calculation := true;
                                        InsertUnitLineLink(AdditionalUnitLineLink);
                                    until WarehouseReceiptLine.Next() = 0;

                                // Inventory putaway
                                WarehouseActivityLine.Reset();
                                WarehouseActivityLine.Setrange("Source Type", SourceDocumentLink."Source Type");
                                WarehouseActivityLine.Setrange("Source Subtype", SourceDocumentLink."Source Subtype");
                                WarehouseActivityLine.Setrange("Source No.", SourceDocumentLink."Source ID");
                                WarehouseActivityLine.Setrange("Source Line No.", SourceDocumentLink."Source Ref. No.");
                                WarehouseActivityLine.Setrange("Lot No.", SourceDocumentLink."Lot No.");
                                WarehouseActivityLine.Setrange("Serial No.", SourceDocumentLink."Serial No.");
                                WarehouseActivityLine.Setrange("Package No.", SourceDocumentLink."Package No.");
                                if WarehouseActivityLine.findset(false) then
                                    repeat
                                        AdditionalUnitLineLink.Init();
                                        AdditionalUnitLineLink.TransferFields(UnitLineLink);
                                        AdditionalUnitLineLink."Source Type" := Database::"Warehouse Activity Line";
                                        AdditionalUnitLineLink."Source Subtype" := WarehouseActivityLine."Activity Type".AsInteger();
                                        AdditionalUnitLineLink."Source ID" := WarehouseActivityLine."No.";
                                        AdditionalUnitLineLink."Source Batch Name" := '';
                                        AdditionalUnitLineLink."Source Prod. Order Line" := 0;
                                        AdditionalUnitLineLink."Source Ref. No." := WarehouseActivityLine."Source Line No.";
                                        AdditionalUnitLineLink.Calculation := false;
                                        UnitLineLink.Calculation := true;
                                        InsertUnitLineLink(AdditionalUnitLineLink);
                                    until WarehouseActivityLine.Next() = 0;
                            end;
                        "Purchase Document Type"::"Return Order":
                            begin
                                WarehouseShipmentLine.Reset();
                                WarehouseShipmentLine.Setrange("Source Type", SourceDocumentLink."Source Type");
                                WarehouseShipmentLine.Setrange("Source Subtype", SourceDocumentLink."Source Subtype");
                                WarehouseShipmentLine.Setrange("Source No.", SourceDocumentLink."Source ID");
                                WarehouseShipmentLine.Setrange("Source Line No.", SourceDocumentLink."Source Ref. No.");
                                if WarehouseShipmentLine.findset(false) then
                                    repeat
                                        AdditionalUnitLineLink.Init();
                                        AdditionalUnitLineLink.TransferFields(UnitLineLink);
                                        AdditionalUnitLineLink."Source Type" := Database::"Warehouse Shipment Line";
                                        AdditionalUnitLineLink."Source Subtype" := 0;
                                        AdditionalUnitLineLink."Source ID" := WarehouseShipmentLine."No.";
                                        AdditionalUnitLineLink."Source Batch Name" := '';
                                        AdditionalUnitLineLink."Source Prod. Order Line" := 0;
                                        AdditionalUnitLineLink."Source Ref. No." := WarehouseShipmentLine."Source Line No.";
                                        AdditionalUnitLineLink.Calculation := false;
                                        UnitLineLink.Calculation := true;
                                        InsertUnitLineLink(AdditionalUnitLineLink);
                                    until WarehouseShipmentLine.Next() = 0;
                            end;
                    end;
                end;
            Database::"Purch. Rcpt. Line":
                begin
                    PurchRcptLine.Get(SourceDocumentLink."Source ID", SourceDocumentLink."Source Ref. No.");
                    PostedWhseReceiptLine.Reset();
                    PostedWhseReceiptLine.SetCurrentKey("Source Type", "Source Subtype", "Source No.", "Source Line No.");
                    PostedWhseReceiptLine.Setrange("Source Type", Database::"Purchase Line");
                    PostedWhseReceiptLine.Setrange("Source Subtype", "Purchase Document Type"::Order);
                    PostedWhseReceiptLine.SetRange("Source No.", PurchRcptLine."Order No.");
                    PostedWhseReceiptLine.SetRange("Source Line No.", PurchRcptLine."Order Line No.");
                    PostedWhseReceiptLine.SetRange(Quantity, PurchRcptLine.Quantity); //ищем на тоже кол-во
                    if PostedWhseReceiptLine.FindSet(false) then
                        repeat
                            AdditionalUnitLineLink.Init();
                            AdditionalUnitLineLink.TransferFields(UnitLineLink);
                            AdditionalUnitLineLink."Source Type" := Database::"Posted Whse. Receipt Line";
                            AdditionalUnitLineLink."Source Subtype" := 0;
                            AdditionalUnitLineLink."Source ID" := PostedWhseReceiptLine."No.";
                            AdditionalUnitLineLink."Source Batch Name" := '';
                            AdditionalUnitLineLink."Source Prod. Order Line" := 0;
                            AdditionalUnitLineLink."Source Ref. No." := PostedWhseReceiptLine."Line No.";
                            AdditionalUnitLineLink.Calculation := false;
                            UnitLineLink.Calculation := true;
                            InsertUnitLineLink(AdditionalUnitLineLink);
                        until PostedWhseReceiptLine.next() = 0;
                end;
            Database::"Warehouse Receipt Line":
                begin
                    WarehouseReceiptLine.Get(SourceDocumentLink."Source ID", SourceDocumentLink."Source Ref. No.");
                    AdditionalUnitLineLink.Init();
                    AdditionalUnitLineLink.TransferFields(UnitLineLink);
                    AdditionalUnitLineLink."Source Type" := WarehouseReceiptLine."Source Type";
                    AdditionalUnitLineLink."Source Subtype" := WarehouseReceiptLine."Source Subtype";
                    AdditionalUnitLineLink."Source ID" := WarehouseReceiptLine."Source No.";
                    AdditionalUnitLineLink."Source Batch Name" := '';
                    AdditionalUnitLineLink."Source Prod. Order Line" := 0;
                    AdditionalUnitLineLink."Source Ref. No." := WarehouseReceiptLine."Source Line No.";
                    AdditionalUnitLineLink.Calculation := true;
                    UnitLineLink.Calculation := false;
                    InsertUnitLineLink(AdditionalUnitLineLink);
                end;
            Database::"Posted Whse. Receipt Line":
                begin
                    PostedWhseReceiptLine.Get(SourceDocumentLink."Source ID", SourceDocumentLink."Source Ref. No.");
                    case PostedWhseReceiptLine."Posted Source Document" of
                        "Warehouse Shipment Posted Source Document"::"Posted Receipt":
                            begin
                                PurchRcptLine.Reset();
                                PurchRcptLine.SetCurrentKey("Order No.", "Order Line No.", "Posting Date");
                                PurchRcptLine.SetRange("Order No.", PostedWhseReceiptLine."Source No.");
                                PurchRcptLine.SetRange("Order Line No.", PostedWhseReceiptLine."Source Line No.");
                                PurchRcptLine.Setrange("Document No.", PostedWhseReceiptLine."Posted Source No.");
                                PurchRcptLine.SetRange("Quantity", PostedWhseReceiptLine.Quantity); //ищем на тоже кол-во ?
                                if PurchRcptLine.findset(false) then
                                    repeat
                                        AdditionalUnitLineLink.Init();
                                        AdditionalUnitLineLink.TransferFields(UnitLineLink);
                                        AdditionalUnitLineLink."Source Type" := Database::"Purch. Rcpt. Line";
                                        AdditionalUnitLineLink."Source Subtype" := 0;
                                        AdditionalUnitLineLink."Source ID" := PurchRcptLine."Document No.";
                                        AdditionalUnitLineLink."Source Batch Name" := '';
                                        AdditionalUnitLineLink."Source Prod. Order Line" := 0;
                                        AdditionalUnitLineLink."Source Ref. No." := PurchRcptLine."Line No.";
                                        AdditionalUnitLineLink.Calculation := true;
                                        UnitLineLink.Calculation := false;
                                        InsertUnitLineLink(AdditionalUnitLineLink);
                                    until PurchRcptLine.next() = 0;
                            end;
                        "Warehouse Shipment Posted Source Document"::"Posted Return Receipt": //возврат продажи
                            begin
                                ReturnReceiptLine.Reset();
                                ReturnReceiptLine.SetRange("Return Order No.", PostedWhseReceiptLine."Source No.");
                                ReturnReceiptLine.SetRange("Return Order Line No.", PostedWhseReceiptLine."Source Line No.");
                                ReturnReceiptLine.Setrange("Document No.", PostedWhseReceiptLine."Posted Source No.");
                                ReturnReceiptLine.SetRange("Quantity", PostedWhseReceiptLine.Quantity); //ищем на тоже кол-во ?
                                if ReturnReceiptLine.findset(false) then
                                    repeat
                                        AdditionalUnitLineLink.Init();
                                        AdditionalUnitLineLink.TransferFields(UnitLineLink);
                                        AdditionalUnitLineLink."Source Type" := Database::"Return Receipt Line";
                                        AdditionalUnitLineLink."Source Subtype" := 0;
                                        AdditionalUnitLineLink."Source ID" := ReturnReceiptLine."Document No.";
                                        AdditionalUnitLineLink."Source Batch Name" := '';
                                        AdditionalUnitLineLink."Source Prod. Order Line" := 0;
                                        AdditionalUnitLineLink."Source Ref. No." := ReturnReceiptLine."Line No.";
                                        AdditionalUnitLineLink.Calculation := true;
                                        UnitLineLink.Calculation := false;
                                        InsertUnitLineLink(AdditionalUnitLineLink);
                                    until ReturnReceiptLine.next() = 0;
                            end;
                    end;
                end;
            Database::"Return Shipment Line":
                begin
                    ReturnShipmentLine.Get(SourceDocumentLink."Source ID", SourceDocumentLink."Source Ref. No.");
                    PostedWhseShipmentLine.Reset();
                    PostedWhseShipmentLine.SetCurrentKey("Source Type", "Source Subtype", "Source No.", "Source Line No.");
                    PostedWhseShipmentLine.Setrange("Source Type", Database::"Purchase Line");
                    PostedWhseShipmentLine.Setrange("Source Subtype", "Purchase Document Type"::"Return Order");
                    PostedWhseShipmentLine.SetRange("Source No.", ReturnShipmentLine."Return Order No.");
                    PostedWhseShipmentLine.SetRange("Source Line No.", ReturnShipmentLine."Return Order Line No.");
                    if PostedWhseShipmentLine.findset() then
                        repeat
                            AdditionalUnitLineLink.Init();
                            AdditionalUnitLineLink.TransferFields(UnitLineLink);
                            AdditionalUnitLineLink."Source Type" := Database::"Posted Whse. Shipment Line";
                            AdditionalUnitLineLink."Source Subtype" := 0;
                            AdditionalUnitLineLink."Source ID" := PostedWhseShipmentLine."No.";
                            AdditionalUnitLineLink."Source Batch Name" := '';
                            AdditionalUnitLineLink."Source Prod. Order Line" := 0;
                            AdditionalUnitLineLink."Source Ref. No." := PostedWhseShipmentLine."Line No.";
                            AdditionalUnitLineLink.Calculation := false;
                            UnitLineLink.Calculation := true;
                            InsertUnitLineLink(AdditionalUnitLineLink);
                        until PostedWhseShipmentLine.next() = 0;
                end;
            Database::"Return Receipt Line":
                begin
                    ReturnReceiptLine.Get(SourceDocumentLink."Source ID", SourceDocumentLink."Source Ref. No.");
                    PostedWhseReceiptLine.Reset();
                    PostedWhseReceiptLine.SetCurrentKey("Source Type", "Source Subtype", "Source No.", "Source Line No.");
                    PostedWhseReceiptLine.Setrange("Source Type", Database::"Sales Line");
                    PostedWhseReceiptLine.Setrange("Source Subtype", "Sales Document Type"::"Return Order");
                    PostedWhseReceiptLine.SetRange("Source No.", ReturnReceiptLine."Return Order No.");
                    PostedWhseReceiptLine.SetRange("Source Line No.", ReturnReceiptLine."Return Order Line No.");
                    PostedWhseReceiptLine.SetRange(Quantity, ReturnReceiptLine.Quantity); //ищем на тоже кол-во
                    if PostedWhseReceiptLine.findset() then
                        repeat
                            AdditionalUnitLineLink.Init();
                            AdditionalUnitLineLink.TransferFields(UnitLineLink);
                            AdditionalUnitLineLink."Source Type" := Database::"Posted Whse. Receipt Line";
                            AdditionalUnitLineLink."Source Subtype" := 0;
                            AdditionalUnitLineLink."Source ID" := PostedWhseReceiptLine."No.";
                            AdditionalUnitLineLink."Source Batch Name" := '';
                            AdditionalUnitLineLink."Source Prod. Order Line" := 0;
                            AdditionalUnitLineLink."Source Ref. No." := PostedWhseReceiptLine."Line No.";
                            AdditionalUnitLineLink.Calculation := false;
                            UnitLineLink.Calculation := true;
                            InsertUnitLineLink(AdditionalUnitLineLink);
                        until PostedWhseReceiptLine.next() = 0;
                end;
            Database::"Transfer Line":
                begin
                    TransferLine.Get(SourceDocumentLink."Source ID", SourceDocumentLink."Source Ref. No.");
                    if SourceDocumentLink.Positive then begin
                        WarehouseReceiptLine.Reset();
                        WarehouseReceiptLine.Setrange("Source Type", SourceDocumentLink."Source Type");
                        WarehouseReceiptLine.Setrange("Source Type", 1);
                        WarehouseReceiptLine.Setrange("Source No.", SourceDocumentLink."Source ID");
                        WarehouseReceiptLine.Setrange("Source Line No.", SourceDocumentLink."Source Ref. No.");
                        if WarehouseReceiptLine.findset() then
                            repeat
                                AdditionalUnitLineLink.Init();
                                AdditionalUnitLineLink.TransferFields(UnitLineLink);
                                AdditionalUnitLineLink."Source Type" := Database::"Warehouse Receipt Line";
                                AdditionalUnitLineLink."Source Subtype" := 0;
                                AdditionalUnitLineLink."Source ID" := WarehouseReceiptLine."No.";
                                AdditionalUnitLineLink."Source Batch Name" := '';
                                AdditionalUnitLineLink."Source Prod. Order Line" := 0;
                                AdditionalUnitLineLink."Source Ref. No." := WarehouseReceiptLine."Line No.";
                                AdditionalUnitLineLink.Calculation := false;
                                UnitLineLink.Calculation := true;
                                InsertUnitLineLink(AdditionalUnitLineLink);
                            until WarehouseReceiptLine.next() = 0;
                    end else begin
                        WarehouseShipmentLine.Reset();
                        WarehouseShipmentLine.Setrange("Source Type", SourceDocumentLink."Source Type");
                        WarehouseShipmentLine.Setrange("Source Type", 0);
                        WarehouseShipmentLine.Setrange("Source No.", SourceDocumentLink."Source ID");
                        WarehouseShipmentLine.Setrange("Source Line No.", SourceDocumentLink."Source Ref. No.");
                        if WarehouseShipmentLine.findset() then
                            repeat
                                AdditionalUnitLineLink.Init();
                                AdditionalUnitLineLink.TransferFields(UnitLineLink);
                                AdditionalUnitLineLink."Source Type" := Database::"Warehouse Shipment Line";
                                AdditionalUnitLineLink."Source Subtype" := 0;
                                AdditionalUnitLineLink."Source ID" := WarehouseShipmentLine."No.";
                                AdditionalUnitLineLink."Source Batch Name" := '';
                                AdditionalUnitLineLink."Source Prod. Order Line" := 0;
                                AdditionalUnitLineLink."Source Ref. No." := WarehouseShipmentLine."Line No.";
                                AdditionalUnitLineLink.Calculation := false;
                                UnitLineLink.Calculation := true;
                                InsertUnitLineLink(AdditionalUnitLineLink);
                            until WarehouseShipmentLine.next() = 0;
                    end;
                end;
            Database::"Invt. Document Line":
                begin
                    InvtDocumentLine.Get(SourceDocumentLink."Source Subtype", SourceDocumentLink."Source ID", SourceDocumentLink."Source Ref. No.");
                    case InvtDocumentLine."Document Type" of
                        "Invt. Doc. Document Type"::Receipt:
                            ;
                    end;
                end;
            Database::"Warehouse Activity Line":
                begin
                    WarehouseActivityLine.get(SourceDocumentLink."Source Subtype", SourceDocumentLink."Source ID", SourceDocumentLink."Source Ref. No.");
                    if (WarehouseActivityLine."Source Type" <> 0) and
                       (WarehouseActivityLine."Source Subtype" <> 0) and
                       (WarehouseActivityLine."Source No." <> '') and
                       //((WarehouseActivityLine."Activity Type" = "Warehouse Activity Type"::"Invt. Pick") or
                       (WarehouseActivityLine."Activity Type" = "Warehouse Activity Type"::"Invt. Put-away")//)
                    then begin
                        AdditionalUnitLineLink.Reset();
                        AdditionalUnitLineLink.SetRange("Unit No.", UnitLineLink."Unit No.");
                        AdditionalUnitLineLink.SetRange("Unit Line No.", UnitLineLink."Unit Line No.");
                        AdditionalUnitLineLink.SetRange("Source Type", WarehouseActivityLine."Source Type");
                        AdditionalUnitLineLink.SetRange("Source Subtype", WarehouseActivityLine."Source Subtype");
                        AdditionalUnitLineLink.SetRange("Source ID", WarehouseActivityLine."Source No.");
                        AdditionalUnitLineLink.SetRange("Source Ref. No.", WarehouseActivityLine."Source Line No.");
                        if AdditionalUnitLineLink.IsEmpty then begin
                            Clear(AdditionalUnitLineLink);
                            AdditionalUnitLineLink.Init();
                            AdditionalUnitLineLink.TransferFields(UnitLineLink);
                            AdditionalUnitLineLink."Source Type" := WarehouseActivityLine."Source Type";
                            AdditionalUnitLineLink."Source Subtype" := WarehouseActivityLine."Source Subtype";
                            AdditionalUnitLineLink."Source ID" := WarehouseActivityLine."Source No.";
                            AdditionalUnitLineLink."Source Ref. No." := WarehouseActivityLine."Source Line No.";
                            AdditionalUnitLineLink.Calculation := false;
                            UnitLineLink.Calculation := true;
                            InsertUnitLineLink(AdditionalUnitLineLink);
                        end;
                    end;
                end;
        end;
    end;


    /// <summary>
    /// Creates a reverse link record for direct movements.
    /// </summary>
    /// <remarks>
    /// This might be used for scenario where items must be reversed or undone, possibly transferring them out.
    /// </remarks>
    /// <param name="UnitLineLink">The original link to replicate in reverse.</param>
    /// <param name="ErrorMessageIfExist">If true, might raise an error if a reverse link already exists.
    /// </param>
    internal procedure CreateReverseLink(var UnitLineLink: Record "TMAC Unit Line Link"; ErrorMessageIfExist: Boolean)
    var
        ReverseUnitLineLink: Record "TMAC Unit Line Link";
    begin
        ReverseUnitLineLink.Init();
        ReverseUnitLineLink.TransferFields(UnitLineLink);
        ReverseUnitLineLink."Quantity" := -(UnitLineLink.Quantity + UnitLineLink."Posted Quantity");
        ReverseUnitLineLink."Quantity (Base)" := ReverseUnitLineLink."Quantity" * ReverseUnitLineLink."Qty. per UoM";
        ReverseUnitLineLink.Posted := false;
        ReverseUnitLineLink."Posted Quantity" := 0;
        ReverseUnitLineLink.Positive := not UnitLineLink.Positive;

        if ReverseUnitLineLink.Positive then
            ReverseUnitLineLink."Source Subtype" := 1
        else
            ReverseUnitLineLink."Source Subtype" := 0;

        if not ReverseUnitLineLink.Insert(true) then
            if ErrorMessageIfExist then
                error(LinkExistErr, ReverseUnitLineLink."Unit No.")
            else
                ReverseUnitLineLink.Modify(true);
    end;

    // internal procedure AddAdditionalLinkForTransfer(var UnitLineLink: Record "TMAC Unit Line Link"; var SourceDocumentLink: Record "TMAC Source Document Link")
    // var
    //     AdditionalUnitLineLink: Record "TMAC Unit Line Link";
    //     WarehouseReceiptLine: Record "Warehouse Receipt Line";
    //     WarehouseShipmentLine: Record "Warehouse Shipment Line";
    //     TransferLine: Record "Transfer Line";
    // begin
    //     if UnitLineLink.Positive then begin
    //         WarehouseReceiptLine.Reset();
    //         WarehouseReceiptLine.Setrange("Source Type", SourceDocumentLink."Source Type");
    //         WarehouseReceiptLine.Setrange("Source Type", 1);
    //         WarehouseReceiptLine.Setrange("Source No.", SourceDocumentLink."Source ID");
    //         WarehouseReceiptLine.Setrange("Source Line No.", SourceDocumentLink."Source Ref. No.");
    //         if WarehouseReceiptLine.findset() then
    //             repeat
    //                 AdditionalUnitLineLink.Init();
    //                 AdditionalUnitLineLink.TransferFields(UnitLineLink);
    //                 AdditionalUnitLineLink."Source Type" := Database::"Warehouse Receipt Line";
    //                 AdditionalUnitLineLink."Source Subtype" := 0;
    //                 AdditionalUnitLineLink."Source ID" := WarehouseReceiptLine."No.";
    //                 AdditionalUnitLineLink."Source Batch Name" := '';
    //                 AdditionalUnitLineLink."Source Prod. Order Line" := 0;
    //                 AdditionalUnitLineLink."Source Ref. No." := WarehouseReceiptLine."Line No.";
    //                 AdditionalUnitLineLink.Calculation := false;
    //                 UnitLineLink.Calculation := true;
    //                 InsertUnitLineLink(AdditionalUnitLineLink);
    //             until WarehouseReceiptLine.next() = 0;
    //     end else begin
    //         TransferLine.Get(SourceDocumentLink."Source ID", SourceDocumentLink."Source Ref. No.");
    //         WarehouseShipmentLine.Reset();
    //         WarehouseShipmentLine.Setrange("Source Type", SourceDocumentLink."Source Type");
    //         WarehouseShipmentLine.Setrange("Source Type", 0);
    //         WarehouseShipmentLine.Setrange("Source No.", SourceDocumentLink."Source ID");
    //         WarehouseShipmentLine.Setrange("Source Line No.", SourceDocumentLink."Source Ref. No.");
    //         if WarehouseShipmentLine.findset() then
    //             repeat
    //                 AdditionalUnitLineLink.Init();
    //                 AdditionalUnitLineLink.TransferFields(UnitLineLink);
    //                 AdditionalUnitLineLink."Source Type" := Database::"Warehouse Shipment Line";
    //                 AdditionalUnitLineLink."Source Subtype" := 0;
    //                 AdditionalUnitLineLink."Source ID" := WarehouseShipmentLine."No.";
    //                 AdditionalUnitLineLink."Source Batch Name" := '';
    //                 AdditionalUnitLineLink."Source Prod. Order Line" := 0;
    //                 AdditionalUnitLineLink."Source Ref. No." := WarehouseShipmentLine."Line No.";
    //                 AdditionalUnitLineLink.Calculation := false;
    //                 UnitLineLink.Calculation := true;
    //                 InsertUnitLineLink(AdditionalUnitLineLink);
    //             until WarehouseShipmentLine.next() = 0;
    //     end;
    // end;

    /// <summary>
    /// Applies lines from different units to a single unit line.
    /// </summary>
    /// <remarks>
    /// This procedure is used to close out the expected quantity of a unit line by combining lines from different sources.
    /// </remarks>
    /// <param name="UnitLine">The unit line to close out.</param>
    internal procedure UnitLineApplication(UnitLine: Record "TMAC Unit Line")
    var
        SourceUnitLine: Record "TMAC Unit Line";
        SourceDocumentLink: Record "TMAC Source Document Link";
        ReverseSourceDocumentLink: Record "TMAC Source Document Link";
        SelectedSourceDocumentLink: Record "TMAC Source Document Link";
        UnitApplication: Page "TMAC Unit Application";
        QtyApplication: Decimal;
        SelectedQty: Decimal;
        QtyDistributed: Decimal;
    begin
        //определяем на какое кол-во нужно закрыть
        UnitLine.CalcFields("Expected Quantity");
        if UnitLine."Expected Quantity" = 0 then
            error(LineHasExpectedQtyZeroErr);

        //ищем строки паллеты с тем же товаром по тому же складу
        SourceUnitLine.Setrange(Type, UnitLine.Type);
        SourceUnitLine.Setrange("No.", UnitLine."No.");
        SourceUnitLine.Setrange("Variant Code", UnitLine."Variant Code");
        SourceUnitLine.Setrange("Location Code", UnitLine."Location Code");
        SourceUnitLine.Setrange("Unit of Measure Code", UnitLine."Unit of Measure Code");
        SourceUnitLine.SetAutoCalcFields("Expected Quantity");
        if UnitLine."Expected Quantity" > 0 then
            SourceUnitLine.SetFilter("Expected Quantity", '<0')
        else
            SourceUnitLine.SetFilter("Expected Quantity", '>0');
        if SourceUnitLine.Findset(false) then
            repeat
                CreateFrom_UnitLine(SourceDocumentLink, SourceUnitLine);
            until SourceUnitLine.next() = 0;

        QtyApplication := abs(UnitLine."Expected Quantity");
        QtyDistributed := abs(UnitLine."Expected Quantity");

        SourceDocumentLink.Reset();
        if SourceDocumentLink.Findset(false) then
            repeat
                if QtyDistributed >= SourceDocumentLink.Quantity then
                    SelectedQty := SourceDocumentLink.Quantity
                else
                    SelectedQty := QtyDistributed;
                UnitApplication.AddLine(SourceDocumentLink, SelectedQty);
                QtyDistributed := QtyDistributed - SelectedQty;
            until SourceDocumentLink.next() = 0;

        UnitApplication.LookupMode(true);
        if UnitApplication.RunModal() = Action::LookupOK then begin
            UnitApplication.GetSelectedLines(SelectedSourceDocumentLink);

            SelectedQty := 0;
            //проверка набранного кол-ва
            if SelectedSourceDocumentLink.FindSet() then
                repeat
                    SelectedQty += SelectedSourceDocumentLink."Selected Quantity";
                until SelectedSourceDocumentLink.Next() = 0;

            if SelectedQty <> QtyApplication then
                error(TotalSelectedQtyErr, SelectedQty);

            if SelectedSourceDocumentLink.FindSet() then
                repeat
                    CreateLink(UnitLine, SelectedSourceDocumentLink, SelectedSourceDocumentLink."Selected Quantity", true);

                    //создание обратного линка
                    SourceUnitLine.Reset();
                    SourceUnitLine.Get(SelectedSourceDocumentLink."Source ID", SelectedSourceDocumentLink."Source Ref. No.");
                    CreateFrom_UnitLine(ReverseSourceDocumentLink, UnitLine);
                    CreateLink(SourceUnitLine, ReverseSourceDocumentLink, SelectedSourceDocumentLink."Selected Quantity", true);

                until SelectedSourceDocumentLink.Next() = 0;

        end
    end;


    /// <summary>
    /// Доп информация
    /// </summary>
    /// <param name="SourceType"></param>
    /// <param name="SourceDocumentType"></param>
    /// <param name="SourceDocumentNo"></param>
    procedure GetSourceName(SourceType: Integer; SourceSubType: Integer): Text[50]
    begin
        case SourceType of
            Database::"TMAC Unit Line Link":
                exit(UnitLineLbl);

            Database::"Purchase Header",
            Database::"Purchase Line":
                case SourceSubType of
                    "Purchase Document Type"::Order.AsInteger(),
                    "Purchase Document Type"::Invoice.AsInteger():
                        exit(PurchaseDocumentLbl);
                    "Purchase Document Type"::"Credit Memo".AsInteger(),
                    "Purchase Document Type"::"Return Order".AsInteger():
                        exit(PurchaseReturnDocumentLbl);
                end;
            Database::"Purch. Rcpt. Header",
            Database::"Purch. Rcpt. Line":
                exit(PostedPurchaseReceiptLbl);

            Database::"Warehouse Receipt Header",
            Database::"Warehouse Receipt Line":
                exit(WarehouseReceiptLbl);

            Database::"Posted Whse. Receipt Header",
            Database::"Posted Whse. Receipt Line":
                exit(PostedWhseReceiptLbl);

            Database::"Sales Header",
            Database::"Sales Line":
                case SourceSubType of
                    "Sales Document Type"::Order.AsInteger(),
                    "Sales Document Type"::Invoice.AsInteger():
                        exit(SalesDocumentLbl);
                    "Sales Document Type"::"Credit Memo".AsInteger(),
                    "Sales Document Type"::"Return Order".AsInteger():
                        exit(SalesReturnDocumentLbl);
                end;

            Database::"Sales Shipment Header",
            Database::"Sales Shipment Line":
                exit(PostedSalesShipmentLbl);

            Database::"Warehouse Shipment Header",
            Database::"Warehouse Shipment Line":
                exit(WarehouseShipmentLbl);

            Database::"Posted Whse. Shipment Header",
            Database::"Posted Whse. Shipment Line":
                exit(PostedWarehouseShipmentLbl);

            Database::"Return Receipt Header",
            Database::"Return Receipt Line": 
                exit(PostedSalesReturnLbl);

            Database::"Return Shipment Header",
            Database::"Return Shipment Line": 
                exit(PostedPurchaseReturnLbl);

            Database::"Transfer Header",
            Database::"Transfer Line":
                exit(TransferOrderLbl);

            Database::"Transfer Shipment Header",
            Database::"Transfer Shipment Line":
                exit(TransferShipmentLbl);

            Database::"Transfer Receipt Header",
            Database::"Transfer Receipt Line":
                exit(TransferReceipLbl);

            Database::"Warehouse Activity Header",
            Database::"Warehouse Activity Line":
                case SourceSubType of
                    "Warehouse Activity Type"::" ".AsInteger():
                        exit(WarehouseActivityLbl);
                    "Warehouse Activity Type"::"Put-away".AsInteger():
                        exit(WarehousePutAwayLbl);
                    "Warehouse Activity Type"::Pick.AsInteger():
                        exit(WarehousePickLbl);
                    "Warehouse Activity Type"::Movement.AsInteger():
                        exit(WarehouseMovementLbl);
                    "Warehouse Activity Type"::"Invt. Put-away".AsInteger():
                        exit(InventoryPutAwayLbl);
                    "Warehouse Activity Type"::"Invt. Pick".AsInteger():
                        exit(InventoryPickLbl);
                    "Warehouse Activity Type"::"Invt. Movement".AsInteger():
                        exit(InventoryMovementLbl);
                end;

            Database::"Registered Whse. Activity Hdr.",
            Database::"Registered Whse. Activity Line":
                case SourceSubType of
                    "Warehouse Activity Type"::" ".AsInteger():
                        exit(RegisteredWarehouseActivityLbl);
                    "Warehouse Activity Type"::"Put-away".AsInteger():
                        exit(RegisteredWarehousePutAwayLbl);
                    "Warehouse Activity Type"::Pick.AsInteger():
                        exit(RegisteredWarehousePickLbl);
                    "Warehouse Activity Type"::Movement.AsInteger():
                        exit(RegisteredWarehouseMovementLbl);
                    "Warehouse Activity Type"::"Invt. Put-away".AsInteger():
                        exit(RegisteredInventoryPutAwayLbl);
                    "Warehouse Activity Type"::"Invt. Pick".AsInteger():
                        exit(RegisteredInventoryPickLbl);
                    "Warehouse Activity Type"::"Invt. Movement".AsInteger():
                        exit(RegisteredInventoryMovementLbl);
                end;

            Database::"Whse. Internal Put-away Header",
            Database::"Whse. Internal Put-away Line":
                exit(WhseInternalPutAwayLbl);

            Database::"Whse. Internal Pick Header",
            Database::"Whse. Internal Pick Line":
                exit(WhseInternalPickLbl);

            Database::"Internal Movement Header",
            Database::"Internal Movement Line":
                exit(InternalMovementLbl);

            Database::"Registered Invt. Movement Hdr.",
            Database::"Registered Invt. Movement Line":
                exit(GetSourceNameEmpl(Database::"Registered Invt. Movement Hdr.", SourceSubType));

            Database::"Posted Invt. Put-away Header",
            Database::"Posted Invt. Put-away Line":
                exit(GetSourceNameEmpl(Database::"Posted Invt. Put-away Header", SourceSubType));

            else
                exit(GetSourceNameEmpl(SourceType, SourceSubType));
        end;
    end;

    var
        PurchaseDocumentLbl: Label 'Purchase Document';
        PurchaseReturnDocumentLbl: label 'Purchase Return';
        PostedPurchaseReceiptLbl: Label 'Posted Purchase Receipt';
        UnitLineLbl: Label 'Unit Line';
        WarehouseReceiptLbl: Label 'Warehouse Receipt';
        PostedWhseReceiptLbl: label 'Posted Warehouse Receipt';
        SalesDocumentLbl: Label 'Sales Document';
        SalesReturnDocumentLbl: Label 'Sales Return';
        PostedSalesShipmentLbl: Label 'Posted Sales Shipment';
        WarehouseShipmentLbl: Label 'Warehouse Shipment';
        PostedWarehouseShipmentLbl: Label 'Posted Warehouse Shipment';
        PostedSalesReturnLbl: label 'Posted Sales Return';
        PostedPurchaseReturnLbl: label 'Posted Purchase Return';
        TransferOrderLbl: Label 'Transfer Order';
        TransferShipmentLbl: label 'Transfer Shipment';
        TransferReceipLbl: Label 'Transfer Receipt';
        WarehouseActivityLbl: Label 'Warehouse Activity';
        WarehousePutAwayLbl: Label 'Warehouse Put-away';
        WarehousePickLbl: Label 'Warehouse Pick';
        WarehouseMovementLbl: Label 'Warehouse Movement';
        InventoryPutAwayLbl: Label 'Inventory Put-away';
        InventoryPickLbl: Label 'Inventory Pick';
        InventoryMovementLbl: Label 'Inventory Movement';
        RegisteredWarehouseActivityLbl: Label 'Registered Warehouse Activity';
        RegisteredWarehousePutAwayLbl: Label 'Registered Warehouse Put-away';
        RegisteredWarehousePickLbl: Label 'Registered Warehouse Pick';
        RegisteredWarehouseMovementLbl: Label 'Registered Warehouse Movement';
        RegisteredInventoryPutAwayLbl: Label 'Registered Inventory Put-away';
        RegisteredInventoryPickLbl: Label 'Registered Inventory Pick';
        RegisteredInventoryMovementLbl: Label 'Registered Inventory Movement';
        WhseInternalPutAwayLbl: label 'Warehouse Internal Put-away';
        WhseInternalPickLbl: label 'Warehouse Internal Pick';
        InternalMovementLbl: Label 'Internal Movement';


    local procedure GetSourceNameEmpl(SourceType: Integer; SourceDocumentType: Integer): Text[50]
    var
        PageMetadata: Record "Page Metadata";
    begin
        if SourceDocumentType = 0 then begin
            PageMetadata.SetRange(SourceTable, SourceType);

            PageMetadata.SetRange(PageType, PageMetadata.PageType::Document);
            if PageMetadata.Findfirst() then
                exit(PageMetadata.Name);

            PageMetadata.SetRange(PageType, PageMetadata.PageType::Worksheet);
            if PageMetadata.Findfirst() then
                exit(PageMetadata.Name);

            PageMetadata.SetRange(PageType, PageMetadata.PageType::List);
            if PageMetadata.Findfirst() then
                exit(CopyStr(PageMetadata.Caption, 1, 50));

            PageMetadata.SetRange(PageType);
            if PageMetadata.Findfirst() then
                exit(CopyStr(PageMetadata.Caption, 1, 50));

        end else begin
            PageMetadata.SetRange(SourceTable, SourceType);
            PageMetadata.SetRange(PageType, PageMetadata.PageType::Document);
            PageMetadata.SetFilter(SourceTableView, '''*FILTER(' + FORMAT(SourceDocumentType) + ')*''');
            if PageMetadata.Findfirst() then
                exit(PageMetadata.Name);

            PageMetadata.SetFilter(SourceTableView, '''*CONST(' + FORMAT(SourceDocumentType) + ')*''');
            if PageMetadata.Findfirst() then
                exit(PageMetadata.Name);
        end;
    end;

    /// <summary>
    /// Additional information
    /// </summary>
    /// <param name="SourceType"></param>
    /// <param name="SourceDocumentType"></param>
    /// <param name="SourceDocumentNo"></param>
    internal procedure GetSourceInformation(SourceType: Integer; SourceDocumentType: Integer; SourceDocumentNo: Code[20]): Text[150]
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesHeader: Record "Sales Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchaseHeader: Record "Purchase Header";
        ReturnShipmentHeader: Record "Return Shipment Header";
        ReturnReceiptHeader: Record "Return Receipt Header";
        TransferHeader: Record "Transfer Header";
        InvtReceiptHeader: Record "Invt. Receipt Header";
        Customer: Record Customer;
    begin
        case SourceType of
            Database::"Purchase Header",
            Database::"Purchase Line":
                if PurchaseHeader.Get(SourceDocumentType, SourceDocumentNo) then
                    exit(PurchaseHeader."Buy-from Vendor Name" + PurchaseHeader."Buy-from Vendor Name 2");
            Database::"Purch. Rcpt. Header",
            Database::"Purch. Rcpt. Line":
                if PurchRcptHeader.get(SourceDocumentNo) then
                    exit(PurchRcptHeader."Buy-from Vendor Name" + PurchRcptHeader."Buy-from Vendor Name 2");
            Database::"Warehouse Receipt Header",
            Database::"Warehouse Receipt Line":
                exit('-');
            Database::"Posted Whse. Receipt Header",
            Database::"Posted Whse. Receipt Line":
                exit('-');
            Database::"Sales Header",
            Database::"Sales Line":
                if SalesHeader.Get(SourceDocumentType, SourceDocumentNo) then
                    exit(SalesHeader."Sell-to Customer Name" + SalesHeader."Sell-to Customer Name 2");
            Database::"Sales Shipment Header",
            Database::"Sales Shipment Line":
                if SalesShipmentHeader.Get(SourceDocumentNo) then
                    exit(SalesShipmentHeader."Sell-to Customer Name" + SalesShipmentHeader."Sell-to Customer Name 2");
            Database::"Warehouse Shipment Header",
            Database::"Warehouse Shipment Line":
                exit('-');
            Database::"Posted Whse. Shipment Header",
            Database::"Posted Whse. Shipment Line":
                exit('-');
            Database::"Return Receipt Header",
            Database::"Return Receipt Line": 
                if ReturnReceiptHeader.get(SourceDocumentNo) then
                    exit(ReturnReceiptHeader."Sell-to Customer Name" + ReturnReceiptHeader."Sell-to Customer Name 2");
            Database::"Return Shipment Header",
            Database::"Return Shipment Line": 
                if ReturnShipmentHeader.Get(SourceDocumentNo) then
                    exit(ReturnShipmentHeader."Buy-from Vendor Name" + ReturnShipmentHeader."Buy-from Vendor Name 2");
            Database::"Transfer Header",
            Database::"Transfer Line":
                if TransferHeader.Get(SourceDocumentNo) then
                    exit(CopyStr(TransferHeader."Transfer-from Name" + ' ' + TransferHeader."Transfer-to Name", 1, 150));
            Database::"Invt. Receipt Header",
            Database::"Invt. Receipt Line":
                if InvtReceiptHeader.get(SourceDocumentNo) and Customer.Get(InvtReceiptHeader."TMAC Customer No.") then
                    exit(Customer.Name + Customer."Name 2");
        end;
    end;

    internal procedure InsertUnitLineLink(var UnitLineLink: Record "TMAC Unit Line Link")
    var
        UnitLineLinkExist: Record "TMAC Unit Line Link";
    begin
        if UnitLineLinkExist.Get(
            UnitLineLink."Unit No.",
            UnitLineLink."Unit Line No.",
            UnitLineLink."Source Type",
            UnitLineLink."Source Subtype",
            UnitLineLink."Source ID",
            UnitLineLink."Source Batch Name",
            UnitLineLink."Source Prod. Order Line",
            UnitLineLink."Source Ref. No.",
            UnitLineLink."Package No.",
            UnitLineLink."Lot No.",
            UnitLineLink."Serial No.")
        then
            UnitLineLinkExist.Delete(true);

        UnitLineLink.Insert(true);
    end;


    /// <summary>
    /// Calls the logistic unit creation wizard
    /// </summary>
    [Obsolete('Use procedure CreateNewLogisticUnits(var SourceDocumentLink: Record "TMAC Source Document Link"; LogisticDirection: enum "TMAC Direction")', '24.1')]
    procedure CreateNewLogisticUnits(SourceType: Integer; SourceDocumentType: Integer; SourceDocumentNo: Code[20]; SourceLineNo: Integer; Positive: Boolean)
    begin
        //CheckStatuses(SourceType, SourceDocumentType, SourceDocumentNo);
        //NewLogisticUnitWizard.SetSource(SourceType, SourceDocumentType, SourceDocumentNo, SourceLineNo, Positive);
        //NewLogisticUnitWizard.RunModal();
    end;

    /// <summary>
    /// New logistic units
    /// </summary>
    /// <param name="LogisticDirection">Inbound or Outbound logistic</param>
    procedure CreateNewLogisticUnits(var SourceDocumentLink: Record "TMAC Source Document Link"; LogisticDirection: enum "TMAC Direction")
    var
        NewLogisticUnitWizard: Page "TMAC New Logistic Unit Wizard";
    begin
        NewLogisticUnitWizard.SetDocumentLinks(SourceDocumentLink, LogisticDirection);
        NewLogisticUnitWizard.RunModal();
    end;

    /// <summary>
    /// Calls the logistic unit addition wizard
    /// </summary>
    [Obsolete('Use procedure AddtoLogisticUnit(var SourceDocumentLink: Record "TMAC Source Document Link"; LogisticDirection: enum "TMAC Direction")', '24.1')]
    procedure AddToLogisticUnit(SourceType: Integer; SourceDocumentType: Integer; SourceDocumentNo: Code[20]; SourceLineNo: Integer; Positive: Boolean)
    begin
        // CheckStatuses(SourceType, SourceDocumentType, SourceDocumentNo);
        // AddToLogisticUnitWz.SetSource(SourceType, SourceDocumentType, SourceDocumentNo, SourceLineNo, Positive);
        // AddToLogisticUnitWz.RunModal();
    end;

    /// <summary>
    /// Вызов мастера добавления в логистическую единицу
    /// </summary>
    /// <param name="LogisticDirection">Inbound or Outbound logistic</param>
    procedure AddtoLogisticUnit(var SourceDocumentLink: Record "TMAC Source Document Link"; LogisticDirection: enum "TMAC Direction")
    var
        AddToLogisticUnitWz: Page "TMAC Add To Logistic Unit Wz.";
    begin
        AddToLogisticUnitWz.SetDocumentLinks(SourceDocumentLink, LogisticDirection);
        AddToLogisticUnitWz.RunModal();
    end;

    /// <summary>
    /// Shows the list of links associated with the selected source
    /// </summary>
    procedure ShowLogisticUnitsList(SourceType: Integer; SourceDocumentType: Integer; SourceDocumentNo: Code[20]; SourceLineNo: Integer; ItemInfoVisible: Boolean)
    var
        UnitLineLink: Record "TMAC Unit Line Link";
        UnitLineLinks: Page "TMAC Unit Line Links";
    begin
        if not UnitLineLink.ReadPermission then
            exit;

        UnitLineLink.Setrange("Source Type", SourceType);
        UnitLineLink.Setrange("Source Subtype", SourceDocumentType);
        UnitLineLink.Setrange("Source ID", SourceDocumentNo);
        if SourceLineNo <> 0 then
            UnitLineLink.SetRange("Source Ref. No.", SourceLineNo);
        UnitLineLinks.SetItemInfoVisible(ItemInfoVisible);
        UnitLineLinks.SetTableView(UnitLineLink);
        UnitLineLinks.Run();
    end;

    /// <summary>
    /// Returns the number of logistic units for the source
    /// </summary>
    procedure NoOfLogisticUnits(SourceType: Integer; SourceDocumentType: Integer; SourceDocumentNo: Code[20]; SourceLineNo: Integer): Integer
    var
        UnitLineLink: Record "TMAC Unit Line Link";
        Units: List of [Code[20]];
    begin
        UnitLineLink.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.", "Package No.", "Lot No.", "Serial No.", "Positive", "Qty. to Post");
        UnitLineLink.Setrange("Source Type", SourceType);
        UnitLineLink.Setrange("Source Subtype", SourceDocumentType);
        UnitLineLink.Setrange("Source ID", SourceDocumentNo);
        if SourceLineNo <> 0 then
            UnitLineLink.SetRange("Source Ref. No.", SourceLineNo);
        UnitLineLink.SetLoadFields("Unit No.");
        if UnitLineLink.findset(false) then
            repeat
                if not Units.Contains(UnitLineLink."Unit No.") then
                    Units.Add(UnitLineLink."Unit No.");
            until UnitLineLink.next() = 0;
        exit(Units.Count);
    end;

    /// <summary>
    /// Returns the name of logistic units or the count if there are multiple()
    /// </summary>
    procedure GetLogisticUnitsInText(SourceType: Integer; SourceDocumentType: Integer; SourceDocumentNo: Code[20]; SourceLineNo: Integer) ReturnValue: Code[20]
    var
        UnitLineLink: Record "TMAC Unit Line Link";
        Units: List of [Code[20]];
        Unit: Code[20];
    begin
        if not UnitLineLink.ReadPermission then
            exit;

        UnitLineLink.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.", "Package No.", "Lot No.", "Serial No.", "Positive", "Qty. to Post");
        UnitLineLink.Setrange("Source Type", SourceType);
        UnitLineLink.Setrange("Source Subtype", SourceDocumentType);
        UnitLineLink.Setrange("Source ID", SourceDocumentNo);
        if SourceLineNo <> 0 then
            UnitLineLink.SetRange("Source Ref. No.", SourceLineNo);
        UnitLineLink.SetLoadFields("Unit No.");
        if UnitLineLink.FindSet(false) then
            repeat
                if not Units.Contains(UnitLineLink."Unit No.") then
                    Units.Add(UnitLineLink."Unit No.");
            until UnitLineLink.Next() = 0;

        if Units.Count = 0 then
            exit;

        foreach Unit in Units do
            if ReturnValue = '' then
                ReturnValue := Unit
            else begin
                ReturnValue := Format(Units.Count) + ' ';
                break;
            end;
    end;

    /// <summary>
    /// Returns the list of logistic units linked to the given source (document)
    /// </summary>
    internal procedure GetUnitsListByDocument(SourceType: Integer; SourceDocumentType: Integer; SourceDocumentNo: Code[20]; SourceLineNo: Integer) returnvalue: List of [Code[20]]
    var
        UnitLineLink: Record "TMAC Unit Line Link";
    begin
        UnitLineLink.Reset();
        UnitLineLink.Setrange("Source Type", SourceType);
        UnitLineLink.Setrange("Source Subtype", SourceDocumentType);
        if SourceDocumentNo <> '' then
            UnitLineLink.Setrange("Source ID", SourceDocumentNo);
        if SourceLineNo <> 0 then
            UnitLineLink.SetRange("Source Ref. No.", SourceLineNo);
        UnitLineLink.SetLoadFields("Unit No.");
        if UnitLineLink.findset(false) then
            repeat
                if not Returnvalue.Contains(UnitLineLink."Unit No.") then
                    Returnvalue.Add(UnitLineLink."Unit No.");
            until UnitLineLink.next() = 0;
    end;

    /// <summary>
    /// Retrieves a list of pallets using Query for a given source
    /// </summary>
    procedure GetUnitListBySource(SourceType: Integer; SourceSubtype: Integer; SourceID: Code[20]) Returnvalue: List of [Code[20]]
    begin
        exit(GetUnitListBySource(SourceType, SourceSubtype, SourceID, '', 0, 0));
    end;

    /// <summary>
    /// Retrieves a list of pallets using Query for a given source
    /// </summary>
    procedure GetUnitListBySource(SourceType: Integer; SourceSubtype: Integer; SourceID: Code[20]; SourceLineNo: Integer) Returnvalue: List of [Code[20]]
    begin
        exit(GetUnitListBySource(SourceType, SourceSubtype, SourceID, '', 0, SourceLineNo));
    end;

    /// <summary>
    /// Retrieves a list of pallets using Query for a given source
    /// </summary>
    procedure GetUnitListBySource(SourceType: Integer; SourceSubtype: Integer; SourceID: Code[20]; SourceBatchName: Code[10]; SourceProdOrderLine: Integer; SourceRefNo: Integer) Returnvalue: List of [Code[20]]
    var
        DistinctUnits: Query "TMAC Distinct Units";
    begin
        if SourceType = 0 then
            exit;

        if SourceID = '' then
            exit;

        DistinctUnits.SetRange(SourceType, SourceType);
        DistinctUnits.SetRange(SourceSubtype, SourceSubtype);

        if SourceID <> '' then
            DistinctUnits.SetRange(SourceID, SourceID);

        if SourceBatchName <> '' then
            DistinctUnits.Setrange(SourceBatchName, SourceBatchName);

        if SourceProdOrderLine <> 0 then
            DistinctUnits.Setrange(SourceProdOrderLine, SourceProdOrderLine);

        if SourceRefNo <> 0 then
            DistinctUnits.Setrange(SourceRefNo, SourceRefNo);

        DistinctUnits.Open();
        while DistinctUnits.Read() do
            ReturnValue.Add(DistinctUnits.UnitNo);

        DistinctUnits.Close();
    end;

    procedure DeleteExistingLinks(SourceType: Integer; SourceSubtype: Integer; SourceNo: Code[20]; SourceLineNo: Integer)
    var
        UnitLineLink: Record "TMAC Unit Line Link";
    begin
        if not UnitLineLink.ReadPermission then
            Error(LogisticUnitModuleAccessErr);

        UnitLineLink.Reset();
        UnitLineLink.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.", "Package No.", "Lot No.", "Serial No.", "Positive", "Qty. to Post");
        UnitLineLink.Setrange("Source Type", SourceType);
        UnitLineLink.Setrange("Source Subtype", SourceSubtype);
        UnitLineLink.Setrange("Source ID", SourceNo);
        UnitLineLink.Setrange("Source Ref. No.", SourceLineNo);
        UnitLineLink.DeleteAll(true);
    end;

    /// <summary>
    /// Shows the linked document for a given Unit Line Link
    /// (no links to movements)
    /// </summary>
    /// <param name="UnitLineLink"></param>
    internal procedure ShowDocument(var PostedUnitLineLink: Record "TMAC Posted Unit Line Link")
    begin
        ShowDocument(PostedUnitLineLink."Source Type", PostedUnitLineLink."Source Subtype", PostedUnitLineLink."Source ID");
    end;

    internal procedure ShowDocument(var UnitLineLink: Record "TMAC Unit Line Link")
    begin
        ShowDocument(UnitLineLink."Source Type", UnitLineLink."Source Subtype", UnitLineLink."Source ID");
    end;


    procedure ShowDocument(SourceType: Integer; SourceSubtype: Integer; SourceNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        TransferHeader: Record "Transfer Header";
        WarehouseReceiptHeader: Record "Warehouse Receipt Header";
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        PostedWhseReceiptHeader: Record "Posted Whse. Receipt Header";
        PostedWhseShipmentHeader: Record "Posted Whse. Shipment Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ReturnReceiptHeader: Record "Return Receipt Header";
        ReturnShipmentHeader: Record "Return Shipment Header";
    begin
        case SourceType of
            Database::"Sales Header",
            Database::"Sales Line":
                begin
                    SalesHeader.Get(SourceSubtype, SourceNo);
                    case SourceSubtype of
                        1:
                            Page.Run(PAGE::"Sales Order", SalesHeader);
                        2:
                            Page.Run(PAGE::"Sales Invoice", SalesHeader);
                        3:
                            Page.Run(PAGE::"Sales Credit Memo", SalesHeader);
                        4:
                            Page.Run(PAGE::"Blanket Sales Order", SalesHeader);
                        5:
                            Page.Run(PAGE::"Sales Return Order", SalesHeader);
                    end;
                end;
            Database::"Purchase Header",
            Database::"Purchase Line":
                begin
                    PurchaseHeader.Get(SourceSubtype, SourceNo);
                    case SourceSubtype of
                        1:
                            Page.Run(PAGE::"Purchase Order", PurchaseHeader);
                        2:
                            Page.Run(PAGE::"Purchase Invoice", PurchaseHeader);
                        3:
                            Page.Run(PAGE::"Purchase Credit Memo", PurchaseHeader);
                        4:
                            Page.Run(PAGE::"Blanket Purchase Order", PurchaseHeader);
                        5:
                            Page.Run(PAGE::"Purchase Return Order", PurchaseHeader);
                    end;
                end;
            Database::"Purch. Rcpt. Line":
                begin
                    PurchRcptHeader.Get(SourceNo);
                    Page.Run(Page::"Posted Purchase Receipt", PurchRcptHeader);
                end;
            Database::"Purch. Cr. Memo Line":
                begin
                    PurchCrMemoHdr.Get(SourceNo);
                    Page.Run(Page::"Posted Purchase Credit Memo", PurchCrMemoHdr);
                end;
            Database::"Sales Shipment Line":
                begin
                    SalesShipmentHeader.Get(SourceNo);
                    Page.Run(Page::"Posted Sales Shipment", SalesShipmentHeader);
                end;
            Database::"Sales Cr.Memo Line":
                begin
                    SalesCrMemoHeader.Get(SourceNo);
                    Page.Run(Page::"Posted Sales Credit Memo", SalesCrMemoHeader);
                end;
            Database::"Warehouse Receipt Line":
                begin
                    WarehouseReceiptHeader.Get(SourceNo);
                    Page.Run(Page::"Warehouse Receipt", WarehouseReceiptHeader);
                end;
            Database::"Warehouse Shipment Line":
                begin
                    WarehouseShipmentHeader.Get(SourceNo);
                    Page.Run(Page::"Warehouse Shipment", WarehouseShipmentHeader);
                end;
            Database::"Posted Whse. Receipt Line":
                begin
                    PostedWhseReceiptHeader.Get(SourceNo);
                    Page.Run(Page::"Posted Whse. Receipt", PostedWhseReceiptHeader);
                end;
            Database::"Posted Whse. Shipment Line":
                begin
                    PostedWhseShipmentHeader.Get(SourceNo);
                    Page.Run(Page::"Posted Whse. Shipment", PostedWhseShipmentHeader);
                end;
            Database::"Return Receipt Line":
                begin
                    ReturnReceiptHeader.Get(SourceNo);
                    Page.Run(Page::"Posted Return Receipt", ReturnReceiptHeader);
                end;
            Database::"Return Shipment Line":
                begin
                    ReturnShipmentHeader.Get(SourceNo);
                    Page.Run(Page::"Posted Return Shipment", ReturnShipmentHeader);
                end;
            Database::"Transfer Line":
                begin
                    TransferHeader.Get(SourceNo);
                    Page.Run(Page::"Transfer Order", TransferHeader);
                end;
        end;
    end;


    var
        UnitLineLinkExistErr: Label 'Current document line has been already linked to a logistic unit(s).';
        TrackingQuantityErr: Label 'Document Line quantity (base) %1 is not equal to quantity (base) %2 by tracking entries. Create a tracking information for item %3', Comment = '%1 is a purchase line quantity, %2 is quantity by tracking lines, %3 is a number of item.';

        LineHasExpectedQtyZeroErr: Label 'The line has an expected quantity of zero and does not need to be applied.';
        TotalSelectedQtyErr: Label 'Total quantity of all selected logistic units lines must be equal %1', Comment = '%1 is a quantity of the logistic unit line';

        SystemErrorUnitLineErr: Label 'System Error. Unit line has a links on %1 quantity. Plase check logistic unit lines', Comment = '%1 is a quantity';
        SystemErrorDocumentLineErr: Label 'System Error. Document line has a links on %1 quantity. Plase check logistic unit lines', Comment = '%1 is a quantity';

        LinkExistErr: label 'Link already exist for %1 logistic unit.', Comment = '%1 is a logistic unit number';

        LogisticUnitModuleAccessErr: Label 'The user does not have access permission to the logistics units management system. Please inform the administrator.';



    [IntegrationEvent(false, false)]
    local procedure OnAfterFillSourceDocumentTable(var SourceDocumentLink: Record "TMAC Source Document Link"; SourceType: Integer; SourceDocumentType: Integer; SourceDocumentNo: Code[20]; SourceLineNo: Integer; OppositeSourceType: Integer; OppositeSourceSubType: Integer; Positive: Boolean)
    begin
    end;

}


