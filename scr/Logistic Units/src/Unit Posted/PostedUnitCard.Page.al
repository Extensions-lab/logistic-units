page 71628605 "TMAC Posted Unit Card"
{
    Caption = 'Posted Unit';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = History;
    SourceTable = "TMAC Posted Unit";
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    
    AboutTitle = 'Logistic Unit';
    AboutText = ' is box, pallet or container; is a combination of: a logistics carrier, such as a pallet, which is uniquely identified worldwide by means of a Global Returnable Asset Identifier **(GRAI)**. and products uniquely identified worldwide using Global Trade Item Numbers **(GTIN’s)**.';
   
    ContextSensitiveHelpPage = 'blob/main/logisticunit.md';

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                Caption = 'General';

                group(FirstColumn)
                {
                    ShowCaption = false;

                    field("No."; Rec."No.")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }

                    field("Posted version"; Rec."Posted version")
                    {
                        ApplicationArea = All;
                    }

                    field("Description"; Rec."Description")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }

                    field("Type Code"; Rec."Type Code")
                    {
                        ApplicationArea = All;
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

                    field("SSCC No."; Rec."SSCC No.")
                    {
                        ApplicationArea = All;

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
                    field("Tracking No."; Rec."Tracking No.")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                    field(Place; Rec."LU Location Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Reusable"; Rec."Reusable")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                }
            }

            part("TMAC Unit Line Subform"; "TMAC Posted Unit Card Line Sub")
            {
                Caption = 'Lines';
                ApplicationArea = Basic, Suite;
                Editable = IsSubformEditable;
                SubPageLink = "Unit No." = FIELD("No."), "Posted Version" = field("Posted Version");
                UpdatePropagation = Both;
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

            part(Documents; "TMAC Unit Card Docs Subf.")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                SubPageLink = "Unit No." = FIELD("No.");
            }

            group(Measurements)
            {
                Caption = 'Measurements';
                group(Sizes)
                {
                    Caption = 'Sizes';
                    field("Length"; Rec.Length)
                    {
                        ApplicationArea = All;
                    }
                    field("Width"; Rec.Width)
                    {
                        ApplicationArea = All;
                    }
                    field("Height"; Rec.Height)
                    {
                        ApplicationArea = All;
                    }
                    field("Volume"; Rec."Volume")
                    {
                        ApplicationArea = All;
                    }
                }
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
                    field("Weight (Base)"; Rec."Weight (Base)")
                    {
                        CaptionClass = '71628575,2,' + Rec.FieldCaption("Weight (Base)");
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                    field("Volume (Base)"; Rec."Volume (Base)")
                    {
                        CaptionClass = '71628575,1,' + Rec.FieldCaption("Volume (Base)");
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                }
            }
        }
    }
    actions
    {
        area(Promoted)
        {
            group(Category_Tracking)
            {
                Caption = 'Tracking';
                actionref(TrackingDetails_Promoted; TrackingDetails)
                {
                }
            }
            group(Category_History)
            {
                Caption = 'History';
                actionref(History_Promoted; History)
                {
                }
            }
        }

        area(Processing)
        {

            action(History)
            {
                ApplicationArea = All;
                Caption = 'Entries';
                Image = Entry;
                InFooterBar = true;
                ToolTip = 'Shows the unit log entries.';
                RunObject = Page "TMAC Posted Unit Entries";
                RunPageLink = "Unit No." = field("No."), "Posted Version" = field("Posted Version");
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
                    Unit: Record "TMAC Unit";
                    TrackingManagement: Codeunit "TMAC Tracking Management";
                begin
                    Unit.TransferFields(Rec);
                    TrackingManagement.OpenTrackingInformation(Unit);
                end;
            }
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetEnableFields();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetEnableFields();
    end;

    trigger OnAfterGetRecord()
    begin
        CurrPage.Documents.Page.UpdateLines(Rec."No.", Rec."Posted Version");
    end;

    local procedure SetEnableFields()
    begin
        IsSubformEditable := CurrPage.Editable;
    end;

    var
        IsSubformEditable: Boolean;
}