/// <summary>
/// Общие функции используемые в тестовых кодеюнитах
/// </summary>
codeunit 71629501 "TMAC Framework"
{

    internal procedure SetWarehouseSetup()
    var
        WarehouseSetup: Record "Warehouse Setup";
    begin
        WarehouseSetup.Get();
        WarehouseSetup.Validate("Shipment Posting Policy", WarehouseSetup."Shipment Posting Policy"::"Stop and show the first posting error");
        WarehouseSetup.Validate("Receipt Posting Policy", WarehouseSetup."Receipt Posting Policy"::"Stop and show the first posting error");
        WarehouseSetup.Modify(true);
    end;

    internal procedure SetWarehouseEmployee(var Location: Record Location)
    var
        WarehouseEmployee: Record "Warehouse Employee";
    begin
        WarehouseEmployee.Init();
        WarehouseEmployee."User ID" := UserId();
        WarehouseEmployee."Location Code" := Location.Code;
        WarehouseEmployee.Insert(true);
    end;

    internal procedure SetPurchaseModuleSetup()
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        SalesAccount: Code[20];
        COGSAccount: Code[20];
        DirectCostAppliedAccount: Code[20];
        PurchAccount: Code[20];
        InventoryAdjmtAccount: Code[20];
    begin
        SalesAccount := LibraryERM.CreateGLAccountNoWithDirectPosting();
        COGSAccount := LibraryERM.CreateGLAccountNoWithDirectPosting();
        DirectCostAppliedAccount := LibraryERM.CreateGLAccountNoWithDirectPosting();
        PurchAccount := LibraryERM.CreateGLAccountNoWithDirectPosting();
        InventoryAdjmtAccount := LibraryERM.CreateGLAccountNoWithDirectPosting();

        LibraryERM.CreateGLAccountNoWithDirectPosting();
        LibraryERM.CreateGLAccountNoWithDirectPosting();

        LibraryERM.CreateGenBusPostingGroup(GenBusinessPostingGroup);
        LibraryERM.CreateGenProdPostingGroup(GenProdPositngGroup);
        LibraryERM.CreateGeneralPostingSetup(GeneralPostingSetup, GenBusinessPostingGroup.Code, GenProdPositngGroup.Code);

        LibraryERM.CreateVATPostingSetupWithAccounts(VatPostingSetup, "Tax Calculation Type"::"Normal VAT", 20);

        GeneralPostingSetup.Validate("Direct Cost Applied Account", DirectCostAppliedAccount);
        GeneralPostingSetup.Validate("Sales Account", SalesAccount);
        GeneralPostingSetup.Validate("COGS Account", COGSAccount);
        GeneralPostingSetup.Validate("Purch. Account", PurchAccount);
        GeneralPostingSetup.Validate("Inventory Adjmt. Account", InventoryAdjmtAccount);
        GeneralPostingSetup.Modify(true);

        LibraryERM.CreateGeneralPostingSetup(GeneralPostingSetup, '', GenProdPositngGroup.Code);
        GeneralPostingSetup.Validate("Direct Cost Applied Account", DirectCostAppliedAccount);
        GeneralPostingSetup.Validate("Sales Account", SalesAccount);
        GeneralPostingSetup.Validate("COGS Account", COGSAccount);
        GeneralPostingSetup.Validate("Purch. Account", PurchAccount);
        GeneralPostingSetup.Validate("Inventory Adjmt. Account", InventoryAdjmtAccount);
        GeneralPostingSetup.Modify(true);

        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Order Nos.", CreateNos('TEST.PO'));
        PurchasesPayablesSetup.Validate("Posted Invoice Nos.", CreateNos('TEST.PI+'));
        PurchasesPayablesSetup.Validate("Posted Receipt Nos.", CreateNos('TEST.PR+'));
        PurchasesPayablesSetup.Validate("Posted Credit Memo Nos.", CreateNos('TEST.PC+'));
        PurchasesPayablesSetup.Modify(true);
    end;

    internal procedure SetSalesModuleSetup()
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        SalesAccount: Code[20];
        COGSAccount: Code[20];
        DirectCostAppliedAccount: Code[20];
        PurchAccount: Code[20];
        InventoryAdjmtAccount: Code[20];
    begin
        SalesAccount := LibraryERM.CreateGLAccountNoWithDirectPosting();
        COGSAccount := LibraryERM.CreateGLAccountNoWithDirectPosting();
        DirectCostAppliedAccount := LibraryERM.CreateGLAccountNoWithDirectPosting();
        PurchAccount := LibraryERM.CreateGLAccountNoWithDirectPosting();
        InventoryAdjmtAccount := LibraryERM.CreateGLAccountNoWithDirectPosting();

        LibraryERM.CreateGenBusPostingGroup(GenBusinessPostingGroup);
        LibraryERM.CreateGenProdPostingGroup(GenProdPositngGroup);
        LibraryERM.CreateGeneralPostingSetup(GeneralPostingSetup, GenBusinessPostingGroup.Code, GenProdPositngGroup.Code);
        LibraryERM.CreateVATPostingSetupWithAccounts(VatPostingSetup, "Tax Calculation Type"::"Normal VAT", 20);

        GeneralPostingSetup.Validate("Direct Cost Applied Account", DirectCostAppliedAccount);
        GeneralPostingSetup.Validate("Sales Account", SalesAccount);
        GeneralPostingSetup.Validate("COGS Account", COGSAccount);
        GeneralPostingSetup.Validate("Sales Credit Memo Account", SalesAccount);
        GeneralPostingSetup.Validate("Purch. Credit Memo Account", SalesAccount);
        GeneralPostingSetup.Modify(true);

        SalesReceivablesSetup.Get();
        SalesReceivablesSetup.Validate("Order Nos.", CreateNos('TEST.SO'));
        SalesReceivablesSetup.Validate("Posted Invoice Nos.", CreateNos('TEST.SI+'));
        SalesReceivablesSetup.Validate("Posted Shipment Nos.", CreateNos('TEST.SS+'));
        SalesReceivablesSetup.Validate("Posted Credit Memo Nos.", CreateNos('TEST.SC+'));
        SalesReceivablesSetup.Modify(true);
    end;


    /// <summary>
    /// Создание обычного склада
    /// </summary>
    /// <returns></returns>
    internal procedure CreateSimpleWarehouse() ReturnValue: Record Location
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
        InventoryAccount: Code[20];
    begin
        InventoryAccount := LibraryERM.CreateGLAccountNoWithDirectPosting();
        LibraryWarehouse.CreateLocation(returnvalue);
        LibraryInventory.CreateInventoryPostingSetup(InventoryPostingSetup, ReturnValue.Code, 'RESALE');
        InventoryPostingSetup.Validate("Inventory Account", InventoryAccount);
        InventoryPostingSetup.Modify(true);
    end;

    /// <summary>
    /// Создание обычного c приемкой
    /// </summary>
    /// <returns></returns>
    local procedure CreateWarehouseWithRcpt() Location: Record Location
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
        InventoryAccount: Code[20];
    begin
        InventoryAccount := LibraryERM.CreateGLAccountNoWithDirectPosting();
        LibraryWarehouse.CreateLocation(Location);
        Location.Validate("Require Receive", true);
        LibraryInventory.CreateInventoryPostingSetup(InventoryPostingSetup, Location.Code, 'RESALE');
        InventoryPostingSetup.Validate("Inventory Account", InventoryAccount);
        InventoryPostingSetup.Modify(true);
    end;

    /// <summary>
    /// СОздание серии номеров если такой нет
    /// </summary>
    /// <param name="Name"></param>
    /// <returns></returns>
    internal procedure CreateNos(Code1: Code[20]): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if NoSeries.Get(Code1) then
            exit(Code1);

        NoSeries.Init();
        NoSeries.Validate(Code, Code1);
        NoSeries.Validate("Default Nos.", true);
        NoSeries.Validate("Manual Nos.", true);
        NoSeries.Validate("Date Order", false);
        NoSeries.Insert(true);

        LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, '', '');
        exit(Code1);
    end;


    /// <summary>
    /// Создание заказа покупки 
    /// - с новым поставщиком
    /// - адресом
    /// </summary>
    /// <param name="PurchaseHeader"></param>
    /// <returns></returns>
    internal procedure CreatePurchaseOrder() ReturnValue: Record "Purchase Header"
    var
        PurchaseLine: Record "Purchase Line";
        OrderAddress: Record "Order Address";
    begin

        LibraryPurchase.CreateVendorPostingGroup(VendorPostingGroup);
        LibraryPurchase.CreateVendorWithAddress(Vendor);
        LibraryPurchase.CreateOrderAddress(OrderAddress, Vendor."No.");

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
        ReturnValue.Validate("Vendor Invoice No.", LibraryUtility.GenerateRandomText(20));
        ReturnValue.Validate("Posting Date", TODAY);
        ReturnValue.Validate("Order Address Code", OrderAddress.Code);
        ReturnValue.Modify(true);
    end;


    /// <summary>
    /// Создание заказа продажи 
    /// - с новым поставщиком
    /// - адресом
    /// </summary>
    /// <param name="PurchaseHeader"></param>
    /// <returns></returns>
    internal procedure CreateSalesOrder() ReturnValue: Record "Sales Header"
    var
        SalesLine: Record "Sales Line";
        ShiptoAddress: Record "Ship-to Address";
    begin

        LibrarySales.CreateCustomerPostingGroup(CustomerPostingGroup);
        LibrarySales.CreateCustomerWithAddress(Customer);
        LibrarySales.CreateShipToAddress(ShiptoAddress, Customer."No.");

        Customer.Validate("Gen. Bus. Posting Group", GenBusinessPostingGroup.Code);
        Customer.Validate("Customer Posting Group", CustomerPostingGroup.Code);
        Customer.Validate("VAT Bus. Posting Group", VatPostingSetup."VAT Bus. Posting Group");
        Customer.Modify(true);

        LibrarySales.CreateSalesOrder(ReturnValue);

        ReturnValue.SetHideValidationDialog(true);

        SalesLine.Reset();
        SalesLine.Setrange("Document Type", ReturnValue."Document Type");
        SalesLine.SetRange("Document No.", ReturnValue."No.");
        SalesLine.DeleteAll(true);

        ReturnValue.Validate("Sell-to Customer No.", Customer."No.");
        ReturnValue.Validate("Posting Date", TODAY);
        ReturnValue.Validate("Ship-to Code", ShiptoAddress.Code);
        ReturnValue.Modify(true);
    end;

    /// <summary>
    /// Создание заказа продажи 
    /// - с новым поставщиком
    /// - адресом
    /// </summary>
    /// <param name="PurchaseHeader"></param>
    /// <returns></returns>
    internal procedure CreateSalesReturnOrder() ReturnValue: Record "Sales Header"
    var
        SalesLine: Record "Sales Line";
        ShiptoAddress: Record "Ship-to Address";
    begin

        LibrarySales.CreateCustomerPostingGroup(CustomerPostingGroup);
        LibrarySales.CreateCustomerWithAddress(Customer);
        LibrarySales.CreateShipToAddress(ShiptoAddress, Customer."No.");

        Customer.Validate("Gen. Bus. Posting Group", GenBusinessPostingGroup.Code);
        Customer.Validate("Customer Posting Group", CustomerPostingGroup.Code);
        Customer.Validate("VAT Bus. Posting Group", VatPostingSetup."VAT Bus. Posting Group");
        Customer.Modify(true);

        LibrarySales.CreateSalesReturnOrder(ReturnValue);

        ReturnValue.SetHideValidationDialog(true);

        SalesLine.Reset();
        SalesLine.Setrange("Document Type", ReturnValue."Document Type");
        SalesLine.SetRange("Document No.", ReturnValue."No.");
        SalesLine.DeleteAll(true);

        ReturnValue.Validate("Sell-to Customer No.", Customer."No.");
        ReturnValue.Validate("Posting Date", TODAY);
        ReturnValue.Validate("Ship-to Code", ShiptoAddress.Code);
        ReturnValue.Modify(true);
    end;

    /// <summary>
    /// Создание нового простого товара
    /// </summary>
    /// <returns></returns>
    internal procedure CreateSimpleItem() ReturnValue: Record Item
    begin
        LibraryInventory.CreateItem(ReturnValue);

        ReturnValue.Validate("Base Unit of Measure", 'PCS');
        ReturnValue.Validate("Gen. Prod. Posting Group", GenProdPositngGroup.Code);
        ReturnValue.Validate("Inventory Posting Group", 'RESALE');
        ReturnValue.Validate("VAT Prod. Posting Group", VatPostingSetup."VAT Prod. Posting Group");
        ReturnValue.Modify(true);

        //Добавляем единицу измерения
        AddUnitOfMeasure(ReturnValue, 'BAG', 50, 0, 0, 0, 0.3, 50.1);

        ReturnValue.Validate("Sales Unit of Measure", 'BAG');
        ReturnValue.Validate("Purch. Unit of Measure", 'BAG');
        ReturnValue.Modify(true);
    end;


    /// <summary>
    /// Добавление новой единицы измерения в товар
    /// </summary>
    /// <param name="Item"></param>
    /// <param name="NewUoM"></param>
    /// <param name="BaseUoMQty"></param>
    /// <param name="Length"></param>
    /// <param name="Width"></param>
    /// <param name="Height"></param>
    /// <param name="Cubage"></param>
    /// <param name="Weight"></param>
    internal procedure AddUnitOfMeasure(var Item: Record Item; NewUoM: Code[10]; BaseUoMQty: Decimal; Length: Decimal; Width: Decimal; Height: Decimal; Cubage: Decimal; Weight: Decimal)
    var
        UnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        if not UnitOfMeasure.Get(NewUoM) then begin
            UnitOfMeasure.Init();
            UnitOfMeasure.Code := NewUoM;
            UnitOfMeasure.Insert(true);
            UnitOfMeasure.Validate(Description, NewUoM);
            UnitOfMeasure.Modify(true);
        end;

        if not ItemUnitOfMeasure.Get(Item."No.", NewUoM) then begin
            ItemUnitOfMeasure.Init();
            ItemUnitOfMeasure.Validate("Item No.", Item."No.");
            ItemUnitOfMeasure.Validate("Code", NewUoM);
            ItemUnitOfMeasure.Insert(true);
        end;

        ItemUnitOfMeasure.Validate("Qty. per Unit of Measure", BaseUoMQty);
        ItemUnitOfMeasure.Validate(Length, Length);
        ItemUnitOfMeasure.Validate(Height, Height);
        ItemUnitOfMeasure.Validate(Width, Width);
        ItemUnitOfMeasure.Validate(Cubage, Cubage);
        ItemUnitOfMeasure.Validate(Weight, Weight);
        ItemUnitOfMeasure.Modify(true);
    end;

    internal procedure CreateUnitBuildRule(UBRCode: Code[20]; Type: Enum "TMAC Content Type"; No: Code[20]; UoM: code[10]; Priority: Integer; BAT: Enum "TMAC Build Action Type"; SplitQty: Decimal; UTC: Code[20]; Blocked: Boolean)
    var
        UnitBuildRuleLine: Record "TMAC Unit Build Rule";
    begin
        UnitBuildRuleLine.Init();
        UnitBuildRuleLine."Unit Build Rule Code" := UBRCode;
        UnitBuildRuleLine.Validate(Type, Type);
        UnitBuildRuleLine.Validate("No.", No);
        UnitBuildRuleLine.Validate("Unit of Measure Code", UoM);
        UnitBuildRuleLine.Validate(Priority, Priority);
        UnitBuildRuleLine.Validate("Build Action Type", BAT);
        UnitBuildRuleLine.Validate("Split Qty.", SplitQty);
        UnitBuildRuleLine.Validate("Unit Type Code", UTC);
        UnitBuildRuleLine.Validate("Remains can be mixed", true);
        UnitBuildRuleLine.Validate(Blocked, Blocked);
        if UnitBuildRuleLine.insert(true) then
            UnitBuildRuleLine.Modify(true);
    end;

    internal procedure CreateNoSeriesWithCheck(NoSeriesCode: Code[20]; Description: Text; StartNo: Code[20]; EndNo: Code[20]) rv: Code[20]
    var
        NoSeries: record "No. Series";
    begin
        if not NoSeries.Get(NoSeriesCode) then
            exit(CreateNoSeries(NoSeriesCode, Description, StartNo, EndNo));
        exit(NoSeriesCode);
    end;

    internal procedure CreateNoSeries(NoSeriesCode: Code[20]; Description: Text; StartNo: Code[20]; EndNo: Code[20]) rv: Code[20]
    var
        NoSeries: record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        NoSeries.Init();
        NoSeries.Code := NoSeriesCode;
        NoSeries.Description := CopyStr(Description, 1, 100);
        NoSeries.Insert(true);
        NoSeries.Validate("Manual Nos.", true);
        NoSeries.Validate("Default Nos.", true);
        NoSeries.Modify(true);

        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := NoSeriesCode;
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine.Insert(true);
        NoSeriesLine.Validate("Starting No.", StartNo);
        NoSeriesLine.Validate("Ending No.", EndNo);
        NoSeriesLine.Validate("Allow Gaps in Nos.", true);
        NoSeriesLine.Modify(true);
        exit(NoSeriesCode);
    end;

    internal procedure CreateUnitType(Code: Code[20]; Description: Text; Description2: Text; PackageType: Code[10];
        LinearUoM: Code[10]; VolumeUoM: Code[10]; WeightUoM: Code[10];
        InternalLength: Decimal; InternalWidth: Decimal; InternalHeight: Decimal; UnitVolume: Decimal; LimitVolumeControl: Boolean;
        TareWeight: Decimal; PayloadWeight: Decimal; MaxWeight: Decimal; LimitWeightControl: Boolean;
        TemperatureControl: Boolean; Ventilation: Boolean; TypeofLoading: Enum "TMAC Load Type"; NoSeriesCode: Code[20])
    var
        UnitType: Record "TMAC Unit Type";
    begin
        UnitType.Init();
        UnitType.Validate(Code, Code);
        UnitType.Validate(Description, Description);
        UnitType.Validate("Description 2", Description2);
        UnitType.Validate("Linear Unit of Measure", LinearUoM);
        UnitType.Validate("Volume Unit of Measure", VolumeUoM);
        UnitType.Validate("Weight Unit of Measure", WeightUoM);
        UnitType.Validate("Internal Length", InternalLength);
        UnitType.Validate("Internal Width", InternalWidth);
        UnitType.Validate("Internal Height", InternalHeight);
        UnitType.Validate("Unit Volume", UnitVolume);
        UnitType.Validate("Limit Filling Volume Control", LimitVolumeControl);
        UnitType.Validate("Tare Weight", TareWeight);
        UnitType.Validate("Payload Weight", PayloadWeight);
        UnitType.Validate("Max Weight", MaxWeight);
        UnitType.Validate("Limit Filling Weight Control", LimitWeightControl);
        UnitType.Validate("Temperature Control", TemperatureControl);
        UnitType.Validate("Ventilation", Ventilation);
        UnitType.Validate("Type of Loading", TypeofLoading);
        UnitType.Validate("No. Series", NoSeriesCode);
        if not UnitType.Insert(true) then
            UnitType.Modify(false);
    end;

    var
        Vendor: Record Vendor;
        Customer: record Customer;
        VendorPostingGroup: Record "Vendor Posting Group";
        GeneralPostingSetup: Record "General Posting Setup";
        GenBusinessPostingGroup: record "Gen. Business Posting Group";
        GenProdPositngGroup: Record "Gen. Product Posting Group";
        VatPostingSetup: Record "VAT Posting Setup";

        //
        CustomerPostingGroup: Record "Customer Posting Group";

        //Framework: Codeunit "EFW Framework";
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";

        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryWarehouse: Codeunit "Library - Warehouse";
}