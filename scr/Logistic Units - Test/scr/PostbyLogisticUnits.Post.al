/// <summary>
/// Кодеюнит проверяющий учет по логистической единице.  прямолинейные тесты
/// </summary>
codeunit 71629504 "TMAC Post by Logistic Units"
{
    Subtype = Test;
    TestPermissions = Disabled;

    #region [Scenario] PO > NEWLU > POST BY LU
    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('NewLogisticUnitWizard,PostConfirmation,UnitListSelector')]
    procedure PO()
    var
        Unit: Record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
        PurchLine: Record "Purchase Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        Item: Record Item;
        Location: Record Location;
        PurchHeader: Record "Purchase Header";
        PurchaseOrder: TestPage "Purchase Order";
    begin
        //[Given] 
        Framework.SetWarehouseSetup();
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

        //[Then]
        //Test_UnitNo - присваивается в визарде
        Test_SourceType := Database::"Purchase Header";
        Test_SourceSubtype := PurchHeader."Document Type".AsInteger();
        Test_SourceID := PurchHeader."No.";

        CheckLinks.OnlyOneUnitLine(Test_UnitNo);
        CheckLinks.BeforePost_Unit_PurchaseLine(10, 10 * 50, Test_UnitNo, PurchLine);
        // Purchase_BeforePost_Line(Test_UnitNo, PurchLine);
        // Purchase_BeforePost_Links(Test_UnitNo, PurchLine);

        //[When]
        PurchaseOrder."TMAC Post Logistic Unit".Invoke();

        //[THEN]        
        Purchase_AfterPost_Line(Test_UnitNo, PurchLine);

        Purchase_AfterPost_Link_PurchRcptLine(Test_UnitNo, PurchLine);
    end;
    #endregion

    #region [Scenario] PO > WHSRCPT > NEWLU > POST BY LU
    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('NewLogisticUnitWizard,WarehouseRcptHandler,ConfirmPostWarehousePurchaseReceipt,UnitListSelector,Message')]
    procedure PO_WHSRCP()
    var
        Unit: Record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
        PurchLine: Record "Purchase Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        Item: Record Item;
        Location: Record Location;
        PurchHeader: Record "Purchase Header";
        PurchaseOrder: TestPage "Purchase Order";
        WarehouseReceipt: TestPage "Warehouse Receipt";
        PostedWarehouseReceipt: TestPage "Posted Whse. Receipt";
        WarehouseReceiptHeader: Record "Warehouse Receipt Header";
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
        PostedWarehouseHeader: Record "Posted Whse. Receipt Header";
        PostedWarehouseLine: Record "Posted Whse. Receipt Line";
        VendorInvoiceNo: Code[20];
    begin
        //[Given] 
        Framework.SetWarehouseSetup();
        Framework.SetPurchaseModuleSetup();
        Location := Framework.CreateSimpleWarehouse();
        Location.Validate("Require Receive", true);
        Location.Modify(true);
        Framework.SetWarehouseEmployee(Location);

        Item := Framework.CreateSimpleItem();

        PurchHeader := Framework.CreatePurchaseOrder();
        LibraryPurchase.CreatePurchaseLine(PurchLine, PurchHeader, "Purchase Line Type"::Item, Item."No.", 10);
        PurchLine.Validate("Location Code", Location.Code);
        PurchLine.Modify(true);

        //VendorInvoiceNo := '00001';

        //[When] 
        PurchaseOrder.OpenEdit();
        PurchaseOrder.GoToRecord(PurchHeader);
        PurchaseOrder.Release.Invoke();
        PurchaseOrder."Create &Whse. Receipt".Invoke();

        //[THEN]
        Purchase_AfterPost_Line(Test_UnitNo, PurchLine);

        Purchase_AfterPost_Link_PurchLine(Test_UnitNo, PurchLine);
        Purchase_AfterPost_Link_PurchRcptLine(Test_UnitNo, PurchLine);
        Purchase_AfterPost_Link_PostedWhseReceiptLine(Test_UnitNo, PurchLine);
    end;

    [PageHandler]
    procedure WarehouseRcptHandler(var WarehouseReceipt: TestPage "Warehouse Receipt")
    var
        WarehouseReceiptLine: record "Warehouse Receipt Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        WhsRcptNo: Code[20];
    begin
        WarehouseReceipt."No.".Activate();
        WhsRcptNo := WarehouseReceipt."No.".Value();
        WarehouseReceipt."TMAC New Logistics Units".Invoke();

        WarehouseReceiptLine.Setrange("No.", WhsRcptNo); //строка то одна в тесте
        WarehouseReceiptLine.FindFirst();

        //Test_UnitNo - присваивается в визарже
        Test_SourceType := 38; //зашиваем т.к. покупка
        Test_SourceSubtype := WarehouseReceiptLine."Source Subtype";
        Test_SourceID := WarehouseReceiptLine."Source No.";

        WarehouseReceipt."TMAC Post Logistic Unit".Invoke();
    end;
    #endregion

    #region [Scenario] SO > NEWLU > POST BY LU 
    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('NewLogisticUnitWizard,UnitListSelector,PostConfirmation')]
    procedure SO()
    var
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

        //[Then]
        //паллета новая
        //Test_UnitNo - присваивается  визарде;
        Test_SourceType := Database::"Sales Header";
        Test_SourceSubtype := SalesHeader."Document Type".AsInteger();
        Test_SourceID := SalesHeader."No.";

        Sale_BeforePost_UnitLine(Test_UnitNo, SalesLine);
        Sale_BeforePost_Links(Test_UnitNo, SalesLine);

        //[When]
        SalesOrder."TMAC Post Logistic Unit".Invoke();

        //[THEN]
        Sale_AfterPost_Line(Test_UnitNo, SalesLine);
        Sale_AfterPost_Link_SalesShipmentLine(Test_UnitNo, SalesLine);
    end;
    #endregion

    #region [Scenario] SO > WHS SHIPMENT > POST BY LU 
    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('NewLogisticUnitWizard,WarehouseShipmentHandler,PostConfirmation,UnitListSelector,Message')]
    procedure SO_WHSSHP()
    var
        Unit: record "TMAC Unit";
        Item: Record Item;
        Location: Record Location;
        SalesHeader: Record "Sales Header";
        WarehouseEmployee: Record "Warehouse Employee";
        PostedeWarehouseShipment: Record "Posted Whse. Shipment Header";
        SalesLine: Record "Sales Line";
        SalesOrder: TestPage "Sales Order";
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

        //[THEN]
        Sale_AfterPost_Line(Test_UnitNo, SalesLine);

        Sale_AfterPost_Link_SalesLine(Test_UnitNo, SalesLine);
        Sale_AfterPost_Link_SalesShipmentLine(Test_UnitNo, SalesLine);
        Sale_AfterPost_Link_PostedWhseShipmentLine(Test_UnitNo, SalesLine);
    end;

    [PageHandler]
    procedure WarehouseShipmentHandler(var WarehouseShipment: TestPage "Warehouse Shipment")
    var
        WarehouseShipmentLine: record "Warehouse Shipment Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        WhsShptNo: Code[20];
    begin
        WarehouseShipment."No.".Activate();
        WhsShptNo := WarehouseShipment."No.".Value();
        WarehouseShipment."TMAC New Logistic Units".Invoke();

        WarehouseShipmentLine.Setrange("No.", WhsShptNo); //строка то одна в тесте
        WarehouseShipmentLine.FindFirst();

        //Test_UnitNo := присваивается визардом
        Test_SourceType := 36; //зашиваем т.к. покупка
        Test_SourceSubtype := WarehouseShipmentLine."Source Subtype";
        Test_SourceID := WarehouseShipmentLine."Source No.";

        WarehouseShipment."TMAC Post Logistic Unit".Invoke();
    end;
    #endregion

    #region [Scenario] Tranfer Order: PO > POST => TRO > NEWLU > POST BY LU  (через учет покупки без LU)
    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('NewLogisticUnitWizard,UnitListSelector,PostConfirmation')]
    procedure TO()
    var
        Unit: Record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        PostedUnit: Record "TMAC Posted Unit";
        PostedUnitLineLink: Record "TMAC Posted Unit Line Link";
        Item: Record Item;
        LocationFrom: Record Location;
        LocationTo: Record Location;
        LocationTransit: Record Location;

        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        TransferOrder: TestPage "Transfer Order";

        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        PurchaseOrder: TestPage "Purchase Order";

        UnitNo: Code[20];
    begin
        //[Given] 
        Framework.SetWarehouseSetup();
        Framework.SetSalesModuleSetup();
        Framework.SetPurchaseModuleSetup();
        LocationFrom := Framework.CreateSimpleWarehouse();
        LocationTo := Framework.CreateSimpleWarehouse();
        LocationTransit := Framework.CreateSimpleWarehouse();
        LocationTransit.Validate("Use As In-Transit", true);
        LocationTransit.Modify(true);

        Item := Framework.CreateSimpleItem();

        //покупаем чтобы можно было чтото перемещать
        PurchHeader := Framework.CreatePurchaseOrder();
        LibraryPurchase.CreatePurchaseLine(PurchLine, PurchHeader, "Purchase Line Type"::Item, Item."No.", 10);
        PurchLine.Validate("Location Code", LocationFrom.Code);
        PurchLine.Modify(true);

        PurchaseOrder.OpenEdit();
        PurchaseOrder.GoToRecord(PurchHeader);
        PurchaseOrder.Release.Invoke();
        PurchaseOrder.Post.Invoke();

        //[When] 
        LibraryWarehouse.CreateTransferHeader(TransferHeader, LocationFrom.Code, LocationTo.Code, LocationTransit.Code);
        LibraryWarehouse.CreateTransferLine(TransferHeader, TransferLine, Item."No.", 10);
        TransferLine.Validate("Unit of Measure Code", Item."Purch. Unit of Measure");
        TransferLine.Modify(true);

        TransferOrder.OpenEdit();
        TransferOrder.GoToRecord(TransferHeader);
        TransferOrder."Re&lease".Invoke();
        TransferOrder."TMAC New Logistics Units".Invoke();

        //[Then]
        // Проверяем созданную логистическую единица
        //Test_UnitNo - присваивается ви
        Test_SourceType := 0;
        Test_SourceSubtype := 0;
        Test_SourceID := '';

        Transfer_AfterCreateNewLU(Test_UnitNo, TransferLine);

        //[When]
        TransferOrder."TMAC Post Logistic Unit".Invoke(); //учет

        //[THEN]
        Transfer_AfterTransferShipment_Line(Test_UnitNo, TransferLine);
        Transfer_AfterTransferShipment_Links(Test_UnitNo, TransferLine);
    end;
    #endregion

    #region [Scenario] Tranfer Order: PO > NEWLU > POST BY LU => TRO > INCLUDELU > SHIPMENT POST BY LU > RECEIPT POST BY LU (через учет покупки без LU)
    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('NewLogisticUnitWizard,UnitListSelector,PostConfirmation,Message')]
    procedure TO_INLUDELU_FULL()
    var
        LogisticUnitSetup: Record "TMAC Logistic Units Setup";
        Unit: Record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        PostedUnit: Record "TMAC Posted Unit";
        PostedUnitLineLink: Record "TMAC Posted Unit Line Link";
        Item: Record Item;
        LocationFrom: Record Location;
        LocationTo: Record Location;
        LocationTransit: Record Location;

        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        TransferOrder: TestPage "Transfer Order";

        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        PurchaseOrder: TestPage "Purchase Order";

        UnitNo: Code[20];
    begin
        LogisticUnitSetup.Get();
        LogisticUnitSetup.Validate("Set Default Selected Quantity", false);
        LogisticUnitSetup.Modify(true);

        //[Given] 
        Framework.SetWarehouseSetup();
        Framework.SetSalesModuleSetup();
        Framework.SetPurchaseModuleSetup();

        LocationFrom := Framework.CreateSimpleWarehouse();
        LocationTo := Framework.CreateSimpleWarehouse();

        LocationTransit := Framework.CreateSimpleWarehouse();
        LocationTransit.Validate("Use As In-Transit", true);
        LocationTransit.Modify(true);

        Item := Framework.CreateSimpleItem();

        //покупаем чтобы можно было чтото перемещать
        PurchHeader := Framework.CreatePurchaseOrder();
        LibraryPurchase.CreatePurchaseLine(PurchLine, PurchHeader, "Purchase Line Type"::Item, Item."No.", 10);
        PurchLine.Validate("Location Code", LocationFrom.Code);
        PurchLine.Modify(true);

        PurchaseOrder.OpenEdit();
        PurchaseOrder.GoToRecord(PurchHeader);
        PurchaseOrder.Release.Invoke();
        PurchaseOrder."TMAC New Logistics Units".Invoke();

        //Test_UnitNo - визардом
        Test_SourceType := Database::"Purchase Header";
        Test_SourceSubtype := PurchHeader."Document Type".AsInteger();
        Test_SourceID := PurchHeader."No.";

        CheckLinks.BeforePost_Unit_PurchaseLine(10, 10 * 50, Test_UnitNo, PurchLine);
        //Purchase_BeforePost_Links(Test_UnitNo, PurchLine);

        //[WHEN]        
        PurchaseOrder."TMAC Post Logistic Unit".Invoke();

        //[THEN]
        Purchase_AfterPost_Link_PurchRcptLine(Test_UnitNo, PurchLine);


        //[When] 
        LibraryWarehouse.CreateTransferHeader(TransferHeader, LocationFrom.Code, LocationTo.Code, LocationTransit.Code);
        //LibraryWarehouse.CreateTransferLine(TransferHeader, TransferLine, Item."No.", 10);
        //TransferLine.Validate("Unit of Measure Code", Item."Purch. Unit of Measure");
        //TransferLine.Modify(true);

        //поиск паллеты для включение в перемещение  
        UnitLineLink.Reset();
        UnitLineLink.Setrange("Unit No.", Test_UnitNo);
        UnitLineLink.SetRange("Source Type", Database::"Purch. Rcpt. Line");
        UnitLineLink.SetRange("Source Subtype", 0);
        UnitLineLink.FindFirst();

        Test_SourceType := Database::"Purch. Rcpt. Header";
        Test_SourceSubtype := 0;
        Test_SourceID := UnitLineLink."Source ID";

        TransferOrder.OpenEdit();
        TransferOrder.GoToRecord(TransferHeader);
        TransferOrder."TMAC Include Logistics Units".Invoke(); //строка в перемещение будет добавлена из паллеты
        TransferOrder."Re&lease".Invoke();

        //[Then]
        TransferLine.Reset();
        TransferLine.Setrange("Document No.", TransferHeader."No.");
        TransferLine.FindFirst(); //там должна быть 1 паллета
        Transfer_AfterCreateNewLU(Test_UnitNo, TransferLine); //но там есть еще линки на покупку

        //[When]
        TransferPostType := false;
        TransferOrder."TMAC Post Logistic Unit".Invoke(); //учет

        //[THEN]
        Transfer_AfterTransferShipment_Line_w_Purchase(Test_UnitNo, TransferLine);
        Transfer_AfterTransferShipment_Links_w_Purchase(Test_UnitNo, TransferLine);

        TransferPostType := true; //receive
        TransferOrder."TMAC Select for Receipt".Invoke(); //выбираем туже паллету для отгрузки

        Transfer_BeforeTransferReceipt_Line_w_Purchase(Test_UnitNo, TransferLine);
        Transfer_BeforeTransferReceipt_Links_w_Purchase(Test_UnitNo, TransferLine);

        TransferOrder."TMAC Post Logistic Unit".Invoke(); //учет
        Transfer_AfterTransferReceipt_Line_w_Purchase(Test_UnitNo, TransferLine);
        Transfer_AfterTransferReceipt_Links_w_Purchase(Test_UnitNo, TransferLine);
    end;
    #endregion


    [ModalPageHandler]
    internal procedure NewLogisticUnitWizard(var NewLogisticUnitWizard: TestPage "TMAC New Logistic Unit Wizard")
    var
        Qty: Decimal;
    begin
        //переходим на вторую страницу
        NewLogisticUnitWizard.ActionNext.Invoke();

        //вторая
        NewLogisticUnitWizard.DocumentLines.First();
        Qty := NewLogisticUnitWizard.DocumentLines.Quantity.AsDecimal();
        NewLogisticUnitWizard.DocumentLines."Selected Quantity".SetValue(Qty);
        //NewLogisticUnitWizard.DocumentLines.UpdateLinesUI.Invoke(); //Set Selected Qty
        NewLogisticUnitWizard.ActionNext.Invoke();

        //третья - выбор типа
        NewLogisticUnitWizard.UnitTypeCode.Activate();
        NewLogisticUnitWizard.UnitTypeCode.Value('PAL.EUR');
        NewLogisticUnitWizard.ActionCreate.Invoke();

        Test_UnitNo := NewLogisticUnitWizard.CreatedUnitNoUI.Value();
        //Закрываем мастер
        NewLogisticUnitWizard.ActionFinish.Invoke();
    end;

    [StrMenuHandler]
    procedure PostConfirmation(Options: Text; var Choice: Integer; Instruction: Text)
    begin
        case Options of
            '&Receive,&Invoice,Receive &and Invoice':
                Choice := 3;   //покупка
            '&Ship,&Receive':
                if TransferPostType then // перемещение отгрузка
                    Choice := 2
                else
                    Choice := 1;
        end;
    end;

    [ModalPageHandler]
    internal procedure UnitListSelector(var UnitSelector: TestPage "TMAC Unit Selection")
    begin
        UnitSelector.GoToKey(Test_UnitNo, Test_SourceType, Test_SourceSubtype, Test_SourceID);
        UnitSelector.OK.Invoke();
    end;

    [MessageHandler]
    internal procedure Message(txt: Text)
    var
        Text1: text;
    begin
        text1 := txt
    end;

    [ConfirmHandler]
    procedure ConfirmPostWarehousePurchaseReceipt(Options: Text; var Select: Boolean)
    begin
        Select := true;
    end;

    [PageHandler]
    internal procedure ErrorMessages(var ErrorMessages: TestPage "Error Messages")
    begin
        ErrorMessages.First();
        ErrorMessage := ErrorMessages.Description.Value();
        ErrorMessages.OK().Invoke();
    end;

    //=====================================================
    //Проверки
    //=====================================================
    // local procedure Purchase_BeforePost_Line(UnitNo: Code[20]; var PurchaseLine: Record "Purchase Line")
    // var
    //     Unit: Record "TMAC Unit";
    //     UnitLine: Record "TMAC Unit Line";
    // begin
    //     Unit.Get(UnitNo);
    //     UnitLine.Reset();
    //     UnitLine.Setrange("Unit No.", Test_UnitNo);
    //     UnitLine.SetAutoCalcFields("Expected Quantity", "Expected Quantity (Base)", "Inventory Quantity", "Inventory Quantity (Base)");
    //     if UnitLine.Count() <> 1 then
    //         Error('One one line must be in logistic unit');
    //     UnitLine.FindFirst();
    //     UnitLine.TestField("No.", PurchaseLine."No.");
    //     UnitLine.TestField("Quantity", PurchaseLine.Quantity);
    //     UnitLine.TestField("Unit of Measure Code", PurchaseLine."Unit of Measure Code");
    //     UnitLine.TestField("Quantity (Base)", PurchaseLine."Quantity (Base)");
    //     UnitLine.TestField("Expected Quantity", PurchaseLine.Quantity);
    //     UnitLine.TestField("Expected Quantity (Base)", PurchaseLine."Quantity (Base)");
    //     UnitLine.TestField("Inventory Quantity", 0);
    //     UnitLine.TestField("Inventory Quantity (Base)", 0);
    //     UnitLine.TestField("Location Code", PurchaseLine."Location Code");
    //     UnitLine.TestField("Unit Type Code", Unit."Type Code");
    // end;

    // local procedure Purchase_BeforePost_Links(UnitNo: Code[20]; var PurchaseLine: Record "Purchase Line")
    // var
    //     UnitLineLink: Record "TMAC Unit Line Link";
    // begin
    //     UnitLineLink.Reset();
    //     UnitLineLink.Setrange("Unit No.", UnitNo);
    //     UnitLineLink.SetRange("Source Type", Database::"Purchase Line"); 
    //     if UnitLineLink.Count() <> 1 then
    //         Error('One line must be in Unit Line Link');
    //     UnitLineLink.FindFirst();
    //     UnitLineLink.TestField(Positive, true);
    //     UnitLineLink.TestField(Quantity, PurchaseLine.Quantity);
    //     UnitLineLink.TestField("Unit of Measure Code", PurchaseLine."Unit of Measure Code");
    //     UnitLineLInk.TestField("Quantity (Base)", PurchaseLine."Quantity (Base)");
    //     UnitLineLInk.TestField("Qty. per UoM", PurchaseLine."Qty. per Unit of Measure");
    //     UnitLineLInk.TestField("Qty. to Post", 0);
    //     UnitLineLInk.TestField("Posted", false);
    //     UnitLineLInk.TestField("Calculation", true);
    //     UnitLineLInk.TestField("Posted Quantity", 0);
    // end;

    local procedure Purchase_AfterPost_Line(UnitNo: Code[20]; var PurchaseLine: Record "Purchase Line")
    var
        Unit: Record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
    begin
        Unit.Get(UnitNo);
        UnitLine.Reset();
        UnitLine.Setrange("Unit No.", UnitNo);
        UnitLine.SetAutoCalcFields("Expected Quantity", "Expected Quantity (Base)", "Inventory Quantity", "Inventory Quantity (Base)");
        if UnitLine.Count() <> 1 then
            Error('One line must be in logistic unit');
        UnitLine.FindFirst();
        UnitLine.TestField("No.", PurchaseLine."No.");
        UnitLine.TestField(Quantity, PurchaseLine.Quantity);
        UnitLine.TestField("Unit of Measure Code", PurchaseLine."Unit of Measure Code");
        UnitLine.TestField("Quantity (Base)", PurchaseLine."Quantity (Base)");
        UnitLine.TestField("Expected Quantity", PurchaseLine.Quantity);
        UnitLine.TestField("Expected Quantity (Base)", PurchaseLine."Quantity (Base)");
        UnitLine.TestField("Inventory Quantity", PurchaseLine.Quantity);
        UnitLine.TestField("Inventory Quantity (Base)", PurchaseLine."Quantity (Base)");
        UnitLine.TestField("Location Code", PurchaseLine."Location Code");
        UnitLine.TestField("Unit Type Code", Unit."Type Code");
    end;

    /// <summary>
    /// Строчка на покупку может остатся если учти только по кол-ву. например если Warehouse Receipt
    /// </summary>
    local procedure Purchase_AfterPost_Link_PurchLine(UnitNo: Code[20]; var PurchaseLine: Record "Purchase Line")
    var
        UnitLineLink: Record "TMAC Unit Line Link";
    begin
        UnitLineLink.Reset();
        UnitLineLink.Setrange("Unit No.", UnitNo);
        UnitLineLink.SetRange("Source Type", Database::"Purchase Line"); //первый линк на учт. покупку
        if UnitLineLink.Count() <> 1 then
            Error('One line must be in Unit Line Link');
        UnitLineLink.FindFirst();
        UnitLineLink.TestField(Positive, true);
        UnitLineLink.TestField(Quantity, 0);
        UnitLineLink.TestField("Unit of Measure Code", PurchaseLine."Unit of Measure Code");
        UnitLineLInk.TestField("Quantity (Base)", 0);
        UnitLineLInk.TestField("Qty. per UoM", PurchaseLine."Qty. per Unit of Measure");
        UnitLineLInk.TestField("Qty. to Post", 0);
        UnitLineLInk.TestField("Posted", false);
        UnitLineLInk.TestField("Calculation", true);
        UnitLineLInk.TestField("Posted Quantity", PurchaseLine.Quantity);
    end;

    local procedure Purchase_AfterPost_Link_PurchRcptLine(UnitNo: Code[20]; var PurchaseLine: Record "Purchase Line")
    var
        UnitLineLink: Record "TMAC Unit Line Link";
    begin
        UnitLineLink.Reset();
        UnitLineLink.Setrange("Unit No.", UnitNo);
        UnitLineLink.SetRange("Source Type", Database::"Purch. Rcpt. Line"); //первый линк на учт. покупку
        if UnitLineLink.Count() <> 1 then
            Error('One line must be in Unit Line Link');
        UnitLineLink.FindFirst();
        UnitLineLink.TestField(Positive, true);
        UnitLineLink.TestField(Quantity, PurchaseLine.Quantity);
        UnitLineLink.TestField("Unit of Measure Code", PurchaseLine."Unit of Measure Code");
        UnitLineLInk.TestField("Quantity (Base)", PurchaseLine."Quantity (Base)");
        UnitLineLInk.TestField("Qty. per UoM", PurchaseLine."Qty. per Unit of Measure");
        UnitLineLInk.TestField("Qty. to Post", 0);
        UnitLineLInk.TestField("Posted", true);
        UnitLineLInk.TestField("Calculation", true);
        UnitLineLInk.TestField("Posted Quantity", 0);
    end;

    local procedure Purchase_AfterPost_Link_PostedWhseReceiptLine(UnitNo: Code[20]; var PurchaseLine: Record "Purchase Line")
    var
        UnitLineLink: Record "TMAC Unit Line Link";
    begin
        UnitLineLink.Reset();
        UnitLineLink.Setrange("Unit No.", UnitNo);
        UnitLineLink.SetRange("Source Type", Database::"Posted Whse. Receipt Line"); //первый линк на учт. покупку
        if UnitLineLink.Count() <> 1 then
            Error('One line must be in Unit Line Link');
        UnitLineLink.FindFirst();
        UnitLineLink.TestField(Positive, true);
        UnitLineLink.TestField(Quantity, PurchaseLine.Quantity);
        UnitLineLink.TestField("Unit of Measure Code", PurchaseLine."Unit of Measure Code");
        UnitLineLInk.TestField("Quantity (Base)", PurchaseLine."Quantity (Base)");
        UnitLineLInk.TestField("Qty. per UoM", PurchaseLine."Qty. per Unit of Measure");
        UnitLineLInk.TestField("Qty. to Post", 0);
        UnitLineLInk.TestField("Posted", true);
        UnitLineLInk.TestField("Calculation", false);
        UnitLineLInk.TestField("Posted Quantity", 0);
    end;



    //SALES
    local procedure Sale_BeforePost_UnitLine(UnitNo: Code[20]; var SalesLIne: Record "Sales Line")
    var
        Unit: Record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
    begin
        Unit.Get(UnitNo);
        UnitLine.Reset();
        UnitLine.Setrange("Unit No.", Test_UnitNo);
        UnitLine.SetAutoCalcFields("Expected Quantity", "Expected Quantity (Base)", "Inventory Quantity", "Inventory Quantity (Base)");
        if UnitLine.Count() <> 1 then
            Error('One one line must be in logistic unit');
        UnitLine.FindFirst();
        UnitLine.TestField("No.", SalesLIne."No.");
        UnitLine.TestField(Quantity, SalesLIne.Quantity);
        UnitLine.TestField("Unit of Measure Code", SalesLIne."Unit of Measure Code");
        UnitLine.TestField("Quantity (Base)", SalesLIne."Quantity (Base)");
        UnitLine.TestField("Expected Quantity", -SalesLIne.Quantity);
        UnitLine.TestField("Expected Quantity (Base)", -SalesLIne."Quantity (Base)");
        UnitLine.TestField("Inventory Quantity", 0);
        UnitLine.TestField("Inventory Quantity (Base)", 0);
        UnitLine.TestField("Location Code", SalesLIne."Location Code");
        UnitLine.TestField("Unit Type Code", Unit."Type Code");
    end;

    local procedure Sale_BeforePost_Links(UnitNo: Code[20]; var SalesLine: Record "Sales Line")
    var
        UnitLineLink: Record "TMAC Unit Line Link";
    begin
        UnitLineLink.Reset();
        UnitLineLink.Setrange("Unit No.", UnitNo);
        UnitLineLink.SetRange("Source Type", Database::"Sales Line"); //первый линк на учт. покупку
        if UnitLineLink.Count() <> 1 then
            Error('One line must be in Unit Line Link');
        UnitLineLink.FindFirst();
        UnitLineLink.TestField(Positive, false);
        UnitLineLink.TestField(Quantity, -SalesLine.Quantity);
        UnitLineLink.TestField("Unit of Measure Code", SalesLine."Unit of Measure Code");
        UnitLineLInk.TestField("Quantity (Base)", -SalesLine."Quantity (Base)");
        UnitLineLInk.TestField("Qty. per UoM", SalesLine."Qty. per Unit of Measure");
        UnitLineLInk.TestField("Qty. to Post", 0);
        UnitLineLInk.TestField("Posted", false);
        UnitLineLink.TestField("Posted Quantity", 0);
        UnitLineLInk.TestField("Calculation", true);
        UnitLineLInk.TestField("Posted Quantity", 0);
    end;

    local procedure Sale_AfterPost_Line(UnitNo: Code[20]; var SalesLine: Record "Sales Line")
    var
        Unit: Record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
    begin
        Unit.Get(UnitNo);
        UnitLine.Reset();
        UnitLine.Setrange("Unit No.", UnitNo);
        UnitLine.SetAutoCalcFields("Expected Quantity", "Expected Quantity (Base)", "Inventory Quantity", "Inventory Quantity (Base)");
        if UnitLine.Count() <> 1 then
            Error('One line must be in logistic unit');
        UnitLine.FindFirst();
        UnitLine.TestField("No.", SalesLine."No.");
        UnitLine.TestField(Quantity, SalesLine.Quantity);
        UnitLine.TestField("Unit of Measure Code", SalesLine."Unit of Measure Code");
        UnitLine.TestField("Quantity (Base)", SalesLine."Quantity (Base)");
        UnitLine.TestField("Expected Quantity", -SalesLine.Quantity);
        UnitLine.TestField("Expected Quantity (Base)", -SalesLine."Quantity (Base)");
        UnitLine.TestField("Inventory Quantity", -SalesLine.Quantity);
        UnitLine.TestField("Inventory Quantity (Base)", -SalesLine."Quantity (Base)");
        UnitLine.TestField("Location Code", SalesLine."Location Code");
        UnitLine.TestField("Unit Type Code", Unit."Type Code");
    end;

    local procedure Sale_AfterPost_Link_SalesLine(UnitNo: Code[20]; var SalesLine: Record "Sales Line")
    var
        UnitLineLink: Record "TMAC Unit Line Link";
    begin
        UnitLineLink.Reset();
        UnitLineLink.Setrange("Unit No.", UnitNo);
        UnitLineLink.SetRange("Source Type", Database::"Sales Line"); //первый линк на учт. покупку
        if UnitLineLink.Count() <> 1 then
            Error('One line must be in Unit Line Link');
        UnitLineLink.FindFirst();
        UnitLineLink.TestField(Positive, false);
        UnitLineLink.TestField(Quantity, 0);
        UnitLineLink.TestField("Unit of Measure Code", SalesLine."Unit of Measure Code");
        UnitLineLInk.TestField("Quantity (Base)", 0);
        UnitLineLInk.TestField("Qty. per UoM", SalesLine."Qty. per Unit of Measure");
        UnitLineLInk.TestField("Qty. to Post", 0);
        UnitLineLInk.TestField("Posted", false);
        UnitLineLInk.TestField("Calculation", true);
        UnitLineLInk.TestField("Posted Quantity", -SalesLine.Quantity);
    end;

    local procedure Sale_AfterPost_Link_SalesShipmentLine(UnitNo: Code[20]; var SalesLine: Record "Sales Line")
    var
        UnitLineLink: Record "TMAC Unit Line Link";
    begin
        UnitLineLink.Reset();
        UnitLineLink.Setrange("Unit No.", UnitNo);
        UnitLineLink.SetRange("Source Type", Database::"Sales Shipment Line"); //первый линк на учт. покупку
        if UnitLineLink.Count() <> 1 then
            Error('One line must be in Unit Line Link');
        UnitLineLink.FindFirst();
        UnitLineLink.TestField(Positive, false);
        UnitLineLink.TestField(Quantity, -SalesLine.Quantity);
        UnitLineLink.TestField("Unit of Measure Code", SalesLine."Unit of Measure Code");
        UnitLineLInk.TestField("Quantity (Base)", -SalesLine."Quantity (Base)");
        UnitLineLInk.TestField("Qty. per UoM", SalesLine."Qty. per Unit of Measure");
        UnitLineLInk.TestField("Qty. to Post", 0);
        UnitLineLInk.TestField("Posted", true);
        UnitLineLInk.TestField("Calculation", true);
        UnitLineLInk.TestField("Posted Quantity", 0);
    end;

    local procedure Sale_AfterPost_Link_PostedWhseShipmentLine(UnitNo: Code[20]; var SalesLine: Record "Sales Line")
    var
        UnitLineLink: Record "TMAC Unit Line Link";
    begin
        UnitLineLink.Reset();
        UnitLineLink.Setrange("Unit No.", UnitNo);
        UnitLineLink.SetRange("Source Type", Database::"Posted Whse. Shipment Line"); //первый линк на учт. покупку
        if UnitLineLink.Count() <> 1 then
            Error('One line must be in Unit Line Link');
        UnitLineLink.FindFirst();
        UnitLineLink.TestField(Positive, false);
        UnitLineLink.TestField(Quantity, -SalesLine.Quantity);
        UnitLineLink.TestField("Unit of Measure Code", SalesLine."Unit of Measure Code");
        UnitLineLInk.TestField("Quantity (Base)", -SalesLine."Quantity (Base)");
        UnitLineLInk.TestField("Qty. per UoM", SalesLine."Qty. per Unit of Measure");
        UnitLineLInk.TestField("Qty. to Post", 0);
        UnitLineLInk.TestField("Posted", true);
        UnitLineLInk.TestField("Calculation", false);
        UnitLineLInk.TestField("Posted Quantity", 0);
    end;



    /// <summary>
    /// Проверки линков после учета отгузки перемещения
    /// </summary>
    local procedure Transfer_AfterCreateNewLU(UnitNo: Code[20]; var TransferLine: record "Transfer Line")
    var
        Unit: Record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
        UnitLineLink: Record "TMAC Unit Line Link";
    begin
        UnitLineLink.Setrange("Unit No.", UnitNo);
        UnitLineLink.SetRange("Source Type", Database::"Transfer Line");
        UnitLineLink.SetRange("Source Subtype", 0);
        UnitLineLink.SetRange("Source ID", TransferLine."Document No.");
        UnitLineLink.SetRange("Source Ref. No.", TransferLine."Line No.");

        //должна быть только 1 связь
        UnitLineLink.SetRange(Positive, false);
        UnitLineLink.FindFirst();
        UnitLineLink.TestField(Quantity, -TransferLine.Quantity);
        UnitLineLink.TestField("Quantity (Base)", -TransferLine."Quantity (Base)");
        UnitLineLink.TestField("Positive", false);
        UnitLineLink.TestField("Qty. to Post", 0);
        UnitLineLink.TestField("Posted Quantity", 0);
        UnitLineLink.TestField("Posted", false);
        UnitLineLink.TestField("Calculation", true);
        UnitLineLink.TestField("Unit of Measure Code", TransferLine."Unit of Measure Code");
        UnitLineLink.TestField("Unit No.");
        UnitLineLink.TestField("Unit Line No.");
    end;

    /// <summary>
    /// Просто перемещение без покупки
    /// </summary>
    local procedure Transfer_AfterTransferShipment_Line(UnitNo: Code[20]; var TransferLine: record "Transfer Line")
    var
        Unit: Record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
        UnitLineLink: Record "TMAC Unit Line Link";
    begin
        UnitLine.Reset();
        UnitLine.Setrange("Unit No.", UnitNo);
        UnitLine.SetAutoCalcFields("Expected Quantity", "Expected Quantity (Base)", "Inventory Quantity", "Inventory Quantity (Base)");
        if UnitLine.Count() <> 1 then
            Error('One line must be in logistic unit');
        UnitLine.FindFirst();
        UnitLine.TestField(Quantity, TransferLine.Quantity);
        UnitLine.TestField("Unit of Measure Code", TransferLine."Unit of Measure Code");
        UnitLine.TestField("Quantity (Base)", TransferLine."Quantity (Base)");
        UnitLine.TestField("Expected Quantity", -TransferLine.Quantity);
        UnitLine.TestField("Expected Quantity (Base)", -TransferLine."Quantity (Base)");
        UnitLine.TestField("Inventory Quantity", -TransferLine.Quantity);
        UnitLine.TestField("Inventory Quantity (Base)", -TransferLine."Quantity (Base)");
    end;

    /// <summary>
    /// Перемещение но с покпкой по паллете
    /// </summary>
    local procedure Transfer_AfterTransferShipment_Line_w_Purchase(UnitNo: Code[20]; var TransferLine: record "Transfer Line")
    var
        Unit: Record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
        UnitLineLink: Record "TMAC Unit Line Link";
    begin
        UnitLine.Reset();
        UnitLine.Setrange("Unit No.", UnitNo);
        UnitLine.SetAutoCalcFields("Expected Quantity", "Expected Quantity (Base)", "Inventory Quantity", "Inventory Quantity (Base)");
        if UnitLine.Count() <> 1 then
            Error('One line must be in logistic unit');
        UnitLine.FindFirst();
        UnitLine.TestField(Quantity, TransferLine.Quantity);
        UnitLine.TestField("Unit of Measure Code", TransferLine."Unit of Measure Code");
        UnitLine.TestField("Quantity (Base)", TransferLine."Quantity (Base)");
        UnitLine.TestField("Expected Quantity", 0);
        UnitLine.TestField("Expected Quantity (Base)", 0);
        UnitLine.TestField("Inventory Quantity", 0);
        UnitLine.TestField("Inventory Quantity (Base)", 0);
    end;


    local procedure Transfer_AfterTransferShipment_Links(UnitNo: Code[20]; var TransferLine: record "Transfer Line")
    var
        UnitLine: Record "TMAC Unit Line";
        UnitLineLink: Record "TMAC Unit Line Link";
    begin
        //должна остаться положительный линк
        UnitLineLink.Reset();
        UnitLineLink.Setrange("Unit No.", UnitNo);
        UnitLineLink.SetRange("Source Type", Database::"Transfer Line");
        UnitLineLink.SetRange("Source Subtype", 0);
        UnitLineLink.SetRange("Source ID", TransferLine."Document No.");
        UnitLineLink.SetRange("Source Ref. No.", TransferLine."Line No.");

        //должна отрицательный линк занулитьсяк
        UnitLineLink.Reset();
        UnitLineLink.Setrange("Unit No.", UnitNo);
        UnitLineLink.SetRange("Source Type", Database::"Transfer Line");
        UnitLineLink.SetRange("Source Subtype", 0);
        UnitLineLink.SetRange("Source ID", TransferLine."Document No.");
        UnitLineLink.SetRange("Source Ref. No.", TransferLine."Line No.");
        UnitLineLink.SetRange(Positive, false);
        UnitLineLink.FindFirst();
        UnitLineLink.TestField(Quantity, 0);
        UnitLineLink.TestField("Quantity (Base)", 0);
        UnitLineLink.TestField("Positive", false);
        UnitLineLink.TestField("Qty. to Post", 0);
        UnitLineLink.TestField("Posted Quantity", -TransferLine.Quantity);
        UnitLineLink.TestField("Posted", false);
        UnitLineLink.TestField("Calculation", true);
        UnitLineLink.TestField("Unit of Measure Code", TransferLine."Unit of Measure Code");
        UnitLineLink.TestField("Unit No.");
        UnitLineLink.TestField("Unit Line No.");

        //линк на уст.отгрузку перемезщения 
        UnitLineLink.Reset();
        UnitLineLink.Setrange("Unit No.", UnitNo);
        UnitLineLink.SetRange("Source Type", Database::"Transfer Shipment Line");
        UnitLineLink.SetRange("Source Subtype", 0);
        UnitLineLink.SetRange("Source Ref. No.", TransferLine."Line No.");
        UnitLineLink.SetRange(Positive, false);
        UnitLineLink.FindFirst();
        UnitLineLink.TestField(Quantity, -TransferLine.Quantity);
        UnitLineLink.TestField("Quantity (Base)", -TransferLine."Quantity (Base)");
        UnitLineLink.TestField("Positive", false);
        UnitLineLink.TestField("Qty. to Post", 0);
        UnitLineLink.TestField("Posted Quantity", 0);
        UnitLineLink.TestField("Posted", true);
        UnitLineLink.TestField("Calculation", true);
        UnitLineLink.TestField("Unit of Measure Code", TransferLine."Unit of Measure Code");
        UnitLineLink.TestField("Unit No.");
        UnitLineLink.TestField("Unit Line No.");
    end;

    local procedure Transfer_AfterTransferShipment_Links_w_Purchase(UnitNo: Code[20]; var TransferLine: record "Transfer Line")
    var
        UnitLine: Record "TMAC Unit Line";
        UnitLineLink: Record "TMAC Unit Line Link";
    begin
        //должна отрицательный линк занулитьсяк
        UnitLineLink.Reset();
        UnitLineLink.Setrange("Unit No.", UnitNo);
        UnitLineLink.SetRange("Source Type", Database::"Transfer Line");
        UnitLineLink.SetRange("Source Subtype", 0);
        UnitLineLink.SetRange("Source ID", TransferLine."Document No.");
        UnitLineLink.SetRange("Source Ref. No.", TransferLine."Line No.");
        UnitLineLink.SetRange(Positive, false);
        UnitLineLink.FindFirst();
        UnitLineLink.TestField(Quantity, 0);
        UnitLineLink.TestField("Quantity (Base)", 0);
        UnitLineLink.TestField("Positive", false);
        UnitLineLink.TestField("Qty. to Post", 0);
        UnitLineLink.TestField("Posted Quantity", -TransferLine.Quantity);
        UnitLineLink.TestField("Posted", false);
        UnitLineLink.TestField("Calculation", true);
        UnitLineLink.TestField("Unit of Measure Code", TransferLine."Unit of Measure Code");
        UnitLineLink.TestField("Unit No.");
        UnitLineLink.TestField("Unit Line No.");

        //линк на уст.отгрузку перемезщения 
        UnitLineLink.Reset();
        UnitLineLink.Setrange("Unit No.", UnitNo);
        UnitLineLink.SetRange("Source Type", Database::"Transfer Shipment Line");
        UnitLineLink.SetRange("Source Subtype", 0);
        UnitLineLink.SetRange("Source Ref. No.", TransferLine."Line No.");
        UnitLineLink.SetRange(Positive, false);
        UnitLineLink.FindFirst();
        UnitLineLink.TestField(Quantity, -TransferLine.Quantity);
        UnitLineLink.TestField("Quantity (Base)", -TransferLine."Quantity (Base)");
        UnitLineLink.TestField("Positive", false);
        UnitLineLink.TestField("Qty. to Post", 0);
        UnitLineLink.TestField("Posted Quantity", 0);
        UnitLineLink.TestField("Posted", true);
        UnitLineLink.TestField("Calculation", true);
        UnitLineLink.TestField("Unit of Measure Code", TransferLine."Unit of Measure Code");
        UnitLineLink.TestField("Unit No.");
        UnitLineLink.TestField("Unit Line No.");
    end;

    //До учета приемки по перемещению
    local procedure Transfer_BeforeTransferReceipt_Line_w_Purchase(UnitNo: Code[20]; var TransferLine: record "Transfer Line")
    var
        Unit: Record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
        UnitLineLink: Record "TMAC Unit Line Link";
    begin
        UnitLine.Reset();
        UnitLine.Setrange("Unit No.", UnitNo);
        UnitLine.SetAutoCalcFields("Expected Quantity", "Expected Quantity (Base)", "Inventory Quantity", "Inventory Quantity (Base)");
        if UnitLine.Count() <> 1 then
            Error('One line must be in logistic unit');
        UnitLine.FindFirst();
        UnitLine.TestField(Quantity, TransferLine.Quantity);
        UnitLine.TestField("Unit of Measure Code", TransferLine."Unit of Measure Code");
        UnitLine.TestField("Quantity (Base)", TransferLine."Quantity (Base)");
        UnitLine.TestField("Expected Quantity", TransferLine.Quantity);
        UnitLine.TestField("Expected Quantity (Base)", TransferLine."Quantity (Base)");
        UnitLine.TestField("Inventory Quantity", 0);
        UnitLine.TestField("Inventory Quantity (Base)", 0);
    end;

    local procedure Transfer_BeforeTransferReceipt_Links_w_Purchase(UnitNo: Code[20]; var TransferLine: record "Transfer Line")
    var
        UnitLine: Record "TMAC Unit Line";
        UnitLineLink: Record "TMAC Unit Line Link";
    begin
        UnitLineLink.Reset();
        UnitLineLink.Setrange("Unit No.", UnitNo);
        UnitLineLink.SetRange("Source Type", Database::"Transfer Line");
        UnitLineLink.SetRange("Source Subtype", 0);
        UnitLineLink.SetRange("Source ID", TransferLine."Document No.");
        UnitLineLink.SetRange("Source Ref. No.", TransferLine."Line No.");
        if UnitLineLink.Count() <> 2 then
            error('Must be only 2 links. But %1 exist', UnitLineLink.Count());

        //плюсовой линк для будуще приемки
        UnitLineLink.SetRange(Positive, true);
        UnitLineLink.FindFirst();
        UnitLineLink.TestField(Quantity, TransferLine.Quantity);
        UnitLineLink.TestField("Quantity (Base)", TransferLine."Quantity (Base)");
        UnitLineLink.TestField("Positive", true);
        UnitLineLink.TestField("Qty. to Post", 0);
        UnitLineLink.TestField("Posted Quantity", 0);
        UnitLineLink.TestField("Posted", false);
        UnitLineLink.TestField("Calculation", true);
        UnitLineLink.TestField("Unit of Measure Code", TransferLine."Unit of Measure Code");
        UnitLineLink.TestField("Unit No.");
        UnitLineLink.TestField("Unit Line No.");

        //линки предыдущей отгрузки
        UnitLineLink.SetRange(Positive, false);
        UnitLineLink.FindFirst();
        UnitLineLink.TestField(Quantity, 0);
        UnitLineLink.TestField("Quantity (Base)", 0);
        UnitLineLink.TestField("Positive", false);
        UnitLineLink.TestField("Qty. to Post", 0);
        UnitLineLink.TestField("Posted Quantity", -TransferLine.Quantity);
        UnitLineLink.TestField("Posted", false);
        UnitLineLink.TestField("Calculation", true);
        UnitLineLink.TestField("Unit of Measure Code", TransferLine."Unit of Measure Code");
        UnitLineLink.TestField("Unit No.");
        UnitLineLink.TestField("Unit Line No.");

        UnitLineLink.Reset();
        UnitLineLink.Setrange("Unit No.", UnitNo);
        UnitLineLink.SetRange("Source Type", Database::"Transfer Shipment Line");
        UnitLineLink.SetRange("Source Subtype", 0);
        UnitLineLink.SetRange("Source Ref. No.", TransferLine."Line No.");
        UnitLineLink.SetRange(Positive, false);
        UnitLineLink.FindFirst();
        UnitLineLink.TestField(Quantity, -TransferLine.Quantity);
        UnitLineLink.TestField("Quantity (Base)", -TransferLine."Quantity (Base)");
        UnitLineLink.TestField("Positive", false);
        UnitLineLink.TestField("Qty. to Post", 0);
        UnitLineLink.TestField("Posted Quantity", 0);
        UnitLineLink.TestField("Posted", true);
        UnitLineLink.TestField("Calculation", true);
        UnitLineLink.TestField("Unit of Measure Code", TransferLine."Unit of Measure Code");
        UnitLineLink.TestField("Unit No.");
        UnitLineLink.TestField("Unit Line No.");
    end;

    //После учета примки по перемещению
    local procedure Transfer_AfterTransferReceipt_Line_w_Purchase(UnitNo: Code[20]; var TransferLine: record "Transfer Line")
    var
        Unit: Record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
        UnitLineLink: Record "TMAC Unit Line Link";
    begin
        UnitLine.Reset();
        UnitLine.Setrange("Unit No.", UnitNo);
        UnitLine.SetAutoCalcFields("Expected Quantity", "Expected Quantity (Base)", "Inventory Quantity", "Inventory Quantity (Base)");
        if UnitLine.Count() <> 1 then
            Error('One line must be in logistic unit');
        UnitLine.FindFirst();
        UnitLine.TestField(Quantity, TransferLine.Quantity);
        UnitLine.TestField("Unit of Measure Code", TransferLine."Unit of Measure Code");
        UnitLine.TestField("Quantity (Base)", TransferLine."Quantity (Base)");
        UnitLine.TestField("Expected Quantity", TransferLine.Quantity);
        UnitLine.TestField("Expected Quantity (Base)", TransferLine."Quantity (Base)");
        UnitLine.TestField("Inventory Quantity", TransferLine.Quantity);
        UnitLine.TestField("Inventory Quantity (Base)", TransferLine."Quantity (Base)");
    end;

    local procedure Transfer_AfterTransferReceipt_Links_w_Purchase(UnitNo: Code[20]; var TransferLine: record "Transfer Line")
    var
        UnitLine: Record "TMAC Unit Line";
        UnitLineLink: Record "TMAC Unit Line Link";
    begin
        //так как после полного учета перемещени удалилось ищем линки только учтенные

        //учтенный линк
        UnitLineLink.Reset();
        UnitLineLink.Setrange("Unit No.", UnitNo);
        UnitLineLink.SetRange("Source Type", Database::"Transfer Receipt Line");
        UnitLineLink.SetRange("Source Subtype", 0);
        UnitLineLink.SetRange(Positive, true);
        UnitLineLink.FindFirst();
        UnitLineLink.TestField(Quantity, TransferLine.Quantity);
        UnitLineLink.TestField("Quantity (Base)", TransferLine."Quantity (Base)");
        UnitLineLink.TestField("Positive", true);
        UnitLineLink.TestField("Qty. to Post", 0);
        UnitLineLink.TestField("Posted Quantity", 0);
        UnitLineLink.TestField("Posted", true);
        UnitLineLink.TestField("Calculation", true);
        UnitLineLink.TestField("Unit of Measure Code", TransferLine."Unit of Measure Code");
        UnitLineLink.TestField("Unit No.");
        UnitLineLink.TestField("Unit Line No.");

        UnitLineLink.Reset();
        UnitLineLink.Setrange("Unit No.", UnitNo);
        UnitLineLink.SetRange("Source Type", Database::"Transfer Shipment Line");
        UnitLineLink.SetRange("Source Subtype", 0);
        UnitLineLink.SetRange(Positive, false);
        UnitLineLink.FindFirst();
        UnitLineLink.TestField(Quantity, -TransferLine.Quantity);
        UnitLineLink.TestField("Quantity (Base)", -TransferLine."Quantity (Base)");
        UnitLineLink.TestField("Positive", false);
        UnitLineLink.TestField("Qty. to Post", 0);
        UnitLineLink.TestField("Posted Quantity", 0);
        UnitLineLink.TestField("Posted", true);
        UnitLineLink.TestField("Calculation", true);
        UnitLineLink.TestField("Unit of Measure Code", TransferLine."Unit of Measure Code");
        UnitLineLink.TestField("Unit No.");
        UnitLineLink.TestField("Unit Line No.");
    end;

    var
        Framework: Codeunit "TMAC Framework";
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        CheckLinks: Codeunit "TMAC Check Links";

        DebugText: Text;
        ErrorMessage: Text;

        Test_UnitNo: Code[20];
        Test_SourceType: Integer;
        Test_SourceSubtype: Integer;
        Test_SourceID: Code[20];

        TransferPostType: Boolean;
}
