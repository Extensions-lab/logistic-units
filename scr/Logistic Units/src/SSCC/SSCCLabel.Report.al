report 71628575 "TMAC SSCC Label"
{
    ApplicationArea = All;
    Caption = 'SSCC';
    UsageCategory = ReportsAndAnalysis;
    WordLayout = './src/SSCC/sscc.docx';
    DefaultLayout = Word;
    PreviewMode = PrintLayout;
    WordMergeDataItem = Header;
    dataset
    {
        dataitem(Header; Integer)
        {
            DataItemTableView = sorting(Number);

            column(No; SSCC."No.")
            {
            }
            column(CompanyPicture; CompanyInformation.Picture)
            {
            }
            column(CompanyEMail; CompanyInformation."E-Mail")
            {
            }

            column(CompanyHomePage; '')
            {
            }
            column(CompanyPhoneNo; CompanyInformation."Phone No.")
            {
            }
            column(CompanyVATRegNo; CompanyInformation.GetVATRegistrationNumber())
            {
            }
            column(CompanyAddress1; CompanyAddress[1])
            {
            }
            column(CompanyAddress2; CompanyAddress[2])
            {
            }
            column(CompanyAddress3; CompanyAddress[3])
            {
            }
            column(CompanyAddress4; CompanyAddress[4])
            {
            }
            column(CompanyAddress5; CompanyAddress[5])
            {
            }

            column(CarrierName; SSCC."Carrier Name")
            {
            }
            column(From; SSCC.From)
            {
            }
            column(To; SSCC."To")
            {
            }
            column(Description; SSCC.Description)
            {
            }
            column(BillofLandingNumber; SSCC."Bill of Landing Number")
            {
            }

            column(Weight; SSCC.Weight)
            {
            }

            column(Volume; SSCC.Volume)
            {
            }
            column(BarCode1; BarCode1)
            {
            }
            column(BarCode2; BarCode2)
            {
            }
            column(BarCode3; BarCode3)
            {
            }
            column(BarCode1Text; BarCode1Text)
            {
            }
            column(BarCode2Text; BarCode2Text)
            {
            }
            column(BarCode3Text; BarCode3Text)
            {
            }
            column(LabelText1; LabelText1)
            {
            }
            column(LabelText2; LabelText2)
            {
            }
            column(LabelText3; LabelText3)
            {
            }
            column(LabelText4; LabelText4)
            {
            }


            trigger OnPreDataItem()
            begin
                SetRange(Number, 1, TempSSCC.Count);
            end;

            trigger OnAfterGetRecord()
            var
                SSCCLine: Record "TMAC SSCC Line";
                BarcodeSymbology: Enum "Barcode Symbology";
                BarcodeSymbology2D: Enum "Barcode Symbology 2D";
                BarcodeFontProvider: Interface "Barcode Font Provider";
                BarcodeFontProvider2D: Interface "Barcode Font Provider 2D";
                BarCode1Type: enum "TMAC SSCC Barcode Type";
                BarCode2Type: enum "TMAC SSCC Barcode Type";
                BarCode3Type: enum "TMAC SSCC Barcode Type";
            begin
                if Number = 1 then
                    TempSSCC.FindFirst()
                else
                    TempSSCC.Next();

                SSCC.TransferFields(TempSSCC);

                FormatAddress.Company(CompanyAddress, CompanyInformation);

                BarCode1Value := '';
                BarCode2Value := '';
                BarCode3Value := '';

                BarCode1Text := '';
                BarCode2Text := '';
                BarCode3Text := '';

                LabelText1 := '';
                LabelText2 := '';
                LabelText3 := '';
                LabelText4 := '';

                SSCCLine.Reset();
                SSCCLine.SetCurrentKey("SSCC No.", "Barcode");
                SSCCLine.SetRange("SSCC No.", SSCC."No.");
                SSCCLine.SetFilter("Barcode", '>0');
                if SSCCLine.Findset(false) then
                    repeat
                        case SSCCLine."Barcode" of
                            "TMAC SSCC Barcode Place"::"Barcode 1":
                                begin
                                    BarCode1Value += SSCCLine.Identifier + SSCCLine.Value;
                                    BarCode1Text += ' (' + SSCCLine.Identifier + ')' + SSCCLine.Value;
                                    if SSCCLine."Barcode Type" <> "TMAC SSCC Barcode Type"::None then
                                        BarCode1Type := SSCCLine."Barcode Type";
                                end;
                            "TMAC SSCC Barcode Place"::"Barcode 2":
                                begin
                                    BarCode2Value += SSCCLine.Identifier + SSCCLine.Value;
                                    BarCode2Text += ' (' + SSCCLine.Identifier + ')' + SSCCLine.Value;
                                    if SSCCLine."Barcode Type" <> "TMAC SSCC Barcode Type"::None then
                                        BarCode2Type := SSCCLine."Barcode Type";
                                end;
                            "TMAC SSCC Barcode Place"::"Barcode 3":
                                begin
                                    BarCode3Value += SSCCLine.Identifier + SSCCLine.Value;
                                    BarCode3Text += ' (' + SSCCLine.Identifier + ')' + SSCCLine.Value;
                                    if SSCCLine."Barcode Type" <> "TMAC SSCC Barcode Type"::None then
                                        BarCode3Type := SSCCLine."Barcode Type";
                                end;
                        end;
                    until SSCCLine.next() = 0;

                SSCCLine.Reset();
                SSCCLine.SetRange("SSCC No.", SSCC."No.");
                if SSCCLine.FindSet() then
                    repeat
                        case SSCCLine."Label Text" of
                            "TMAC SSCC Label Text Number"::"Label Text 1":
                                LabelText1 := SSCCLine.Value;
                            "TMAC SSCC Label Text Number"::"Label Text 2":
                                LabelText2 := SSCCLine.Value;
                            "TMAC SSCC Label Text Number"::"Label Text 3":
                                LabelText3 := SSCCLine.Value;
                            "TMAC SSCC Label Text Number"::"Label Text 4":
                                LabelText4 := SSCCLine.Value;
                        end;
                    until SSCCLine.Next() = 0;

                case SSCCManagement.GetDimensionOfBarCode(BarCode1Type) of
                    1:
                        begin
                            BarcodeFontProvider := Enum::"Barcode Font Provider"::IDAutomation1D;
                            BarcodeSymbology := SSCCManagement.GetBarcodeSymbology1D(BarCode1Type);
                            BarcodeFontProvider.ValidateInput(BarCode1Value, BarcodeSymbology);
                            BarCode1 := BarcodeFontProvider.EncodeFont(BarCode1Value, BarcodeSymbology);
                        end;
                    2:
                        begin
                            BarcodeFontProvider2D := Enum::"Barcode Font Provider 2D"::IDAutomation2D;
                            BarcodeSymbology2D := SSCCManagement.GetBarcodeSymbol2D(BarCode1Type);
                            BarCode1 := BarcodeFontProvider2D.EncodeFont(BarCode1Value, BarcodeSymbology2D);
                        end;
                end;

                case SSCCManagement.GetDimensionOfBarCode(BarCode2Type) of
                    1:
                        begin
                            BarcodeFontProvider := Enum::"Barcode Font Provider"::IDAutomation1D;
                            BarcodeSymbology := SSCCManagement.GetBarcodeSymbology1D(BarCode2Type);
                            BarcodeFontProvider.ValidateInput(BarCode2Value, BarcodeSymbology);
                            BarCode2 := BarcodeFontProvider.EncodeFont(BarCode2Value, BarcodeSymbology);
                        end;
                    2:
                        begin
                            BarcodeFontProvider2D := Enum::"Barcode Font Provider 2D"::IDAutomation2D;
                            BarcodeSymbology2D := SSCCManagement.GetBarcodeSymbol2D(BarCode2Type);
                            BarCode2 := BarcodeFontProvider2D.EncodeFont(BarCode2Value, BarcodeSymbology2D);
                        end;
                end;

                case SSCCManagement.GetDimensionOfBarCode(BarCode3Type) of
                    1:
                        begin
                            BarcodeFontProvider := Enum::"Barcode Font Provider"::IDAutomation1D;
                            BarcodeSymbology := SSCCManagement.GetBarcodeSymbology1D(BarCode3Type);
                            BarcodeFontProvider.ValidateInput(BarCode3Value, BarcodeSymbology);
                            BarCode3 := BarcodeFontProvider.EncodeFont(BarCode3Value, BarcodeSymbology);
                        end;
                    2:
                        begin
                            BarcodeFontProvider2D := Enum::"Barcode Font Provider 2D"::IDAutomation2D;
                            BarcodeSymbology2D := SSCCManagement.GetBarcodeSymbol2D(BarCode3Type);
                            BarCode3 := BarcodeFontProvider2D.EncodeFont(BarCode3Value, BarcodeSymbology2D);
                        end;
                end;
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
    }

    trigger OnInitReport()
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);
    end;

    internal procedure AddSSCC(var sscc1: Record "TMAC SSCC")
    begin
        TempSSCC.Init();
        TempSSCC.TransferFields(sscc1);
        TempSSCC.Insert(false);
    end;

    var
        SSCC: Record "TMAC SSCC";
        TempSSCC: Record "TMAC SSCC" temporary;
        CompanyInformation: Record "Company Information";
        FormatAddress: Codeunit "Format Address";
        SSCCManagement: Codeunit "TMAC SSCC Management";
        CompanyAddress: array[8] of Text[100];

        BarCode1Value: Text;
        BarCode2Value: Text;
        BarCode3Value: Text;

        BarCode1: Text;
        BarCode2: Text;
        BarCode3: Text;
        BarCode1Text: Text;
        BarCode2Text: Text;
        BarCode3Text: Text;

        LabelText1: Text;
        LabelText2: Text;
        LabelText3: Text;
        LabelText4: Text;
}
