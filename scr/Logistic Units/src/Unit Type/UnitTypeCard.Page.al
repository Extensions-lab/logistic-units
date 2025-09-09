
page 71628600 "TMAC Unit Type Card"
{
    Caption = 'Unit Type Card';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "TMAC Unit Type";

    AboutTitle = 'Unit Type';
    AboutText = 'Logistic Unit Type is a master data entity that defines standardized container specifications for logistics operations. It serves as a template for creating actual logistic units (containers, pallets, trailers, etc.) by specifying their physical dimensions (internal/external length, width, height), weight capacities (tare, payload, maximum), volume limits, and operational constraints.';
    
    ContextSensitiveHelpPage = 'blob/main/logisticunittype.md';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
                field("Type of Loading"; Rec."Type of Loading")
                {
                    ApplicationArea = All;
                }
                field("Sort Order"; Rec."Sort Order")
                {
                    ApplicationArea = All;
                }
                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = All;
                }
                field("Reversible container"; Rec."Reusable")
                {
                    ApplicationArea = All;
                }
                field("Automatic SSCC Creation"; Rec."Automatic SSCC Creation")
                {
                    ApplicationArea = All;
                }
                field("SSCC No. Series"; Rec."SSCC No. Series")
                {
                    ApplicationArea = All;
                }
            }
            group(ContentControl)
            {
                Caption = 'Control';

                group(overweightcontrol)
                {
                    Caption = 'Weight';
                    field("Limit Filling Weight"; Rec."Limit Filling Weight")
                    {
                        ApplicationArea = All;
                        CaptionClass = '71628575,9,' + Rec.FieldCaption("Limit Filling Weight") + Rec.GetCaptionSufix(2);
                    }

                    field("Limit Filling Weight Control"; Rec."Limit Filling Weight Control")
                    {
                        ApplicationArea = All;
                    }
                }

                group(Control)
                {
                    Caption = 'Volume';
                    field("Limit Filling Volume"; Rec."Limit Filling Volume")
                    {
                        ApplicationArea = All;
                        CaptionClass = '71628575,9,' + Rec.FieldCaption("Limit Filling Volume") + Rec.GetCaptionSufix(1);
                    }

                    field("Limit Filling Volume Control"; Rec."Limit Filling Volume Control")
                    {
                        ApplicationArea = All;
                    }
                }
                group(FootageControl)
                {
                    Caption = 'Footage';
                    field(Footage; Rec.Footage)
                    {
                        ApplicationArea = All;
                    }
                    field("Limit Filling Footage Control"; Rec."Limit Filling Footage Control")
                    {
                        ApplicationArea = All;
                    }
                }
                group(GroupControl)
                {
                    Caption = 'Content';
                    field("Mix Source Document Allowed"; Rec."Mix Source Document Allowed")
                    {
                        ApplicationArea = All;
                    }
                    field("Mix Location Bin Allowed"; Rec."Mix Location/Bin Allowed")
                    {
                        ApplicationArea = All;
                    }
                }

                group(GroupTemperature)
                {
                    Caption = 'Temperature';
                    Visible = false;

                    field("Temperature Control"; Rec."Temperature Control")
                    {
                        ApplicationArea = All;
                        trigger OnValidate()
                        begin
                            IsTemperatureEditable := rec."Temperature Control";
                        end;
                    }

                    field(Temperature; Rec.Temperature)
                    {
                        Editable = IsTemperatureEditable;
                        ApplicationArea = All;
                    }

                    field("Ventilation"; Rec."Ventilation")
                    {
                        ApplicationArea = All;
                    }
                }
            }

            group("Units of Measure")
            {
                Caption = 'Units of Measure';
                Visible = false;
            }

            group("Weight")
            {
                Caption = 'Weight';
                field("Weight Unit of Measure"; Rec."Weight Unit of Measure")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Tare Weight"; Rec."Tare Weight")
                {
                    ApplicationArea = All;
                    CaptionClass = '71628575,9,' + Rec.FieldCaption("Tare Weight") + Rec.GetCaptionSufix(2);
                }
                field("Payload Weight"; Rec."Payload Weight")
                {
                    ApplicationArea = All;
                    CaptionClass = '71628575,9,' + Rec.FieldCaption("Payload Weight") + Rec.GetCaptionSufix(2);
                }
                field("Max Weight"; Rec."Max Weight")
                {
                    ApplicationArea = All;
                    CaptionClass = '71628575,9,' + Rec.FieldCaption("Max Weight") + Rec.GetCaptionSufix(2);
                }
            }

            group("Sizes")
            {
                Caption = 'Sizes';
                field("Linear Unit of Measure"; Rec."Linear Unit of Measure")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                group("Internal")
                {
                    Caption = 'Internal';
                    field("Internal Length"; Rec."Internal Length")
                    {
                        ApplicationArea = All;
                        CaptionClass = '71628575,9,' + Rec.FieldCaption("Internal Length") + Rec.GetCaptionSufix(0);
                    }
                    field("Internal Width"; Rec."Internal Width")
                    {
                        ApplicationArea = All;
                        CaptionClass = '71628575,9,' + Rec.FieldCaption("Internal Width") + Rec.GetCaptionSufix(0);
                    }
                    field("Internal Height"; Rec."Internal Height")
                    {
                        ApplicationArea = All;
                        CaptionClass = '71628575,9,' + Rec.FieldCaption("Internal Height") + Rec.GetCaptionSufix(0);
                    }
                    field("Internal Volume"; Rec."Internal Volume")
                    {
                        ApplicationArea = All;
                        CaptionClass = '71628575,9,' + Rec.FieldCaption("Internal Volume") + Rec.GetCaptionSufix(1);
                    }
                }

                field("Volume Unit of Measure"; Rec."Volume Unit of Measure")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }

                group("External")
                {
                    Caption = 'External';
                    field("Length"; Rec."Length")
                    {
                        CaptionClass = '71628575,9,' + Rec.FieldCaption("Length") + Rec.GetCaptionSufix(0);
                        ApplicationArea = All;
                    }
                    field("Width"; Rec."Width")
                    {
                        CaptionClass = '71628575,9,' + Rec.FieldCaption("Width") + Rec.GetCaptionSufix(0);
                        ApplicationArea = All;
                    }
                    field("Height"; Rec."Height")
                    {
                        CaptionClass = '71628575,9,' + Rec.FieldCaption("Height") + Rec.GetCaptionSufix(0);
                        ApplicationArea = All;
                    }
                    field("Unit Volume"; Rec."Unit Volume")
                    {
                        ApplicationArea = All;
                        CaptionClass = '71628575,9,' + Rec.FieldCaption("Unit Volume") + Rec.GetCaptionSufix(1);
                    }
                }

            }
        }
        area(factboxes)
        {
            part(UnitTypePicture; "TMAC Unit Type Picture")
            {
                ApplicationArea = All;
                Caption = 'Picture';
                SubPageLink = Code = FIELD("Code");
            }

            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)

            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        IsTemperatureEditable := rec."Temperature Control";
    end;

    var
        IsTemperatureEditable: Boolean;
}