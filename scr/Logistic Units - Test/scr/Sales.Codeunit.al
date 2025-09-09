/// <summary>
/// Проверка общих праваил или настроек
/// </summary>
codeunit 71629511 "TMAC Test Sales"
{
    Subtype = Test;
    TestPermissions = Disabled;

    #region [Scenario] SO > NEWLU > POST WO LU (присвоили LU а учет делаем без) 
    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('PostConfirmation,NewLogisticUnitWizard,ErrorMessages')]
    procedure SO_NEWLU_POST_WITHOUT_LU()
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
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, "Purchase Line Type"::Item, Item."No.", 10);

        SalesLine.Validate("Location Code", Location.Code);
        SalesLine.Modify(true);

        //[When] 
        SalesOrder.OpenEdit();
        SalesOrder.GoToRecord(SalesHeader);
        SalesOrder.Release.Invoke();
        SalesOrder."TMAC New Logistics Units".Invoke();

        //[THEN] - есть паллета есть линки
        UnitLineLink.Reset();
        UnitLineLink.SetRange("Source Type", Database::"Sales Line");
        UnitLineLink.SetRange("Source Subtype", SalesLine."Document Type".AsInteger());
        UnitLineLink.SetRange("Source ID", SalesLine."Document No.");
        UnitLineLink.SetRange("Source Ref. No.", SalesLine."Line No.");
        UnitLineLink.FindFirst();
        UnitLineLink.TestField(Quantity, -10);
        UnitLineLink.TestField("Unit of Measure Code", Item."Sales Unit of Measure");
        UnitLineLink.TestField("Unit No.");
        UnitLineLink.TestField("Unit Line No.");
        Unit.Get(UnitLineLink."Unit No.");
        Unit.Testfield("Type Code", 'PAL.EUR');
        UnitNo := Unit."No.";

        //[WHEN]
        //должна быть ошибка что учет только по логистической единице
        SalesOrder.Post.Invoke();

        //[Tnen]
        // ErrorText = текст из первой строки окна ошибок
        IF StrPos(ErrorMessage, 'If a document line is linked to a logistic unit') = 0 THEN
            ERROR('Incorrect error: %1', GETLASTERRORTEXT);

    end;


    #region [Scenario] PO > NEWLU > POST WO LU (присвоили LU а учет делаем без)
    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('NewLogisticUnitWizard,PostConfirmation,ErrorMessages')]
    procedure PO_NEWLU_POST_WITHOUT_LU()
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
        PurchaseOrder.Post.Invoke();

        //[Tnen]
        // ErrorText = текст из первой строки окна ошибок
        IF StrPos(ErrorMessage, 'If a document line is linked to a logistic unit') = 0 THEN
            ERROR('Incorrect error: %1', GETLASTERRORTEXT);
    end;

    [PageHandler]
    internal procedure ErrorMessages(var ErrorMessages: TestPage "Error Messages")
    begin
        ErrorMessages.First();
        ErrorMessage := ErrorMessages.Description.Value();
        ErrorMessages.OK().Invoke();
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

        //Закрываем мастер
        NewLogisticUnitWizard.ActionFinish.Invoke();
    end;

    [StrMenuHandler]
    procedure PostConfirmation(Options: Text; var Choice: Integer; Instruction: Text)
    begin
        Choice := 3;  //учесть как отгрузку и как счет
    end;
    #endregion






    var
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
        GeneralPostingSetup: Record "General Posting Setup";
        GenBusinessPostingGroup: record "Gen. Business Posting Group";
        GenProdPositngGroup: Record "Gen. Product Posting Group";
        VatPostingSetup: Record "VAT Posting Setup";

        Framework: Codeunit "TMAC Framework";
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryPurchase: Codeunit "Library - Purchase";

        ErrorMessage: Text;
}