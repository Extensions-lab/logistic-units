// Функции проверки корректности линков после каких то действий
// Проверка линков

codeunit 71629503 "TMAC Check Links"
{

    #region Common check
    internal procedure OnlyOneUnitLine(UnitNo: Code[20])
    var
        UnitLine: record "TMAC Unit Line";
    begin
        UnitLine.Setrange("Unit No.", UnitNo);
        if UnitLine.Count() <> 1 then
            Error('Only one line must be in logistic unit %1', UnitNo);
    end;
    #endregion
    #region Purchases

    //в паллете есть строки на эту строку покупки и они более менее правильные
    //связь между 2 сущностями на заданное кол-во. Количетсво может быть размазано по паллете (если трассировка например)
    internal procedure BeforePost_Unit_PurchaseLine(ControlQty: decimal; ControlQtyBase: decimal; UnitNo: Code[20]; var PurchaseLine: Record "Purchase Line")
    var
        UnitLine: record "TMAC Unit Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        Checked: Boolean;
        TotalQuantity: Decimal;
        TotalQuantityBase: Decimal;
        TotalExpectedQuantity: Decimal;
        TotalExpectedQuantityBase: Decimal;
        TotalInventoryQuantity: Decimal;
        TotalInventoryQuantityBase: Decimal;
    begin
        PurchaseLine.Find('=');
        if ControlQty = 0 then
            error('ControlQty = 0');

        UnitLine.Reset();
        UnitLine.Setrange("Unit No.", UnitNo);
        UnitLine.Setrange("No.", PurchaseLine."No.");
        if UnitLine.FindSet() then
            repeat
                UnitLine.CalcFields("Expected Quantity", "Expected Quantity (Base)", "Inventory Quantity", "Inventory Quantity (Base)");

                UnitLineLink.Reset();
                UnitLineLink.Setrange("Unit No.", UnitNo);
                UnitLineLink.Setrange("Unit Line No.", UnitLine."Line No.");
                UnitLineLink.SetRange("Source Type", Database::"Purchase Line"); //первый линк на учт. покупку
                UnitLineLink.SetRange("Source Subtype", PurchaseLine."Document Type".AsInteger());
                UnitLineLink.SetRange("Source ID", PurchaseLine."Document No.");
                UnitLineLink.SetRange("Source Ref. No.", PurchaseLine."Line No.");
                if UnitLineLink.FindFirst() then begin //если есть строка с линком на строку покупки
                    UnitLineLink.TestField(Positive, true);
                    UnitLineLink.TestField(Quantity, UnitLine.Quantity);
                    UnitLineLink.TestField("Unit of Measure Code", PurchaseLine."Unit of Measure Code");
                    UnitLineLInk.TestField("Quantity (Base)", UnitLine."Quantity (Base)");
                    UnitLineLInk.TestField("Qty. per UoM", PurchaseLine."Qty. per Unit of Measure");
                    UnitLineLInk.TestField("Qty. to Post", 0);
                    UnitLineLInk.TestField("Posted", false);
                    UnitLineLInk.TestField("Calculation", true);
                    UnitLineLInk.TestField("Posted Quantity", 0);

                    TotalQuantity += UnitLine.Quantity;
                    TotalQuantityBase += UnitLine."Quantity (Base)";
                    TotalExpectedQuantity += UnitLine."Expected Quantity";
                    TotalExpectedQuantityBase += UnitLine."Expected Quantity (Base)";
                    TotalInventoryQuantity += UnitLine."Inventory Quantity";
                    TotalInventoryQuantityBase += UnitLine."Inventory Quantity (Base)";

                    UnitLine.TestField("Location Code", PurchaseLine."Location Code");

                    checked := true;
                end;
            until UnitLine.Next() = 0;

        if TotalQuantity <> ControlQty then
            Error('TotalQuantity %1 <> ControlQty %2 ',TotalQuantity, ControlQty);
        if TotalQuantityBase <> ControlQtyBase then
            Error('TotalQuantityBase %1 <> ControlQtyBase %2',TotalQuantityBase, ControlQtyBase);
        if TotalExpectedQuantity <> ControlQty then
            Error('TotalExpectedQuantity %1 <> ControlQty %2 ', TotalExpectedQuantity, ControlQty);
        if TotalExpectedQuantityBase <> ControlQtyBase then
            Error('TotalExpectedQuantityBase %1 <> ControlQtyBase %2',TotalExpectedQuantity, ControlQtyBase);
        if TotalInventoryQuantity <> 0 then
            Error('TotalInventoryQuantity %1 <> 0',TotalInventoryQuantity);
        if TotalInventoryQuantityBase <> 0 then
            Error('TotalInventoryQuantityBase %1 <> 0',TotalInventoryQuantityBase);
        if not checked then
            error('There is no link between %1 and %2 %3 purchase line', UnitNo, PurchaseLine."Document No.", PurchaseLine."Line No.");
    end;

    internal procedure AfterPost_Unit_PurchaseLine(ControlQty: decimal; ControlQtyBase: decimal; UnitNo: Code[20]; var PurchaseLine: Record "Purchase Line")
    var
        UnitLine: Record "TMAC Unit Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        Checked: Boolean;
        TotalQuantity: Decimal;
        TotalQuantityBase: Decimal;
        TotalExpectedQuantity: Decimal;
        TotalExpectedQuantityBase: Decimal;
        TotalInventoryQuantity: Decimal;
        TotalInventoryQuantityBase: Decimal;
    begin
        PurchaseLine.Find('=');
        UnitLine.Reset();
        UnitLine.Setrange("Unit No.", UnitNo);
        if UnitLine.FindSet() then
            repeat
                UnitLine.CalcFields("Expected Quantity", "Expected Quantity (Base)", "Inventory Quantity", "Inventory Quantity (Base)");

                UnitLineLink.Reset();
                UnitLineLink.Setrange("Unit No.", UnitNo);
                UnitLineLink.Setrange("Unit Line No.", UnitLine."Line No.");
                UnitLineLink.SetRange("Source Type", Database::"Purchase Line");
                UnitLineLink.SetRange("Source Subtype", PurchaseLine."Document Type".AsInteger());
                UnitLineLink.SetRange("Source ID", PurchaseLine."Document No.");
                UnitLineLink.SetRange("Source Ref. No.", PurchaseLine."Line No.");
                if UnitLineLink.FindFirst() then begin
                    UnitLineLink.TestField(Positive, true);
                    UnitLineLink.TestField(Quantity, 0);
                    UnitLineLink.TestField("Unit of Measure Code", PurchaseLine."Unit of Measure Code");
                    UnitLineLInk.TestField("Quantity (Base)", 0);
                    UnitLineLInk.TestField("Qty. per UoM", PurchaseLine."Qty. per Unit of Measure");
                    UnitLineLInk.TestField("Qty. to Post", 0);
                    UnitLineLInk.TestField("Posted", false);
                    UnitLineLInk.TestField("Calculation", true);
                    UnitLineLInk.TestField("Posted Quantity", UnitLine.Quantity);
                    checked := true;

                    TotalQuantity += UnitLine.Quantity;
                    TotalQuantityBase += UnitLine."Quantity (Base)";
                    TotalExpectedQuantity += UnitLine."Expected Quantity";
                    TotalExpectedQuantityBase += UnitLine."Expected Quantity (Base)";
                    TotalInventoryQuantity += UnitLine."Inventory Quantity";
                    TotalInventoryQuantityBase += UnitLine."Inventory Quantity (Base)";

                    UnitLine.TestField("Location Code", PurchaseLine."Location Code");
                end;
            until UnitLine.Next() = 0;

        if TotalQuantity <> ControlQty then
            Error('TotalQuantity %1 <> ControlQty %2 ',TotalQuantity, ControlQty);
        if TotalQuantityBase <> ControlQtyBase then
            Error('TotalQuantityBase %1 <> ControlQtyBase %2',TotalQuantityBase, ControlQtyBase);
        if TotalExpectedQuantity <> ControlQty then
            Error('TotalExpectedQuantity %1 <> ControlQty %2 ', TotalExpectedQuantity, ControlQty);
        if TotalExpectedQuantityBase <> ControlQtyBase then
            Error('TotalExpectedQuantityBase %1 <> ControlQtyBase %2',TotalExpectedQuantityBase, ControlQtyBase);
        if TotalInventoryQuantity <> ControlQty then
            Error('TotalInventoryQuantity %1 <> ControlQty %2',TotalInventoryQuantity, ControlQty); 
        if TotalInventoryQuantityBase <> ControlQtyBase then
            Error('TotalInventoryQuantityBase %1 <> ControlQtyBase %2',TotalInventoryQuantityBase, ControlQtyBase);
        
        if not checked then
            error('There is no link between %1 and %2 %3 purchase line', UnitNo, PurchaseLine."Document No.", PurchaseLine."Line No.");
    end;

    internal procedure AfterPost_Unit_PurchRcptLine(ControlQty: decimal; ControlQtyBase: decimal; UnitNo: Code[20]; var PurchRcptLine: Record "Purch. Rcpt. Line")
    var
        UnitLine: Record "TMAC Unit Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        Checked: Boolean;
        TotalQuantity: Decimal;
        TotalQuantityBase: Decimal;
        TotalExpectedQuantity: Decimal;
        TotalExpectedQuantityBase: Decimal;
        TotalInventoryQuantity: Decimal;
        TotalInventoryQuantityBase: Decimal;
    begin
        UnitLine.Reset();
        UnitLine.Setrange("Unit No.", UnitNo);
        if UnitLine.FindSet() then
            repeat
                UnitLine.CalcFields("Expected Quantity", "Expected Quantity (Base)", "Inventory Quantity", "Inventory Quantity (Base)");

                UnitLineLink.Reset();
                UnitLineLink.Setrange("Unit No.", UnitNo);
                UnitLineLink.Setrange("Unit Line No.", UnitLine."Line No.");
                UnitLineLink.SetRange("Source Type", Database::"Purch. Rcpt. Line"); //первый линк на учт. покупку
                UnitLineLink.SetRange("Source Subtype", 0);
                UnitLineLink.SetRange("Source ID", PurchRcptLine."Document No.");
                UnitLineLink.SetRange("Source Ref. No.", PurchRcptLine."Line No.");
                if UnitLineLink.FindFirst() then begin
                    UnitLineLink.TestField(Positive, true);
                    UnitLineLink.TestField(Quantity, UnitLine.Quantity);
                    UnitLineLink.TestField("Unit of Measure Code", PurchRcptLine."Unit of Measure Code");
                    UnitLineLInk.TestField("Quantity (Base)", UnitLine."Quantity (Base)");
                    UnitLineLInk.TestField("Qty. per UoM", UnitLine."Qty. per Unit of Measure");
                    UnitLineLInk.TestField("Qty. to Post", 0);
                    UnitLineLInk.TestField("Posted", true);
                    UnitLineLInk.TestField("Calculation", true);
                    UnitLineLink.TestField("Posted Quantity", 0);

                    TotalQuantity += UnitLine.Quantity;
                    TotalQuantityBase += UnitLine."Quantity (Base)";
                    TotalExpectedQuantity += UnitLine."Expected Quantity";
                    TotalExpectedQuantityBase += UnitLine."Expected Quantity (Base)";
                    TotalInventoryQuantity += UnitLine."Inventory Quantity";
                    TotalInventoryQuantityBase += UnitLine."Inventory Quantity (Base)";

                    UnitLine.TestField("Location Code", PurchRcptLine."Location Code");

                    Checked := true;
                end;
            until UnitLine.Next() = 0;

        if TotalQuantity <> ControlQty then
            Error('TotalQuantity %1 <> ControlQty %2 ',TotalQuantity, ControlQty);
        if TotalQuantityBase <> ControlQtyBase then
            Error('TotalQuantityBase %1 <> ControlQtyBase %2',TotalQuantityBase, ControlQtyBase);
        if TotalExpectedQuantity <> ControlQty then
            Error('TotalExpectedQuantity %1 <> ControlQty %2 ', TotalExpectedQuantity, ControlQty);
        if TotalExpectedQuantityBase <> ControlQtyBase then
            Error('TotalExpectedQuantityBase %1 <> ControlQtyBase %2',TotalExpectedQuantityBase, ControlQtyBase);
        if TotalInventoryQuantity <> ControlQty then
            Error('TotalInventoryQuantity %1 <> ControlQty %2',TotalInventoryQuantity, ControlQty); 
        if TotalInventoryQuantityBase <> ControlQtyBase then
            Error('TotalInventoryQuantityBase %1 <> ControlQtyBase %2',TotalInventoryQuantityBase, ControlQtyBase);
        
        if not checked then
            error('There is no link between %1 and %2 %3 PurchRcptLine line', UnitNo, PurchRcptLine."Document No.", PurchRcptLine."Line No.");
    end;
    #endregion

    #region Sales

    internal procedure BeforePost_SalesLine_UnitLine(UnitNo: Code[20]; var SalesLine: Record "Sales Line")
    var
        UnitLine: record "TMAC Unit Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        checked: Boolean;
    begin
        SalesLine.Find('=');
        UnitLine.Reset();
        UnitLine.Setrange("Unit No.", UnitNo);
        if UnitLine.FindSet() then
            repeat
                UnitLineLink.Reset();
                UnitLineLink.Setrange("Unit No.", UnitNo);
                UnitLineLink.Setrange("Unit Line No.", UnitLine."Line No.");
                UnitLineLink.SetRange("Source Type", Database::"Sales Line"); //первый линк на учт. покупку
                UnitLineLink.SetRange("Source Subtype", SalesLine."Document Type".AsInteger());
                UnitLineLink.SetRange("Source ID", SalesLine."Document No.");
                UnitLineLink.SetRange("Source Ref. No.", SalesLine."Line No.");
                if UnitLineLink.FindFirst() then begin
                    UnitLineLink.TestField(Positive, false);
                    UnitLineLink.TestField(Quantity, -UnitLine.Quantity);
                    UnitLineLink.TestField("Unit of Measure Code", SalesLine."Unit of Measure Code");
                    UnitLineLInk.TestField("Quantity (Base)", -UnitLine."Quantity (Base)");
                    UnitLineLInk.TestField("Qty. per UoM", SalesLine."Qty. per Unit of Measure");
                    UnitLineLInk.TestField("Qty. to Post", 0);
                    UnitLineLInk.TestField("Posted", false);
                    UnitLineLInk.TestField("Calculation", true);
                    UnitLineLInk.TestField("Posted Quantity", 0);
                    checked := true;
                end;
            until UnitLine.Next() = 0;

        if not checked then
            error('There is no link between %1 and %2 %3 SalesLine line', UnitNo, SalesLine."Document No.", SalesLine."Line No.");
    end;

    internal procedure AfterPost_SalesLine_UnitLine(UnitNo: Code[20]; var SalesLine: Record "Sales Line")
    var
        UnitLine: Record "TMAC Unit Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        checked: Boolean;
    begin
        SalesLine.Find('=');
        //каждая строка логистической единицы это
        UnitLine.Reset();
        UnitLine.Setrange("Unit No.", UnitNo);
        if UnitLine.FindSet() then
            repeat
                UnitLineLink.Reset();
                UnitLineLink.Setrange("Unit No.", UnitNo);
                UnitLineLink.Setrange("Unit Line No.", UnitLine."Line No.");
                UnitLineLink.SetRange("Source Type", Database::"Sales Line"); //первый линк на учт. покупку
                UnitLineLink.SetRange("Source Subtype", SalesLine."Document Type".AsInteger());
                UnitLineLink.SetRange("Source ID", SalesLine."Document No.");
                UnitLineLink.SetRange("Source Ref. No.", SalesLine."Line No.");
                if UnitLineLink.FindFirst() then begin
                    UnitLineLink.TestField(Positive, false);
                    UnitLineLink.TestField(Quantity, 0);
                    UnitLineLink.TestField("Unit of Measure Code", SalesLine."Unit of Measure Code");
                    UnitLineLInk.TestField("Quantity (Base)", 0);
                    UnitLineLInk.TestField("Qty. per UoM", SalesLine."Qty. per Unit of Measure");
                    UnitLineLInk.TestField("Qty. to Post", 0);
                    UnitLineLInk.TestField("Posted", false);
                    UnitLineLInk.TestField("Calculation", true);
                    UnitLineLInk.TestField("Posted Quantity", -UnitLine.Quantity);
                    checked := true;
                end;
            until UnitLine.Next() = 0;
        if not checked then
            error('There is no link between %1 and %2 %3 SalesLine line', UnitNo, SalesLine."Document No.", SalesLine."Line No.");
    end;

    internal procedure AfterPost_SalesShipmentLine_UnitLine(UnitNo: Code[20]; var SalesShipmentLine: Record "Sales Shipment Line")
    var
        UnitLine: Record "TMAC Unit Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        checked: Boolean;
    begin
        //каждая строка логистической единицы это
        UnitLine.Reset();
        UnitLine.Setrange("Unit No.", UnitNo);
        if UnitLine.FindSet() then
            repeat
                UnitLineLink.Reset();
                UnitLineLink.Setrange("Unit No.", UnitNo);
                UnitLineLink.Setrange("Unit Line No.", UnitLine."Line No.");
                UnitLineLink.SetRange("Source Type", Database::"Sales Shipment Line"); //первый линк на учт. покупку
                UnitLineLink.SetRange("Source Subtype", 0);
                UnitLineLink.SetRange("Source ID", SalesShipmentLine."Document No.");
                UnitLineLink.SetRange("Source Ref. No.", SalesShipmentLine."Line No.");
                if UnitLineLink.FindFirst() then begin
                    UnitLineLink.TestField(Positive, false);
                    UnitLineLink.TestField(Quantity, -UnitLine.Quantity);
                    UnitLineLink.TestField("Unit of Measure Code", SalesShipmentLine."Unit of Measure Code");
                    UnitLineLInk.TestField("Quantity (Base)", -UnitLine."Quantity (Base)");
                    UnitLineLInk.TestField("Qty. per UoM", UnitLine."Qty. per Unit of Measure");
                    UnitLineLInk.TestField("Qty. to Post", 0);
                    UnitLineLInk.TestField("Posted", true);
                    UnitLineLInk.TestField("Calculation", true);
                    UnitLineLink.TestField("Posted Quantity", 0);
                    checked := true;
                end;
            until UnitLine.Next() = 0;

        if not checked then
            error('There is no link between %1 and %2 %3 SalesShipmentLine line', UnitNo, SalesShipmentLine."Document No.", SalesShipmentLine."Line No.");
    end;
    #endregion

    #region Warehouse Receipt
    internal procedure AfterPost_WarehouseReceiptLine_UnitLine(UnitNo: Code[20]; var WarehousePurchseLine: Record "Warehouse Receipt Line")
    var
        UnitLine: Record "TMAC Unit Line";
        UnitLineLink: Record "TMAC Unit Line Link";
        checked: Boolean;
    begin
        UnitLine.Reset();
        UnitLine.Setrange("Unit No.", UnitNo);
        if UnitLine.FindSet() then
            repeat
                UnitLineLink.Reset();
                UnitLineLink.Setrange("Unit No.", UnitNo);
                UnitLineLink.Setrange("Unit Line No.", UnitLine."Line No.");
                UnitLineLink.SetRange("Source Type", Database::"Warehouse Receipt Line"); //первый линк на учт. покупку
                UnitLineLink.SetRange("Source Subtype", 0);
                UnitLineLink.SetRange("Source ID", WarehousePurchseLine."No.");
                UnitLineLink.SetRange("Source Ref. No.", WarehousePurchseLine."Line No.");
                if UnitLineLink.FindFirst() then begin
                    UnitLineLink.TestField(Positive, true);
                    UnitLineLink.TestField(Quantity, 0);
                    UnitLineLink.TestField("Unit of Measure Code", WarehousePurchseLine."Unit of Measure Code");
                    UnitLineLInk.TestField("Quantity (Base)", 0);
                    UnitLineLInk.TestField("Qty. per UoM", UnitLine."Qty. per Unit of Measure");
                    UnitLineLInk.TestField("Qty. to Post", 0);
                    UnitLineLInk.TestField("Posted", false);
                    UnitLineLInk.TestField("Calculation", false);
                    UnitLineLink.TestField("Posted Quantity", UnitLine.Quantity);
                    checked := true;
                end;
            until UnitLine.Next() = 0;

        if not checked then
            error('There is no link between %1 and %2 %3 WarehousePurchseLine line', UnitNo, WarehousePurchseLine."No.", WarehousePurchseLine."Line No.");
    end;
    #endregion
}
