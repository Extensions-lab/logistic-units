
/// <summary>
/// For selecting logistics units in certain functionality.  
/// The table on which this page is based is temporary.
/// </summary>
page 71628591 "TMAC Unit Selection"
{
    ApplicationArea = All;
    Caption = 'Logistic Unit Select';
    PageType = List;
    SourceTable = "TMAC Unit Select By Source";
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
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Width = 10;
                }
                field(Volume; Rec.Volume)
                {
                    ApplicationArea = All;
                }
                field(Weight; Rec.Weight)
                {
                    ApplicationArea = All;
                }
                field("Source Name"; Rec."Source Name")
                {
                    ApplicationArea = All;
                }
                field("Source ID"; Rec."Source ID")
                {
                    ApplicationArea = All;
                }
                field("Customer/Vendor No."; Rec."Customer/Vendor No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Customer/Vendor Name"; Rec."Customer/Vendor Name")
                {
                    ApplicationArea = All;
                }
                field("Country Code"; Rec."Country Code")
                {
                    ApplicationArea = All;
                }
                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = All;
                }
                field(County; Rec.County)
                {
                    ApplicationArea = All;
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = All;
                }
                field("LU Location Code"; Rec."LU Location Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Tracking No."; Rec."Tracking No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    procedure AddLine(var UnitSelectBySource: Record "TMAC Unit Select By Source")
    begin
        Rec.Init();
        Rec.TransferFields(UnitSelectBySource);
        Rec.Insert(false);
    end;
}