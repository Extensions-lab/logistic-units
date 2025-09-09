page 71628587 "TMAC Unit Card Docs Subf."
{
    ApplicationArea = All;
    Caption = 'Documents';
    PageType = ListPart;
    SourceTable = "TMAC Unit Document Info";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                IndentationColumn = 0;

                field("Source Name"; Rec."Document Name")
                {
                }
                field("Source ID"; Rec."Document No.")
                {
                    trigger OnDrillDown()
                    begin
                        UnitLinkManagement.ShowDocument(Rec."Source Type", Rec."Source Subtype", Rec."Source ID");
                    end;
                }
            }
        }
    }

    internal procedure UpdateLines(UnitNo: Code[20]; PostedVersion: Integer)
    var
        UnitLineLink: Record "TMAC Unit Line Link";
        PostedUnitLineLink: Record "TMAC Posted Unit Line Link";
    begin
        Rec.DeleteAll();
        UnitLineLink.Reset();
        if PostedVersion > 0 then begin
            PostedUnitLineLink.Reset();
            PostedUnitLineLink.Setrange("Unit No.", UnitNo);
            PostedUnitLineLink.Setrange("Posted Version", PostedVersion);
            PostedUnitLineLink.SetLoadFields("Unit No.", "Source Type", "Source Subtype", "Source ID", "Source Name", Positive);
            if PostedUnitLineLink.FindSet() then
                repeat
                    UnitLineLink.TransferFields(PostedUnitLineLink);
                    AddToRec(PostedUnitLineLink."Unit No.", PostedUnitLineLink."Source Type", PostedUnitLineLink."Source Subtype", PostedUnitLineLink."Source ID", PostedUnitLineLink."Source Name", PostedUnitLineLink.Positive);
                until PostedUnitLineLink.Next() = 0;
        end else begin
            UnitLineLink.Reset();
            UnitLineLink.Setrange("Unit No.", UnitNo);
            UnitLineLink.SetLoadFields("Unit No.", "Source Type", "Source Subtype", "Source ID", "Source Name", Positive);
            if UnitLineLink.FindSet() then
                repeat
                    AddToRec(UnitLineLink."Unit No.", UnitLineLink."Source Type", UnitLineLink."Source Subtype", UnitLineLink."Source ID", UnitLineLink."Source Name", UnitLineLink.Positive);
                until UnitLineLink.next() = 0;
        end;
    end;

    local procedure AddToRec(UnitNo: Code[20]; SourceType: Integer; SourceDocumentType: Integer; SourceDocumentNo: Code[20]; SourceName: Text[50]; Positive: Boolean)
    var
        SortingNo: Integer;
    begin
        SortingNo := GetSortingNo(SourceType, SourceDocumentType, Positive);
        Rec.Init();
        Rec."Unit No." := UnitNo;
        Rec.Sorting := SortingNo;
        Rec."Source Type" := SourceType;

        if SourceDocumentType = Database::"Transfer Line" then
            Rec."Source Subtype" := 0
        else
            Rec."Source Subtype" := SourceDocumentType;

        Rec."Source ID" := SourceDocumentNo;
        Rec."Source Batch Name" := '';
        Rec."Source Prod. Order Line" := 0;
        Rec."Source Ref. No." := 0;
        Rec."Document No." := SourceDocumentNo;
        Rec."Document Name" := SourceName;
        if Rec.Insert(true) then;
    end;

    local procedure GetSortingNo(SourceType: Integer; SourceDocumentType: Integer; Positive: Boolean): Integer
    begin
        case SourceType of
            Database::"Purchase Header",
            Database::"Purchase Line":
                case SourceDocumentType of
                    1:
                        exit(100);
                    2:
                        exit(101);
                    3:
                        exit(0); // credit-memo
                    4:
                        exit(0);
                    5:
                        exit(2700); // purchase return = shipment
                end;
            Database::"Purch. Rcpt. Line":
                exit(200);
            Database::"Transfer Receipt Line":
                exit(300);
            Database::"Return Receipt Line":
                exit(400);
            Database::"Warehouse Receipt Line":
                exit(500);
            Database::"Posted Whse. Receipt Line":
                exit(600);
            Database::"Transfer Line":
                if Positive then
                    exit(250)
                else
                    exit(2350);
            Database::"Warehouse Activity Line":
                case SourceDocumentType of
                    "Warehouse Activity Type"::"Put-away".AsInteger():
                        exit(800);
                    "Warehouse Activity Type"::Movement.AsInteger():
                        exit(850);
                    "Warehouse Activity Type"::Pick.AsInteger():
                        exit(900);
                    "Warehouse Activity Type"::"Invt. Put-away".AsInteger():
                        exit(805);
                    "Warehouse Activity Type"::"Invt. Movement".AsInteger():
                        exit(855);
                    "Warehouse Activity Type"::"Invt. Pick".AsInteger():
                        exit(905);
                end;
            Database::"Registered Whse. Activity Line":
                case SourceDocumentType of
                    "Warehouse Activity Type"::"Put-away".AsInteger():
                        exit(801);
                    "Warehouse Activity Type"::Movement.AsInteger():
                        exit(851);
                    "Warehouse Activity Type"::Pick.AsInteger():
                        exit(901);
                    "Warehouse Activity Type"::"Invt. Put-away".AsInteger():
                        exit(806);
                    "Warehouse Activity Type"::"Invt. Movement".AsInteger():
                        exit(856);
                    "Warehouse Activity Type"::"Invt. Pick".AsInteger():
                        exit(906);
                end;
            Database::"Posted Whse. Shipment Line":
                exit(2000);
            Database::"Warehouse Shipment Line":
                exit(2100);
            Database::"Sales Shipment Line":
                exit(2200);
            Database::"Transfer Shipment Line":
                exit(2300);
            Database::"Return Shipment Line":
                exit(2500);
            Database::"Sales Header",
            Database::"Sales Line":
                case SourceDocumentType of
                    1:
                        exit(2600);
                    2:
                        exit(2601);
                    3:
                        exit(10000);
                    4:
                        exit(10000);
                    5:
                        exit(150); // sales return
                end;
        end
    end;

    var
        UnitLinkManagement: Codeunit "TMAC Unit Link Management";
}
