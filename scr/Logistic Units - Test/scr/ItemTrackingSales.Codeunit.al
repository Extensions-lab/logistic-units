codeunit 71629507 "TMAC Item Tracking - Sales"
{
    Subtype = Test;
    TestPermissions = Disabled;

    #region [Scenario] SO > LOT > NEWLU > POST BY LU  - через заказ покупки чтобы было что продавать
    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('NewLogisticUnitWizard,UnitListSelector,ItemTrackingLinesHandler,PostConfirmation')]
    procedure SO_LOT()
    var
        Unit: record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        PostedUnitLineLink: Record "TMAC Posted Unit Line Link";
        Item: Record Item;
        Location: Record Location;
        SalesHeader: Record "Sales Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesLine: Record "Sales Line";

        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        PurchaseOrder: TestPage "Purchase Order";

        SalesOrder: TestPage "Sales Order";
        UnitCard: TestPage "TMAC Unit Card";
        UnitNo: Code[20];
    begin
        //[Given] 
        Framework.SetWarehouseSetup();
        Framework.SetSalesModuleSetup();
        Framework.SetPurchaseModuleSetup();
        Location := Framework.CreateSimpleWarehouse();
        Item := Framework.CreateSimpleItem();
        Item.Validate("Item Tracking Code", 'LOTALL');
        Item.Modify(true);

        PurchHeader := Framework.CreatePurchaseOrder();
        LibraryPurchase.CreatePurchaseLine(PurchLine, PurchHeader, "Purchase Line Type"::Item, Item."No.", 10);
        PurchLine.Validate("Location Code", Location.Code);
        PurchLine.Modify(true);

        //[When] 
        PurchaseOrder.OpenEdit();
        PurchaseOrder.GoToRecord(PurchHeader);
        PurchaseOrder.Release.Invoke();
        PurchaseOrder.PurchLines."Item Tracking Lines".Invoke();  //навершиваем трасисировку
        PurchaseOrder.Post.Invoke();


        //[When]
        SalesHeader := Framework.CreateSalesOrder();
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item, Item."No.", 10);
        SalesLine.Validate("Location Code", Location.Code);
        SalesLine.Modify(true);

        SalesOrder.OpenEdit();
        SalesOrder.GoToRecord(SalesHeader);
        SalesOrder.Release.Invoke();
        SalesOrder.SalesLines.ItemTrackingLines.Invoke();  //навершиваем трасисировку
        SalesOrder."TMAC New Logistics Units".Invoke(); //тут поместит все в одну логистическую единицу

        //[Then]
        // Проверяем созданную логистическую единица
        UnitLineLink.SetRange("Source Type", Database::"Sales Line");
        UnitLineLink.SetRange("Source Subtype", SalesLine."Document Type".AsInteger());
        UnitLineLink.SetRange("Source ID", SalesLine."Document No.");
        UnitLineLink.SetRange("Source Ref. No.", SalesLine."Line No.");
        UnitLineLink.FindFirst();

        Test_UnitNo := UnitLineLink."Unit No.";
        Test_SourceType := Database::"Sales Header";
        Test_SourceSubtype := SalesHeader."Document Type".AsInteger();
        Test_SourceID := SalesHeader."No.";

        UnitLine.Reset();
        UnitLine.Setrange("Unit No.", Test_UnitNo);
        UnitLine.SetAutoCalcFields("Expected Quantity", "Expected Quantity (Base)", "Inventory Quantity", "Inventory Quantity (Base)");
        if UnitLine.Count() <> 5 then
            Error('One one line must be in logistic unit');

        //[When]
        SalesOrder."TMAC Post Logistic Unit".Invoke();

        //[THEN]
        Unit.Get(Test_UnitNo);
        UnitLine.Reset();
        UnitLine.Setrange("Unit No.", Test_UnitNo);
        UnitLine.SetAutoCalcFields("Expected Quantity", "Expected Quantity (Base)", "Inventory Quantity", "Inventory Quantity (Base)");
        if UnitLine.Count() <> 5 then
            Error('5 unit line must be in logistic unit');
        if UnitLine.FindSet then
            repeat
                UnitLine.TestField("No.", SalesLine."No.");
                UnitLine.TestField(Quantity, 2);
                UnitLine.TestField("Unit of Measure Code", SalesLine."Unit of Measure Code");
                UnitLine.TestField("Quantity (Base)", 100);
                UnitLine.TestField("Expected Quantity", -2);
                UnitLine.TestField("Expected Quantity (Base)", -100);
                UnitLine.TestField("Inventory Quantity", -2);
                UnitLine.TestField("Inventory Quantity (Base)", -100);
                UnitLine.TestField("Location Code", SalesLine."Location Code");
                UnitLine.TestField("Unit Type Code", Unit."Type Code");
            until UnitLine.next() = 0;
    end;
    #endregion

    #region [Scenario] SO > LOT > NEWLU > POST BY LU  - через заказ покупки чтобы было что продавать
    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('NewLogisticUnitWizardForSO,UnitListSelector,ItemTrackingLinesHandler,PostConfirmation')]
    procedure SO_LOT_COMPLEXT_5LOT_3LU_POSTBYLU()
    var
        Unit: record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        PostedUnitLineLink: Record "TMAC Posted Unit Line Link";
        Item: Record Item;
        Location: Record Location;
        SalesHeader: Record "Sales Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesLine: Record "Sales Line";
        SalesShipmentLine: Record "Sales Shipment Line";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        PurchaseOrder: TestPage "Purchase Order";

        SalesOrder: TestPage "Sales Order";
        UnitCard: TestPage "TMAC Unit Card";
        UnitNo: Code[20];
        LogisticUnit1: Code[20];
        LogisticUnit2: Code[20];
        LogisticUnit3: Code[20];
    begin
        //[Given] 
        Framework.SetWarehouseSetup();
        Framework.SetSalesModuleSetup();
        Framework.SetPurchaseModuleSetup();
        Location := Framework.CreateSimpleWarehouse();
        Item := Framework.CreateSimpleItem();
        Item.Validate("Item Tracking Code", 'LOTALL');
        Item.Modify(true);

        PurchHeader := Framework.CreatePurchaseOrder();
        LibraryPurchase.CreatePurchaseLine(PurchLine, PurchHeader, "Purchase Line Type"::Item, Item."No.", 10);
        PurchLine.Validate("Location Code", Location.Code);
        PurchLine.Modify(true);

        //[When] 
        // Учитываем заказ покупки чтобы были товары с лотами
        PurchaseOrder.OpenEdit();
        PurchaseOrder.GoToRecord(PurchHeader);
        PurchaseOrder.Release.Invoke();
        PurchaseOrder.PurchLines."Item Tracking Lines".Invoke();  //навершиваем трасисировку  2 каждый лот 
        PurchaseOrder.Post.Invoke();

        SalesHeader := Framework.CreateSalesOrder();
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item, Item."No.", 10);
        SalesLine.Validate("Location Code", Location.Code);
        SalesLine.Modify(true);

        SalesOrder.OpenEdit();
        SalesOrder.GoToRecord(SalesHeader);
        SalesOrder.Release.Invoke();
        SalesOrder.SalesLines.ItemTrackingLines.Invoke();  //навершиваем трасисировку (устанавливаем теже самые лоты)

        Counter := 1;
        SalesOrder."TMAC New Logistics Units".Invoke(); //тут поместит все в одну логистическую единицу
        LogisticUnit1 := LastLogisticUnitNo;

        Counter := 2;
        SalesOrder."TMAC New Logistics Units".Invoke(); //тут поместит все в одну логистическую единицу
        LogisticUnit2 := LastLogisticUnitNo;

        Counter := 3;
        SalesOrder."TMAC New Logistics Units".Invoke(); //тут поместит все в одну логистическую единицу
        LogisticUnit3 := LastLogisticUnitNo;

        //[Then]
        //проверяeeм что логистические единицы имеют строки
        UnitLine.Reset();
        UnitLine.Setrange("Unit No.", LogisticUnit1);
        if UnitLine.Count <> 2 then
            error('LU %1 contains not 2 lines', LogisticUnit1);

        UnitLine.Reset();
        UnitLine.Setrange("Unit No.", LogisticUnit2);
        if UnitLine.Count <> 2 then
            error('LU %1 contains not 2 lines', LogisticUnit2);

        UnitLine.Reset();
        UnitLine.Setrange("Unit No.", LogisticUnit3);
        if UnitLine.Count <> 1 then
            error('LU %1 contains not 1 lines', LogisticUnit3);

        //[When]
        //учитываем первую логистическую единицу
        Test_UnitNo := LogisticUnit1;
        Test_SourceType := Database::"Sales Header";
        Test_SourceSubtype := SalesHeader."Document Type".AsInteger();
        Test_SourceID := SalesHeader."No.";
        SalesOrder."TMAC Post Logistic Unit".Invoke();

        //[THEN]
        //проверяем получивщиеся линки
        SalesShipmentLine.SetRange("Order No.", SalesLine."Document No.");
        SalesShipmentLine.SetRange("Order Line No.", SalesLine."Line No.");
        SalesShipmentLine.FindLast(); //если несколько раз вызывать то строк будет несколько
         
        CheckLinks.AfterPost_SalesLine_UnitLine(LogisticUnit1, SalesLine);
        CheckLinks.AfterPost_SalesShipmentLine_UnitLine(LogisticUnit1, SalesShipmentLine);
        CheckLinks.BeforePost_SalesLine_UnitLine(LogisticUnit2, SalesLine);
        CheckLinks.BeforePost_SalesLine_UnitLine(LogisticUnit3, SalesLine);
    end;


    [ModalPageHandler]
    internal procedure NewLogisticUnitWizardForSO(var NewLogisticUnitWizard: TestPage "TMAC New Logistic Unit Wizard")
    var
        Qty: Decimal;
    begin
        //переходим на вторую страницу
        NewLogisticUnitWizard.ActionNext.Invoke();
        //вторая
        case Counter of
            1: //1 и 2 строки в окне визарда
                begin
                    NewLogisticUnitWizard.DocumentLines.First();
                    Qty := NewLogisticUnitWizard.DocumentLines.Quantity.AsDecimal();
                    NewLogisticUnitWizard.DocumentLines."Selected Quantity".SetValue(Qty);

                    NewLogisticUnitWizard.DocumentLines.Next();
                    Qty := NewLogisticUnitWizard.DocumentLines.Quantity.AsDecimal();
                    NewLogisticUnitWizard.DocumentLines."Selected Quantity".SetValue(Qty);
                end;
            2:  //3 и 4 строки в окне визарда
                begin
                    NewLogisticUnitWizard.DocumentLines.First();
                    NewLogisticUnitWizard.DocumentLines.Next();
                    NewLogisticUnitWizard.DocumentLines.Next();
                    Qty := NewLogisticUnitWizard.DocumentLines.Quantity.AsDecimal();
                    NewLogisticUnitWizard.DocumentLines."Selected Quantity".SetValue(Qty);

                    NewLogisticUnitWizard.DocumentLines.Next();
                    Qty := NewLogisticUnitWizard.DocumentLines.Quantity.AsDecimal();
                    NewLogisticUnitWizard.DocumentLines."Selected Quantity".SetValue(Qty);
                end;
            3:  //5 строка в окне визарда
                begin
                    NewLogisticUnitWizard.DocumentLines.First();
                    NewLogisticUnitWizard.DocumentLines.Next();
                    NewLogisticUnitWizard.DocumentLines.Next();
                    NewLogisticUnitWizard.DocumentLines.Next();
                    NewLogisticUnitWizard.DocumentLines.Next();
                    Qty := NewLogisticUnitWizard.DocumentLines.Quantity.AsDecimal();
                    NewLogisticUnitWizard.DocumentLines."Selected Quantity".SetValue(Qty);
                end;
        end;
        NewLogisticUnitWizard.ActionNext.Invoke();

        //третья - выбор типа
        NewLogisticUnitWizard.UnitTypeCode.Activate();
        NewLogisticUnitWizard.UnitTypeCode.Value('PAL.EUR');
        NewLogisticUnitWizard.ActionCreate.Invoke();

        LastLogisticUnitNo := NewLogisticUnitWizard.CreatedUnitNoUI.Value;

        //Закрываем мастер
        NewLogisticUnitWizard.ActionFinish.Invoke();
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
        CheckLinks: Codeunit "TMAC Check Links";
        DebugText: Text;

        ErrorMessage: Text;
        Test_UnitNo: Code[20];
        Test_SourceType: Integer;
        Test_SourceSubtype: Integer;
        Test_SourceID: Code[20];
        LastLogisticUnitNo: Code[20];
        Counter: Integer;
}
