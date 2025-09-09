codeunit 71629508 "TMAC Item Tracking - Transfers"
{
    Subtype = Test;
    TestPermissions = Disabled;
    
    #region [Scenario] Tranfer Order: PO > LOTS > POST => TRO > NEWLU > POST BY LU  (через учет покупки без LU)
    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('NewLogisticUnitWizard,PostConfirmation,ItemTrackingLinesHandler,UnitListSelector')]
    procedure TRO_LOT()
    var
        Unit: Record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
        UnitLineLink: record "TMAC Unit Line Link";
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
        Item.Validate("Item Tracking Code", 'LOTALL');
        Item.Modify(true);

        PurchHeader := Framework.CreatePurchaseOrder();
        LibraryPurchase.CreatePurchaseLine(PurchLine, PurchHeader, "Purchase Line Type"::Item, Item."No.", 10);
        PurchLine.Validate("Location Code", LocationFrom.Code);
        PurchLine.Modify(true);

        //[When] 
        PurchaseOrder.OpenEdit();
        PurchaseOrder.GoToRecord(PurchHeader);
        PurchaseOrder.Release.Invoke();
        PurchaseOrder.PurchLines."Item Tracking Lines".Invoke();  //навершиваем трасисировку
        PurchaseOrder.Post.Invoke();                              //учет товаров с трассировкой на склад отправления

        LibraryWarehouse.CreateTransferHeader(TransferHeader, LocationFrom.Code, LocationTo.Code, LocationTransit.Code);
        LibraryWarehouse.CreateTransferLine(TransferHeader, TransferLine, Item."No.", 10);
        TransferLine.Validate("Unit of Measure Code", Item."Purch. Unit of Measure");
        TransferLine.Modify(true);

        TransferOrder.OpenEdit();
        TransferOrder.GoToRecord(TransferHeader);
        TransferOrder."Re&lease".Invoke();
        TransferOrder.TransferLines.Shipment.Invoke(); //навершиваем трассировку
        TransferOrder."TMAC New Logistics Units".Invoke();

        //[Then]
        //Находим логистическую единицy
        Test_UnitNo := GetUnitNo(Database::"Transfer Line", 0, TransferLine."Document No.", TransferLine."Line No.");
        Test_SourceType := 0;
        Test_SourceSubtype := 0;
        Test_SourceID := '';

        //[When]
        TransferOrder."TMAC Post Logistic Unit".Invoke();

        //дложно быть 5 строк
        UnitLine.Reset();
        UnitLine.Setrange("Unit No.", Test_UnitNo);
        UnitLine.SetAutoCalcFields("Expected Quantity", "Expected Quantity (Base)", "Inventory Quantity", "Inventory Quantity (Base)");
        if UnitLine.FindSet() then
            repeat
                UnitLine.TestField(Quantity, 2);
                UnitLine.TestField("Unit of Measure Code", PurchLine."Unit of Measure Code");
                UnitLine.TestField("Quantity (Base)", 100);
                UnitLine.TestField("Expected Quantity", -2);
                UnitLine.TestField("Expected Quantity (Base)", -100);
                UnitLine.TestField("Inventory Quantity", -2);
                UnitLine.TestField("Inventory Quantity (Base)", -100);

                UnitLineLink.Reset();
                UnitLineLink.Setrange("Unit No.", Test_UnitNo);
                UnitLineLink.Setrange("Unit Line No.", UnitLine."Line No.");
                UnitLineLink.SetRange("Source Type", Database::"Transfer Line");
                UnitLineLink.SetRange("Source Subtype", 0);
                UnitLineLink.SetRange("Source ID", TransferLine."Document No.");
                UnitLineLink.SetRange("Source Ref. No.", TransferLine."Line No.");

                //Линки неучтенных документов
                UnitLineLink.SetRange(Positive, false);
                UnitLineLink.FindFirst();
                UnitLineLink.TestField(Quantity, 0);
                UnitLineLink.TestField("Quantity (Base)", 0);
                UnitLineLink.TestField("Positive", false);
                UnitLineLink.TestField("Qty. to Post", 0);
                UnitLineLink.TestField("Posted Quantity", -2);
                UnitLineLink.TestField("Posted", false);
                UnitLineLink.TestField("Calculation", true);
                UnitLineLink.TestField("Unit of Measure Code", Item."Sales Unit of Measure");
                UnitLineLink.TestField("Unit No.");
                UnitLineLink.TestField("Unit Line No.");

                //линки учт. документов
                UnitLineLink.Reset();
                UnitLineLink.Setrange("Unit No.", Test_UnitNo);
                UnitLineLink.Setrange("Unit Line No.", UnitLine."Line No.");
                UnitLineLink.SetRange("Source Type", Database::"Transfer Shipment Line");
                UnitLineLink.SetRange("Source Subtype", 0);
                UnitLineLink.SetRange("Source Ref. No.", TransferLine."Line No.");
                UnitLineLink.SetRange(Positive, false);
                UnitLineLink.FindFirst();
                UnitLineLink.TestField(Quantity, -2);
                UnitLineLink.TestField("Quantity (Base)", -100);
                UnitLineLink.TestField("Positive", false);
                UnitLineLink.TestField("Qty. to Post", 0);
                UnitLineLink.TestField("Posted Quantity", 0); //заполняется только для линков на неучт документы
                UnitLineLink.TestField("Posted", true);
                UnitLineLink.TestField("Calculation", true);
                UnitLineLink.TestField("Unit of Measure Code", Item."Sales Unit of Measure");
                UnitLineLink.TestField("Unit No.");
                UnitLineLink.TestField("Unit Line No.");

            until UnitLine.next() = 0;
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

        LastLogisticUnitNo := NewLogisticUnitWizard.CreatedUnitNoUI.Value;

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
                Choice := 1;   // перемещение отгрузка
        end;
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

    [PageHandler]
    internal procedure ErrorMessages(var ErrorMessages: TestPage "Error Messages")
    begin
        ErrorMessages.First();
        ErrorMessage := ErrorMessages.Description.Value();
        ErrorMessages.OK().Invoke();
    end;

    //
    local procedure GetUnitNo(SourceType: Integer; SourceSubType: Integer; SourceID: Code[20]; SourceRefNo: Integer): Code[20]
    var
        UnitLineLink: Record "TMAC Unit Line Link";
    begin
        UnitLineLink.SetRange("Source Type", SourceType);
        UnitLineLink.SetRange("Source Subtype", SourceSubType);
        UnitLineLink.SetRange("Source ID", SourceID);
        UnitLineLink.SetRange("Source Ref. No.", SourceRefNo);
        UnitLineLink.FindFirst();
        exit(UnitLineLink."Unit No.");
    end;

    [ModalPageHandler]
    internal procedure UnitListSelector(var UnitSelector: TestPage "TMAC Unit Selection")
    begin
        UnitSelector.GoToKey(Test_UnitNo, Test_SourceType, Test_SourceSubtype, Test_SourceID);
        UnitSelector.OK.Invoke();
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

        ErrorMessage: Text;
        Test_UnitNo: Code[20];
        Test_SourceType: Integer;
        Test_SourceSubtype: Integer;
        Test_SourceID: Code[20];
        LastLogisticUnitNo: Code[20];
        Counter: Integer;
}
