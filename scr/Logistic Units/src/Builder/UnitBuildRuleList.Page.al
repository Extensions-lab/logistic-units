page 71628622 "TMAC Unit Build Rule List"
{
    Caption = 'Logistic Unit Build Rules';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "TMAC Unit Build Rule";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Type"; Rec."Type")
                {
                    ApplicationArea = All;
                }

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }

                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }

                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                }

                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                    Visible = false;
                }

                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }

                field("Priority"; Rec."Priority")
                {
                    ApplicationArea = All;
                }

                field("Build Action Type"; Rec."Build Action Type")
                {
                    ApplicationArea = All;
                    Style = Strong;
                }

                field("Unit Type Code"; Rec."Unit Type Code")
                {
                    Caption = 'Logistic Units By Type';
                    ApplicationArea = All;
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        ControlWeightAndVolume();
                    end;
                }

                field("Unit Type Description"; Rec."Unit Type Description")
                {
                    ApplicationArea = All;
                }

                field("Split Qty."; Rec."Split Qty.")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    trigger OnValidate()
                    begin
                        ControlWeightAndVolume();
                    end;
                }

                field("Blocked"; Rec."Blocked")
                {
                    ApplicationArea = All;
                }
                field("Remains can be mixed"; Rec."Remains can be mixed")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }


    trigger OnNewRecord(BelowxRec: Boolean)
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        Rec.Type := xRec.Type;
        Rec."No." := xRec."No.";
        Rec."Variant Code" := xrec."Variant Code";
        Rec."Unit of Measure Code" := xRec."Unit of Measure Code";
        Rec.Priority := xRec.Priority + 1;

        if Rec.Type = "TMAC Content Type"::None then begin
            Rec.Type := "TMAC Content Type"::Item;
            if Rec."No." = '' then
                if Rec.GetFilter("No.") <> '' then
                    if Item.Get(Rec.GetFilter("No.")) then begin
                        Rec."No." := CopyStr(Rec.GetFilter("No."), 1, 20);
                        Rec.Description := Item.Description;
                    end;

            if Rec."Variant Code" = '' then
                if Rec.GetFilter("Variant Code") <> '' then
                    if ItemVariant.Get(Rec."No.", Rec.GetFilter("Variant Code")) then
                        Rec."Variant Code" := CopyStr(Rec.GetFilter("Variant Code"), 1, 10);

            if Rec."Unit of Measure Code" = '' then
                if Rec.GetFilter("Unit of Measure Code") <> '' then
                    if ItemUnitOfMeasure.Get(Rec."No.", Rec.GetFilter("Unit of Measure Code")) then
                        Rec."Unit of Measure Code" := CopyStr(Rec.GetFilter("Unit of Measure Code"), 1, 10);
        end;
    end;


    local procedure ControlWeightAndVolume()
    var
        UnitType: Record "TMAC Unit Type";
        UnitBuildManagement: Codeunit "TMAC Unit Build Management";
        SelectedTotalWeight: Decimal;
        SelectedTotalVolume: Decimal;
    begin
        if Rec.Type <> "TMAC Content Type"::Item then
            exit;

        if Rec."Build Action Type" <> "TMAC Build Action Type"::Create then
            exit;

        Message := '';

        SelectedTotalWeight := Rec."Split Qty." * UnitBuildManagement.GetItemGrossWeight(Rec."No.", rec."Unit of Measure Code");
        SelectedTotalVolume := Rec."Split Qty." * UnitBuildManagement.GetItemVolume(Rec."No.", Rec."Unit of Measure Code");

        if UnitType.Get(Rec."Unit Type Code") then begin
            if UnitType."Limit Filling Weight Control" then
                if SelectedTotalWeight > UnitType."Limit Filling Weight" then
                    Message := StrSubstNo(OverWeightMsg, SelectedTotalWeight, UnitType.Description, UnitType."Limit Filling Weight");

            if UnitType."Limit Filling Volume Control" then
                if SelectedTotalVolume > UnitType."Limit Filling Volume" then begin
                    if Message <> '' then
                        Message += '\';
                    Message += StrSubstNo(OverVolumeMsg, SelectedTotalVolume, UnitType.Description, UnitType."Limit Filling Volume");
                end;
        end;

        if Message <> '' then
            Message(Message);
    end;

    var
        Message: Text;
        OverWeightMsg: Label 'Weight limit warning!\%1 exceeds the weight limit of "%2" , which is %3', Comment = '%1 is an weight, %2 is a logistic unit name, %3 is an weight limit';
        OverVolumeMsg: Label 'Volume/Cubage limit warning!\%1 exceeds the volume limit of "%2" , which is %3', Comment = '%1 is an volume, %2 is a logistic unit name, %3 is an volume limit';

}