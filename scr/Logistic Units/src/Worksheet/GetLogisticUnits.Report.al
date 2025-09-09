report 71628576 "TMAC Get Logistic Units"
{
    Caption = 'Get Logistic Units';
    ProcessingOnly = true;
    UsageCategory = None;

    dataset
    {
        dataitem(TMACUnit; "TMAC Unit")
        {
            RequestFilterFields = "No.", "LU Location Code", "Inbound Logistics Enabled", "Outbound Logistics Enabled", "Location Code", "Zone Code", "Bin Code";
            trigger OnAfterGetRecord()
            var
                UnitWorksheetLine: Record "TMAC Unit Worksheet Line";
                LineNo: Integer;
            begin
                LineNo := 10000;
                UnitWorksheetLine.Reset();
                UnitWorksheetLine.Setrange(Name, UnitWorksheetName);
                if UnitWorksheetLine.FindLast() then
                    LineNo := UnitWorksheetLine."Line No." + 10000;
                UnitWorksheetLine.Init();
                UnitWorksheetLine.Name := UnitWorksheetName;
                UnitWorksheetLine."Line No." := LineNo;
                UnitWorksheetLine.Insert(true);
                UnitWorksheetLine.Validate("Unit No.", "No.");
                UnitWorksheetLine.Modify(true);
            end;
        }
    }

    internal procedure SetUnitWorkSheetName(Value: Code[10])
    begin
        UnitWorksheetName := Value;
    end;

    var
        UnitWorksheetName: Code[10];
}
