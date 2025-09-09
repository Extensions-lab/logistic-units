page 71628585 "TMAC Unit Card"
{
    Caption = 'Logistic Unit';
    PageType = Document;
    ApplicationArea = All;
    UsageCategory = Documents;
    SourceTable = "TMAC Unit";

    DelayedInsert = true; //обязательно т.к. тужно выбирать тип

    AboutTitle = 'Logistic Unit';
    AboutText = ' is box, pallet or container; is a combination of: a logistics carrier, such as a pallet, which is uniquely identified worldwide by means of a Global Returnable Asset Identifier **(GRAI)**. and products uniquely identified worldwide using Global Trade Item Numbers **(GTIN’s)**.';
   
    ContextSensitiveHelpPage = 'blob/main/logisticunit.md';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                group(FirstColumn)
                {
                    ShowCaption = false;

                    field("No."; Rec."No.")
                    {
                        ApplicationArea = All;
                        ShowMandatory = false;
                        Importance = Additional;
                    }

                    field("Type Code"; Rec."Type Code")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }

                    field("Description"; Rec."Description")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                    field("SSCC"; Rec."SSCC No.")
                    {
                        ApplicationArea = All;
                        AboutTitle = 'SSCC';
                        AboutText = 'Serial Shipping Container Code can be used by companies to identify a logistic unit, which can be any combination of trade items packaged together for storage and/or transport purposes; for example, a case, pallet or parcel.';

                        trigger OnValidate()
                        begin
                            CurrPage.Update();
                        end;

                        trigger OnAssistEdit()
                        var
                            SSCC: Record "TMAC SSCC";
                        begin
                            if Rec."SSCC No." <> '' then begin
                                SSCC.Get(Rec."SSCC No.");
                                Page.Run(Page::"TMAC SSCC Card", SSCC);
                            end;
                        end;
                    }

                    field(Barcode; Rec.Barcode)
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        Visible = false;
                    }
                }
                group(SecondColumn)
                {
                    ShowCaption = false;

                    field("Tracking No."; Rec."Tracking No.")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        AboutTitle = 'Tracking Number';
                        AboutText = 'A tracking number or ID is a unique identifier of a shipment or package. It is usually alphanumeric and contains information about the shipping carrier, destination, and origin. Tracking numbers can be used to track the status of a shipment, view estimated delivery dates and times, and verify delivery information.';
                    }

                    field(Place; Rec."LU Location Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'The "Logistic Unit Location Code" field indicates where the logistics unit is placed, clarifying whether it is available for use within the warehouse or located outside the company, such as with a customer.';
                    }

                    field("Reusable"; Rec."Reusable")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field(Archived; Rec.Archived)
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Parent Unit No."; Rec."Parent Unit No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Indicates the parent logistic unit. Indicates what the given logistic unit is folded into or is a component of.';
                    }
                }
            }

            part(UnitLines; "TMAC Unit Card Lines Subf.")
            {
                Caption = 'Lines';
                ApplicationArea = Basic, Suite;
                Editable = IsSubformEditable;
                SubPageLink = "Unit No." = FIELD("No.");
            }

            group(Measurements)
            {
                Caption = 'Totals';
                group(ContentGroup)
                {
                    Caption = 'Content';
                    field("Gross Weight (Base)"; Rec."Content Weight (Base)")
                    {
                        CaptionClass = '71628575,2,' + Rec.FieldCaption("Content Weight (Base)");
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                    field("Content Volume (Base)"; Rec."Content Volume (Base)")
                    {
                        CaptionClass = '71628575,1,' + Rec.FieldCaption("Content Volume (Base)");
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                }

                group(Totals)
                {
                    Caption = 'Totals';
                    field("Weight (Base)"; Rec."Weight (Base)")
                    {
                        CaptionClass = '71628575,2,' + Rec.FieldCaption("Weight (Base)");
                        ApplicationArea = All;
                        Importance = Promoted;
                        Editable = false;
                    }
                    field("Volume (Base)"; Rec."Volume (Base)")
                    {
                        CaptionClass = '71628575,1,' + Rec.FieldCaption("Volume (Base)");
                        ApplicationArea = All;
                        Importance = Promoted;
                        Editable = false;
                    }
                }
            }

            part(Documents; "TMAC Unit Card Docs Subf.")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                SubPageLink = "Unit No." = FIELD("No.");
            }

            group(Logistics)
            {
                Caption = 'Logistics';
                group(Directions)
                {
                    ShowCaption = false;
                    field("Inbound Logistics Enabled"; Rec."Inbound Logistics Enabled")
                    {
                        Caption = 'Inbound Logistics';
                        ApplicationArea = All;
                    }
                    field("Outbound Logistics Enabled"; Rec."Outbound Logistics Enabled")
                    {
                        Caption = 'Outbound Logistics';
                        ApplicationArea = All;
                    }
                }

                group(Warehouse)
                {
                    Caption = 'Warehouse';
                    field("Location Code"; Rec."Location Code")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                    field("Zone Code"; Rec."Zone Code")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                    field("Bin Code"; Rec."Bin Code")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                }
            }



            group(TrackingInformation)
            {
                Caption = 'Tracking';
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                }
                field("Tracking Information"; Rec."Tracking Information")
                {
                    ApplicationArea = All;
                }
            }
        }
    }


    actions
    {
        area(Promoted)
        {
            group(Category_Home)
            {
                Caption = 'Home';

                actionref(CreateSSCC_Promoted; CreateSSCC)
                {
                }
                actionref(ArchiveUnit_Promoted; ArchiveUnit)
                {
                }
                group(Category_Post)
                {
                    Caption = 'Post Documents';
                    actionref(PostReceipt_Promoted; PostReceipt)
                    {
                    }
                    actionref(PostShipment_Promoted; PostShipment)
                    {
                    }
                }
                actionref(Worksheet_Promoted; Worksheet)
                {
                }
                actionref(LoadDetails_Promoted; LoadDetails)
                {
                }
            }
            group(Tracking)
            {
                Caption = 'Tracking';
                actionref(TrackingAction_Promote; TrackingAction)
                {
                }
                actionref(TrackingDetails_Promote; TrackingDetails)
                {
                }
            }

            group(Print)
            {
                Caption = 'Print';
                actionref(PrintSSCC_Promoted; PrintSSCC)
                {
                }
            }

            group(Category_History)
            {
                Caption = 'History';
                actionref(PHistory_Promoted; History)
                {
                }
            }
        }

        area(Processing)
        {
            action(CreateSSCC)
            {
                ApplicationArea = All;
                Caption = 'Create SSCC';
                Image = Archive;
                InFooterBar = true;
                ToolTip = 'Crate new sscc and assign to the logistic unit.';

                trigger OnAction();
                var
                    SSCCManagement: Codeunit "TMAC SSCC Management";
                begin
                    SSCCManagement.CreateSSCC(Rec);
                end;
            }

            action(ArchiveUnit)
            {
                ApplicationArea = All;
                Caption = 'Archive Logistic Unit';
                Image = Archive;
                InFooterBar = true;
                ToolTip = 'Archive Logistic Unit.';

                trigger OnAction();
                var
                    UnitManagement: Codeunit "TMAC Unit Management";
                begin
                    UnitManagement.ArchiveUnit(Rec);
                end;
            }

            action(PostReceipt)
            {
                ApplicationArea = All;
                Caption = 'Post Purchase Documents by Logistic Unit';
                Image = ReceiptLines;
                InFooterBar = true;
                ToolTip = 'Post Purchase Documents by Logistic Unit.';

                trigger OnAction();
                var
                    UnitPost: Codeunit "TMAC Unit Post";
                begin
                    UnitPost.PostByLogisticUnit(Rec."No.", Database::"Purchase Line", Database::"Purch. Rcpt. Line");
                end;
            }
            action(PostShipment)
            {
                ApplicationArea = All;
                Caption = 'Post Sale Documents by Logistic Unit';
                Image = ShipmentLines;
                InFooterBar = true;
                ToolTip = 'Post Sale Documents by Logistic Unit.';

                trigger OnAction();
                var
                    UnitPost: Codeunit "TMAC Unit Post";
                begin
                    UnitPost.PostByLogisticUnit(Rec."No.", Database::"Sales Line", Database::"Sales Shipment Line");
                end;
            }
            action(PrintSSCC)
            {
                ApplicationArea = All;
                Caption = 'Print SSCC label';
                Image = Print;
                InFooterBar = true;
                ToolTip = 'Print SSCC';
                trigger OnAction()
                var
                    SSCCManagement: Codeunit "TMAC SSCC Management";
                begin
                    SSCCManagement.PrintSSCCByLogisticUnit(Rec."No.");
                end;
            }

            action(History)
            {
                ApplicationArea = All;
                Caption = 'Entries';
                Image = Entry;
                InFooterBar = true;
                ToolTip = 'Shows the log entries.';
                RunObject = Page "TMAC Unit Entries";
                RunPageLink = "Unit No." = field("No.");
            }

            action(Worksheet)
            {
                ApplicationArea = All;
                Caption = 'Unit Worksheet';
                Image = Entry;
                InFooterBar = true;
                ToolTip = 'Shows unit worksheet to register operations.';
                trigger OnAction()
                var
                    UnitWorksheet: Page "TMAC Unit Worksheets";
                begin
                    UnitWorksheet.AddUnit(Rec."No.");
                    UnitWorksheet.Run();
                end;
            }
            action(TrackingAction)
            {
                ApplicationArea = All;
                Caption = 'Update Tracking Information';
                Image = Refresh;
                InFooterBar = true;
                ToolTip = 'Request tracking & delivery information.';
                trigger OnAction()
                var
                    TrackingManagement: Codeunit "TMAC Tracking Management";
                begin
                    TrackingManagement.UpdateTrackingInformation(Rec);
                    CurrPage.Update();
                end;
            }
            action(TrackingDetails)
            {
                ApplicationArea = All;
                Caption = 'Detailed Tracking Information';
                Image = Track;
                InFooterBar = true;
                ToolTip = 'Request tracking & delivery information.';
                trigger OnAction()
                var
                    TrackingManagement: Codeunit "TMAC Tracking Management";
                begin
                    TrackingManagement.OpenTrackingInformation(Rec);
                end;
            }

            action(LoadDetails)
            {
                ApplicationArea = All;
                Caption = 'Load Details';
                Image = Track;
                InFooterBar = true;
                ToolTip = 'Shows all units linked to this logistic unit.';
                trigger OnAction()
                var
                    UnitsLoadDetails: Page "TMAC Unit Load Details";
                    Units: List of [Code[20]];
                begin
                    Units.Add(Rec."No.");
                    UnitsLoadDetails.SetUnits(Units);
                    UnitsLoadDetails.Run();
                end;
            }

        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetEnableFields();
    end;

    trigger OnAfterGetRecord()
    begin
        CurrPage.Documents.Page.UpdateLines(Rec."No.", 0);
        SetEnableFields();
    end;

    local procedure SetEnableFields()
    begin
        IsSubformEditable := (Rec."No." <> '') and (Rec."Type Code" <> '');
    end;

    var
        IsSubformEditable: Boolean;
}