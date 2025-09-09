table 71628580 "TMAC SSCC"
{
    Caption = 'Serial Shipping Container Code';
    DataClassification = ToBeClassified;
    DrillDownPageId = "TMAC SSCC List";
    LookupPageId = "TMAC SSCC List";

    fields
    {
        field(1; "No."; Code[25])
        {
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the fully formed SSCC, providing a unique identifier for shipping containers.';
        }
        field(2; Description; Text[100])
        {
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a descriptive label or notes for the serial shipping container code.';
        }
        field(3; "Global Company Prefix"; Code[15])
        {
            Caption = 'Global Company Prefix';
            Numeric = true;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the assigned GS1 prefix for the shipper, forming part of the SSCC value.';
        }
        field(4; "Serial Reference"; Code[10])
        {
            Caption = 'Serial Reference';
            Numeric = true;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the numeric portion that uniquely identifies the container within the global company prefix.';
        }
        field(7; "From"; Text[100])
        {
            Caption = 'From';
            Numeric = true;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the shipper name or location details indicating where the container originated.';
        }
        field(8; "To"; Text[100])
        {
            Caption = 'To';
            Numeric = true;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the consignee name or destination details for the container''s journey.';
        }
        field(9; "Carrier Name"; Text[100])
        {
            Caption = 'Carrier Name';
            Numeric = true;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the name of the carrier or transport provider handling the container shipment.';
        }
        field(10; "Bill of Landing Number"; Text[100])
        {
            Caption = 'Bill of Landing';
            Numeric = true;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the reference for the Bill of Lading used to track the container''s transport.';

        }
        field(11; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ToolTip = 'Specifies the number series to generate SSCC if none is manually entered.';
        }

        field(30; Weight; Decimal)
        {
            Caption = 'Weight';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the total mass of the container''s contents for shipping or handling purposes.';
        }
        field(31; Volume; Decimal)
        {
            Caption = 'Volume';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the cubic space occupied by the container''s contents for storage or transport considerations.';
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }


    trigger OnInsert()
    var
        LogisticUnitsSetup: Record "TMAC Logistic Units Setup";
        SSCCDefaultIdentifier: Record "TMAC SSCC Default Identifier";
        SSCCLine: Record "TMAC SSCC Line";
        NoSeries: Codeunit "No. Series";
        Ssccmanagement: Codeunit "TMAC SSCC Management";
        LineNo: Integer;
        SerialReference: Code[20];
    begin
        if "No." = '' then
            if Rec."No. Series" = '' then begin
                LogisticUnitsSetup.Get();
                LogisticUnitsSetup.TestField("Global Company Prefix");
                LogisticUnitsSetup.TestField("SSCC Nos.");
                "Global Company Prefix" := LogisticUnitsSetup."Global Company Prefix";
                SerialReference := NoSeries.GetNextNo(LogisticUnitsSetup."SSCC Nos.");
                "Serial Reference" := CopyStr(SerialReference, 1, 10);
                "No." := LogisticUnitsSetup."Global Company Prefix" + "Serial Reference";
                if LogisticUnitsSetup."SSCC Check Digit" then
                    "No." += ssccmanagement.CalcCheckDigit("No.");
            end else
                "No." := NoSeries.GetNextNo(Rec."No. Series");

        LineNo := 0;
        if SSCCDefaultIdentifier.FindSet() then
            repeat
                SSCCLine.Init();
                SSCCLine."SSCC No." := "No.";
                SSCCLine."Line No." := LineNo + 10000;
                SSCCLine.Validate(Identifier, SSCCDefaultIdentifier.Identifier);
                SSCCLine.Validate(Description, SSCCDefaultIdentifier.Description);
                SSCCLine.Validate(Value, SSCCDefaultIdentifier.Value);
                SSCCLine."Barcode" := SSCCDefaultIdentifier."Barcode Place";
                SSCCLine."Label Text" := SSCCDefaultIdentifier."Label Text";
                SSCCLine."Barcode Type" := SSCCDefaultIdentifier."Barcode Type";
                SSCCLine.Insert(true);
                LineNo += 10000;
            until SSCCDefaultIdentifier.next() = 0;
    end;

    trigger OnModify()
    begin
    end;

    trigger OnDelete()
    var
        SSCCLine: Record "TMAC SSCC Line";
    begin
        SSCCLine.SetRange("SSCC No.", "No.");
        SSCCLine.DeleteAll(true);
    end;

    trigger OnRename()
    begin

    end;
}