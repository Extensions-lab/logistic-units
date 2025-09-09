table 71628577 "TMAC Unit Action"
{
    Caption = 'Logistic Unit Action';
    DataClassification = CustomerContent;
    DrillDownPageId = "TMAC Unit Actions";
    LookupPageId = "TMAC Unit Actions";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the unique code that identifies the logistic unit action during TMS processes.';
        }

        field(2; "Description"; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a brief explanation of the logistic unit action to help users understand its meaning.';
        }
        field(10; "Purchase"; Boolean)
        {
            Caption = 'Purchase';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether this action is recorded when a purchase document for the logistic unit is posted.';
            trigger OnValidate()
            var
                LogisticUniAction: Record "TMAC Unit Action";
            begin
                if "Purchase" then begin
                    LogisticUniAction.SetFilter(Code, '<>%1', Code);
                    LogisticUniAction.Setrange(Purchase, true);
                    if LogisticUniAction.FindFirst() then
                        Error(ThereIsAnotherServiceErr, LogisticUniAction.Code);
                end;
            end;
        }
        field(11; "Warehouse Receipt"; Boolean)
        {
            Caption = 'Warehouse Receipt';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether this action is recorded when the logistic unit is received into the warehouse.';
            trigger OnValidate()
            var
                LogisticUniAction: Record "TMAC Unit Action";
            begin
                if "Warehouse Receipt" then begin
                    LogisticUniAction.SetFilter(Code, '<>%1', Code);
                    LogisticUniAction.Setrange("Warehouse Receipt", true);
                    if LogisticUniAction.FindFirst() then
                        Error(ThereIsAnotherServiceErr, LogisticUniAction.Code);
                end;
            end;
        }
        field(12; "Warehouse Put-away"; Boolean)
        {
            Caption = 'Warehouse Put-away';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether this action is recorded when the logistic unit is placed into storage at receipt.';
            trigger OnValidate()
            var
                LogisticUniAction: Record "TMAC Unit Action";
            begin
                if "Warehouse Put-away" then begin
                    LogisticUniAction.SetFilter(Code, '<>%1', Code);
                    LogisticUniAction.Setrange("Warehouse Put-away", true);
                    if LogisticUniAction.FindFirst() then
                        Error(ThereIsAnotherServiceErr, LogisticUniAction.Code);
                end;
            end;
        }
        field(13; "Sale"; Boolean)
        {
            Caption = 'Sale';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether this action is recorded when a sales document for the logistic unit is posted.';
            trigger OnValidate()
            var
                LogisticUniAction: Record "TMAC Unit Action";
            begin
                if "Sale" then begin
                    LogisticUniAction.SetFilter(Code, '<>%1', Code);
                    LogisticUniAction.Setrange("Sale", true);
                    if LogisticUniAction.FindFirst() then
                        Error(ThereIsAnotherServiceErr, LogisticUniAction.Code);
                end;
            end;
        }
        field(14; "Warehouse Shipment"; Boolean)
        {
            Caption = 'Warehouse Shipment';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether this action is recorded when the logistic unit is shipped from the warehouse.';
            trigger OnValidate()
            var
                LogisticUniAction: Record "TMAC Unit Action";
            begin
                if "Warehouse Shipment" then begin
                    LogisticUniAction.SetFilter(Code, '<>%1', Code);
                    LogisticUniAction.Setrange("Warehouse Shipment", true);
                    if LogisticUniAction.FindFirst() then
                        Error(ThereIsAnotherServiceErr, LogisticUniAction.Code);
                end;
            end;
        }

        field(15; "Warehouse Pickup"; Boolean)
        {
            Caption = 'Warehouse Pickup';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether this action is recorded when the logistic unit is picked from the warehouse.';
            trigger OnValidate()
            var
                LogisticUniAction: Record "TMAC Unit Action";
            begin
                if "Warehouse Pickup" then begin
                    LogisticUniAction.SetFilter(Code, '<>%1', Code);
                    LogisticUniAction.Setrange("Warehouse Pickup", true);
                    if LogisticUniAction.FindFirst() then
                        Error(ThereIsAnotherServiceErr, LogisticUniAction.Code);
                end;
            end;
        }

        field(20; "Create"; Boolean)
        {
            Caption = 'Create';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether this action is recorded when a new logistic unit is created.';
            trigger OnValidate()
            var
                LogisticUniAction: Record "TMAC Unit Action";
            begin
                if "Create" then begin
                    LogisticUniAction.SetFilter(Code, '<>%1', Code);
                    LogisticUniAction.Setrange(Create, true);
                    if LogisticUniAction.FindFirst() then
                        Error(ThereIsAnotherServiceErr, LogisticUniAction.Code);
                end;
            end;
        }
        field(21; "Archive"; Boolean)
        {
            Caption = 'Archive';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether this action is recorded when the logistic unit is archived, marking it as inactive.';
            trigger OnValidate()
            var
                LogisticUniAction: Record "TMAC Unit Action";
            begin
                if "Archive" then begin
                    LogisticUniAction.SetFilter(Code, '<>%1', Code);
                    LogisticUniAction.Setrange(Archive, true);
                    if LogisticUniAction.FindFirst() then
                        Error(ThereIsAnotherServiceErr, LogisticUniAction.Code);
                end;
            end;
        }
        field(22; "Relocation"; Boolean)
        {
            Caption = 'Relocation';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether this action is recorded when the logistic unit''s location changes, like moving bins or transferring.';
            trigger OnValidate()
            var
                LogisticUniAction: Record "TMAC Unit Action";
            begin
                if "Relocation" then begin
                    LogisticUniAction.SetFilter(Code, '<>%1', Code);
                    LogisticUniAction.Setrange("Relocation", true);
                    if LogisticUniAction.FindFirst() then
                        Error(ThereIsAnotherServiceErr, LogisticUniAction.Code);
                end;
            end;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    var
        ThereIsAnotherServiceErr: label 'There is the service %1 with this parameter', Comment = '%1 is Service Code';
}
