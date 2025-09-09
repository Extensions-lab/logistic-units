page 71628575 "TMAC Logistic Units Setup"
{
    PageType = Card;
    Caption = 'Logistic Units Setup';
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "TMAC Logistic Units Setup";
    DataCaptionExpression = 'Logistic Units Setup';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group("General")
            {
                Caption = 'General';

                field("Def. Unit Type"; Rec."Def. Unit Type")
                {
                    ApplicationArea = Basic, Suite;
                }
            }

            group(CreateLogisticUnits)
            {
                Caption = 'Create Logistic Units';

                field("Set Default Selected Quantity"; Rec."Set Default Selected Quantity")
                {
                    ApplicationArea = Basic, Suite;
                    trigger OnValidate()
                    begin
                        IsSetDefaultSelectedQuantityEnabled := Rec."Set Default Selected Quantity";
                    end;
                }
                field("Exclude Lines w/o Def. Qty."; Rec."Exclude Lines w/o Def. Qty.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = IsSetDefaultSelectedQuantityEnabled;
                }
                field("Strict Control Def. Qty."; Rec."Strict Control Def. Qty.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = IsSetDefaultSelectedQuantityEnabled;
                }

                field("Auto Build Logistic Units"; Rec."Auto Build Logistic Units")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Number Series")
            {
                Caption = 'Number Series';

                field("Logistic Unit Nos."; Rec."Unit Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Default Shipping Agent"; Rec."Default Shipping Agent")
                {
                    ApplicationArea = Basic, Suite;
                }

            }
            group("SSCC")
            {
                Caption = 'SSCC - Serial Shipping Container Codes';
                field("Global Company Prefix"; Rec."Global Company Prefix")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("SSCC Nos."; Rec."SSCC Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("SSCC Check Digit"; Rec."SSCC Check Digit")
                {
                    ApplicationArea = Basic, Suite;
                }
            }

            group("Units of Measure")
            {
                Caption = 'Units of Measure';

                field("Base Weight Unit of Measure"; Rec."Base Weight Unit of Measure")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Base Volume Unit of Measure"; Rec."Base Volume Unit of Measure")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Base Linear Unit of Measure"; Rec."Base Linear Unit of Measure")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Base Distance Unit of Measure"; Rec."Base Distance Unit of Measure")
                {
                    ApplicationArea = Basic, Suite;
                }
            }

            group(AdditionalReportingUnitsofMeasure)
            {
                Caption = 'Additional Reporting Units of Measure';

                Visible = false;

                field("Use Addional Reporting UoM"; Rec."Use Addional Reporting UoM")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Add. Reporting Weight UoM"; Rec."Add. Reporting Weight UoM")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Add. Reporting Volume UoM"; Rec."Add. Reporting Volume UoM")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Add. Reporting Linear UoM"; Rec."Add. Reporting Linear UoM")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }

        area(factboxes)
        {
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
    actions
    {
        area(Promoted)
        {
            group(Settings)
            {
                Caption = 'Settings';
                Image = Setup;
                actionref(ActionsSetup_Promoted; ActionsSetup)
                {
                }
                actionref(UnitType_Promoted; UnitType)
                {
                }
                actionref(SSCCDefaultIdentifiers_Promoted; SSCCDefaultIdentifiers)
                {
                }
                actionref(UnitLocations_Promoted; UnitLocations)
                {
                }
                group(Tracking)
                {
                    Caption = 'Tracking Setup';
                    Image = Track;
                    actionref(AfterShipSetup_Promoted; AfterShipSetup)
                    {
                    }
                }
            }
        }

        area(Processing)
        {
            action(ActionsSetup)
            {
                ApplicationArea = All;
                Caption = 'Actions Setup';
                Image = Setup;
                ToolTip = 'Specifies the setting of the Recorded activities with logistic units';
                RunObject = page "TMAC Unit Actions";
            }
            action(UnitType)
            {
                ApplicationArea = All;
                Caption = 'Logistic Unit Types';
                Image = Setup;
                ToolTip = 'Specifies the setting of the Recorded activities with logistic units';
                RunObject = page "TMAC Unit Type List";
            }
            action("SSCCDefaultIdentifiers")
            {
                ApplicationArea = All;
                Caption = 'SSCC Default Identifier';
                Image = Setup;
                ToolTip = 'Specifies the sscc idenfifiers that will be included in SSCC';
                RunObject = page "TMAC SSCC Default Identifiers";
            }

            action(UnitLocations)
            {
                ApplicationArea = All;
                Caption = 'Unit Locations';
                Image = Setup;
                ToolTip = 'Specifies the sscc idenfifiers that will be included in SSCC';
                RunObject = page "TMAC Unit Locations";
            }

            action(AfterShipSetup)
            {
                ApplicationArea = All;
                Caption = 'Aftership Tracking Setup';
                Image = Setup;
                ToolTip = 'Specifies the settings of the aftership tracing service.';
                RunObject = page "TMAC Aftership Setup Wizard";
            }
        }

    }

    trigger OnAfterGetCurrRecord()
    begin
        IsSetDefaultSelectedQuantityEnabled := Rec."Set Default Selected Quantity";
    end;

    var
        IsSetDefaultSelectedQuantityEnabled: Boolean;

}