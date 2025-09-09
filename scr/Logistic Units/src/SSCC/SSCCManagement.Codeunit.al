codeunit 71628591 "TMAC SSCC Management"
{
    internal procedure CreateSSCC(var Unit: Record "TMAC Unit")
    var
        UnitType: Record "TMAC Unit Type";
        SSCC: Record "TMAC SSCC";
    begin
        if Unit."SSCC No." <> '' then
            exit;
        SSCC.Init();
        SSCC."No." := '';
        if UnitType.Get(Unit."Type Code") then
            if UnitType."SSCC No. Series" <> '' then
                SSCC."No. Series" := UnitType."SSCC No. Series";
        SSCC.Insert(true);
        Unit."SSCC No." := SSCC."No.";
        CompleteInformation(Unit, SSCC);
    end;

    internal procedure PrintSSCCByLogisticUnit(UnitNo: Code[20])
    var
        Unit: Record "TMAC Unit";
        SSCC: Record "TMAC SSCC";
    begin
        Unit.Get(UnitNo);
        Unit.TestField("SSCC No.");
        SSCC.Get(Unit."SSCC No.");
        CompleteInformation(Unit, SSCC);

        Commit();

        SSCC.Reset();
        SSCC.SetRange("No.", Unit."SSCC No.");
        PrintSSCC(SSCC);
    end;

    internal procedure PrintSSCC(var SSCC1: Record "TMAC SSCC")
    var
        SSCCLabelReport: report "TMAC SSCC Label";
    begin
        SSCCLabelReport.AddSSCC(SSCC1);
        SSCCLabelReport.Run();
    end;

    /// <summary>
    /// SSCC printing by document.
    /// </summary>
    internal procedure PrintSSCCByDocument(SourceType: Integer; SourceDocumentType: Integer; SourceDocumentNo: Code[20]; SourceLineNo: Integer)
    var
        SSCC: Record "TMAC SSCC";
        SSCCLabel: Report "TMAC SSCC Label";
        SSCCs: List of [Code[25]];
        SSCCNo: Code[25];
    begin
        SSCCs := GetSSCCListByDocument(SourceType, SourceDocumentType, SourceDocumentNo, SourceLineNo);
        foreach SSCCNo in SSCCs do begin
            SSCC.Get(SSCCNo);
            SSCCLabel.AddSSCC(SSCC);
        end;
        SSCCLabel.Run();
    end;

    /// <summary>
    /// Label filling.
    /// </summary>
    internal procedure CompleteInformation(var Unit: Record "TMAC Unit"; var SSCC: Record "TMAC SSCC")
    var
        UnitLine: Record "TMAC Unit Line";
    begin
        Unit.CalcFields("Content Weight (Base)", "Content Volume (Base)");
        SSCC.Weight := Unit."Content Weight (Base)";
        SSCC.Volume := Unit."Content Volume (Base)";
        SSCC.Modify(true);

        SetParameter(SSCC."No.", '00', SSCC."No.");

        UnitLine.Reset();
        UnitLine.Setrange("Unit No.", Unit."No.");
        UnitLine.Setrange(Type, "TMAC unit Line Type"::Item);
        UnitLine.SetFilter(GTIN, '<>''''');
        if UnitLine.FindFirst() then
            SetParameter(SSCC."No.", '01', UnitLine.GTIN);

        UnitLine.Reset();
        UnitLine.Setrange("Unit No.", Unit."No.");
        UnitLine.Setrange(Type, "TMAC unit Line Type"::Item);
        UnitLine.CalcSums(Quantity);
        if UnitLine.Quantity > 0 then
            SetParameter(SSCC."No.", '37', Format(UnitLine.Quantity));

    end;

    local procedure SetParameter(SSCCNo: Code[25]; ParamID: Code[20]; Value: Text)
    var
        SSCCLine: Record "TMAC SSCC Line";
    begin
        SSCCLine.Setrange("SSCC No.", SSCCNo);
        SSCCLine.Setrange(Identifier, ParamID);
        if SSCCLine.FindFirst() then begin
            SSCCLine.Value := CopyStr(Value, 1, 250);
            SSCCLine.Modify();
        end;
    end;

    /// <summary>
    /// Whether this code is 1D or 2D.
    /// </summary>
    /// <param name="Value"></param>
    /// <returns></returns>
    internal procedure GetDimensionOfBarCode(Value: enum "TMAC SSCC Barcode Type"): Integer
    begin
        case Value of
            "TMAC SSCC Barcode Type"::"None":
                exit(0);
            "TMAC SSCC Barcode Type"::"1D - Code39":
                exit(1);
            "TMAC SSCC Barcode Type"::"1D - Codabar":
                exit(1);
            "TMAC SSCC Barcode Type"::"1D - Code128":
                exit(1);
            "TMAC SSCC Barcode Type"::"1D - Code93":
                exit(1);
            "TMAC SSCC Barcode Type"::"1D - Interleaved2of5":
                exit(1);
            "TMAC SSCC Barcode Type"::"1D - Postnet":
                exit(1);
            "TMAC SSCC Barcode Type"::"1D - MSI":
                exit(1);
            "TMAC SSCC Barcode Type"::"1D - EAN-8":
                exit(1);
            "TMAC SSCC Barcode Type"::"1D - EAN-13":
                exit(1);
            "TMAC SSCC Barcode Type"::"1D - UPC-A":
                exit(1);
            "TMAC SSCC Barcode Type"::"1D - UPC-E":
                exit(1);
            "TMAC SSCC Barcode Type"::"2D - Aztec":
                exit(2);
            "TMAC SSCC Barcode Type"::"2D - Data Matrix":
                exit(2);
            "TMAC SSCC Barcode Type"::"2D - Maxi Code":
                exit(2);
            "TMAC SSCC Barcode Type"::"2D - PDF417":
                exit(2);
            "TMAC SSCC Barcode Type"::"2D - QR-Code":
                exit(2);
        end;
    end;

    internal procedure GetBarcodeSymbology1D(Value: enum "TMAC SSCC Barcode Type"): Enum "Barcode Symbology"
    begin
        case Value of
            "TMAC SSCC Barcode Type"::"1D - Code39":
                exit("Barcode Symbology"::Code39);
            "TMAC SSCC Barcode Type"::"1D - Codabar":
                exit("Barcode Symbology"::Codabar);
            "TMAC SSCC Barcode Type"::"1D - Code128":
                exit("Barcode Symbology"::Code128);
            "TMAC SSCC Barcode Type"::"1D - Code93":
                exit("Barcode Symbology"::Code93);
            "TMAC SSCC Barcode Type"::"1D - Interleaved2of5":
                exit("Barcode Symbology"::Interleaved2of5);
            "TMAC SSCC Barcode Type"::"1D - Postnet":
                exit("Barcode Symbology"::Postnet);
            "TMAC SSCC Barcode Type"::"1D - MSI":
                exit("Barcode Symbology"::MSI);
            "TMAC SSCC Barcode Type"::"1D - EAN-8":
                exit("Barcode Symbology"::"EAN-8");
            "TMAC SSCC Barcode Type"::"1D - EAN-13":
                exit("Barcode Symbology"::"EAN-13");
            "TMAC SSCC Barcode Type"::"1D - UPC-A":
                exit("Barcode Symbology"::"UPC-A");
            "TMAC SSCC Barcode Type"::"1D - UPC-E":
                exit("Barcode Symbology"::"UPC-E");
        end;
    end;

    internal procedure GetBarcodeSymbol2D(value: enum "TMAC SSCC Barcode Type"): enum "Barcode Symbology 2D"
    begin
        case Value of
            "TMAC SSCC Barcode Type"::"2D - Aztec":
                exit("Barcode Symbology 2D"::Aztec);
            "TMAC SSCC Barcode Type"::"2D - Data Matrix":
                exit("Barcode Symbology 2D"::"Data Matrix");
            "TMAC SSCC Barcode Type"::"2D - Maxi Code":
                exit("Barcode Symbology 2D"::"Maxi Code");
            "TMAC SSCC Barcode Type"::"2D - PDF417":
                exit("Barcode Symbology 2D"::PDF417);
            "TMAC SSCC Barcode Type"::"2D - QR-Code":
                exit("Barcode Symbology 2D"::"QR-Code");
        end;
    end;

    /// <summary>
    /// Function to calculate the check digit = the last digit.
    /// </summary>
    /// <param name="preSSCC"></param>
    internal procedure CalcCheckDigit(preSSCC: Text): Text
    var
        rounded: Integer;
        i: Integer;
        sum: Integer;
    begin
        for i := 1 to StrLen(preSSCC) do
            if i mod 2 = 1 then
                sum += 3 * ConvertToDigit(preSSCC[i])
            else
                sum += ConvertToDigit(preSSCC[i]);
        rounded := Round(Sum, 10, '>');
        exit(Format(rounded - sum));
    end;

    local procedure ConvertToDigit(Letter: Char): Integer
    begin
        case Letter of
            '0':
                exit(0);
            '1':
                exit(1);
            '2':
                exit(2);
            '3':
                exit(3);
            '4':
                exit(4);
            '5':
                exit(5);
            '6':
                exit(6);
            '7':
                exit(7);
            '8':
                exit(8);
            '9':
                exit(9);
            else
                exit(0);
        end;
    end;

    /// <summary>
    /// Returns a list of SSCCs by document.
    /// </summary>
    internal procedure GetSSCCListByDocument(SourceType: Integer; SourceDocumentType: Integer; SourceDocumentNo: Code[20]; SourceLineNo: Integer) SSCCs: List of [Code[25]]
    var
        Unit: Record "TMAC Unit";
        UnitLineLink: Record "TMAC Unit Line Link";
        Units: List of [Code[20]];
        UnitNo: Code[20];
    begin
        UnitLineLink.Setrange("Source Type", SourceType);
        UnitLineLink.Setrange("Source Subtype", SourceDocumentType);
        UnitLineLink.Setrange("Source ID", SourceDocumentNo);
        if SourceLineNo <> 0 then
            UnitLineLink.SetRange("Source Ref. No.", SourceLineNo);
        UnitLineLink.LoadFields("Unit No.");
        if UnitLineLink.FindSet(false) then
            repeat
                if not Units.Contains(UnitLineLink."Unit No.") then
                    Units.Add(UnitLineLink."Unit No.");
            until UnitLineLink.Next() = 0;

        foreach UnitNo in Units do begin
            Unit.Get(UnitNo);
            if Unit."SSCC No." <> '' then
                if not SSCCs.Contains(Unit."SSCC No.") then
                    SSCCs.Add(Unit."SSCC No.");
        end;
    end;
}
