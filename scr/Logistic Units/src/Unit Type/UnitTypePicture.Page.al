
page 71628601 "TMAC Unit Type Picture"
{
    Caption = 'Unit Type Picture';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = CardPart;
    SourceTable = "TMAC Unit Type";

    layout
    {
        area(content)
        {
            field(Picture; Rec.Picture)
            {
                ApplicationArea = Basic, Suite;
                ShowCaption = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(TakePicture)
            {
                ApplicationArea = All;
                Caption = 'Take';
                Image = Camera;
                ToolTip = 'Activate the camera on the device.';
                Visible = CameraAvailable AND (HideActions = FALSE);

                trigger OnAction()
                begin
                    TakeNewPicture();
                end;
            }
            action(ImportPicture)
            {
                ApplicationArea = All;
                Caption = 'Import';
                Image = Import;
                ToolTip = 'Import a picture file.';
                Visible = HideActions = FALSE;

                trigger OnAction()
                begin
                    ImportFromDevice();
                end;
            }
            action(ExportFile)
            {
                ApplicationArea = All;
                Caption = 'Export';
                Enabled = DeleteExportEnabled;
                Image = Export;
                ToolTip = 'Export the picture to a file.';
                Visible = HideActions = FALSE;

                trigger OnAction()
                begin
                    ExportToFile();
                end;
            }
            action(DeletePicture)
            {
                ApplicationArea = All;
                Caption = 'Delete';
                Enabled = DeleteExportEnabled;
                Image = Delete;
                ToolTip = 'Delete the record.';
                Visible = HideActions = FALSE;

                trigger OnAction()
                begin
                    DeleteItemPicture();
                end;
            }
        }
    }


    trigger OnAfterGetCurrRecord()
    begin
        SetEditableOnPictureActions();
    end;

    trigger OnOpenPage()
    begin
        CameraAvailable := Camera.IsAvailable();
    end;


    internal procedure TakeNewPicture()
    var
        InStream: InStream;
    begin
        if Rec.FindFirst() then begin
            Rec.TestField(Code);
            Rec.TestField(Description);

            if not CameraAvailable then
                exit;

            Camera.RunModal();
            if Camera.HasPicture() then begin
                if Rec.Picture.HasValue then
                    if not Confirm(OverrideImageQst) then
                        exit;

                Camera.GetPicture(Instream);

                Clear(Rec.Picture);
                Rec.Picture.ImportStream(Instream, 'Item Picture');
                if not Rec.Modify(true) then
                    Rec.Insert(true);
            end;

            Clear(Camera);
        end;
    end;

    internal procedure ImportFromDevice()
    var
        PictureInStream: InStream;
        FileName: Text;
    begin
        if Rec.FindFirst() then begin
            Rec.TestField(Code);

            if Rec.Picture.HasValue then
                if not CONFIRM(OverrideImageQst) then
                    exit;
            if UploadIntoStream(DialogCaptionMsg, PictureInStream) then begin
                Rec.Picture.ImportStream(PictureInStream, FileName);
                Rec.Modify(TRUE);
            end;
        end;
    end;

    internal procedure ExportToFile()

    var
        TempBlob: Codeunit "Temp Blob";
        ToFile: Text;
        InStream: InStream;
        OutStream: OutStream;
    begin
        if Rec.FindFirst() then begin
            Rec.TestField(Code);
            if Rec.Picture.HasValue then begin
                TempBlob.CreateOutStream(OutStream);
                Rec.Picture.ExportStream(OutStream);
                TempBlob.CreateInStream(InStream);
                IF not DownloadFromStream(InStream, 'Export Picture', '', '', ToFile) then
                    Message('Unable to export');
            end;
        end;
    end;

    local procedure SetEditableOnPictureActions()
    begin
        DeleteExportEnabled := Rec.Picture.HasValue;
    end;

    internal procedure IsCameraAvailable(): Boolean
    begin
        exit(Camera.IsAvailable());
    end;

    internal procedure SetHideActions()
    begin
        HideActions := true;
    end;

    internal procedure DeleteItemPicture()
    begin
        Rec.TestField(Code);

        if not Confirm(DeleteImageQst) then
            exit;

        Clear(Rec.Picture);
        Rec.Modify(true);
    end;

    var
        Camera: Page Camera;
        DeleteExportEnabled: Boolean;
        CameraAvailable: Boolean;
        HideActions: Boolean;
        OverrideImageQst: Label 'The existing picture will be replaced. Do you want to continue?';
        DeleteImageQst: Label 'Are you sure you want to delete the picture?';
        DialogCaptionMsg: Label 'Select a picture to upload (*.png)|*.png';



}