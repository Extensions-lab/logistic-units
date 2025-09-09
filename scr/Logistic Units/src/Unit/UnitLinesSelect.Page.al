/// <summary>
/// For selecting a logistics unit line
/// </summary>
page 71628590 "TMAC Unit Lines Select"
{

    ApplicationArea = All;
    Caption = 'Logistic Units Select';
    PageType = List;
    SourceTable = "TMAC Unit Line";
    SourceTableTemporary = true;
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Unit No."; Rec."Unit No.")
                {
                    ToolTip = 'Specifies the value of the Unit No. field.';
                    ApplicationArea = All;
                }
                field("Unit Type Code"; Rec."Unit Type Code")
                {
                    ToolTip = 'Specifies the value of the Unit Type Code field.';
                    ApplicationArea = All;
                }
                field("Type"; Rec."Type")
                {
                    ToolTip = 'Specifies the value of the Type field.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field.';
                    ApplicationArea = All;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies the value of the Variant Code field.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field.';
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ToolTip = 'Specifies the value of the Unit of Measure Code field.';
                    ApplicationArea = All;
                }
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                    ToolTip = 'Specifies the value of the Quantity (Base) field.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Gross Weight (base)"; Rec."Gross Weight (base)")
                {
                    ToolTip = 'Specifies the value of the Gross Weight field.';
                    ApplicationArea = All;
                }
            }
        }
    }

    procedure SetSourceTypeFilter(SourceType: Integer)
    begin
        Rec.SetRange("Linked Type Filter", SourceType);
    end;

    Procedure AddLine(var UnitLine: Record "TMAC Unit Line")
    begin
        Rec.Init();
        Rec.TransferFields(UnitLine);
        Rec.Insert(true);
    end;
}
