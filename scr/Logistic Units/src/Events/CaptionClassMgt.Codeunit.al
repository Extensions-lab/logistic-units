
codeunit 71628575 "TMAC CaptionClass Mgt"
{
    SingleInstance = true;


    [EventSubscriber(ObjectType::Codeunit, 42, 'OnResolveCaptionClass', '', true, true)]
    local procedure ResolveCaptionClass(CaptionArea: Text; CaptionExpr: Text; Language: Integer; var Caption: Text; var Resolved: Boolean)
    begin
        if CaptionArea = '71628575' then begin
            Caption := CaptionClassTranslate(CaptionExpr);
            Resolved := true;
        end;
    end;

    local procedure CaptionClassTranslate(CaptionExpr: Text): Text
    var
        CaptionType: Text;
        CaptionRef: Text;
        CommaPosition: Integer;
    begin
        CommaPosition := StrPos(CaptionExpr, ',');
        if CommaPosition > 0 then begin
            CaptionType := CopyStr(CaptionExpr, 1, CommaPosition - 1);
            CaptionRef := CopyStr(CaptionExpr, CommaPosition + 1);

            if not SetupReady then begin
                LogisticUnitsSetup.Get();
                SetupReady := true;
            end;

            case CaptionType of
                '0':
                    exit(CaptionRef + ' (' + LogisticUnitsSetup."Base Linear UoM Caption" + ')');
                '1':
                    exit(CaptionRef + ' (' + LogisticUnitsSetup."Base Volume UoM Caption" + ')');
                '2':
                    exit(CaptionRef + ' (' + LogisticUnitsSetup."Base Weight UoM Caption" + ')');
                '3':
                    exit(CaptionRef + ' (' + LogisticUnitsSetup."Base Distance UoM Caption" + ')');
                '9':
                    exit(CaptionRef);
            end;
            exit(CaptionRef);
        end;
        exit('');
    end;

    var
        LogisticUnitsSetup: Record "TMAC Logistic Units Setup";
        SetupReady: Boolean;  

}