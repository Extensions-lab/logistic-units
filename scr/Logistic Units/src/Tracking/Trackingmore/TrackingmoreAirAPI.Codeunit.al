codeunit 71628598 "TMAC Trackingmore Air API" implements "TMAC Tracking Provider Impl."
{
    procedure Track(TrackingNumber: Text; AddParameter: Text): Integer;
    var
        error: Integer;
    begin
        error := AirTracking(TrackingNumber);
        case error of
            0:
                exit;
            1:
                error(LastError)
            else
                error(ConnectionErr);
        end;
    end;

    procedure CancelTracking(TrackingNumber: Text; CarrierCode: Text);
    begin
    end;

    procedure AirTracking(TrackingNumber: Text) errorcode: Integer
    var
        TrackingSetup: Record "TMAC Tracking Setup";
        TypeHelper: Codeunit "Type Helper";
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        QueryString: Text;
        ResponseTxt: text;
        HttpContent: HttpContent;
        Body: JsonObject;
        TrackingNumber1: Text;
        BodyText: Text;
    begin
        ClearAPIMessages();

        if not TrackingSetup.get() then begin
            errorcode := 1;
            LastError := ThereIsNoAfterShipSettingsErr;
            exit;
        end;

        if (TrackingSetup."Trackingmore API Key" = '') or
           (TrackingSetup."Trackingmore AirCargo URL" = '')
        then begin
            errorcode := 1;
            LastError := ThereIsNoAfterShipSettingsErr;
            exit;
        end;

        QueryString := TrackingSetup."Trackingmore AirCargo URL";

        HttpRequestMessage.Method := 'POST';
        HttpRequestMessage.GetHeaders(Headers);
        Headers.Add('User-Agent', 'Microsoft Dynamics 365 Business Central');
        Headers.Add('Trackingmore-Api-Key', TrackingSetup."Trackingmore API Key");

        TrackingNumber1 := DelChr(TrackingNumber, '=', '-');
        Body.Add('track_number', TypeHelper.UrlEncode(TrackingNumber1));
        Body.WriteTo(BodyText);
        HttpContent.WriteFrom(BodyText);
        HttpRequestMessage.Content(HttpContent);

        HttpRequestMessage.SetRequestUri(QueryString);
        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            if HttpResponseMessage.HttpStatusCode = 200 then begin
                HttpResponseMessage.Content.ReadAs(ResponseTxt);
                if ParseCreateTrackingResponse(ResponseTxt, TrackingNumber) = '' then
                    errorcode := 0
                else
                    errorcode := 1;
            end else
                errorcode := HttpResponseMessage.HttpStatusCode;
        end else
            errorcode := 3;
    end;

    procedure ParseCreateTrackingResponse(ResponseText: Text; TrackingNumber: Text) Errortext: Text
    var
        TrackingmoreAirTracking: record "TMAC Trackingmore Air Tracking";
        TrackingmoreAirTracking2: record "TMAC Trackingmore Air Tracking";
        TrackingmoreAirDetail: Record "TMAC Trackingmore Air Detail";
        JsonManagement: Codeunit "TMAC JSON Management";
        Response: JsonObject;
        metajso: JsonObject;
        datajso: JsonObject;
        trackingnumberjso: JsonObject;
        airlineinfojso: JsonObject;
        flightinfojso: JsonObject;
        returndatajso: JsonObject;
        currentflightjso: JsonObject;
        CurrentTrack: JsonObject;
        TrackArray: JsonArray;
        Token: JsonToken;
        code: Text;
        message: Text;
        type: Text;
        EntryNo: Integer;
        flightnumbers: Text;
        CurrentFlight: Text;
        SourceTackingNumber: Text;
        FlightList: List of [Text[15]];
        Tokens: List of [JsonToken];
        TrackingExist: Boolean;
    begin
        SourceTackingNumber := TrackingNumber;
        Response.ReadFrom(ResponseText);
        JsonManagement.SetJsonObject(Response);
        if JsonManagement.ProperyExist('meta') then
            metajso := JsonManagement.GetJsonObject('meta');

        if JsonManagement.ProperyExist('data') then
            datajso := JsonManagement.GetJsonObject('data');

        JsonManagement.SetJsonObject(metajso);
        code := JsonManagement.SelectJsonValue('code').AsText();

        if JsonManagement.ProperyExist('message') then
            message := JsonManagement.SelectJsonValue('message').AsText();

        if JsonManagement.ProperyExist('type') then
            type := JsonManagement.SelectJsonValue('type').AsText();

        if (code = '200') or (code = '201') then begin
            JsonManagement.SetJsonObject(datajso);
            TrackingNumber := DelChr(TrackingNumber, '=', '-');
            TrackingNumber := ConvertAWB(TrackingNumber);
            if JsonManagement.ProperyExist(TrackingNumber) then begin
                TrackingmoreAirTracking2.Reset();
                TrackingmoreAirTracking2.SetRange("Tracking Number", SourceTackingNumber);
                TrackingExist := not TrackingmoreAirTracking2.IsEmpty;

                TrackingmoreAirTracking.Init();
                TrackingmoreAirTracking."Tracking Number" := CopyStr(SourceTackingNumber, 1, 50);

                trackingnumberjso := JsonManagement.GetJsonObject(TrackingNumber);

                JsonManagement.SetJsonObject(trackingnumberjso);
                if JsonManagement.ProperyExist('return_data') then begin
                    returndatajso := JsonManagement.GetJsonObject('return_data');
                    JsonManagement.SetJsonObject(returndatajso);
                    TrackingmoreAirTracking.Weight := CopyStr(JsonManagement.GetPropertyAsText('weight'), 1, 50);
                    TrackingmoreAirTracking.Piece := JsonManagement.GetPropertyAsInteger('piece');
                    TrackingmoreAirTracking.Origin := CopyStr(JsonManagement.GetPropertyAsText('origin'), 1, 10);
                    TrackingmoreAirTracking.Destination := CopyStr(JsonManagement.GetPropertyAsText('destination'), 1, 10);
                    TrackingmoreAirTracking."Last Event" := CopyStr(JsonManagement.GetPropertyAsText('last_event'), 1, 250);

                    if (TrackingmoreAirTracking."Last Event" <> '') and
                       (TrackingExist)
                    then begin
                        TrackingmoreAirTracking2.Reset();
                        TrackingmoreAirTracking2.SetRange("Tracking Number", SourceTackingNumber);
                        TrackingmoreAirTracking2.DeleteAll();

                        TrackingmoreAirDetail.Reset();
                        TrackingmoreAirDetail.SetRange("Tracking Number", SourceTackingNumber);
                        TrackingmoreAirDetail.DeleteAll(true);
                    end;

                    Clear(FlightList);
                    if JsonManagement.ProperyExist('track_info') then begin
                        EntryNo := 10000;
                        TrackArray := JsonManagement.GetJsonArray('track_info');
                        if TrackArray.Count > 0 then
                            foreach Token in TrackArray do begin
                                CurrentTrack := Token.AsObject();
                                JsonManagement.SetJsonObject(CurrentTrack);
                                EntryNo += 10000;
                                TrackingmoreAirDetail.Init();
                                TrackingmoreAirDetail."Tracking Number" := CopyStr(SourceTackingNumber, 1, 50);
                                TrackingmoreAirDetail."Entry No." := EntryNo;
                                TrackingmoreAirDetail."Plan Date" := ConvertToDatetime(JsonManagement.GetPropertyAsText('plan_date'));
                                TrackingmoreAirDetail."Actual Date" := ConvertToDatetime(JsonManagement.GetPropertyAsText('actual_date'));
                                TrackingmoreAirDetail."Event" := CopyStr(JsonManagement.GetPropertyAsText('event'), 1, 250);
                                TrackingmoreAirDetail.Station := CopyStr(JsonManagement.GetPropertyAsText('station'), 1, 10);
                                TrackingmoreAirDetail."Flight Number" := CopyStr(JsonManagement.GetPropertyAsText('flight_number'), 1, 15);
                                TrackingmoreAirDetail.Status := CopyStr(JsonManagement.GetPropertyAsText('status'), 1, 50);
                                TrackingmoreAirDetail.Piece := CopyStr(JsonManagement.GetPropertyAsText('piece'), 1, 20);
                                TrackingmoreAirDetail.Weight := CopyStr(JsonManagement.GetPropertyAsText('weight'), 1, 15);
                                if TrackingmoreAirDetail.Insert() then;

                                if not FlightList.Contains(TrackingmoreAirDetail."Flight Number") then
                                    FlightList.add(TrackingmoreAirDetail."Flight Number");
                            end;
                    end;

                    foreach CurrentFlight in FlightList do
                        if flightnumbers = '' then
                            flightnumbers := CurrentFlight
                        else
                            flightnumbers += flightnumbers + ',' + CurrentFlight;

                    TrackingmoreAirTracking."Flight Info" := CopyStr(flightnumbers, 1, 100);

                    JsonManagement.SetJsonObject(returndatajso);
                    if JsonManagement.ProperyExist('flight_info') then begin
                        flightinfojso := JsonManagement.GetJsonObject('flight_info');
                        Tokens := flightinfojso.Values();
                        if Tokens.Count > 0 then
                            foreach Token in Tokens do
                                if Token.IsObject then begin
                                    currentflightjso := Token.AsObject();
                                    JsonManagement.SetJsonObject(currentflightjso);

                                    if TrackingmoreAirTracking.Origin = JsonManagement.GetPropertyAsText('depart_station') then
                                        TrackingmoreAirTracking."Origin Departure Time" := ConvertToDatetime(JsonManagement.GetPropertyAsText('depart_time'));

                                    if TrackingmoreAirTracking.Destination = JsonManagement.GetPropertyAsText('arrival_station') then
                                        TrackingmoreAirTracking."Destination Arrival Time" := ConvertToDatetime(JsonManagement.GetPropertyAsText('arrival_time'));
                                end
                    end;


                    JsonManagement.SetJsonObject(trackingnumberjso);
                    if JsonManagement.ProperyExist('airline_info') then begin
                        airlineinfojso := JsonManagement.GetJsonObject('airline_info');
                        JsonManagement.SetJsonObject(airlineinfojso);
                        TrackingmoreAirTracking.Airline := CopyStr(JsonManagement.GetPropertyAsText('name'), 1, 250);
                        TrackingmoreAirTracking."Airline Url" := CopyStr(JsonManagement.GetPropertyAsText('url'), 1, 250);
                        TrackingmoreAirTracking."Airline Track Url" := CopyStr(JsonManagement.GetPropertyAsText('track_url'), 1, 250);
                    end;
                end;

                if (TrackingmoreAirTracking."Last Event" = '') then begin
                    if (not TrackingExist) then
                        TrackingmoreAirTracking.Insert();
                end else
                    TrackingmoreAirTracking.Insert();
            end;
        end else
            LastError := APIErr + code + '  ' + message + '   ' + type;
        Errortext := LastError;
    end;

    procedure ConvertAWB(TrackingNumber: Text): Text
    begin
        exit(CopyStr(TrackingNumber, 1, 3) + '-' + CopyStr(TrackingNumber, 4));
    end;

    local procedure ConvertToDatetime(DateText: Text) rv: DateTime
    var
        TypeHelper: Codeunit "Type Helper";
        AVariant: Variant;
        FormatString: Text;
    begin
        //2020-05-01 16:3
        AVariant := rv;
        FormatString := 'yyyy-MM-dd HH:mm:ss';
        if TypeHelper.Evaluate(AVariant, DateText, FormatString, '') then
            rv := AVariant
        else begin
            FormatString := 'yyyy-MM-dd HH:mm';
            if TypeHelper.Evaluate(AVariant, DateText, FormatString, '') then
                rv := AVariant
        end;
    end;

    procedure ClearAPIMessages()
    begin
        LastError := '';
        LastApiCode := '';
        LastApiMessage := '';
    end;

    procedure GetLastError(): Text;
    begin
        exit(LastError);
    end;

    procedure GetApiCode(): Text;
    begin
        exit(LastApiCode);
    end;

    procedure GetApiMessage(): Text;
    begin
        exit(LastApiMessage);
    end;

    var
        LastError: text;
        LastApiCode: text;
        LastApiMessage: Text;

        APIErr: Label 'API Error: ';
        ConnectionErr: Label 'Connection error. Check if the web service for TMS is enabled.';

        ThereIsNoAfterShipSettingsErr: Label 'There is no settings for trackingmore.com service. Run Assisted setup Wizard for setup trackingmore.com integration.';

}