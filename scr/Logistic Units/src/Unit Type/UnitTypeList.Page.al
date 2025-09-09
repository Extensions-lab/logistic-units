
page 71628602 "TMAC Unit Type List"
{
    Caption = 'Logistic Unit Types';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "TMAC Unit Type";
    SourceTableView = sorting("Sort Order", Code);
    CardPageId = "TMAC Unit Type Card";
    Editable = false;
    
    AboutTitle = 'Unit Type';
    AboutText = 'Logistic Unit Type is a master data entity that defines standardized container specifications for logistics operations. It serves as a template for creating actual logistic units (containers, pallets, trailers, etc.) by specifying their physical dimensions (internal/external length, width, height), weight capacities (tare, payload, maximum), volume limits, and operational constraints.';
    
    ContextSensitiveHelpPage = 'blob/main/logisticunittype.md';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Description2; Rec."Description 2")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Linear Unit of Measure"; Rec."Linear Unit of Measure")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Volume Unit of Measure"; Rec."Volume Unit of Measure")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Weight Unit of Measure"; Rec."Weight Unit of Measure")
                {
                    ApplicationArea = All;
                    Visible = false;
                }

                field("Length"; Rec."Length")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Width"; Rec."Width")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Height"; Rec."Height")
                {
                    ApplicationArea = All;
                    Visible = false;
                }

                field("Unit Volume"; Rec."Unit Volume")
                {
                    ApplicationArea = All;
                    DecimalPlaces = 5 :;
                    Visible = false;
                }

                field("Limit Filling Volume Control"; Rec."Limit Filling Volume Control")
                {
                    ApplicationArea = All;
                }
                field("Limit Filling Volume"; Rec."Limit Filling Volume")
                {
                    ApplicationArea = All;
                    Visible = false;
                }

                field("Internal Length"; Rec."Internal Length")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Internal Width"; Rec."Internal Width")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Internal Height"; Rec."Internal Height")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Internal Volume"; Rec."Internal Volume")
                {
                    ApplicationArea = All;
                    DecimalPlaces = 5 :;
                    Visible = false;
                }

                field("Tare Weight"; Rec."Tare Weight")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Payload Weight"; Rec."Payload Weight")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Max Weight"; Rec."Max Weight")
                {
                    ApplicationArea = All;
                    Visible = false;
                }

                field("Limit Filling Weight Control"; Rec."Limit Filling Weight Control")
                {
                    ApplicationArea = All;
                }
                field("Limit Filling Weight"; Rec."Limit Filling Weight")
                {
                    ApplicationArea = All;
                    CaptionClass = '71628575,9,' + Rec.FieldCaption("Limit Filling Weight") + Rec.GetCaptionSufix(2);
                    Visible = false;
                }

                field("Temperature Control"; Rec."Temperature Control")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Ventilation; Rec.Ventilation)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Type of Loading"; Rec."Type of Loading")
                {
                    ApplicationArea = All;
                    Visible = false;
                }

                field("Reversible container"; Rec.Reusable)
                {
                    ApplicationArea = All;
                    Visible = false;
                }

                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
        area(Factboxes)
        {
            part(TrUnitTypePicture; "TMAC Unit Type Picture")
            {
                ApplicationArea = All;
                Caption = 'Picture';
                SubPageLink = Code = FIELD("Code");
            }
        }
    }
}