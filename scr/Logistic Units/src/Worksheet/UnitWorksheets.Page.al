page 71628597 "TMAC Unit Worksheets"
{
    ApplicationArea = All;
    Caption = 'Logistic Units Worksheets';
    PageType = Worksheet;
    SourceTable = "TMAC Unit Worksheet Line";
    UsageCategory = Tasks;
    AutoSplitKey = true;

    layout
    {
        area(content)
        {

            field(CurrentWkshName; CurrentWkshName)
            {
                ApplicationArea = Warehouse;
                Caption = 'Name';
                Lookup = true;
                ToolTip = 'Specifies the name of the logistic units worksheet in which you can organize various kinds of operations.';

                trigger OnLookup(var Text: Text): Boolean
                begin
                    CurrPage.SaveRecord();
                    LookupWhseWkshName(Rec, CurrentWkshName);
                    CurrPage.Update(false);
                end;

                trigger OnValidate()
                begin
                    CheckWhseWkshName(CurrentWkshName, Rec);
                    CurrentWkshNameOnAfterValidate();
                end;
            }
            repeater(General)
            {
                ShowCaption = false;
                field("Unit No."; Rec."Unit No.")
                {
                }
                field("Date"; Rec.Date)
                {
                }
                field("Date And Time"; Rec."Date And Time")
                {
                    Visible = false;
                }
                field("Action Code"; Rec."Action Code")
                {
                }
                field("LU Location Code"; Rec."LU Location Code")
                {
                }
                field(Description; Rec.Description)
                {
                }

                field("Location Code"; Rec."Location Code")
                {
                    Visible = false;
                }
                field("Zone Code"; Rec."Zone Code")
                {
                    Visible = false;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(GetLogisticUnits_Promoted; GetLogisticUnits)
                {
                }
                actionref(Post_Promoted; Post)
                {
                }
                actionref(History_Promoted; History)
                {

                }
            }
        }

        area(Processing)
        {
            action(GetLogisticUnits)
            {
                Caption = 'Get Logistic Units';
                Image = GetSourceDoc;
                ShortCutKey = 'Shift+F11';
                ToolTip = 'Select a logistic units.';
                trigger OnAction()
                var
                    GetLogisticUnits: Report "TMAC Get Logistic Units";
                begin
                    GetLogisticUnits.SetUnitWorkSheetName(CurrentWkshName);
                    GetLogisticUnits.RunModal();
                    CurrPage.Update();
                end;
            }

            action(Post)
            {
                ApplicationArea = All;
                Caption = 'Post';
                Image = Post;
                ShortCutKey = 'F9';
                ToolTip = 'Finalize the journal or journal by posting the lines to unit entries.';

                trigger OnAction()
                var
                    UnitManagement: Codeunit "TMAC Unit Management";
                begin
                    UnitManagement.PostUnitWorksheet(Rec);
                end;
            }


            action(History)
            {
                ApplicationArea = All;
                Caption = 'Unit Entries';
                Image = Entry;
                InFooterBar = true;
                ToolTip = 'Shows the log entries.';
                RunObject = Page "TMAC Unit Entries";
                RunPageLink = "Unit No." = field("Unit No.");
            }
        }
    }

    trigger OnOpenPage()
    var
        UnitWorksheetName: Record "TMAC Unit Worksheet Name";
        UnitWorksheetLine: Record "TMAC Unit Worksheet Line";
        LineNo: Integer;
    begin
        OpenedFromBatch := Rec.Name <> '';
        if OpenedFromBatch then begin
            CurrentWkshName := Rec.Name;
            OpenWhseWksh(Rec, CurrentWkshName);
            exit;
        end;

        UnitWorksheetName.SetRange("USER ID", UserId());
        if UnitWorksheetName.FindFirst() then
            CurrentWkshName := UnitWorksheetName.Name
        else begin
            UnitWorksheetName.SetRange("USER ID");
            UnitWorksheetName.FindFirst();
            CurrentWkshName := UnitWorksheetName.Name
        end;
        OpenWhseWksh(Rec, CurrentWkshName);

        if AutoAddUnitNo <> '' then begin
            LineNo := 10000;
            UnitWorksheetLine.Reset();
            UnitWorksheetLine.Setrange(Name, CurrentWkshName);
            if UnitWorksheetLine.FindLast() then
                LineNo := UnitWorksheetLine."Line No." + 10000;
            UnitWorksheetLine.Init();
            UnitWorksheetLine.Name := CurrentWkshName;
            UnitWorksheetLine."Line No." := LineNo;
            UnitWorksheetLine.Insert(true);
            UnitWorksheetLine.Validate("Unit No.", AutoAddUnitNo);
            UnitWorksheetLine.Modify(true);
            if Rec.Get(CurrentWkshName, LineNo) then;
        end;
    end;

    internal procedure LookupWhseWkshName(var UnitWorksheetLine: Record "TMAC Unit Worksheet Line"; var CurrentWkshName1: Code[10])
    var
        UnitWorksheetName: Record "TMAC Unit Worksheet Name";
    begin
        Commit();
        if PAGE.RunModal(0, UnitWorksheetName) = ACTION::LookupOK then begin
            CurrentWkshName1 := UnitWorksheetName.Name;
            SetWhseWkshName(CurrentWkshName1, UnitWorksheetLine);
        end;
    end;

    internal procedure SetWhseWkshName(CurrentWkshName1: Code[10]; var UnitWorksheetLine: Record "TMAC Unit Worksheet Line")
    begin
        UnitWorksheetLine.FilterGroup := 2;
        UnitWorksheetLine.SetRange(Name, CurrentWkshName1);
        UnitWorksheetLine.FilterGroup := 0;
        if UnitWorksheetLine.Find('-') then;
    end;

    internal procedure CheckWhseWkshName(CurrentWkshName1: Code[10]; var UnitWorksheetLine: Record "TMAC Unit Worksheet Line")
    var
        UnitWorksheetName: Record "TMAC Unit Worksheet Name";
    begin
        UnitWorksheetName.Get(CurrentWkshName1);
    end;

    protected procedure CurrentWkshNameOnAfterValidate()
    begin
        CurrPage.SaveRecord();
        SetWhseWkshName(CurrentWkshName, Rec);
        CurrPage.Update(false);
    end;

    internal procedure OpenWhseWksh(var UnitWorksheetLine: Record "TMAC Unit Worksheet Line"; CurrentWkshName1: Code[10])
    begin
        UnitWorksheetLine.FilterGroup := 2;
        UnitWorksheetLine.SetRange(Name, CurrentWkshName1);
        UnitWorksheetLine.FilterGroup := 0;
    end;

    internal procedure AddUnit(UnitNo: Code[20])
    begin
        AutoAddUnitNo := UnitNo;
    end;

    var
        OpenedFromBatch: Boolean;
        CurrentWkshName: Code[10];
        AutoAddUnitNo: Code[20];
}
