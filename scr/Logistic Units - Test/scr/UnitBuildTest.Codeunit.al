Codeunit 71629512 "TMAС Test Unit Build"
{
    Subtype = Test;
    TestPermissions = Disabled; //ахахахаха а вот хуй знает зачем., без этого с 22 года не работает

    // <summary>
    // Тестирование функции автосоздания грузовых единиц из Wizard New Logistic Units
    // </summary>
    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('NewLogisticUnitWizard,AutoBuildCOnfirm')]
    procedure AutoBuild_FromWizard()
    var
        Location: Record Location;
        PurchHeader: Record "Purchase Header";
        PurchLine1: Record "Purchase Line";
        PurchLine2: Record "Purchase Line";
        Item: Record Item;
        Unit: Record "TMAC Unit";
        UnitLine: Record "TMAC Unit Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        UnitType: Record "TMAC Unit Type";
        UnitManagement: Codeunit "TMAC Unit Management";
        FWONo: Code[20];
        NoSeries: Code[20];
        NewUnitTypeCode: Code[20];
        PurchaseOrder: TestPage "Purchase Order";
        Units: List of [Code[20]];
        TotalQty: Decimal;
        CurrentUnit: Code[20];
    begin
        //[Scenario]

        //[Given]       
        Location := CreateWarehouse();
        PurchHeader := CreatePurchaseOrder();
        Item := CreateItem();

        //Новый тип логистических единиц 
        NoSeries := Framework.CreateNoSeriesWithCheck('TMS-P1', '', 'UX01', 'UX99');
        NewUnitTypeCode := CopyStr(LibraryUtility.GenerateRandomText(20), 1, 10);
        Framework.CreateUnitType(NewUnitTypeCode, 'Pallet EU TEST', 'EUR and EUR1, ISO6', 'PX', 'MM', 'M3', 'KG',
            800, 1200, 0, 1.5, false,
            15, 1500, 1500, true,
            False, False, "TMAC Load Type"::"Front or Side or Top", NoSeries);

        UnitType.get(NewUnitTypeCode);
        UnitType."Mix Location/Bin Allowed" := true;
        UnitType."Mix Source Document Allowed" := true;
        UnitType.Modify(true);

        Framework.CreateUnitBuildRule('', "TMAC Content Type"::Item, Item."No.", Item."Base Unit of Measure", 1, "TMAC Build Action Type"::Create, 30, NewUnitTypeCode, false);
        Framework.CreateUnitBuildRule('', "TMAC Content Type"::Item, Item."No.", Item."Base Unit of Measure", 2, "TMAC Build Action Type"::"Add or Create", 30, NewUnitTypeCode, false);

        //Добавляем две строки
        LibraryPurchase.CreatePurchaseLine(PurchLine1, PurchHeader, "Purchase Line Type"::Item, Item."No.", 153);
        PurchLine1.Validate("Location Code", Location.Code);
        PurchLine1.Validate("Unit of Measure Code", Item."Base Unit of Measure");
        PurchLine1.Modify(true);

        LibraryPurchase.CreatePurchaseLine(PurchLine2, PurchHeader, "Purchase Line Type"::Item, Item."No.", 5);
        PurchLine2.Validate("Location Code", Location.Code);
        PurchLine2.Validate("Unit of Measure Code", Item."Base Unit of Measure");
        PurchLine2.Modify(true);

        //[When] 
        PurchaseOrder.OpenEdit();
        PurchaseOrder.GoToRecord(PurchHeader);
        PurchaseOrder.Release.Invoke();
        PurchaseOrder."TMAC New Logistics Units".Invoke();
        PurchaseOrder.Close();

        //====================================================================================
        //[Then] - проверяем что получилось
        //====================================================================================
        UnitLineLink.SetRange("Source Type", Database::"Purchase Line");
        UnitLineLink.SetRange("Source Subtype", PurchHeader."Document Type".AsInteger());
        UnitLineLink.SetRange("Source ID", PurchHeader."No.");
        UnitLineLink.SetLoadFields("Unit No.");
        if UnitLineLink.FindSet(false) then
            repeat
                if not Units.Contains(UnitLineLink."Unit No.") then
                    Units.Add(UnitLineLink."Unit No.");
            until UnitLineLink.Next() = 0;

        if Units.Count() <> 6 then
            error('Must be 6 palled generated but not %1', Units.Count());

        foreach CurrentUnit in Units do begin
            UnitLine.Reset();
            UnitLine.Setrange("Unit No.", CurrentUnit);
            UnitLine.Setrange(Type, UnitLine.Type::Item);
            UnitLine.Setrange("No.", Item."No.");
            if UnitLine.FindSet() then
                repeat
                    TotalQty += UnitLine.Quantity;
                until UnitLine.Next() = 0;
        end;

        if TotalQty <> 158 then
            Error('Total Quantity must be equal 158. Real %1', TotalQty);
    end;

    [ModalPageHandler]
    internal procedure NewLogisticUnitWizard(var NewLogisticUnitWizard: TestPage "TMAC New Logistic Unit Wizard")
    var
        Qty: Decimal;
    begin
        //переходим на вторую страницу
        NewLogisticUnitWizard.ActionNext.Invoke();

        //вторая  нажимаешь увтобил
        if NewLogisticUnitWizard.DocumentLines.First() then
            repeat
                Qty := NewLogisticUnitWizard.DocumentLines.Quantity.AsDecimal();
                NewLogisticUnitWizard.DocumentLines."Selected Quantity".SetValue(Qty);
            until NewLogisticUnitWizard.DocumentLines.Next() = false;

        NewLogisticUnitWizard.AutoBuild.Invoke();

        // //третья - выбор типа
        // NewLogisticUnitWizard.UnitTypeCode.Activate();
        // NewLogisticUnitWizard.UnitTypeCode.Value('PAL.EUR');
        // NewLogisticUnitWizard.ActionCreate.Invoke();

        //Закрываем мастер
        NewLogisticUnitWizard.ActionFinish.Invoke();
    end;

    [ConfirmHandler]
    internal procedure AutoBuildCOnfirm(txt: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;




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


    var
        Vendor: Record Vendor;
        VendorPostingGroup: Record "Vendor Posting Group";
        GeneralPostingSetup: Record "General Posting Setup";
        GenBusinessPostingGroup: record "Gen. Business Posting Group";
        GenProdPositngGroup: Record "Gen. Product Posting Group";
        VatPostingSetup: Record "VAT Posting Setup";

        Framework: Codeunit "TMAC Framework";
        Management: Codeunit "TMAC Install Management";
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryWarehouse: Codeunit "Library - Warehouse";

}