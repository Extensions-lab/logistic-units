codeunit 71629506 "TMAC Item Tracking - Purchases"
{
    Subtype = Test;
    TestPermissions = Disabled;

    #region [Scenario] PO > LOT > NEWLU > POST BY LU
    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('NewLogisticUnitWizard,PostConfirmation,ItemTrackingLinesHandler,UnitListSelector')]
    procedure PO_LOT()
    var
        Unit: Record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
        Item: Record Item;
        Location: Record Location;
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        PurchaseOrder: TestPage "Purchase Order";
    begin
        //[Given] 
        Framework.SetWarehouseSetup();
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
        PurchaseOrder."TMAC New Logistics Units".Invoke();

        //[THEN]
        Test_UnitNo := LastLogisticUnitNo;
        Test_SourceType := Database::"Purchase Header";
        Test_SourceSubtype := PurchHeader."Document Type".AsInteger();
        Test_SourceID := PurchHeader."No.";

        UnitLine.Reset();
        UnitLine.Setrange("Unit No.", Test_UnitNo);
        UnitLine.SetAutoCalcFields("Expected Quantity", "Expected Quantity (Base)", "Inventory Quantity", "Inventory Quantity (Base)");
        if UnitLine.Count() <> 5 then
            Error('5 unit line must be in logistic unit');

        PurchaseOrder."TMAC Post Logistic Unit".Invoke();

        //[Then]
        Unit.Get(Test_UnitNo);
        UnitLine.Reset();
        UnitLine.Setrange("Unit No.", Test_UnitNo);
        UnitLine.SetAutoCalcFields("Expected Quantity", "Expected Quantity (Base)", "Inventory Quantity", "Inventory Quantity (Base)");
        if UnitLine.Count() <> 5 then
            Error('5 unit line must be in logistic unit');
        if UnitLine.FindSet then
            repeat
                UnitLine.TestField("No.", PurchLine."No.");
                UnitLine.TestField("Quantity", 2);
                UnitLine.TestField("Unit of Measure Code", PurchLine."Unit of Measure Code");
                UnitLine.TestField("Quantity (Base)", 100);
                UnitLine.TestField("Expected Quantity", 2);
                UnitLine.TestField("Expected Quantity (Base)", 100);
                UnitLine.TestField("Inventory Quantity", 2);
                UnitLine.TestField("Inventory Quantity (Base)", 100);
                UnitLine.TestField("Location Code", PurchLine."Location Code");
                UnitLine.TestField("Unit Type Code", Unit."Type Code");
            until UnitLine.next() = 0;


    end;
    #endregion

    #region [Scenario] PO > LOT > 4 NEWLU > POST BY LU
    // Был баг, Вова нашел: 
    // заказ покупки с одной строкой, товар с лотом, количество 10 
    // -> создаем приемку 
    // -> делаем линк на 2 LU (одна на 2 шт, вторая на 3шт) 
    // -> учитываем из приемки только вторую LU (на 3шт) 
    // -> Результат: учет проходит без ошибок, учтено по приемке 3шт, а линки учтённые создаются на 
    // обе LU и обе LU имеют статус, что учтены. Причём , если добавить ещё одну LU к строке, то создастся во все 3 LU еще по одному учтенному линку

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('NewLogisticUnitWizardX,PostConfirmation,ItemTrackingLinesHandler,UnitListSelector')]
    procedure PO_LOT_COMPLEX_5LOT_3LU_POSTBYLU()
    var
        LogisticUnitSetup: Record "TMAC Logistic Units Setup";
        Unit: Record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
        Item: Record Item;
        Location: Record Location;
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        PurchaseOrder: TestPage "Purchase Order";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        PurchRcptLine2: Record "Purch. Rcpt. Line";
        LogisticUnit1: Code[20];
        LogisticUnit2: Code[20];
        LogisticUnit3: Code[20];
        VendorInvoiceNo: Code[20];
    begin
        //[Given] 
        LogisticUnitSetup.Get();
        LogisticUnitSetup.Validate("Set Default Selected Quantity", false);
        LogisticUnitSetup.Modify(true);

        Framework.SetWarehouseSetup();
        Framework.SetPurchaseModuleSetup();
        Location := Framework.CreateSimpleWarehouse();
        Item := Framework.CreateSimpleItem();
        Item.Validate("Item Tracking Code", 'LOTALL');
        Item.Modify(true);

        PurchHeader := Framework.CreatePurchaseOrder();
        LibraryPurchase.CreatePurchaseLine(PurchLine, PurchHeader, "Purchase Line Type"::Item, Item."No.", 10);
        PurchLine.Validate("Location Code", Location.Code);
        PurchLine.Modify(true);

        VendorInvoiceNo := '00001';

        //[When] 
        PurchaseOrder.OpenEdit();
        PurchaseOrder.GoToRecord(PurchHeader);
        PurchaseOrder.Release.Invoke();
        PurchaseOrder.PurchLines."Item Tracking Lines".Invoke();  //навершиваем трасисировку 5 партий  LOTX : 2Qty 100 =  Qty Base

        LastLogisticUnitNo := '';
        Counter := 1;
        PurchaseOrder."TMAC New Logistics Units".Invoke();  //создает логистическую единицу 1 : для 1 и 2 партии
        LogisticUnit1 := LastLogisticUnitNo;

        Counter := 2;
        PurchaseOrder."TMAC New Logistics Units".Invoke(); //создает логистическую единицу  2 : для 3 и 4 партии
        LogisticUnit2 := LastLogisticUnitNo;

        Counter := 3;
        PurchaseOrder."TMAC New Logistics Units".Invoke(); //создает логистическую единицу  3 : для 5 партии
        LogisticUnit3 := LastLogisticUnitNo;

        //[WHEN]
        //учитываем первую логистическую единицу
        PurchaseOrder."Vendor Invoice No.".Activate();
        PurchaseOrder."Vendor Invoice No.".SetValue(VendorInvoiceNo);

        Test_UnitNo := LogisticUnit1;
        Test_SourceType := Database::"Purchase Header";
        Test_SourceSubtype := PurchHeader."Document Type".AsInteger();
        Test_SourceID := PurchHeader."No.";
        PurchaseOrder."TMAC Post Logistic Unit".Invoke();

        //[Then]
        //проверка ликнком по первой партии
        PurchRcptLine.Reset;
        PurchRcptLine.Setrange("Order No.", PurchLine."Document No.");
        PurchRcptLine.Setrange("Order Line No.", PurchLine."Line No.");
        PurchRcptLine.FindLast();

        CheckLinks.AfterPost_Unit_PurchaseLine(4, 4 * 50, LogisticUnit1, PurchLine);
        CheckLinks.AfterPost_Unit_PurchRcptLine(4, 4 * 50, LogisticUnit1, PurchRcptLine);
        CheckLinks.BeforePost_Unit_PurchaseLine(4, 4 * 50, LogisticUnit2, PurchLine);
        CheckLinks.BeforePost_Unit_PurchaseLine(2, 2 * 50, LogisticUnit3, PurchLine);


        //[WHEN]
        //учитываем вторую логистическую единицу
        VendorInvoiceNo := IncStr(VendorInvoiceNo);
        PurchaseOrder."Vendor Invoice No.".Activate();
        PurchaseOrder."Vendor Invoice No.".SetValue(VendorInvoiceNo);

        Test_UnitNo := LogisticUnit2;
        Test_SourceType := Database::"Purchase Header";
        Test_SourceSubtype := PurchHeader."Document Type".AsInteger();
        Test_SourceID := PurchHeader."No.";
        PurchaseOrder."TMAC Post Logistic Unit".Invoke();

        //проверка ликнком по первой партии
        //[Then]
        PurchRcptLine2.Reset;
        PurchRcptLine2.Setrange("Order No.", PurchLine."Document No.");
        PurchRcptLine2.Setrange("Order Line No.", PurchLine."Line No.");
        PurchRcptLine2.FindLast();

        CheckLinks.AfterPost_Unit_PurchaseLine(4, 4 * 50, LogisticUnit1, PurchLine);
        CheckLinks.AfterPost_Unit_PurchRcptLine(4, 4 * 50, LogisticUnit1, PurchRcptLine);
        CheckLinks.AfterPost_Unit_PurchaseLine(4, 4 * 50, LogisticUnit2, PurchLine);
        CheckLinks.AfterPost_Unit_PurchRcptLine(4, 4 * 50, LogisticUnit2, PurchRcptLine2);
        CheckLinks.BeforePost_Unit_PurchaseLine(2, 2 * 50, LogisticUnit3, PurchLine);

    end;


    [ModalPageHandler]
    internal procedure NewLogisticUnitWizardX(var NewLogisticUnitWizard: TestPage "TMAC New Logistic Unit Wizard")
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

    #region [Scenario] PO > 5 LOT > 4 NEWLU > POST BY LU
    //тоже что выше но с приемкой
    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('NewLogisticUnitWizardX2,ItemTrackingLinesHandler,UnitListSelector,WarehouseRcptHandler,Message,ConfirmPostWarehousePurchaseReceipt')]
    procedure PO_LOT_WHSRCP_COMPLEX_5LOT_3LU_POSTBYLU()
    var
        LogisticUnitSetup: Record "TMAC Logistic Units Setup";
        Unit: Record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
        Item: Record Item;
        Location: Record Location;
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        PurchaseOrder: TestPage "Purchase Order";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        VendorInvoiceNo: Code[20];
    begin
        //[Given] 
        LogisticUnitSetup.Get();
        LogisticUnitSetup.Validate("Set Default Selected Quantity", false);
        LogisticUnitSetup.Modify(true);

        Framework.SetWarehouseSetup();
        Framework.SetPurchaseModuleSetup();
        Location := Framework.CreateSimpleWarehouse();
        Location.Validate("Require Receive", true); //включаем приемку
        Location.Modify(true);
        Framework.SetWarehouseEmployee(Location);

        Item := Framework.CreateSimpleItem();
        Item.Validate("Item Tracking Code", 'LOTALL');
        Item.Modify(true);

        PurchHeader := Framework.CreatePurchaseOrder();
        LibraryPurchase.CreatePurchaseLine(PurchLine, PurchHeader, "Purchase Line Type"::Item, Item."No.", 10);
        PurchLine.Validate("Location Code", Location.Code);
        PurchLine.Modify(true);

        VendorInvoiceNo := '00001';

        //[When] 
        PurchaseOrder.OpenEdit();
        PurchaseOrder.GoToRecord(PurchHeader);
        PurchaseOrder.Release.Invoke();
        PurchaseOrder.PurchLines."Item Tracking Lines".Invoke();  //навершиваем трасисировку 5 партий  LOTX : 2Qty 100 =  Qty Base

        //[WHEN]
        //учитываем первую логистическую единицу
        PurchaseOrder."Vendor Invoice No.".Activate();
        PurchaseOrder."Vendor Invoice No.".SetValue(VendorInvoiceNo);

        //
        PurchaseOrder."Create &Whse. Receipt".Invoke();

    end;


    // Открываем и учитываем приемку 
    [PageHandler]
    procedure WarehouseRcptHandler(var WarehouseReceipt: TestPage "Warehouse Receipt")
    var
        WarehouseReceiptLine: record "Warehouse Receipt Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        PurchaseLine: Record "Purchase Line";
        WhsRcptNo: Code[20];
        LogisticUnit1: Code[20];
        LogisticUnit2: Code[20];
        LogisticUnit3: Code[20];
    begin
        WarehouseReceipt."No.".Activate();
        WhsRcptNo := WarehouseReceipt."No.".Value();

        LastLogisticUnitNo := '';
        Counter := 1;
        WarehouseReceipt."TMAC New Logistics Units".Invoke();  //создает логистическую единицу 1 : для 1й и 2й партии
        LogisticUnit1 := LastLogisticUnitNo;

        Counter := 2;
        WarehouseReceipt."TMAC New Logistics Units".Invoke(); //создает логистическую единицу  2 : для 3й и 4й партии
        LogisticUnit2 := LastLogisticUnitNo;

        Counter := 3;
        WarehouseReceipt."TMAC New Logistics Units".Invoke(); //создает логистическую единицу  3 : для 5й партии
        LogisticUnit3 := LastLogisticUnitNo;

        WarehouseReceiptLine.Setrange("No.", WhsRcptNo); //строка то одна в тесте
        WarehouseReceiptLine.FindFirst();

        Test_UnitNo := LogisticUnit1;
        Test_SourceType := 38; //зашиваем т.к. покупка
        Test_SourceSubtype := WarehouseReceiptLine."Source Subtype";
        Test_SourceID := WarehouseReceiptLine."Source No.";

        WarehouseReceipt."TMAC Post Logistic Unit".Invoke();

        // //проверяем линки
        CheckLinks.AfterPost_WarehouseReceiptLine_UnitLine(LogisticUnit1, WarehouseReceiptLine);
        PurchaseLine.Setrange("Document No.", WarehouseReceiptLine."Source No.");
        PurchaseLine.Setrange("Document Type", WarehouseReceiptLine."Source Subtype");
        PurchaseLine.SetRange("Line No.", WarehouseReceiptLine."Source Line No.");
        PurchaseLine.FindFirst();
        CheckLinks.AfterPost_Unit_PurchaseLine(4, 4 * 50, LogisticUnit1, PurchaseLine);
    end;

    [ModalPageHandler]
    internal procedure NewLogisticUnitWizardX2(var NewLogisticUnitWizard: TestPage "TMAC New Logistic Unit Wizard")
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