///Создание логических единиц из разных документов. учт и нет. 
codeunit 71629502 "TMAC Create Logistic Units"
{
    Subtype = Test;
    TestPermissions = Disabled;

    #region [Scenario] Создание логистической единицы из пейджа
    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('ArchiveConfirmation0')]
    procedure NEWLU_FROM_LUCARD()
    var
        Item: Record Item;
        Item2: Record Item;
        UnitCard: TestPage "TMAC Unit Card";
        Unit: Record "TMAC Unit";
        PostedUnit: Record "TMAC Posted Unit";
    begin
        Item := Framework.CreateSimpleItem();
        Item2 := Framework.CreateSimpleItem();

        //[Given] 
        UnitCard.OpenNew();
        UnitCard."Type Code".Activate();
        UnitCard."Type Code".Value('PAL.EUR');

        // 1 строка паллеты
        UnitCard.UnitLines.New();
        UnitCard.UnitLines.Type.Activate();
        UnitCard.UnitLines.Type.Value('Item');

        UnitCard.UnitLines."No.".Activate();
        UnitCard.UnitLines."No.".Value(Item."No.");

        UnitCard.UnitLines.Quantity.Activate();
        UnitCard.UnitLines.Quantity.Value('10');

        // 2 строка паллеты
        UnitCard.UnitLines.New();
        UnitCard.UnitLines.Type.Activate();
        UnitCard.UnitLines.Type.Value('Item');

        UnitCard.UnitLines."No.".Activate();
        UnitCard.UnitLines."No.".Value(Item2."No.");

        UnitCard.UnitLines.Quantity.Activate();
        UnitCard.UnitLines.Quantity.Value('20');

        UnitCard.Reusable.Activate();
        UnitCard.Reusable.SetValue(True);

        //[When] 
        UnitCard.ArchiveUnit.Invoke();  //УЧЕТ покупки

        //[Then]
        Unit.Get(UnitCard."No.".Value);

        PostedUnit.Reset();
        PostedUnit.SetRange("No.", Unit."No.");
        PostedUnit.FindFirst();

        UnitCard.Close();
    end;

    [ConfirmHandler]
    procedure ArchiveConfirmation0(Options: Text; var Select: Boolean)
    begin
        Select := true;
    end;
    #endregion

    #region [Scenario] PO > NEWLU
    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('NewLogisticUnitWizard,DrilldownUnitLineLinks,DrilldownUnitLineLinks2')]
    procedure NEWLU_FROM_PO()
    var
        Unit: Record "TMAC Unit";
        Item: Record Item;
        Location: Record Location;
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        UnitLine: Record "TMAC Unit Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        PurchaseOrder: TestPage "Purchase Order";
        UnitCard: TestPage "TMAC Unit Card";
    begin
        //[Given] 
        Framework.SetPurchaseModuleSetup();
        Location := Framework.CreateSimpleWarehouse();
        Location.Modify(true);
        PurchHeader := Framework.CreatePurchaseOrder();
        Item := Framework.CreateSimpleItem();

        LibraryPurchase.CreatePurchaseLine(PurchLine, PurchHeader, "Purchase Line Type"::Item, Item."No.", 10);

        PurchLine.Validate("Location Code", Location.Code);
        PurchLine.Modify(true);

        //[When] 
        PurchaseOrder.OpenEdit();
        PurchaseOrder.GoToRecord(PurchHeader);
        PurchaseOrder.Release.Invoke();
        PurchaseOrder."TMAC New Logistics Units".Invoke();
        PurchaseOrder.PurchLines.First();
        PurchaseOrder.PurchLines."TMAC Logistic Units".Drilldown();
        PurchaseOrder."TMAC Logistic Units List".Invoke(); //просмотр логистических единиц
        PurchaseOrder.Close();

        //[Then]
        // Проверяем созданную логистическую единица
        UnitLineLink.SetRange("Source Type", Database::"Purchase Line");
        UnitLineLink.SetRange("Source Subtype", PurchLine."Document Type".AsInteger());
        UnitLineLink.SetRange("Source ID", PurchLine."Document No.");
        UnitLineLink.SetRange("Source Ref. No.", PurchLine."Line No.");
        UnitLineLink.FindFirst();
        UnitLineLink.TestField(Quantity, 10);
        UnitLineLink.TestField("Quantity (Base)", 500);
        UnitLineLink.TestField(Positive, true);
        UnitLineLink.TestField("Qty. to Post", 0);
        UnitLineLink.TestField("Posted Quantity", 0);
        UnitLineLink.TestField("Posted", false);
        UnitLineLink.TestField("Calculation", true);
        UnitLineLink.TestField("Unit of Measure Code", Item."Purch. Unit of Measure");
        UnitLineLink.TestField("Unit No.");
        UnitLineLink.TestField("Unit Line No.");

        //Удаляем созданную паллету
        Unit.Get(CreatedUnitNo);
        Unit.Testfield("Type Code", 'PAL.EUR');
        Unit.Delete(true);

        UnitLine.Reset();
        UnitLine.Setrange("Unit No.", CreatedUnitNo);
        if not UnitLine.IsEmpty() then
            error('Must be no line in unit line.');

        UnitLineLink.Reset();
        UnitLineLink.Setrange("Unit No.", CreatedUnitNo);
        if not UnitLineLink.IsEmpty() then
            error('Must be no line in unit line.');
    end;
    #endregion

    #region [Scenario] PO > POST > PRCT > NEWLU 
    var
        PostedRcptNo: Code[20];

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('NewLogisticUnitWizard,PostConfirmation,DrilldownUnitLineLinks,DrilldownUnitLineLinks2')]
    procedure NEWLU_FROM_POSTED_PURCH_PRCT()
    var
        Unit: Record "TMAC Unit";
        Item: Record Item;
        Location: Record Location;
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
        PurchLine1: Record "Purchase Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        PurchRcptHeader: record "Purch. Rcpt. Header";
        PurchaseOrder: TestPage "Purchase Order";
        PostedPurchaseReceipt: TestPage "Posted Purchase Receipt";
        SalesOrder: TestPage "Sales Order";
        CurrentUnitNo: Code[20];
    begin
        //[Given] 
        Framework.SetPurchaseModuleSetup();
        Location := Framework.CreateSimpleWarehouse();
        PurchHeader := Framework.CreatePurchaseOrder();
        Item := Framework.CreateSimpleItem();
        LibraryPurchase.CreatePurchaseLine(PurchLine1, PurchHeader, "Purchase Line Type"::Item, Item."No.", 10);
        PurchLine1.Validate("Location Code", Location.Code);
        PurchLine1.Modify(true);

        //[WHEN]
        PurchaseOrder.OpenEdit();
        PurchaseOrder.GoToRecord(PurchHeader);
        PurchaseOrder.Release.Invoke();
        PurchaseOrder.Post.Invoke();

        PurchRcptHeader.SetRange("Buy-from Vendor No.", PurchHeader."Buy-from Vendor No.");
        PurchRcptHeader.FindFirst();

        PostedPurchaseReceipt.OpenView();
        PostedPurchaseReceipt.GoToRecord(PurchRcptHeader);
        PostedPurchaseReceipt."TMAC New Logistic Units".Invoke();
        PostedPurchaseReceipt.PurchReceiptLines.First();
        PostedPurchaseReceipt.PurchReceiptLines."TMAC Logistic Units".Drilldown();
        PostedPurchaseReceipt."TMAC Logistic Units List".Invoke(); //просмотр логистических единиц

        //[THEN]
        UnitLineLink.Reset();
        UnitLineLink.SetRange("Source Type", Database::"Purch. Rcpt. Line");
        UnitLineLink.SetRange("Source Subtype", 0);
        UnitLineLink.SetRange("Source ID", PurchRcptHeader."No.");
        UnitLineLink.FindFirst();
        CurrentUnitNo := UnitLineLink."Unit No.";
        UnitLineLink.TestField(Quantity, 10);
        UnitLineLink.TestField("Quantity (Base)", 500);
        UnitLineLink.TestField(Positive, true);
        UnitLineLink.TestField("Qty. to Post", 0);
        UnitLineLink.TestField("Posted Quantity", 0);
        UnitLineLink.TestField("Posted", false);
        UnitLineLink.TestField("Calculation", true);
        UnitLineLink.TestField("Unit of Measure Code", Item."Purch. Unit of Measure");
        UnitLineLink.TestField("Unit No.");
        UnitLineLink.TestField("Unit Line No.");
        Unit.Get(UnitLineLink."Unit No.");
        Unit.Testfield("Type Code", 'PAL.EUR');

        //на нучт. покупку не должно быть связи
        UnitLineLink.Reset();
        UnitLineLink.SetRange("Unit No.", CurrentUnitNo);
        UnitLineLink.SetRange("Source Type", Database::"Purchase Line");
        UnitLineLink.SetRange("Source Subtype", PurchLine1."Document Type".AsInteger());
        UnitLineLink.SetRange("Source ID", PurchLine1."Document No.");
        if UnitLineLink.FindFirst() then
            Error('Link on unposted document prohibited.');
    end;

    [PageHandler]
    procedure PurchaseRcptHandler(var PostedPurchaseReceipt: TestPage "Posted Purchase Receipt")
    begin
        PostedPurchaseReceipt."TMAC New Logistic Units".Invoke();
        PostedRcptNo := PostedPurchaseReceipt."No.".Value();
    end;

    #endregion

    #region [Scenario] PO > WHS RCPT > POST > POSTED WHS PRC > NEWLU 
    var
        PostedWhsRcptNo: Code[20];

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('NewLogisticUnitWizard,Message,WarehouseRcptHandler,ConfirmPostWarehousePurchaseReceipt,DrilldownUnitLineLinks,DrilldownUnitLineLinks2')]
    procedure NEWLU_FROM_POSTED_WAREHOUSE_RCT()
    var
        Unit: Record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
        Item: Record Item;
        Location: Record Location;
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
        PurchLine1: Record "Purchase Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        WarehouseReceiptHeader: Record "Warehouse Receipt Header";
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
        PostedWarehouseHeader: Record "Posted Whse. Receipt Header";
        PostedWarehouseLine: Record "Posted Whse. Receipt Line";
        WarehouseEmployee: Record "Warehouse Employee";
        PurchRcptHeader: record "Purch. Rcpt. Header";
        PurchaseOrder: TestPage "Purchase Order";
        PostedPurch: TestPage "Posted Purchase Receipt";
        WarehouseReceipt: TestPage "Warehouse Receipt";
        PostedWarehouseReceipt: TestPage "Posted Whse. Receipt";
        SalesOrder: TestPage "Sales Order";
        Units: List of [Code[20]];
        CurrentUnitNo: Code[20];
    begin
        //[Given] 
        PostedWhsRcptNo := '';
        Framework.SetWarehouseSetup();
        Framework.SetPurchaseModuleSetup();
        Location := Framework.CreateSimpleWarehouse();
        Location.Validate("Require Receive", true);
        Location.Modify(true);

        WarehouseEmployee.Init();
        WarehouseEmployee."User ID" := UserId();
        WarehouseEmployee."Location Code" := Location.Code;
        WarehouseEmployee.Insert(true);

        PurchHeader := Framework.CreatePurchaseOrder();
        Item := Framework.CreateSimpleItem();
        LibraryPurchase.CreatePurchaseLine(PurchLine1, PurchHeader, "Purchase Line Type"::Item, Item."No.", 10);
        PurchLine1.Validate("Location Code", Location.Code);
        PurchLine1.Modify(true);

        //[WHEN]
        PurchaseOrder.OpenEdit();
        PurchaseOrder.GoToRecord(PurchHeader);
        PurchaseOrder.Release.Invoke();
        PurchaseOrder."Create &Whse. Receipt".Invoke();

        PostedWarehouseHeader.Reset();
        PostedWarehouseHeader.Setrange("Whse. Receipt No.", PostedWhsRcptNo);
        PostedWarehouseHeader.FindFirst();

        PostedWarehouseReceipt.OpenView();
        PostedWarehouseReceipt.GoToRecord(PostedWarehouseHeader);
        PostedWarehouseReceipt."TMAC New Logistics Units".Invoke();
        PostedWarehouseReceipt.PostedWhseRcptLines.First();
        PostedWarehouseReceipt.PostedWhseRcptLines."TMAC Logistic Units".Drilldown();
        PostedWarehouseReceipt."TMAC Logistic Units List".Invoke(); //просмотр логистических единиц\

        //[THEN]
        UnitLineLink.Reset();
        UnitLineLink.SetRange("Source Type", Database::"Posted Whse. Receipt Line");
        UnitLineLink.SetRange("Source Subtype", 0);
        UnitLineLink.SetRange("Source ID", PostedWarehouseHeader."No.");
        UnitLineLink.FindFirst();
        CurrentUnitNo := UnitLineLink."Unit No.";
        UnitLineLink.TestField(Quantity, 10);
        UnitLineLink.TestField("Quantity (Base)", 500);
        UnitLineLink.TestField(Positive, true);
        UnitLineLink.TestField("Qty. to Post", 0);
        UnitLineLink.TestField("Posted Quantity", 0);
        UnitLineLink.TestField("Posted", false);
        UnitLineLink.TestField("Calculation", false);
        UnitLineLink.TestField("Unit of Measure Code", Item."Purch. Unit of Measure");
        UnitLineLink.TestField("Unit No.");
        UnitLineLink.TestField("Unit Line No.");
        Unit.Get(UnitLineLink."Unit No.");
        Unit.Testfield("Type Code", 'PAL.EUR');

        //на нучт. покупку не должно быть связи
        UnitLineLink.Reset();
        UnitLineLink.SetRange("Unit No.", CurrentUnitNo);
        UnitLineLink.SetRange("Source Type", Database::"Purchase Line");
        UnitLineLink.SetRange("Source Subtype", PurchLine1."Document Type".AsInteger());
        UnitLineLink.SetRange("Source ID", PurchLine1."Document No.");
        if UnitLineLink.FindFirst() then
            Error('Link on unposted document prohibited.');
    end;

    [PageHandler]
    procedure WarehouseRcptHandler(var WarehouseReceipt: TestPage "Warehouse Receipt")
    begin
        WarehouseReceipt."No.".Activate();
        PostedWhsRcptNo := WarehouseReceipt."No.".Value();
        WarehouseReceipt."Post Receipt".Invoke();
    end;
    #endregion

    #region [Scenario] SO > NEWLU 
    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('NewLogisticUnitWizard,DrilldownUnitLineLinks,DrilldownUnitLineLinks2')]
    procedure NEWLU_FROM_SO()
    var
        Unit: record "TMAC Unit";
        UnitLineLink: Record "TMAC Unit Line Link";
        PostedUnit: record "TMAC Posted Unit";
        PostedUnitLineLink: Record "TMAC Posted Unit Line Link";
        Item: Record Item;
        Location: Record Location;
        SalesHeader: Record "Sales Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesLine: Record "Sales Line";
        SalesOrder: TestPage "Sales Order";
        UnitCard: TestPage "TMAC Unit Card";
        UnitNo: Code[20];
    begin
        //[Given] 
        Framework.SetSalesModuleSetup();
        Location := Framework.CreateSimpleWarehouse();
        SalesHeader := Framework.CreateSalesOrder();
        Item := Framework.CreateSimpleItem();
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item, Item."No.", 10);
        SalesLine.Validate("Location Code", Location.Code);
        SalesLine.Modify(true);

        //[When] 
        SalesOrder.OpenEdit();
        SalesOrder.GoToRecord(SalesHeader);
        SalesOrder.Release.Invoke();
        SalesOrder."TMAC New Logistics Units".Invoke();
        SalesOrder.SalesLines.First();
        SalesOrder.SalesLines."TMAC Logistic Units".Drilldown();
        SalesOrder."TMAC Logistic Units List".Invoke(); //просмотр логистических единиц

        //[Then]
        // Проверяем созданную логистическую единица
        UnitLineLink.SetRange("Source Type", Database::"Sales Line");
        UnitLineLink.SetRange("Source Subtype", SalesLine."Document Type".AsInteger());
        UnitLineLink.SetRange("Source ID", SalesLine."Document No.");
        UnitLineLink.SetRange("Source Ref. No.", SalesLine."Line No.");
        UnitLineLink.FindFirst();
        UnitLineLink.TestField(Quantity, -10);
        UnitLineLink.TestField("Quantity (Base)", -500);
        UnitLineLink.TestField(Positive, false);
        UnitLineLink.TestField("Qty. to Post", 0);
        UnitLineLink.TestField("Posted Quantity", 0);
        UnitLineLink.TestField("Posted", false);
        UnitLineLink.TestField("Calculation", true);
        UnitLineLink.TestField("Unit of Measure Code", Item."Sales Unit of Measure");
        UnitLineLink.TestField("Unit No.");
        UnitLineLink.TestField("Unit Line No.");
        Unit.Get(UnitLineLink."Unit No.");
        Unit.Testfield("Type Code", 'PAL.EUR');
    end;
    #endregion

    #region [Scenario] SO > POST > SALESSHIPMENT > NEWLU 
    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('NewLogisticUnitWizard,PostConfirmation,DrilldownUnitLineLinks,DrilldownUnitLineLinks2')]
    procedure NEWLU_FROM_POSTED_SALESSHIPMENT()
    var
        Unit: record "TMAC Unit";
        UnitLineLink: Record "TMAC Unit Line Link";
        PostedUnit: record "TMAC Posted Unit";
        PostedUnitLineLink: Record "TMAC Posted Unit Line Link";
        Item: Record Item;
        Location: Record Location;
        SalesHeader: Record "Sales Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipment: TestPage "Posted Sales Shipment";
        SalesLine: Record "Sales Line";
        SalesOrder: TestPage "Sales Order";
        UnitCard: TestPage "TMAC Unit Card";
        CurrentUnitNo: Code[20];
    begin
        //[Given] 
        Framework.SetSalesModuleSetup();
        Location := Framework.CreateSimpleWarehouse();
        SalesHeader := Framework.CreateSalesOrder();
        Item := Framework.CreateSimpleItem();
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item, Item."No.", 10);
        SalesLine.Validate("Location Code", Location.Code);
        SalesLine.Modify(true);

        //[When] 
        SalesOrder.OpenEdit();
        SalesOrder.GoToRecord(SalesHeader);
        SalesOrder.Release.Invoke();
        SalesOrder.Post.Invoke();

        //[WHEN]
        SalesShipmentHeader.SetRange("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
        SalesShipmentHeader.FindFirst();

        SalesShipment.OpenView();
        SalesShipment.GoToRecord(SalesShipmentHeader);
        SalesShipment."TMAC New Logistics Units".Invoke();
        SalesShipment.SalesShipmLines.First();
        SalesShipment.SalesShipmLines."TMAC Logistic Units".Drilldown();
        SalesShipment."TMAC Logistic Units List".Invoke(); //просмотр логистических единиц

        //[THEN]
        UnitLineLink.Reset();
        UnitLineLink.SetRange("Source Type", Database::"Sales Shipment Line");
        UnitLineLink.SetRange("Source Subtype", 0);
        UnitLineLink.SetRange("Source ID", SalesShipmentHeader."No.");
        UnitLineLink.FindFirst();
        CurrentUnitNo := UnitLineLink."Unit No.";
        UnitLineLink.TestField(Quantity, -10);
        UnitLineLink.TestField("Quantity (Base)", -500);
        UnitLineLink.TestField(Positive, false);
        UnitLineLink.TestField("Qty. to Post", 0);
        UnitLineLink.TestField("Posted Quantity", 0);
        UnitLineLink.TestField("Posted", false);
        UnitLineLink.TestField("Calculation", true);
        UnitLineLink.TestField("Unit of Measure Code", Item."Purch. Unit of Measure");
        UnitLineLink.TestField("Unit No.");
        UnitLineLink.TestField("Unit Line No.");
        Unit.Get(UnitLineLink."Unit No.");
        Unit.Testfield("Type Code", 'PAL.EUR');

        //на нучт. покупку не должно быть связи
        UnitLineLink.Reset();
        UnitLineLink.SetRange("Unit No.", CurrentUnitNo);
        UnitLineLink.SetRange("Source Type", Database::"Sales Line");
        UnitLineLink.SetRange("Source Subtype", SalesLine."Document Type".AsInteger());
        UnitLineLink.SetRange("Source ID", SalesLine."Document No.");
        if UnitLineLink.FindFirst() then
            Error('Link on unposted document prohibited.');
    end;
    #endregion

    #region [Scenario] SO > WHS SHIPMENT > POST > POSTED WHS PRC > NEWLU 
    var
        PostedShipmentNo: Code[20];

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('NewLogisticUnitWizard,WarehouseShipmentHandler,PostConfirmation,Message,DrilldownUnitLineLinks,DrilldownUnitLineLinks2')]
    procedure NEWLU_FROM_POSTED_WAREHOUSE_SHIPMENT()
    var
        Unit: record "TMAC Unit";
        UnitLineLink: Record "TMAC Unit Line Link";
        PostedUnit: record "TMAC Posted Unit";
        PostedUnitLineLink: Record "TMAC Posted Unit Line Link";
        Item: Record Item;
        Location: Record Location;
        SalesHeader: Record "Sales Header";
        WarehouseEmployee: Record "Warehouse Employee";
        PostedeWarehouseShipment: Record "Posted Whse. Shipment Header";
        SalesLine: Record "Sales Line";
        SalesOrder: TestPage "Sales Order";
        PostedWarehouseShipment: Testpage "Posted Whse. Shipment";
        UnitCard: TestPage "TMAC Unit Card";
        CurrentUnitNo: Code[20];
    begin
        //[Given] 
        Framework.SetSalesModuleSetup();
        Framework.SetWarehouseSetup();
        Location := Framework.CreateSimpleWarehouse();
        Location.Validate("Require Shipment", true);
        Location.Modify(true);

        WarehouseEmployee.Init();
        WarehouseEmployee."User ID" := UserId();
        WarehouseEmployee."Location Code" := Location.Code;
        WarehouseEmployee.Insert(true);

        SalesHeader := Framework.CreateSalesOrder();
        Item := Framework.CreateSimpleItem();
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item, Item."No.", 10);
        SalesLine.Validate("Location Code", Location.Code);
        SalesLine.Modify(true);

        //[WHEN]
        SalesOrder.OpenEdit();
        SalesOrder.GoToRecord(SalesHeader);
        SalesOrder.Release.Invoke();
        SalesOrder."Create &Warehouse Shipment".Invoke();

        PostedeWarehouseShipment.Reset();
        PostedeWarehouseShipment.Setrange("Whse. Shipment No.", PostedShipmentNo);
        PostedeWarehouseShipment.FindFirst();

        PostedWarehouseShipment.OpenView();
        PostedWarehouseShipment.GoToRecord(PostedeWarehouseShipment);
        PostedWarehouseShipment."TMAC New Logistics Units".Invoke();
        PostedWarehouseShipment.WhseShptLines.First();
        PostedWarehouseShipment.WhseShptLines."TMAC Logistic Units".Drilldown();
        PostedWarehouseShipment."TMAC Logistic Units List".Invoke(); //просмотр логистических единиц

        //[THEN]
        UnitLineLink.Reset();
        UnitLineLink.SetRange("Source Type", Database::"Posted Whse. Shipment Line");
        UnitLineLink.SetRange("Source Subtype", 0);
        UnitLineLink.SetRange("Source ID", PostedeWarehouseShipment."No.");
        UnitLineLink.FindFirst();
        CurrentUnitNo := UnitLineLink."Unit No.";
        UnitLineLink.TestField(Quantity, -10);
        UnitLineLink.TestField("Quantity (Base)", -500);
        UnitLineLink.TestField(Positive, false);
        UnitLineLink.TestField("Qty. to Post", 0);
        UnitLineLink.TestField("Posted Quantity", 0);
        UnitLineLink.TestField("Posted", false);
        UnitLineLink.TestField("Calculation", false);
        UnitLineLink.TestField("Unit of Measure Code", Item."Purch. Unit of Measure");
        UnitLineLink.TestField("Unit No.");
        UnitLineLink.TestField("Unit Line No.");
        Unit.Get(UnitLineLink."Unit No.");
        Unit.Testfield("Type Code", 'PAL.EUR');

        //на нучт. покупку не должно быть связи
        UnitLineLink.Reset();
        UnitLineLink.SetRange("Unit No.", CurrentUnitNo);
        UnitLineLink.SetRange("Source Type", Database::"Sales Line");
        UnitLineLink.SetRange("Source Subtype", SalesLine."Document Type".AsInteger());
        UnitLineLink.SetRange("Source ID", SalesLine."Document No.");
        if UnitLineLink.FindFirst() then
            Error('Link on unposted document prohibited.');
    end;

    [PageHandler]
    procedure WarehouseShipmentHandler(var WarehouseShipment: TestPage "Warehouse Shipment")
    begin
        WarehouseShipment."No.".Activate();
        PostedShipmentNo := WarehouseShipment."No.".Value();
        WarehouseShipment."Autofill Qty. to Ship".Invoke();
        WarehouseShipment."P&ost Shipment".Invoke();
    end;
    #endregion

    #region [Scenario] SRO > NEWLU    (Sales Return)
    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('NewLogisticUnitWizard,DrilldownUnitLineLinks,DrilldownUnitLineLinks2')]
    procedure NEWLU_FROM_SRO()
    var
        Unit: record "TMAC Unit";
        UnitLineLink: Record "TMAC Unit Line Link";
        PostedUnit: record "TMAC Posted Unit";
        PostedUnitLineLink: Record "TMAC Posted Unit Line Link";
        Item: Record Item;
        Location: Record Location;
        SalesHeader: Record "Sales Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesLine: Record "Sales Line";
        SalesReturnOrder: TestPage "Sales Return Order";
        UnitCard: TestPage "TMAC Unit Card";
        UnitNo: Code[20];
    begin
        //[Given] 
        Framework.SetSalesModuleSetup();
        Location := Framework.CreateSimpleWarehouse();
        SalesHeader := Framework.CreateSalesReturnOrder();
        Item := Framework.CreateSimpleItem();

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item, Item."No.", 10);
        SalesLine.Validate("Location Code", Location.Code);
        SalesLine.Modify(true);

        //[When] 
        SalesReturnOrder.OpenEdit();
        SalesReturnOrder.GoToRecord(SalesHeader);
        SalesReturnOrder.Release.Invoke();
        SalesReturnOrder."TMAC New Logistics Units".Invoke();
        SalesReturnOrder.SalesLines.First();
        SalesReturnOrder.SalesLines."TMAC Logistic Units".Drilldown();
        SalesReturnOrder."TMAC Logistic Units List".Invoke(); //просмотр логистических единиц

        //[Then]
        // Проверяем созданную логистическую единица
        UnitLineLink.SetRange("Source Type", Database::"Sales Line");
        UnitLineLink.SetRange("Source Subtype", SalesLine."Document Type".AsInteger());
        UnitLineLink.SetRange("Source ID", SalesLine."Document No.");
        UnitLineLink.SetRange("Source Ref. No.", SalesLine."Line No.");
        UnitLineLink.FindFirst();
        UnitLineLink.TestField(Quantity, 10);
        UnitLineLink.TestField("Quantity (Base)", 500);
        UnitLineLink.TestField(Positive, true);
        UnitLineLink.TestField("Qty. to Post", 0);
        UnitLineLink.TestField("Posted Quantity", 0);
        UnitLineLink.TestField("Posted", false);
        UnitLineLink.TestField("Calculation", true);
        UnitLineLink.TestField("Unit of Measure Code", Item."Sales Unit of Measure");
        UnitLineLink.TestField("Unit No.");
        UnitLineLink.TestField("Unit Line No.");
        Unit.Get(UnitLineLink."Unit No.");
        Unit.Testfield("Type Code", 'PAL.EUR');
    end;
    #endregion

    #region [Scenario] SRO > POST > SALESSHIPMENT > NEWLU 
    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('NewLogisticUnitWizard,PostConfirmation,DrilldownUnitLineLinks,DrilldownUnitLineLinks2')]
    procedure NEWLU_FROM_POSTED_SALESRETURN()
    var
        Unit: record "TMAC Unit";
        UnitLineLink: Record "TMAC Unit Line Link";
        PostedUnit: record "TMAC Posted Unit";
        PostedUnitLineLink: Record "TMAC Posted Unit Line Link";
        Item: Record Item;
        Location: Record Location;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ReturnReceipHeader: Record "Return Receipt Header";
        ReturnReceiptLine: Record "Return Receipt Line";
        ReturnReceipt: TestPage "Posted Return Receipt";
        SalesReturnOrder: TestPage "Sales Return Order";
        CurrentUnitNo: Code[20];
    begin
        //[Given] 
        Framework.SetSalesModuleSetup();
        Location := Framework.CreateSimpleWarehouse();
        SalesHeader := Framework.CreateSalesReturnOrder();
        Item := Framework.CreateSimpleItem();
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item, Item."No.", 10);
        SalesLine.Validate("Location Code", Location.Code);
        SalesLine.Modify(true);

        //[When] 
        SalesReturnOrder.OpenEdit();
        SalesReturnOrder.GoToRecord(SalesHeader);
        SalesReturnOrder.Release.Invoke();
        SalesReturnOrder.Post.Invoke();

        //[WHEN]
        ReturnReceipHeader.SetRange("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
        ReturnReceipHeader.FindFirst();

        ReturnReceipt.OpenView();
        ReturnReceipt.GoToRecord(ReturnReceipHeader);
        ReturnReceipt."TMAC New Logistics Units".Invoke();
        // ReturnReceipt.ReturnRcptLines.First();
        // ReturnReceipt.ReturnRcptLines.t"TMAC No Of Logistic Units".Drilldown();
        ReturnReceipt."TMAC Logistic Units List".Invoke(); //просмотр логистических единиц

        //[THEN]
        UnitLineLink.Reset();
        UnitLineLink.SetRange("Source Type", Database::"Return Receipt Line");
        UnitLineLink.SetRange("Source Subtype", 0);
        UnitLineLink.SetRange("Source ID", ReturnReceipHeader."No.");
        UnitLineLink.FindFirst();
        CurrentUnitNo := UnitLineLink."Unit No.";
        UnitLineLink.TestField(Quantity, 10);
        UnitLineLink.TestField("Quantity (Base)", 500);
        UnitLineLink.TestField(Positive, true);
        UnitLineLink.TestField("Qty. to Post", 0);
        UnitLineLink.TestField("Posted Quantity", 0);
        UnitLineLink.TestField("Posted", false);
        UnitLineLink.TestField("Calculation", true);
        UnitLineLink.TestField("Unit of Measure Code", Item."Purch. Unit of Measure");
        UnitLineLink.TestField("Unit No.");
        UnitLineLink.TestField("Unit Line No.");
        Unit.Get(UnitLineLink."Unit No.");
        Unit.Testfield("Type Code", 'PAL.EUR');

        //на нучт. покупку не должно быть связи
        UnitLineLink.Reset();
        UnitLineLink.SetRange("Unit No.", CurrentUnitNo);
        UnitLineLink.SetRange("Source Type", Database::"Sales Line");
        UnitLineLink.SetRange("Source Subtype", SalesLine."Document Type".AsInteger());
        UnitLineLink.SetRange("Source ID", SalesLine."Document No.");
        if UnitLineLink.FindFirst() then
            Error('Link on unposted document prohibited.');
    end;
    #endregion

    #region [Scenario] LOT - PO > NEWLU - товар с трассировкой по лотам
    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('NewLogisticUnitWizard,ItemTrackingLinesHandler,DrilldownUnitLineLinks,DrilldownUnitLineLinks2')]
    procedure TRK_NEWLU_FROM_PO()
    var
        Unit: Record "TMAC Unit";
        Item: Record Item;
        Location: Record Location;
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        PurchaseOrder: TestPage "Purchase Order";
    begin
        //[Given] 
        Framework.SetPurchaseModuleSetup();
        Location := Framework.CreateSimpleWarehouse();
        Location.Modify(true);
        PurchHeader := Framework.CreatePurchaseOrder();
        Item := Framework.CreateSimpleItem();
        Item.Validate("Item Tracking Code", 'LOTALL');
        Item.Modify(true);

        LibraryPurchase.CreatePurchaseLine(PurchLine, PurchHeader, "Purchase Line Type"::Item, Item."No.", 10);

        PurchLine.Validate("Location Code", Location.Code);
        PurchLine.Modify(true);

        //[When] 
        PurchaseOrder.OpenEdit();
        PurchaseOrder.GoToRecord(PurchHeader);
        PurchaseOrder.Release.Invoke();
        PurchaseOrder.PurchLines."Item Tracking Lines".Invoke();  //навершиваем трасисировку
        PurchaseOrder."TMAC New Logistics Units".Invoke();
        PurchaseOrder.PurchLines.First();
        PurchaseOrder.PurchLines."TMAC Logistic Units".Drilldown();
        PurchaseOrder."TMAC Logistic Units List".Invoke(); //просмотр логистических единиц

        PurchaseOrder.Close();

        //[Then]
        // Проверяем созданную логистическую единицу
        UnitLineLink.SetRange("Source Type", Database::"Purchase Line");
        UnitLineLink.SetRange("Source Subtype", PurchLine."Document Type".AsInteger());
        UnitLineLink.SetRange("Source ID", PurchLine."Document No.");
        UnitLineLink.SetRange("Source Ref. No.", PurchLine."Line No.");
        UnitLineLink.CalcSums(Quantity);
        if UnitLineLink.Quantity <> 10 then
            error('Все коль-во должно быть распределено.');
        if UnitLineLink.Count() <> 5 then
            error('Количество линков должно быть равно 5');
        if UnitLineLink.FindSet() then
            repeat
                UnitLineLink.TestField(Quantity, 2);
                UnitLineLink.TestField("Unit of Measure Code", Item."Purch. Unit of Measure");
                UnitLineLink.TestField("Unit No.");
                UnitLineLink.TestField("Unit Line No.");
                Unit.Get(UnitLineLink."Unit No.");
                Unit.Testfield("Type Code", 'PAL.EUR');
            until UnitLineLink.Next() = 0;
    end;
    #endregion

    #region [Scenario] LOT - SO > NEWLU - товар с трассировкой по лотам
    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('NewLogisticUnitWizard,ItemTrackingLinesHandler,NEWLU_FROM_SO_TKR_Confirm,DrilldownUnitLineLinks,DrilldownUnitLineLinks2')]
    procedure TKR_NEWLU_FROM_SO()
    var
        Unit: record "TMAC Unit";
        UnitLineLink: Record "TMAC Unit Line Link";
        PostedUnit: record "TMAC Posted Unit";
        PostedUnitLineLink: Record "TMAC Posted Unit Line Link";
        Item: Record Item;
        Location: Record Location;
        SalesHeader: Record "Sales Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesLine: Record "Sales Line";
        SalesOrder: TestPage "Sales Order";
        UnitCard: TestPage "TMAC Unit Card";
        UnitNo: Code[20];
    begin
        //[Given] 
        Framework.SetSalesModuleSetup();
        Location := Framework.CreateSimpleWarehouse();
        SalesHeader := Framework.CreateSalesOrder();
        Item := Framework.CreateSimpleItem();
        Item.Validate("Item Tracking Code", 'LOTALL');
        Item.Modify(true);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item, Item."No.", 10);
        SalesLine.Validate("Location Code", Location.Code);
        SalesLine.Modify(true);

        //[When] 
        SalesOrder.OpenEdit();
        SalesOrder.GoToRecord(SalesHeader);
        SalesOrder.Release.Invoke();
        SalesOrder.SalesLines.ItemTrackingLines.Invoke();  //навершиваем трасисировку      
        SalesOrder."TMAC New Logistics Units".Invoke();
        SalesOrder.SalesLines.First();
        SalesOrder.SalesLines."TMAC Logistic Units".Drilldown();
        SalesOrder."TMAC Logistic Units List".Invoke(); //просмотр логистических единиц

        SalesOrder.Close();

        //[Then]
        // Проверяем созданную логистическую единица
        UnitLineLink.SetRange("Source Type", Database::"Sales Line");
        UnitLineLink.SetRange("Source Subtype", SalesLine."Document Type".AsInteger());
        UnitLineLink.SetRange("Source ID", SalesLine."Document No.");
        UnitLineLink.SetRange("Source Ref. No.", SalesLine."Line No.");
        UnitLineLink.CalcSums(Quantity);
        if UnitLineLink.Quantity <> -10 then
            error('Все коль-во должно быть распределено.');
        if UnitLineLink.Count() <> 5 then
            error('Количество линков должно быть равно 5');
        if UnitLineLink.FindSet() then
            repeat
                UnitLineLink.TestField(Quantity, -2);
                UnitLineLink.TestField("Unit of Measure Code", Item."Purch. Unit of Measure");
                UnitLineLink.TestField("Unit No.");
                UnitLineLink.TestField("Unit Line No.");
                Unit.Get(UnitLineLink."Unit No.");
                Unit.Testfield("Type Code", 'PAL.EUR');
            until UnitLineLink.Next() = 0;
    end;

    [ConfirmHandler]
    procedure NEWLU_FROM_SO_TKR_Confirm(Options: Text; var Select: Boolean)
    begin
        Select := true;
    end;

    #endregion

    #region [Scenario] LOT - PO > POST > PRCT > NEWLU  - товар с трассировкой по лотам
    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('NewLogisticUnitWizard,PostConfirmation,ItemTrackingLinesHandler,DrilldownUnitLineLinks,DrilldownUnitLineLinks2')]
    procedure TRK_NEWLU_FROM_POSTED_PURCH_PRCT()
    var
        Unit: Record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
        Item: Record Item;
        Location: Record Location;
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
        PurchLine1: Record "Purchase Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        PurchRcptHeader: record "Purch. Rcpt. Header";
        PurchaseOrder: TestPage "Purchase Order";
        PostedPurchaseReceipt: TestPage "Posted Purchase Receipt";
        SalesOrder: TestPage "Sales Order";
        Units: List of [Code[20]];
        CurrentUnitNo: Code[20];
    begin
        //[Given] 
        Framework.SetPurchaseModuleSetup();
        Location := Framework.CreateSimpleWarehouse();
        PurchHeader := Framework.CreatePurchaseOrder();

        Item := Framework.CreateSimpleItem();
        Item.Validate("Item Tracking Code", 'LOTALL');
        Item.Modify(true);

        LibraryPurchase.CreatePurchaseLine(PurchLine1, PurchHeader, "Purchase Line Type"::Item, Item."No.", 10);
        PurchLine1.Validate("Location Code", Location.Code);
        PurchLine1.Modify(true);

        //[WHEN]
        PurchaseOrder.OpenEdit();
        PurchaseOrder.GoToRecord(PurchHeader);
        PurchaseOrder.Release.Invoke();
        PurchaseOrder.PurchLines."Item Tracking Lines".Invoke();  //навершиваем трасисировку
        PurchaseOrder.Post.Invoke();

        PurchRcptHeader.SetRange("Buy-from Vendor No.", PurchHeader."Buy-from Vendor No.");
        PurchRcptHeader.FindLast();

        PostedPurchaseReceipt.OpenView();
        PostedPurchaseReceipt.GoToRecord(PurchRcptHeader);
        PostedPurchaseReceipt."TMAC New Logistic Units".Invoke();
        PostedPurchaseReceipt.PurchReceiptLines.First();
        PostedPurchaseReceipt.PurchReceiptLines."TMAC Logistic Units".Drilldown();
        PostedPurchaseReceipt."TMAC Logistic Units List".Invoke(); //просмотр логистических единиц

        //[THEN]
        // Проверяем созданную логистическую единицу
        UnitLineLink.Reset();
        UnitLineLink.SetRange("Source Type", Database::"Purch. Rcpt. Line");
        UnitLineLink.SetRange("Source Subtype", 0);
        UnitLineLink.SetRange("Source ID", PurchRcptHeader."No.");
        UnitLineLink.CalcSums(Quantity);
        if UnitLineLink.Quantity <> 10 then
            error('Все коль-во должно быть распределено.');
        if UnitLineLink.Count() <> 5 then
            error('Количество линков должно быть равно 5');
        if UnitLineLink.FindSet() then
            repeat
                UnitLineLink.TestField(Quantity, 2);
                UnitLineLink.TestField("Unit of Measure Code", Item."Purch. Unit of Measure");
                UnitLineLink.TestField("Unit No.");
                UnitLineLink.TestField("Unit Line No.");
                Unit.Get(UnitLineLink."Unit No.");
                Unit.Testfield("Type Code", 'PAL.EUR');
            until UnitLineLink.Next() = 0;
    end;
    #endregion


    [ModalPageHandler]
    internal procedure NewLogisticUnitWizard(var NewLogisticUnitWizard: TestPage "TMAC New Logistic Unit Wizard")
    var
        Qty: decimal;
    begin
        //переходим на вторую страницу
        NewLogisticUnitWizard.ActionNext.Invoke();

        //вторая
        if NewLogisticUnitWizard.DocumentLines.First() then
            repeat
                Qty := NewLogisticUnitWizard.DocumentLines.Quantity.AsDecimal();
                NewLogisticUnitWizard.DocumentLines."Selected Quantity".SetValue(Qty);
            until NewLogisticUnitWizard.DocumentLines.Next() = false;
        //NewLogisticUnitWizard.DocumentLines.UpdateLinesUI.Invoke(); //Set Selected Qty
        NewLogisticUnitWizard.ActionNext.Invoke();

        //третья - выбор типа
        NewLogisticUnitWizard.UnitTypeCode.Activate();
        NewLogisticUnitWizard.UnitTypeCode.Value('PAL.EUR');
        NewLogisticUnitWizard.ActionCreate.Invoke();

        CreatedUnitNo := NewLogisticUnitWizard.CreatedUnitNoUI.Value();

        //Закрываем мастер
        NewLogisticUnitWizard.ActionFinish.Invoke();
    end;

    [ModalPageHandler]
    internal procedure ItemTrackingLinesHandler(var ItemTrackingLines: TestPage "Item Tracking Lines")
    var
        i: Integer;
    begin
        for i := 1 to 5 do begin
            ItemTrackingLines.New();
            ItemTrackingLines."Lot No.".Activate();
            ItemTrackingLines."Lot No.".SetValue('LOT' + FORMAT(i));
            ItemTrackingLines."Quantity (Base)".Activate();
            ItemTrackingLines."Quantity (Base)".SetValue(2 * 50);  //там 50 шт базовой едницы измерения в 1 BAG
        end;
    end;

    [StrMenuHandler]
    procedure PostConfirmation(Options: Text; var Choice: Integer; Instruction: Text)
    begin
        Choice := 3;  //учесть как отгрузку 1 и как счет 2  то и то 3 (но это только для 1 строки)
    end;

    [ConfirmHandler]
    procedure ConfirmPostWarehousePurchaseReceipt(Options: Text; var Select: Boolean)
    begin
        Select := true;
    end;

    [MessageHandler]
    internal procedure Message(txt: Text)
    var
        Text1: text;
    begin
        text1 := txt
    end;

    [PageHandler]
    internal procedure ErrorMessages(var ErrorMessages: TestPage "Error Messages")
    begin
        ErrorMessages.First();
        DebugText := ErrorMessages.Description.Value();
        ErrorMessages.OK().Invoke();
    end;

    [PageHandler]
    internal procedure DrilldownUnitLineLinks(var UnitLoadDetails: TestPage "TMAC Unit Load Details")
    begin
        UnitLoadDetails.Close();
    end;

    [PageHandler]
    internal procedure DrilldownUnitLineLinks2(var UnitLineLinks: TestPage "TMAC Unit Line Links")
    begin
        UnitLineLinks.Close();
    end;

    var
        Framework: Codeunit "TMAC Framework";
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        DebugText: Text;

        CreatedUnitNo: Code[20];
}