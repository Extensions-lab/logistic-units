page 71628626 "TMAC Scan Values"
{
    PageType = StandardDialog;
    ApplicationArea = All;
    Caption = 'Scan multiple';
    DataCaptionExpression = '';

    layout
    {
        area(content)
        {
            group("Input Area")
            {
                field("Scanning Area"; LastInput)
                {
                    Caption = 'Scan';
                    ToolTip = 'Specifies the content scanned to input.';
                    ExtendedDatatype = Barcode;

                    trigger OnValidate()
                    begin
                        if ContinuousScanningMode then
                            CurrPage.Close();
                    end;
                }
            }
            part("Result"; "TMAC Scan Values Details")
            {
                Caption = 'Scan Results';
            }
        }
    }

    trigger OnOpenPage()
    begin
    end;

    var
        LastInput: Text;
        ContinuousScanningMode: Boolean;


    internal procedure GetInput(): Text
    begin
        exit(LastInput);
    end;

    internal procedure SetInput(ExtInput: Text)
    begin
        LastInput := ExtInput;
    end;

    internal procedure SetContinuousScanningMode(DestMode: Boolean)
    begin
        ContinuousScanningMode := DestMode;
    end;
}
