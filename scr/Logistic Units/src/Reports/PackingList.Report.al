report 71628577 "TMAC Packing List"
{
    ApplicationArea = All;
    Caption = 'Packing List';
    UsageCategory = ReportsAndAnalysis;
    WordLayout = './src/Reports/Layouts/PackingList.docx';
    DefaultLayout = Word;
    PreviewMode = PrintLayout;
    WordMergeDataItem = Header;

    dataset
    {
        dataitem(Header; "Warehouse Shipment Header")
        {
            #region Header Fields
            column(No; Header."No.")
            {
            }
            column(ShipmentDate; Header."Shipment Date")
            {
            }

            column(CompanyAddress1; CompanyAddr[1])
            {
            }
            column(CompanyAddress2; CompanyAddr[2])
            {
            }
            column(CompanyAddress3; CompanyAddr[3])
            {
            }
            column(CompanyAddress4; CompanyAddr[4])
            {
            }
            column(CompanyAddress5; CompanyAddr[5])
            {
            }
            column(CompanyAddress6; CompanyAddr[6])
            {
            }
            column(CompanyAddress7; CompanyAddr[7])
            {
            }
            column(CompanyAddress8; CompanyAddr[8])
            {
            }
            //column(CompanyHomePage; CompanyInformation."Home Page")
            column(CompanyHomePage; '')
            {
            }
            column(CompanyEMail; CompanyInformation."E-Mail")
            {
            }
            column(CompanyPicture; DummyCompanyInformation.Picture)
            {
            }
            column(CompanyPhoneNo; CompanyInformation."Phone No.")
            {
            }
            column(PrintByUserName; GetUserName())
            {
            }
            #endregion
            dataitem(SourceDocuments; "TMAC Source Document Link")
            {
                DataItemTableView = sorting("Source Type", "Source Subtype", "Source ID", "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.", "Package No.", "Lot No.", "Serial No.", "Positive");

                //поля источника
                column(SourceID; SourceDocuments."Source ID")
                {
                }
                column(SourceName; UnitLinkManagement.GetSourceName(SourceDocuments."Source Type", SourceDocuments."Source Subtype"))
                {
                }
                column(ShipTo; ShipTo)
                {
                }
                column(ShipToCity; ShipToCity)
                {
                }
                column(ShipToPostCode; ShipToPostCode)
                {
                }
                column(ShipToAddress; ShipToAddress)
                {
                }

                dataitem(LogisticUnits; Integer)
                {
                    DataItemTableView = sorting(Number);

                    #region Unit Fields
                    column(UnitNo; Unit."No.")
                    {
                    }
                    column(UnitDescription; Unit.Description)
                    {
                    }
                    column(UnitContentWeight; Unit."Content Weight (Base)")
                    {
                    }
                    column(UnitContentVolume; Unit."Content Volume (Base)")
                    {
                    }
                    column(UnitShippingAgent; Unit."Shipping Agent Code")
                    {
                    }
                    column(UnitSSCCNo; Unit."SSCC No.")
                    {
                    }
                    column(UnitBarcode; Unit.Barcode)
                    {
                    }
                    column(UnitType; Unit."Type Code")
                    {
                    }
                    column(UnitTrackingNo; Unit."Tracking No.")
                    {
                    }
                    column(UnitWeight; Unit.Width)
                    {
                    }
                    column(UnitVolume; Unit.Volume)
                    {
                    }
                    #endregion

                    dataitem(Lines; Integer)
                    {
                        DataItemTableView = sorting(Number);
                        //Строки отгрузки входящей в паллету

                        column(ItemNo; TempWarehouseShipmentLine."Item No.")
                        {
                        }
                        column(VariantCode; TempWarehouseShipmentLine."Variant Code")
                        {
                        }
                        column(Description; TempWarehouseShipmentLine.Description)
                        {
                        }
                        column(Quantity; TempWarehouseShipmentLine.Quantity)
                        {
                        }
                        column(QuantityBase; TempWarehouseShipmentLine."Qty. (Base)")
                        {
                        }

                        trigger OnPreDataItem()
                        begin
                            SETRANGE(Number, 1, TempWarehouseShipmentLine.Count);
                        end;

                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 then
                                TempWarehouseShipmentLine.FindFirst()
                            else
                                TempWarehouseShipmentLine.Next();
                        end;
                    }

                    trigger OnPreDataItem()
                    begin
                        SETRANGE(Number, 1, Units.Count);
                    end;

                    trigger OnAfterGetRecord()
                    var
                        WarehouseShipmentLine: record "Warehouse Shipment Line";
                        UnitLineLink: Record "TMAC Unit Line Link";
                        CurrentUnit: Code[20];
                    begin
                        Units.Get(LogisticUnits.Number, CurrentUnit);
                        Unit.Get(CurrentUnit);

                        TempWarehouseShipmentLine.DeleteAll(false);

                        UnitLineLink.Setrange("Unit No.", CurrentUnit);
                        UnitLineLink.Setrange("Source Type", Database::"Warehouse Shipment Line");
                        UnitLineLink.Setrange("Source Subtype", 0);
                        UnitLineLink.Setrange("Source ID", Header."No.");
                        if UnitLineLink.Findset(false) then
                            repeat
                                if WarehouseShipmentLine.Get(UnitLineLink."Source ID", UnitLineLink."Source Ref. No.") then begin
                                    TempWarehouseShipmentLine.Init();
                                    TempWarehouseShipmentLine.TransferFields(WarehouseShipmentLine);
                                    TempWarehouseShipmentLine.Quantity := Abs(UnitLineLink.Quantity);
                                    TempWarehouseShipmentLine."Qty. (Base)" := Abs(UnitLineLink."Quantity (Base)");
                                    if not TempWarehouseShipmentLine.Insert(false) then begin
                                        TempWarehouseShipmentLine.Get(UnitLineLink."Source ID", UnitLineLink."Source Ref. No.");
                                        TempWarehouseShipmentLine.Quantity += Abs(UnitLineLink.Quantity);
                                        TempWarehouseShipmentLine."Qty. (Base)" += Abs(UnitLineLink."Quantity (Base)");
                                        TempWarehouseShipmentLine.Modify(false);
                                    end;
                                end;
                            until UnitLineLink.Next() = 0;

                    end;
                }

                trigger OnAfterGetRecord()
                var
                    SalesHeader: Record "Sales Header";
                    TransferHeader: Record "Transfer Header";
                    PurchaseHeader: Record "Purchase Header";
                    UnitLineLink: Record "TMAC Unit Line Link";
                begin
                    //паллеты в разрезе источника
                    System.Clear(Units);
                    UnitLineLink.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.", "Package No.", "Lot No.", "Serial No.", "Positive", "Qty. to Post");
                    UnitLineLink.Setrange("Source Type", SourceDocuments."Source Type");
                    UnitLineLink.Setrange("Source Subtype", SourceDocuments."Source Subtype");
                    UnitLineLink.Setrange("Source ID", SourceDocuments."Source ID");
                    UnitLineLink.SetLoadFields("Unit No.");
                    if UnitLineLink.Findset(false) then
                        repeat
                            if not Units.Contains(UnitLineLink."Unit No.") then
                                Units.Add(UnitLineLink."Unit No.");
                        until UnitLineLink.Next() = 0;

                    ShipTo := '';
                    ShipToAddress := '';
                    ShipToCity := '';
                    ShipToPostCode := '';
                    ShipToCounty := '';

                    case SourceDocuments."Source Type" of
                        Database::"Sales Line":

                            if SalesHeader.Get(SourceDocuments."Source Subtype", SourceDocuments."Source ID") then begin
                                ShipTo := SalesHeader."Sell-to Customer Name" + SalesHeader."Sell-to Customer Name 2";
                                ShipToAddress := SalesHeader."Sell-to Address" + SalesHeader."Sell-to Address 2";
                                ShipToCity := SalesHeader."Sell-to City";
                                ShipToPostCode := SalesHeader."Sell-to Post Code";
                                ShipToCounty := SalesHeader."Sell-to County";
                            end;
                        Database::"Transfer Line":
                            if TransferHeader.Get(SourceDocuments."Source ID") then begin
                                ShipTo := TransferHeader."Transfer-to Code";
                                ShipToAddress := TransferHeader."Transfer-to Address" + TransferHeader."Transfer-to Address 2";
                                ShipToCity := TransferHeader."Transfer-to City";
                                ShipToPostCode := TransferHeader."Transfer-to Post Code";
                                ShipToCounty := TransferHeader."Transfer-to County";
                            end;
                        Database::"Purchase Line":
                            if PurchaseHeader.Get(SourceDocuments."Source Subtype", SourceDocuments."Source ID") then begin
                                ShipTo := PurchaseHeader."Buy-from Vendor Name" + PurchaseHeader."Buy-from Vendor Name 2";
                                ShipToAddress := PurchaseHeader."Buy-from Address" + PurchaseHeader."Buy-from Address 2";
                                ShipToCity := PurchaseHeader."Buy-from City";
                                ShipToPostCode := PurchaseHeader."Buy-from Post Code";
                                ShipToCounty := PurchaseHeader."Buy-from County";
                            end;
                    end;
                end;
            }

            trigger OnAfterGetRecord()
            var
                WarehouseShipmentLine: Record "Warehouse Shipment Line";
            begin
                //список источников
                SourceDocuments.DeleteAll();
                WarehouseShipmentLine.SetRange("No.", Header."No.");
                WarehouseShipmentLine.Setfilter(Quantity, '>0');
                if WarehouseShipmentLine.Findset() then
                    repeat
                        SourceDocuments.Init();
                        SourceDocuments.Clear();
                        SourceDocuments."Source Type" := WarehouseShipmentLine."Source Type";
                        SourceDocuments."Source Subtype" := WarehouseShipmentLine."Source Subtype";
                        SourceDocuments."Source ID" := WarehouseShipmentLine."Source No.";
                        if SourceDocuments.Insert(false) then;
                    until WarehouseShipmentLine.Next() = 0;
            end;
        }
    }

    trigger OnInitReport()
    begin
        CompanyInformation.SetAutoCalcFields(Picture);
        CompanyInformation.Get();
        DummyCompanyInformation.Picture := CompanyInformation.Picture;
        FormatAddress.Company(CompanyAddr, CompanyInformation);
    end;

    local procedure GetUserName(): Text;
    var
        User: Record User;
    begin
        User.Setrange("User Name", UserId);
        if User.FindFirst() then
            if User."Full Name" <> '' then
                exit(User."Full Name")
            else
                exit(UserId);
    end;

    var
        TempWarehouseShipmentLine: record "Warehouse Shipment Line" temporary;
        Unit: Record "TMAC Unit";
        CompanyInformation: Record "Company Information";
        DummyCompanyInformation: Record "Company Information";
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
        FormatAddress: Codeunit "Format Address";
        Units: List of [code[20]];
        CompanyAddr: array[8] of Text[100];
        ShipTo: Text;
        ShipToAddress: text;
        ShipToCity: Text;
        ShipToPostCode: Text;
        ShipToCounty: Text;
}
