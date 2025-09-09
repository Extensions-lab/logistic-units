/// <summary>
/// Тестирование работы с логистическими единицами
/// некоторые переменные захардкожены (номера счетов)
/// </summary>
codeunit 71629510 "TMAC Purchases"
{
    Subtype = Test;
    TestPermissions = Disabled; //ахахахаха а вот хуй знает зачем., без этого с 22 года не работает

    #region [Scenario] Покупка - Учет - проверка
    // - Создаем обычный склад
    // - Создаем простой товар с новой единицей измерения
    // - Cоздаем заказ покупки c строкой товара 
    // - учет
    // - проверка результата учета

    // <summary>
    // Тестирование функции создания грузовых единиц мастером
    // </summary>
    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('PostConfirmation0')]
    procedure CreateAndPost()
    var
        Item: Record Item;
        Location: Record Location;
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        PurchaseOrder: TestPage "Purchase Order";
        UnitNo: Code[20];
    begin
        //[Given] 
        Framework.SetPurchaseModuleSetup();
        Location := Framework.CreateSimpleWarehouse();
        PurchHeader := Framework.CreatePurchaseOrder();
        Item := Framework.CreateSimpleItem();
        LibraryPurchase.CreatePurchaseLine(PurchLine, PurchHeader, "Purchase Line Type"::Item, Item."No.", 10);

        PurchLine.Validate("Location Code", Location.Code);
        PurchLine.Validate("Direct Unit Cost", 100);
        PurchLine.Validate("Qty. to Receive", 10);
        PurchLine.Modify(true);

        //[When] 
        PurchaseOrder.OpenEdit();
        PurchaseOrder.GoToRecord(PurchHeader);
        PurchaseOrder.Release.Invoke();
        PurchaseOrder.Post.Invoke();

        //[Then]
        //Результаты учета покупки
        //если учность уже ехорошо
    end;


    [StrMenuHandler]
    procedure PostConfirmation0(Options: Text; var Choice: Integer; Instruction: Text)
    begin
        Choice := 3;  //учесть как отгрузку и как счет
    end;
    #endregion

    #region Тестирование функции создания грузовых единиц мастером - покупка
    // [Scenario]
    // - Создаем обычный склад
    // - Создаем простой товар с новой единицей измерения
    // - Cоздаем заказ покупки c строкой товара 
    // - запускаем мастер создания логистической единицы
    // - должна создаться LU нужного типа
    // <summary>
    // Тестирование функции создания грузовых единиц мастером
    // </summary>


    [ModalPageHandler]
    internal procedure NewLogisticUnitWizard(var NewLogisticUnitWizard: TestPage "TMAC New Logistic Unit Wizard")
    begin
        //переходим на вторую страницу
        NewLogisticUnitWizard.ActionNext.Invoke();

        //вторая
        NewLogisticUnitWizard.DocumentLines.First();
        NewLogisticUnitWizard.ActionNext.Invoke();

        //третья - выбор типа
        NewLogisticUnitWizard.UnitTypeCode.Activate();
        NewLogisticUnitWizard.UnitTypeCode.Value('PAL.EUR');
        NewLogisticUnitWizard.ActionCreate.Invoke();

        //Закрываем мастер
        NewLogisticUnitWizard.ActionFinish.Invoke();
    end;
    #endregion

    #region учет в разрезе логистической единицы - покупка
    // [Scenario]
    // - Создаем обычный склад
    // - Создаем простой товар с новой единицей измерения
    // - Cоздаем заказ покупки c строкой товара 
    // - запускаем мастер создания логистической единицы
    // - должна создаться LU нужного типа
    // <summary>
    // Тестирование функции создания грузовых единиц мастером
    // </summary>
    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('AddLogisticUnitWizard2')]
    procedure Purchase_Add_To_Logistic_Unit()
    var
        LogisticUnitSetup: Record "TMAC Logistic Units Setup";
        Unit: Record "TMAC Unit";
        Item: Record Item;
        Location: Record Location;
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        UnitLine: record "TMAC Unit Line";
        PurchaseOrder: TestPage "Purchase Order";
        UnitBuild: Codeunit "TMAC Unit Management";
    begin
        //[Given] 
        LogisticUnitSetup.Get;
        LogisticUnitSetup."Set Default Selected Quantity" := true; //чтобы автоматом заполялись Selected Quantity
        LogisticUnitSetup.Modify();

        //Создаем логистическую единицу
        Test2_UnitNo := UnitBuild.CreateUnitByType('PAL.EUR', 'Test Pallete');

        //Создаем заказ
        Location := CreateWarehouse();
        PurchHeader := CreatePurchaseOrder();
        Item := CreateItem();
        LibraryPurchase.CreatePurchaseLine(PurchLine, PurchHeader, "Purchase Line Type"::Item, Item."No.", 100);
        PurchLine.Validate("Location Code", Location.Code);
        PurchLine.Modify(true);

        //[When] 
        PurchaseOrder.OpenEdit();
        PurchaseOrder.GoToRecord(PurchHeader);
        PurchaseOrder.Release.Invoke();
        PurchaseOrder."TMAC Add To Logistic Unit".Invoke();
        PurchaseOrder.Close();

        //[Then]
        //Доп проверки - не важные
        Unit.Get(Test2_UnitNo);
        Unit.Testfield("Type Code", 'PAL.EUR');

        //Должна быть создана строка c таким товаром и на такое кол-во
        UnitLine.Setrange("Unit No.", Test2_UnitNo);
        UnitLine.Setrange(Type, UnitLine.Type::Item);
        UnitLine.SetRange("No.", Item."No.");
        UnitLine.SetRange(Quantity, 100);
        UnitLine.SetRange("Unit of Measure Code", Item."Purch. Unit of Measure");
        UnitLine.FindFirst();

        // Проверяем созданную логистическую единица
        UnitLineLink.Setrange("Unit No.", Test2_UnitNo);
        UnitLineLink.SetRange("Source Type", Database::"Purchase Line");
        UnitLineLink.SetRange("Source Subtype", PurchLine."Document Type".AsInteger());
        UnitLineLink.SetRange("Source ID", PurchLine."Document No.");
        UnitLineLink.SetRange("Source Ref. No.", PurchLine."Line No.");
        UnitLineLink.FindFirst();

        UnitLineLink.TestField(Quantity, 100);
        UnitLineLink.TestField("Unit of Measure Code", Item."Purch. Unit of Measure");
        UnitLineLink.TestField("Unit Line No.");
    end;

    [ModalPageHandler]
    internal procedure AddLogisticUnitWizard2(var AddLogisticUnitWizard: TestPage "TMAC Add To Logistic Unit Wz.")
    begin
        //переходим на вторую страницу
        AddLogisticUnitWizard.ActionNext.Invoke();

        //страница выбора логистической единицы
        //AddLogisticUnitWizard.UnitNo.Activate();
        if AddLogisticUnitWizard.LogisticUnitList.First() then
            repeat
            until (AddLogisticUnitWizard.LogisticUnitList.Next() = false) or (AddLogisticUnitWizard.LogisticUnitList."Unit No.".Value = Test2_UnitNo);

        // AddLogisticUnitWizard.ActionNext.Invoke();

        //создание логистической единицы
        AddLogisticUnitWizard.ActionCreateLink.Invoke();  //тупо создаем по всем строкам

        //Закрываем мастер
        AddLogisticUnitWizard.ActionFinish.Invoke();
    end;
    #endregion

    #region Тес учета по логистической единице - покупка
    // [Scenario]
    // - Создаем обычный склад
    // - Создаем простой товар с новой единицей измерения
    // - Cоздаем заказ покупки c строкой товара 
    // - запускаем 3 раза мастер создания логистической единицы. Создаем 3 логистических единицы
    // - учитываем по порядку 3 логистические единицы Post By Logistic Unit
    // <summary>
    // Тестирование функции создания грузовых единиц мастером
    // </summary>
    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('NewLogisticUnitWizard3,UnitListSelector3,PostConfirmation3')]
    procedure Purchase_PostByLogisticUnit()
    var
        Unit: Record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
        Item: Record Item;
        Location: Record Location;
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        UnitLineLink: Record "TMAC Unit Line Link";

        PurchaseOrder: TestPage "Purchase Order";
        Units: List of [Code[20]];
        CurrentUnitNo: Code[20];
    begin
        //[Given] 
        Framework.SetPurchaseModuleSetup();
        Location := Framework.CreateSimpleWarehouse();
        PurchHeader := Framework.CreatePurchaseOrder();
        Item := Framework.CreateSimpleItem();
        LibraryPurchase.CreatePurchaseLine(PurchLine, PurchHeader, "Purchase Line Type"::Item, Item."No.", 3);

        PurchLine.Validate("Location Code", Location.Code);
        PurchLine.Modify(true);

        //[When] 
        PurchaseOrder.OpenEdit();
        PurchaseOrder.GoToRecord(PurchHeader);
        PurchaseOrder.Release.Invoke();
        //с помощью визарда создаем 3 логистические единицы
        PurchaseOrder."TMAC New Logistics Units".Invoke();
        PurchaseOrder."TMAC New Logistics Units".Invoke();
        PurchaseOrder."TMAC New Logistics Units".Invoke();

        //[Then]
        //должно быть 3 линка на строку покупки
        UnitLineLink.SetRange("Source Type", Database::"Purchase Line");
        UnitLineLink.SetRange("Source Subtype", PurchLine."Document Type".AsInteger());
        UnitLineLink.SetRange("Source ID", PurchLine."Document No.");
        UnitLineLink.SetRange("Source Ref. No.", PurchLine."Line No.");
        if (UnitLineLink.Count <> 3) then
            Error('UnitLineLink.Count must be = 3');
        if UnitLineLink.Findset() then
            repeat
                UnitLine.Get(UnitLineLink."Unit No.", UnitLineLink."Unit Line No."); //строка паллеты должна быть
                UnitLine.TestField(Quantity, 1);
                Units.Add(UnitLineLink."Unit No.");
            until UnitLineLink.next() = 0;

        //[When]  
        foreach CurrentUnitNo in Units do begin
            Test3_UnitNo := CurrentUnitNo;
            Test3_SourceType := Database::"Purchase Header";
            Test3_SourceSubtype := PurchHeader."Document Type".AsInteger();
            Test3_SourceID := PurchHeader."No.";

            PurchaseOrder."Vendor Invoice No.".Activate();
            PurchaseOrder."Vendor Invoice No.".Value(Format(random(10000000)));
            PurchaseOrder."TMAC Post Logistic Unit".Invoke();
        end;

        PurchaseOrder.Close();

        //[Then] 
        // - проверяем строку покупки - она должна остаться т.к. учет только приемки
        PurchLine.Find('='); //пересчитываем строку
        PurchLine.TestField("Quantity Received", 3);
        PurchLine.TestField("Quantity Invoiced", 0);

        //проверка учтенных линков. в паллете 1 товар 1 строка
        foreach CurrentUnitNo in Units do begin
            UnitLineLink.Reset();
            UnitLineLink.SetRange("Unit No.", CurrentUnitNo);
            UnitLineLink.SetRange("Source Type", Database::"Purch. Rcpt. Line");
            UnitLineLink.SetRange("Source Subtype", 0);
            if UnitLineLink.Count() <> 1 then
                error('Check posted linked %1', UnitLineLink.Count());
        end;
    end;

    [ModalPageHandler]
    internal procedure NewLogisticUnitWizard3(var NewLogisticUnitWizard: TestPage "TMAC New Logistic Unit Wizard")
    begin
        //переходим на вторую страницу
        NewLogisticUnitWizard.ActionNext.Invoke();

        //вторая страница
        NewLogisticUnitWizard.DocumentLines.First();
        NewLogisticUnitWizard.DocumentLines."Selected Quantity".Activate();
        NewLogisticUnitWizard.DocumentLines."Selected Quantity".Value('1');
        NewLogisticUnitWizard.ActionNext.Invoke();

        //переходим на страницу выбора типа логистической единицы
        NewLogisticUnitWizard.UnitTypeCode.Activate();
        NewLogisticUnitWizard.UnitTypeCode.Value('PAL.EUR');
        NewLogisticUnitWizard.ActionCreate.Invoke();

        //Закрываем мастер
        NewLogisticUnitWizard.ActionFinish.Invoke();
    end;

    [ModalPageHandler]
    internal procedure UnitListSelector3(var UnitSelector: TestPage "TMAC Unit Selection")
    begin
        UnitSelector.GoToKey(Test3_UnitNo, Test3_SourceType, Test3_SourceSubtype, Test3_SourceID);
        UnitSelector.OK.Invoke();
    end;

    [StrMenuHandler]
    procedure PostConfirmation3(Options: Text; var Choice: Integer; Instruction: Text)
    begin
        Choice := 1;  //учесть как отгрузку 1 и как счет 2  то и то 3
    end;
    #endregion

    #region Тест 4 учета по логистической единице - покупка - склад с приемкой
    // [Scenario]
    // - Создаем обычный склад c требуемой премкой
    // - Создаем простой товар с новой единицей измерения
    // - Cоздаем заказ покупки c 3 строгками товара 
    // - запускаем  мастер создания логистической единицы. Создаем с помощью его паллету только на одну строку
    // - учитываем Post By Logistic Unit
    // <summary>
    // Тестирование функции создания грузовых единиц мастером
    // </summary>
    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('NewLogisticUnitWizard4,UnitListSelector4,PostConfirmation4')]
    procedure Purchase_WhsRecipt_PostByLU()
    var
        Unit: Record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
        Item: Record Item;
        Location: Record Location;
        PurchHeader: Record "Purchase Header";
        PurchLine1: Record "Purchase Line";
        PurchLine2: Record "Purchase Line";
        PurchLine3: Record "Purchase Line";
        UnitLineLink: Record "TMAC Unit Line Link";

        PurchaseOrder: TestPage "Purchase Order";
        Units: List of [Code[20]];
        CurrentUnitNo: Code[20];
    begin
        //[Given] 
        Framework.SetPurchaseModuleSetup();
        Location := Framework.CreateSimpleWarehouse();
        Location.Validate("Require Receive", true);  //склад должен быть с премкой
        Location.Modify(true);

        PurchHeader := Framework.CreatePurchaseOrder();

        Item := Framework.CreateSimpleItem();
        LibraryPurchase.CreatePurchaseLine(PurchLine1, PurchHeader, "Purchase Line Type"::Item, Item."No.", 10);
        PurchLine1.Validate("Location Code", Location.Code);
        PurchLine1.Modify(true);


        Item := Framework.CreateSimpleItem();
        LibraryPurchase.CreatePurchaseLine(PurchLine2, PurchHeader, "Purchase Line Type"::Item, Item."No.", 20);
        PurchLine2.Validate("Location Code", Location.Code);
        PurchLine2.Modify(true);

        Item := Framework.CreateSimpleItem();
        LibraryPurchase.CreatePurchaseLine(PurchLine3, PurchHeader, "Purchase Line Type"::Item, Item."No.", 5);
        PurchLine3.Validate("Location Code", Location.Code);
        PurchLine3.Modify(true);
        Test4_SelectedItemNo := PurchLine3."No.";

        //[When] 
        PurchaseOrder.OpenEdit();
        PurchaseOrder.GoToRecord(PurchHeader);
        PurchaseOrder.Release.Invoke();
        PurchaseOrder."TMAC New Logistics Units".Invoke();  //с помощью визарда создаем логистическую единицу


        //[Then]
        //должно быть 1 линк только на 1 строку покупки из всего документа
        UnitLineLink.SetRange("Source Type", Database::"Purchase Line");
        UnitLineLink.SetRange("Source Subtype", PurchLine3."Document Type".AsInteger());
        UnitLineLink.SetRange("Source ID", PurchLine3."Document No.");
        //UnitLineLink.SetRange("Source Ref. No.", PurchLine."Line No.");
        if (UnitLineLink.Count <> 1) then
            Error('UnitLineLink.Count must be = 1');
        if UnitLineLink.Findset() then
            repeat
                UnitLine.Get(UnitLineLink."Unit No.", UnitLineLink."Unit Line No."); //строка паллеты должна быть
                UnitLine.TestField(Quantity, 5);
                Units.Add(UnitLineLink."Unit No.");
            until UnitLineLink.next() = 0;

        //[When]  
        foreach CurrentUnitNo in Units do begin

            Test4_UnitNo := CurrentUnitNo;
            Test4_SourceType := Database::"Purchase Header";
            Test4_SourceSubtype := PurchHeader."Document Type".AsInteger();
            Test4_SourceID := PurchHeader."No.";

            PurchaseOrder."Vendor Invoice No.".Activate();
            PurchaseOrder."Vendor Invoice No.".Value(Format(random(10000000)));
            PurchaseOrder."TMAC Post Logistic Unit".Invoke();
        end;

        PurchaseOrder.Close();

        //[Then] 
        // - проверяем строку покупки - она должна остаться т.к. учет только приемки
        PurchLine1.Find('='); //пересчитываем строку
        PurchLine1.TestField("Quantity Received", 0);
        PurchLine1.TestField("Quantity Invoiced", 0);

        PurchLine2.Find('='); //пересчитываем строку
        PurchLine2.TestField("Quantity Received", 0);
        PurchLine2.TestField("Quantity Invoiced", 0);

        PurchLine3.Find('='); //пересчитываем строку
        PurchLine3.TestField("Quantity Received", 5);
        PurchLine3.TestField("Quantity Invoiced", 5);

        //проверка учтенных линков. в паллете 1 товар 1 строка
        foreach CurrentUnitNo in Units do begin
            UnitLineLink.Reset();
            UnitLineLink.SetRange("Unit No.", CurrentUnitNo);
            UnitLineLink.SetRange("Source Type", Database::"Purch. Rcpt. Line");
            UnitLineLink.SetRange("Source Subtype", 0);
            if UnitLineLink.Count() <> 1 then
                error('Check posted linked %1', UnitLineLink.Count());
        end;
    end;

    [ModalPageHandler]
    internal procedure NewLogisticUnitWizard4(var NewLogisticUnitWizard: TestPage "TMAC New Logistic Unit Wizard")
    begin
        //переходим на вторую страницу
        NewLogisticUnitWizard.ActionNext.Invoke();

        //вторая страница
        if NewLogisticUnitWizard.DocumentLines.First() then
            repeat
                if NewLogisticUnitWizard.DocumentLines."Item No.".Value = Test4_SelectedItemNo then begin
                    NewLogisticUnitWizard.DocumentLines."Selected Quantity".Activate();
                    NewLogisticUnitWizard.DocumentLines."Selected Quantity".Value('5'); //5 шт в тесте
                end else begin
                    NewLogisticUnitWizard.DocumentLines."Selected Quantity".Activate();
                    NewLogisticUnitWizard.DocumentLines."Selected Quantity".Value('0');
                end;
            until NewLogisticUnitWizard.DocumentLines.Next() = false;
        NewLogisticUnitWizard.ActionNext.Invoke();

        //переходим на страницу выбора типа логистической единицы
        NewLogisticUnitWizard.UnitTypeCode.Activate();
        NewLogisticUnitWizard.UnitTypeCode.Value('PAL.EUR');
        NewLogisticUnitWizard.ActionCreate.Invoke();

        //Закрываем мастер
        NewLogisticUnitWizard.ActionFinish.Invoke();
    end;

    [ModalPageHandler]
    internal procedure UnitListSelector4(var UnitSelector: TestPage "TMAC Unit Selection")
    begin
        UnitSelector.GoToKey(Test4_UnitNo, Test4_SourceType, Test4_SourceSubtype, Test4_SourceID);
        UnitSelector.OK.Invoke();
    end;

    [StrMenuHandler]
    procedure PostConfirmation4(Options: Text; var Choice: Integer; Instruction: Text)
    begin
        Choice := 3;  //учесть как отгрузку 1 и как счет 2  то и то 3 (но это только для 1 строки)
    end;
    #endregion

    #region Тест 5 учета из логистической единицы - покупкa
    // [Scenario]
    // - Создаем 3 заказа покупки
    // - Создаем простой товар с новой единицей измерения (товар тот же самый для 3 заказов)
    // - в 1 заказе - запускаем  мастер создания логистической единицы.
    // - в 2 заказе - доавляем товар в созанную LU визардом Add Logistic Unit
    // - в 3 заказе - доавляем товар в созанную LU визардом Add Logistic Unit
    // - учитываем покупки из Logistic Unit
    // <summary>
    // Тестирование функции создания грузовых единиц мастером
    // </summary>
    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('NewLogisticUnitWizard5,AddLogisticUnitWizard5,PostConfirmation5')]
    procedure Purchase_3PO_Post_From_LU()
    var
        LogisticUnitsSetup: Record "TMAC Logistic Units Setup";
        Unit: Record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
        Item: Record Item;
        Location: Record Location;
        //3 заказа
        PurchHeader1: Record "Purchase Header";
        PurchHeader2: Record "Purchase Header";
        PurchHeader3: Record "Purchase Header";
        //3 строки
        PurchLine1: Record "Purchase Line";
        PurchLine2: Record "Purchase Line";
        PurchLine3: Record "Purchase Line";
        UnitLineLink: Record "TMAC Unit Line Link";

        UnitType: Record "TMAC Unit Type";
        PurchaseOrder: TestPage "Purchase Order";
        UnitCard: TestPage "TMAC Unit Card";
        Units: List of [Code[20]];
        CurrentUnitNo: Code[20];
        NoSeries: Code[20];
        Debug: Text;
    begin

        //[Given] 
        LogisticUnitsSetup.Get();
        LogisticUnitsSetup."Set Default Selected Quantity" := true;
        LogisticUnitsSetup.Modify(true);

        Framework.SetPurchaseModuleSetup();
        Location := Framework.CreateSimpleWarehouse();
        Item := Framework.CreateSimpleItem();

        //создаем новый тип 
        NoSeries := Framework.CreateNoSeriesWithCheck('TMS-P1', '', 'UX01', 'UX99');
        Test1_UnitTypeCode := CopyStr(LibraryUtility.GenerateRandomText(20), 1, 10);
        Framework.CreateUnitType(Test1_UnitTypeCode, 'Pallet EU TEST', 'EUR and EUR1, ISO6', 'PX', 'MM', 'M3', 'KG',
            800, 1200, 0, 1.5, false,
            15, 1500, 1500, true,
            False, False, "TMAC Load Type"::"Front or Side or Top", NoSeries);

        UnitType.get(Test1_UnitTypeCode);
        UnitType."Mix Location/Bin Allowed" := true;
        UnitType."Mix Source Document Allowed" := true;
        UnitType.Modify(true);

        // - Заказ 1
        PurchHeader1 := Framework.CreatePurchaseOrder();
        LibraryPurchase.CreatePurchaseLine(PurchLine1, PurchHeader1, "Purchase Line Type"::Item, Item."No.", 5);
        PurchLine1.Validate("Location Code", Location.Code);
        PurchLine1.Modify(true);

        PurchaseOrder.OpenEdit();
        PurchaseOrder.GoToRecord(PurchHeader1);
        PurchaseOrder.Release.Invoke();
        PurchaseOrder.Close();

        // - Заказ 2
        PurchHeader2 := Framework.CreatePurchaseOrder();
        LibraryPurchase.CreatePurchaseLine(PurchLine2, PurchHeader2, "Purchase Line Type"::Item, Item."No.", 5);
        PurchLine2.Validate("Location Code", Location.Code);
        PurchLine2.Modify(true);

        PurchaseOrder.OpenEdit();
        PurchaseOrder.GoToRecord(PurchHeader2);
        PurchaseOrder.Release.Invoke();
        PurchaseOrder.Close();

        // - Заказ 3
        PurchHeader3 := Framework.CreatePurchaseOrder();
        LibraryPurchase.CreatePurchaseLine(PurchLine3, PurchHeader3, "Purchase Line Type"::Item, Item."No.", 5);
        PurchLine3.Validate("Location Code", Location.Code);
        PurchLine3.Modify(true);

        PurchaseOrder.OpenEdit();
        PurchaseOrder.GoToRecord(PurchHeader3);
        PurchaseOrder.Release.Invoke();
        PurchaseOrder.Close();

        //[When] 
        PurchaseOrder.OpenEdit();
        PurchaseOrder.GoToRecord(PurchHeader1);
        //с помощью визарда создаем логистическую единицу
        PurchaseOrder."TMAC New Logistics Units".Invoke();
        PurchaseOrder.Close();

        Test5_UnitNo := CreatedUnitNo;

        //добавляем товар из заказа 2 в созданную логистическую единицу
        PurchaseOrder.OpenEdit();
        PurchaseOrder.GoToRecord(PurchHeader2);
        PurchaseOrder."TMAC Add To Logistic Unit".Invoke();
        PurchaseOrder.Close();

        //добавляем товар из заказа 3 в созданную логистическую единицу
        PurchaseOrder.OpenEdit();
        PurchaseOrder.GoToRecord(PurchHeader3);
        PurchaseOrder."TMAC Add To Logistic Unit".Invoke();
        PurchaseOrder.Close();

        //======================================================================
        //  проверка результатов до учета
        //======================================================================
        CheckLinks.BeforePost_Unit_PurchaseLine(5, 5 * 50, CreatedUnitNo, PurchLine1);
        CheckLinks.BeforePost_Unit_PurchaseLine(5, 5 * 50, CreatedUnitNo, PurchLine2);
        CheckLinks.BeforePost_Unit_PurchaseLine(5, 5 * 50, CreatedUnitNo, PurchLine3);

        //Учет из логистической единицы
        UnitCard.OpenEdit();
        UnitCard.GoToKey(Test5_UnitNo);
        UnitCard.PostReceipt.Invoke();
        UnitCard.Close();

        UnitLineLink.Reset();
        UnitLineLink.SetRange("Unit No.", Test5_UnitNo);

        //ссылок на неучт. покупки быть не должно
        UnitLineLink.SetRange("Source Type", Database::"Purchase Line");
        UnitLineLink.SetRange("Source Subtype", PurchLine1."Document Type".AsInteger());
        UnitLineLink.SetRange("Source ID", PurchLine1."Document No.");
        UnitLineLink.SetRange("Source Ref. No.", PurchLine1."Line No.");
        if not UnitLineLink.IsEmpty() then
            error('Must Be zero link on unposted order');

        UnitLineLink.SetRange("Source Type", Database::"Purchase Line");
        UnitLineLink.SetRange("Source Subtype", PurchLine2."Document Type".AsInteger());
        UnitLineLink.SetRange("Source ID", PurchLine2."Document No.");
        UnitLineLink.SetRange("Source Ref. No.", PurchLine2."Line No.");
        if not UnitLineLink.IsEmpty() then
            error('Must Be zero link on unposted order');

        UnitLineLink.SetRange("Source Type", Database::"Purchase Line");
        UnitLineLink.SetRange("Source Subtype", PurchLine3."Document Type".AsInteger());
        UnitLineLink.SetRange("Source ID", PurchLine3."Document No.");
        UnitLineLink.SetRange("Source Ref. No.", PurchLine3."Line No.");
        if not UnitLineLink.IsEmpty() then
            error('Must Be zero link on unposted order');

        UnitLineLink.SetRange("Source Type", Database::"Purch. Rcpt. Line");
        UnitLineLink.SetRange("Source Subtype", 0);
        UnitLineLink.SetRange("Source ID");
        UnitLineLink.SetRange("Source Ref. No.");
        if UnitLineLink.Count() <> 3 then
            error('Must be 3 lines');

    end;

    [ModalPageHandler]
    internal procedure NewLogisticUnitWizard5(var NewLogisticUnitWizard: TestPage "TMAC New Logistic Unit Wizard")
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
        NewLogisticUnitWizard.ActionNext.Invoke();

        //переходим на страницу выбора типа логистической единицы
        NewLogisticUnitWizard.UnitTypeCode.Activate();
        NewLogisticUnitWizard.UnitTypeCode.Value(Test1_UnitTypeCode);
        NewLogisticUnitWizard.ActionCreate.Invoke();

        CreatedUnitNo := NewLogisticUnitWizard.CreatedUnitNoUI.Value();

        //Закрываем мастер
        NewLogisticUnitWizard.ActionFinish.Invoke();
    end;

    [ModalPageHandler]
    internal procedure AddLogisticUnitWizard5(var AddLogisticUnitWizard: TestPage "TMAC Add To Logistic Unit Wz.")
    begin
        //переходим на вторую страницу
        AddLogisticUnitWizard.ActionNext.Invoke();

        //страница выбора логистической единицы
        //AddLogisticUnitWizard.UnitNo.Activate();
        if AddLogisticUnitWizard.LogisticUnitList.First() then
            repeat
            until (AddLogisticUnitWizard.LogisticUnitList.Next() = false) or (AddLogisticUnitWizard.LogisticUnitList."Unit No.".Value = Test5_UnitNo);

        //создание логистической единицы
        AddLogisticUnitWizard.ActionCreateLink.Invoke();  //тупо создаем по всем строкам

        //Закрываем мастер
        AddLogisticUnitWizard.ActionFinish.Invoke();
    end;

    ////учесть как отгрузку 1 и как счет 2  то и то 3 (но это только для 1 строки)
    [StrMenuHandler]
    procedure PostConfirmation5(Options: Text; var Choice: Integer; Instruction: Text)
    begin
        Choice := 3;  //чтобы остался документ
    end;
    #endregion

    #region Тест 6 учета из логистической единицы - покупкa
    // [Scenario]
    //  Заказ Покупкт
    //  Учет покупки
    //  Создание LU из учт. покупки
    //  Заказ продажи
    //  Включить в заказ продажи паллету с содержимым
    //  Учет по логистической единице
    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('NewLogisticUnitWizard6,UnitListSelector6,PostConfirmation6')]
    procedure Purchase_Post_NewLU_Sale_Post()
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
        PostedPurch: TestPage "Posted Purchase Receipt";
        SalesOrder: TestPage "Sales Order";
        Units: List of [Code[20]];
        CurrentUnitNo: Code[20];
    begin
        //[Given] 
        Framework.SetPurchaseModuleSetup();
        Location := Framework.CreateSimpleWarehouse();
        Location.Modify(true);

        PurchHeader := Framework.CreatePurchaseOrder();
        PurchHeader."Vendor Invoice No." := 'XXX';
        PurchHeader.Modify(true);

        Item := Framework.CreateSimpleItem();
        LibraryPurchase.CreatePurchaseLine(PurchLine1, PurchHeader, "Purchase Line Type"::Item, Item."No.", 10);
        PurchLine1.Validate("Location Code", Location.Code);
        PurchLine1.Modify(true);

        //[When] 
        // с помощью визарда создаем логистическую единицу - всю строку
        PurchaseOrder.OpenEdit();
        PurchaseOrder.GoToRecord(PurchHeader);
        PurchaseOrder.Release.Invoke();
        PurchaseOrder.Post.Invoke();  //учет пейдж удаляется

        PurchRcptHeader.Reset();
        PurchRcptHeader.Setrange("Buy-from Vendor No.", PurchHeader."Buy-from Vendor No.");
        PurchRcptHeader.FindLast();

        PostedPurch.OpenView();
        PostedPurch.GoToRecord(PurchRcptHeader);
        PostedPurch."TMAC New Logistic Units".Invoke();

        Test6_UnitNo := CreatedUnitNo;
        Test6_SourceType := Database::"Purch. Rcpt. Header";
        Test6_SourceSubtype := 0;
        Test6_SourceID := PurchRcptHeader."No.";

        SalesHeader := Framework.CreateSalesOrder();

        //включаем логистическую едиинцу в заказ с содержимым
        SalesOrder.OpenEdit();
        SalesOrder.GoToRecord(SalesHeader);
        SalesOrder."TMAC Include Logistics Units".Invoke();  //включаем паллету заказ

        Test6_UnitNo := CreatedUnitNo;
        Test6_SourceType := Database::"Sales Header";
        Test6_SourceSubtype := SalesHeader."Document Type".AsInteger();
        Test6_SourceID := SalesHeader."No.";
        SalesOrder."TMAC Post Logistic Unit".Invoke();   //учитываем ее же

    end;

    [ModalPageHandler]
    internal procedure NewLogisticUnitWizard6(var NewLogisticUnitWizard: TestPage "TMAC New Logistic Unit Wizard")
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

        //переходим на страницу выбора типа логистической единицы
        NewLogisticUnitWizard.UnitTypeCode.Activate();
        NewLogisticUnitWizard.UnitTypeCode.Value('PAL.EUR');
        NewLogisticUnitWizard.ActionCreate.Invoke();

        CreatedUnitNo := NewLogisticUnitWizard.CreatedUnitNoUI.Value();

        //Закрываем мастер
        NewLogisticUnitWizard.ActionFinish.Invoke();
    end;

    [ModalPageHandler]
    internal procedure UnitListSelector6(var UnitSelector: TestPage "TMAC Unit Selection")
    begin
        UnitSelector.GoToKey(Test6_UnitNo, Test6_SourceType, Test6_SourceSubtype, Test6_SourceID);
        UnitSelector.OK.Invoke();
    end;

    [PageHandler]
    internal procedure ErrorMessages6(var ErrorMessages: TestPage "Error Messages")
    begin
        ErrorMessages.First();
        Test6_ErrorText := ErrorMessages.Description.Value();
        ErrorMessages.OK().Invoke();
    end;


    [StrMenuHandler]
    procedure PostConfirmation6(Options: Text; var Choice: Integer; Instruction: Text)
    begin
        Choice := 3;  //учесть как отгрузку 1 и как счет 2  то и то 3 (но это только для 1 строки)
    end;
    #endregion






    /// <summary>
    /// Создание заказа покупки с новым поставщиком
    /// </summary>
    /// <param name="PurchaseHeader"></param>
    /// <returns></returns>
    procedure CreatePurchaseOrder() ReturnValue: Record "Purchase Header"
    var
        PurchaseLine: Record "Purchase Line";
        OrderAdress: Record "Order Address";
    begin

        LibraryERM.CreateGenBusPostingGroup(GenBusinessPostingGroup);
        LibraryERM.CreateGenProdPostingGroup(GenProdPositngGroup);
        LibraryERM.CreateGeneralPostingSetup(GeneralPostingSetup, GenBusinessPostingGroup.Code, GenProdPositngGroup.Code);
        LibraryERM.CreateVATPostingSetupWithAccounts(VatPostingSetup, "Tax Calculation Type"::"Normal VAT", 20);

        LibraryPurchase.SetOrderNoSeriesInSetup();
        LibraryPurchase.SetPostedNoSeriesInSetup();

        LibraryPurchase.CreateVendorPostingGroup(VendorPostingGroup);
        LibraryPurchase.CreateVendorWithAddress(Vendor);
        LibraryPurchase.CreateOrderAddress(OrderAdress, Vendor."No.");

        Vendor.Validate("Gen. Bus. Posting Group", GenBusinessPostingGroup.Code);
        Vendor.Validate("Vendor Posting Group", VendorPostingGroup.Code);
        Vendor.Validate("VAT Bus. Posting Group", VatPostingSetup."VAT Bus. Posting Group");
        Vendor.Modify(true);

        LibraryPurchase.CreatePurchaseOrder(ReturnValue);

        ReturnValue.SetHideValidationDialog(true);

        PurchaseLine.Reset();
        PurchaseLine.Setrange("Document Type", ReturnValue."Document Type");
        PurchaseLine.SetRange("Document No.", ReturnValue."No.");
        PurchaseLine.DeleteAll(true);

        ReturnValue.Validate("Buy-from Vendor No.", Vendor."No.");
        ReturnValue.Validate("Vendor Invoice No.", Format(TODAY) + FORMAT(Random(1000000)));
        ReturnValue.Validate("Posting Date", TODAY);
        ReturnValue.Validate("Order Address Code", OrderAdress.Code);
        ReturnValue.Modify(true);
    end;

    /// <summary>
    /// Создание обысного склада
    /// </summary>
    /// <returns></returns>
    local procedure CreateWarehouse() ReturnValue: Record Location
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
        InventoryAccount: Code[20];
    begin
        InventoryAccount := LibraryERM.CreateGLAccountNoWithDirectPosting();
        LibraryWarehouse.CreateLocation(returnvalue);
        LibraryInventory.CreateInventoryPostingSetup(InventoryPostingSetup, ReturnValue.Code, 'RESALE');
        InventoryPostingSetup.Validate("Inventory Account", InventoryAccount);
    end;

    /// <summary>
    /// Создание нового рандомного товара
    /// </summary>
    /// <returns></returns>
    local procedure CreateItem() ReturnValue: Record Item
    begin
        LibraryInventory.CreateItem(ReturnValue);
        ReturnValue.Validate("Base Unit of Measure", 'PCS');
        ReturnValue.Validate("Gen. Prod. Posting Group", 'RETAIL');
        ReturnValue.Validate("Inventory Posting Group", 'RESALE');
        ReturnValue.Validate("VAT Prod. Posting Group", VatPostingSetup."VAT Prod. Posting Group");
        ReturnValue.Modify(true);

        //Добавляем единицу измерения
        Framework.AddUnitOfMeasure(ReturnValue, 'BAG', 50, 0, 0, 0, 0.3, 50.1);

        ReturnValue.Validate("Sales Unit of Measure", 'BAG');
        ReturnValue.Validate("Purch. Unit of Measure", 'BAG');
        ReturnValue.Modify(true);
    end;


    var
        Vendor: Record Vendor;
        VendorPostingGroup: Record "Vendor Posting Group";
        GeneralPostingSetup: Record "General Posting Setup";
        GenBusinessPostingGroup: record "Gen. Business Posting Group";
        GenProdPositngGroup: Record "Gen. Product Posting Group";
        VatPostingSetup: Record "VAT Posting Setup";

        Framework: Codeunit "TMAC Framework";
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryWarehouse: Codeunit "Library - Warehouse";

        CheckLinks: Codeunit "TMAC Check Links";

        Test1_UnitTypeCode: Code[20];
        Test2_UnitNo: Code[20];

        Test3_UnitNo: Code[20];
        Test3_SourceType: Integer;
        Test3_SourceSubtype: Integer;
        Test3_SourceID: Code[20];

        Test4_UnitNo: Code[20];
        Test4_SourceType: Integer;
        Test4_SourceSubtype: Integer;
        Test4_SourceID: Code[20];
        Test4_SelectedItemNo: Code[20];

        Test5_UnitNo: Code[20];

        Test6_UnitNo: Code[20];
        Test6_SourceType: Integer;
        Test6_SourceSubtype: Integer;
        Test6_SourceID: Code[20];
        Test6_ErrorText: Text;

        CreatedUnitNo: Code[20];

}
