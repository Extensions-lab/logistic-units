codeunit 71628597 "TMAC Trackingmore API" implements "TMAC Tracking Provider Impl."
{
    procedure Track(TrackingNumber: Text; CarrierCode: Text): Integer;
    var
        error: Integer;
    begin
        error := GetResult(TrackingNumber, CarrierCode);
        case error of
            0:
                exit;
            1:
                if LastApiCode = '4031' then
                    CreateTracking(TrackingNumber, CarrierCode);
            else
                error(ConnectionErr);
        end;
    end;

    procedure CancelTracking(TrackingNumber: Text; CarrierCode: Text);
    begin
        TryDeleteTracking(TrackingNumber, CarrierCode);
    end;

    [TryFunction]
    local procedure TryDeleteTracking(TrackingNumber: Text; CarrierCode: Text)
    begin
        DeleteTracking(TrackingNumber, CarrierCode);
    end;

    procedure GetAllCouriers() errorcode: Integer
    var
        TrackingSetup: Record "TMAC Tracking Setup";
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        QueryString: Text;
        ResponseTxt: text;

    begin
        ClearAPIMessages();

        if not TrackingSetup.get() then begin
            errorcode := 1;
            LastError := ThereIsNoAfterShipSettingsErr;
            exit;
        end;

        if (TrackingSetup."Trackingmore API Key" = '') or
           (TrackingSetup."Trackingmore All Courier URL" = '')
        then begin
            errorcode := 1;
            LastError := ThereIsNoAfterShipSettingsErr;
            exit;
        end;

        QueryString := TrackingSetup."Trackingmore All Courier URL";

        HttpRequestMessage.Method := 'GET';
        HttpRequestMessage.GetHeaders(Headers);
        Headers.Add('User-Agent', 'Microsoft Dynamics 365 Business Central');
        // Headers.Add('Content-Type', 'application/json');
        Headers.Add('Trackingmore-Api-Key', TrackingSetup."Trackingmore API Key");

        HttpRequestMessage.SetRequestUri(QueryString);
        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            if HttpResponseMessage.HttpStatusCode = 200 then begin
                HttpResponseMessage.Content.ReadAs(ResponseTxt);
                if ParseAllCouriers(ResponseTxt) = '' then
                    errorcode := 0
                else
                    errorcode := 1;
            end else
                errorcode := 2;
        end else
            errorcode := 3;
    end;

    procedure ParseAllCouriers(ResponseText: Text) Errortext: Text
    var
        TrackingmoreCarrier: Record "TMAC Trackingmore Carrier";
        JsonManagement: Codeunit "TMAC JSON Management";
        Response: JsonObject;
        metajso: JsonObject;
        CurrentCourier: JsonObject;
        CouriersArray: JsonArray;
        Token: JsonToken;
        code: Text;
        message: Text;
        type: Text;
        name: Text;
        phone: Text;
        homepage: Text;
        carriertype: Text;
        trackurl: text;
        countrycode: Text;
        picture: text;
    begin
        Response.ReadFrom(ResponseText);
        JsonManagement.SetJsonObject(Response);
        if JsonManagement.ProperyExist('meta') then
            metajso := JsonManagement.GetJsonObject('meta');
        if JsonManagement.ProperyExist('data') then
            CouriersArray := JsonManagement.GetJsonArray('data');

        JsonManagement.SetJsonObject(metajso);
        code := JsonManagement.SelectJsonValue('code').AsText();
        LastApiCode := code;

        if JsonManagement.ProperyExist('message') then
            message := JsonManagement.SelectJsonValue('message').AsText();
        LastApiMessage := message;

        if JsonManagement.ProperyExist('type') then
            type := JsonManagement.SelectJsonValue('type').AsText();

        if code = '200' then begin

            if CouriersArray.Count > 0 then begin

                TrackingmoreCarrier.Reset();
                TrackingmoreCarrier.DeleteAll();

                foreach Token in CouriersArray do begin

                    CurrentCourier := Token.AsObject();
                    JsonManagement.SetJsonObject(CurrentCourier);

                    name := JsonManagement.GetPropertyAsText('name');
                    code := JsonManagement.GetPropertyAsText('code');
                    phone := JsonManagement.GetPropertyAsText('phone');
                    homepage := JsonManagement.GetPropertyAsText('homepage');
                    carriertype := JsonManagement.GetPropertyAsText('type');
                    picture := JsonManagement.GetPropertyAsText('picture');
                    trackurl := JsonManagement.GetPropertyAsText('track_url');
                    countrycode := JsonManagement.GetPropertyAsText('country_code');

                    TrackingmoreCarrier.Init();
                    TrackingmoreCarrier.code := CopyStr(code, 1, 50);
                    TrackingmoreCarrier.name := CopyStr(name, 1, 100);
                    TrackingmoreCarrier.Phone := CopyStr(phone, 1, 50);
                    TrackingmoreCarrier."homepage" := CopyStr(homepage, 1, 250);
                    TrackingmoreCarrier."type" := CopyStr(carriertype, 1, 50);
                    TrackingmoreCarrier."Picture URL" := CopyStr(picture, 1, 250);
                    TrackingmoreCarrier."Track URL" := CopyStr(trackurl, 1, 250);
                    TrackingmoreCarrier."Country Code" := CopyStr(countrycode, 1, 10);
                    if TrackingmoreCarrier.insert() then;
                end;
            end;
        end else
            LastError := 'API Error ' + code + '  ' + message + '   ' + type;
        Errortext := LastError;
    end;


    procedure GetUserInfo(var email: Text; var Phone: Text; var Money: Text) errorcode: Integer
    var
        TrackingSetup: Record "TMAC Tracking Setup";
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        QueryString: Text;
        ResponseTxt: text;

    begin
        ClearAPIMessages();

        if not TrackingSetup.get() then begin
            errorcode := 1;
            LastError := ThereIsNoAfterShipSettingsErr;
            exit;
        end;

        if (TrackingSetup."Trackingmore API Key" = '') then begin
            errorcode := 1;
            LastError := ThereIsNoAfterShipSettingsErr;
            exit;
        end;

        QueryString := TrackingSetup."Trackingmore Ger User Info URL";

        HttpRequestMessage.Method := 'GET';
        HttpRequestMessage.GetHeaders(Headers);
        Headers.Add('User-Agent', 'Microsoft Dynamics 365 Business Central');
        // Headers.Add('Content-Type', 'application/json');
        Headers.Add('Trackingmore-Api-Key', TrackingSetup."Trackingmore API Key");

        HttpRequestMessage.SetRequestUri(QueryString);
        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            if HttpResponseMessage.HttpStatusCode = 200 then begin
                HttpResponseMessage.Content.ReadAs(ResponseTxt);
                if ParseUserInfo(ResponseTxt, email, Phone, Money) = '' then
                    errorcode := 0
                else
                    errorcode := 1;
            end else
                errorcode := 2;
        end else
            errorcode := 3;
    end;

    procedure ParseUserInfo(ResponseText: Text; var email: Text; var Phone: Text; var Money: Text) Errortext: Text
    var
        JsonManagement: Codeunit "TMAC JSON Management";
        Response: JsonObject;
        metajso: JsonObject;
        datajso: JsonObject;
        code: Text;
        message: Text;
        type: Text;
    begin
        Response.ReadFrom(ResponseText);
        JsonManagement.SetJsonObject(Response);
        if JsonManagement.ProperyExist('meta') then
            metajso := JsonManagement.GetJsonObject('meta');

        if JsonManagement.ProperyExist('data') then
            datajso := JsonManagement.GetJsonObject('data');

        JsonManagement.SetJsonObject(metajso);
        code := JsonManagement.SelectJsonValue('code').AsText();
        LastApiCode := code;

        if JsonManagement.ProperyExist('message') then
            message := JsonManagement.SelectJsonValue('message').AsText();
        LastApiMessage := message;

        if JsonManagement.ProperyExist('type') then
            type := JsonManagement.SelectJsonValue('type').AsText();

        if code = '200' then begin
            JsonManagement.SetJsonObject(datajso);
            email := JsonManagement.GetPropertyAsText('email');
            phone := JsonManagement.GetPropertyAsText('phone');
            money := JsonManagement.GetPropertyAsText('money');
        end else
            LastError := 'API Error ' + code + '  ' + message + '   ' + type;

        Errortext := LastError;
    end;

    /// <summary>
    /// CreateTracking - create tracking on Trackingmore.com site
    /// </summary>
    /// <param name="TrackingNumber"></param>
    /// <param name="CarrierCode"></param>
    /// <param name="FreightOrderNo"></param>
    /// <returns></returns>
    procedure CreateTracking(TrackingNumber: Text; CarrierCode: Text) errorcode: Integer
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
        //TrackingNumberBody: JsonObject;
        BodyText: Text;
    begin
        ClearAPIMessages();

        if not TrackingSetup.get() then begin
            errorcode := 1;
            LastError := ThereIsNoAfterShipSettingsErr;
            exit;
        end;

        if (TrackingSetup."Trackingmore API Key" = '') or
           (TrackingSetup."Trackingmore Create Tracking" = '')
        then begin
            errorcode := 1;
            LastError := ThereIsNoAfterShipSettingsErr;
            exit;
        end;

        QueryString := TrackingSetup."Trackingmore Create Tracking";

        HttpRequestMessage.Method := 'POST';
        HttpRequestMessage.GetHeaders(Headers);
        Headers.Add('User-Agent', 'Microsoft Dynamics 365 Business Central');
        Headers.Add('Trackingmore-Api-Key', TrackingSetup."Trackingmore API Key");

        //Body
        //TrackingNumberBody.Add('tracking_number', TypeHelper.UrlEncode(TrackingNumber));

        Body.Add('tracking_number', TypeHelper.UrlEncode(TrackingNumber));
        Body.Add('carrier_code', CarrierCode);
        Body.WriteTo(BodyText);
        HttpContent.WriteFrom(BodyText);
        HttpRequestMessage.Content(HttpContent);

        HttpRequestMessage.SetRequestUri(QueryString);
        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            if HttpResponseMessage.HttpStatusCode = 200 then begin
                HttpResponseMessage.Content.ReadAs(ResponseTxt);
                if ParseCreateTrackingResponse(ResponseTxt, TrackingNumber, CarrierCode) = '' then
                    errorcode := 0
                else
                    errorcode := 1;
            end else
                errorcode := HttpResponseMessage.HttpStatusCode;
        end else
            errorcode := 3;
    end;

    procedure ParseCreateTrackingResponse(ResponseText: Text; TrackingNumber: Text; CarrierCode: text) Errortext: Text
    var
        TrackingmoreTracking: record "TMAC Trackingmore Tracking";
        JsonManagement: Codeunit "TMAC JSON Management";
        Response: JsonObject;
        metajso: JsonObject;
        datajso: JsonObject;
        code: Text;
        message: Text;
        type: Text;

    begin
        Response.ReadFrom(ResponseText);
        JsonManagement.SetJsonObject(Response);
        if JsonManagement.ProperyExist('meta') then
            metajso := JsonManagement.GetJsonObject('meta');

        if JsonManagement.ProperyExist('data') then
            datajso := JsonManagement.GetJsonObject('data');

        JsonManagement.SetJsonObject(metajso);
        code := JsonManagement.SelectJsonValue('code').AsText();
        LastApiCode := code;

        if JsonManagement.ProperyExist('message') then
            message := JsonManagement.SelectJsonValue('message').AsText();
        LastApiMessage := message;

        if JsonManagement.ProperyExist('type') then
            type := JsonManagement.SelectJsonValue('type').AsText();

        if (code = '200') or (code = '201') then begin
            JsonManagement.SetJsonObject(datajso);

            TrackingmoreTracking.Reset();
            TrackingmoreTracking.SetCurrentKey("Tracking Number", "Carrier Code");
            TrackingmoreTracking.Setrange("Tracking Number", TrackingNumber);
            TrackingmoreTracking.SetRange("Carrier Code", CarrierCode);
            TrackingmoreTracking.DeleteAll(true);

            TrackingmoreTracking.Init();
            TrackingmoreTracking.ID := CopyStr(JsonManagement.GetPropertyAsText('id'), 1, 100);
            TrackingmoreTracking."Tracking Number" := CopyStr(JsonManagement.GetPropertyAsText('tracking_number'), 1, 250);
            TrackingmoreTracking."Carrier Code" := CopyStr(JsonManagement.GetPropertyAsText('carrier_code'), 1, 100);
            //TrackingmoreTracking."Order Create Time" := ;
            TrackingmoreTracking.Status := ParseStatus(JsonManagement.GetPropertyAsText('status'));
            TrackingmoreTracking."Created At" := JsonManagement.GetPropertyAsDateTime('created_at');
            TrackingmoreTracking."Customer Email" := CopyStr(JsonManagement.GetPropertyAsText('customer_email'), 1, 100);
            TrackingmoreTracking."Customer Name" := CopyStr(JsonManagement.GetPropertyAsText('customer_name'), 1, 100);
            TrackingmoreTracking."Order ID" := CopyStr(JsonManagement.GetPropertyAsText('order_id'), 1, 100);
            TrackingmoreTracking."Comment" := CopyStr(JsonManagement.GetPropertyAsText('comment'), 1, 100);
            TrackingmoreTracking.Title := CopyStr(JsonManagement.GetPropertyAsText('title'), 1, 200);
            TrackingmoreTracking."Logistics Channel" := CopyStr(JsonManagement.GetPropertyAsText('logistics_channel'), 1, 200);
            TrackingmoreTracking.Destination := CopyStr(JsonManagement.GetPropertyAsText('destination'), 1, 200);

            TrackingmoreTracking."Status Description" := CopyStr(StatusToText(TrackingmoreTracking.Status), 1, 100);
            TrackingmoreTracking."Substatus Description" := CopyStr(SubStatusToText(TrackingmoreTracking."Sub Status"), 1, 100);

            TrackingmoreTracking.Insert();
        end else
            LastError := 'API Error ' + code + '  ' + message + '   ' + type;
        Errortext := LastError;
    end;

    local procedure ParseStatus(Status: Text): enum "TMAC Trackingmore Status"
    begin
        // pending	New package added that are pending to track
        // notfound	Package tracking information is no available yet
        // transit	Courier has picked up package from shipper, the package is on the way to destination
        // pickup	Also known as "Out For Delivery", courier is about to deliver the package, or the package is wating for addressee to pick up
        // delivered	The package was delivered successfully
        // expired	No tracking information for 30days for express service, or no tracking information for 60 days for postal service since the package added
        // undelivered	Also known as "Failed Attempt", courier attempted to deliver but failded, usually left a notice and will try to delivery again
        // exception	Package missed, addressee returned package to sender or other exceptions
        case Status of
            'pending':
                exit("TMAC Trackingmore Status"::pending);
            'notfound':
                exit("TMAC Trackingmore Status"::notfound);
            'transit':
                exit("TMAC Trackingmore Status"::transit);
            'pickup':
                exit("TMAC Trackingmore Status"::pickup);
            'delivered':
                exit("TMAC Trackingmore Status"::delivered);
            'expired':
                exit("TMAC Trackingmore Status"::expired);
            'undelivered':
                exit("TMAC Trackingmore Status"::undelivered);
            'exception':
                exit("TMAC Trackingmore Status"::exception);
        end;
        exit("TMAC Trackingmore Status"::None);
    end;

    local procedure ParseSubStatus(Status: Text): enum "TMAC Trackingmore SubStatus"
    begin
        // notfound001	The package is waiting for courier to pick up
        // notfound002	No tracking information found

        // transit001	Package is on the way to destination
        // transit002	Package arrived at a hub or sorting center
        // transit003	Package arrived at delivery facility
        // transit004	Package arrived at destination country
        // transit005	Customs clearance completed

        // delivered001	Package delivered successfully
        // delivered002	Package picked up by the addressee
        // delivered003	Package received and signed by addressee
        // delivered004	Package was left at the front door or left with your neighbour

        // exception004	The package is unclaimed
        // exception005	Other exceptions
        // exception006	Package was detained by customs
        // exception007	Package was lost or damaged during delivery
        // exception008	Logistics order was cancelled before courier pick up the package
        // exception009	Package was refused by addressee
        // exception0010	Package has been returned to sender
        // exception0011	Package is beening sent to sender
        case Status of
            'notfound001':
                exit("TMAC Trackingmore SubStatus"::notfound001);
            'notfound002':
                exit("TMAC Trackingmore SubStatus"::notfound002);

            'transit001':
                exit("TMAC Trackingmore SubStatus"::transit001);
            'transit002':
                exit("TMAC Trackingmore SubStatus"::transit002);
            'transit003':
                exit("TMAC Trackingmore SubStatus"::transit003);
            'transit004':
                exit("TMAC Trackingmore SubStatus"::transit004);
            'transit005':
                exit("TMAC Trackingmore SubStatus"::transit005);

            'delivered001':
                exit("TMAC Trackingmore SubStatus"::delivered001);
            'delivered002':
                exit("TMAC Trackingmore SubStatus"::delivered002);
            'delivered003':
                exit("TMAC Trackingmore SubStatus"::delivered003);
            'delivered004':
                exit("TMAC Trackingmore SubStatus"::delivered004);

            'exception004':
                exit("TMAC Trackingmore SubStatus"::exception004);
            'exception005':
                exit("TMAC Trackingmore SubStatus"::exception005);
            'exception006':
                exit("TMAC Trackingmore SubStatus"::exception006);
            'exception007':
                exit("TMAC Trackingmore SubStatus"::exception007);
            'exception008':
                exit("TMAC Trackingmore SubStatus"::exception008);
            'exception009':
                exit("TMAC Trackingmore SubStatus"::exception009);
            'exception0010':
                exit("TMAC Trackingmore SubStatus"::exception0010);
            'exception0011':
                exit("TMAC Trackingmore SubStatus"::exception0011);
        end;
        exit("TMAC Trackingmore SubStatus"::None);
    end;

    local procedure StatusToText(Status: enum "TMAC Trackingmore Status"): Text
    begin
        case Status of
            "TMAC Trackingmore Status"::pending:
                exit('New package added that are pending to track');
            "TMAC Trackingmore Status"::notfound:
                exit('Package tracking information is no available yet');
            "TMAC Trackingmore Status"::transit:
                exit('Courier has picked up package from shipper, the package is on the way to destination');
            "TMAC Trackingmore Status"::pickup:
                exit('Also known as "Out For Delivery", courier is about to deliver the package, or the package is wating for addressee to pick up');
            "TMAC Trackingmore Status"::delivered:
                exit('The package was delivered successfully');
            "TMAC Trackingmore Status"::expired:
                exit('No tracking information for 30days for express service, or no tracking information for 60 days for postal service since the package added');
            "TMAC Trackingmore Status"::undelivered:
                exit('Also known as "Failed Attempt", courier attempted to deliver but failded, usually left a notice and will try to delivery again');
            "TMAC Trackingmore Status"::exception:
                exit('Package missed, addressee returned package to sender or other exceptions');
        end;
    end;

    procedure SubStatusToText(SubStatus: Enum "TMAC Trackingmore Substatus"): Text
    begin
        case SubStatus of
            "TMAC Trackingmore SubStatus"::notfound001:
                exit('The package is waiting for courier to pick up');
            "TMAC Trackingmore SubStatus"::notfound002:
                exit('No tracking information found');

            "TMAC Trackingmore SubStatus"::transit001:
                exit('Package is on the way to destination');
            "TMAC Trackingmore SubStatus"::transit002:
                exit('Package arrived at a hub or sorting center');
            "TMAC Trackingmore SubStatus"::transit003:
                exit('Package arrived at delivery facility');
            "TMAC Trackingmore SubStatus"::transit004:
                exit('Package arrived at destination country');
            "TMAC Trackingmore SubStatus"::transit005:
                exit('Customs clearance completed');

            "TMAC Trackingmore SubStatus"::delivered001:
                exit('Package delivered successfully');
            "TMAC Trackingmore SubStatus"::delivered002:
                exit('Package picked up by the addressee');
            "TMAC Trackingmore SubStatus"::delivered003:
                exit('Package received and signed by addressee');
            "TMAC Trackingmore SubStatus"::delivered004:
                exit('Package was left at the front door or left with your neighbour');

            "TMAC Trackingmore SubStatus"::exception004:
                exit('The package is unclaimed');
            "TMAC Trackingmore SubStatus"::exception005:
                exit('Other exceptions');
            "TMAC Trackingmore SubStatus"::exception006:
                exit('Package was detained by customs');
            "TMAC Trackingmore SubStatus"::exception007:
                exit('Package was lost or damaged during delivery');
            "TMAC Trackingmore SubStatus"::exception008:
                exit('Logistics order was cancelled before courier pick up the package');
            "TMAC Trackingmore SubStatus"::exception009:
                exit('Package was refused by addressee');
            "TMAC Trackingmore SubStatus"::exception0010:
                exit('Package has been returned to sender');
            "TMAC Trackingmore SubStatus"::exception0011:
                exit('Package is beening sent to sender');
        end;
    end;

    procedure GetResult(TrackingNumber: Text; CarrierCode: Text) errorcode: Integer
    var
        TrackingSetup: Record "TMAC Tracking Setup";
        TypeHelper: Codeunit "Type Helper";
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        QueryString: Text;
        ResponseTxt: text;
    begin
        ClearAPIMessages();

        if not TrackingSetup.get() then begin
            errorcode := 1;
            LastError := ThereIsNoAfterShipSettingsErr;
            exit;
        end;

        if (TrackingSetup."Trackingmore API Key" = '') or
           (TrackingSetup."Trackingmore Delete Tracking" = '')
        then begin
            errorcode := 1;
            LastError := ThereIsNoAfterShipSettingsErr;
            exit;
        end;

        QueryString := TrackingSetup."Trackingmore Delete Tracking" + '/' + CarrierCode + '/' + TypeHelper.UrlEncode(TrackingNumber);

        HttpRequestMessage.Method := 'GET';
        HttpRequestMessage.GetHeaders(Headers);
        Headers.Add('User-Agent', 'Microsoft Dynamics 365 Business Central');
        Headers.Add('Trackingmore-Api-Key', TrackingSetup."Trackingmore API Key");

        HttpRequestMessage.SetRequestUri(QueryString);
        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            if HttpResponseMessage.HttpStatusCode = 200 then begin
                HttpResponseMessage.Content.ReadAs(ResponseTxt);
                if ParseGetResultResponse(ResponseTxt, TrackingNumber, CarrierCode) = '' then
                    errorcode := 0
                else
                    errorcode := 1;
            end else
                errorcode := HttpResponseMessage.HttpStatusCode;
        end else
            errorcode := 3;
    end;

    procedure ParseGetResultResponse(ResponseText: Text; TrackingNumber: Text; CarrierCode: text) Errortext: Text
    var
        TrackingmoreTracking: record "TMAC Trackingmore Tracking";
        TrackingmoreCheckpoint: record "TMAC Trackingmore Checkpoint";

        JsonManagement: Codeunit "TMAC JSON Management";
        Response: JsonObject;
        metajso: JsonObject;
        datajso: JsonObject;
        originjso: JsonObject;
        destjso: JsonObject;
        TrackArray: JsonArray;
        Token: JsonToken;
        CurrentTrack: JsonObject;
        code: Text;
        message: Text;
        type: Text;
        EntryNo: Integer;
    begin
        Response.ReadFrom(ResponseText);
        JsonManagement.SetJsonObject(Response);
        if JsonManagement.ProperyExist('meta') then
            metajso := JsonManagement.GetJsonObject('meta');

        if JsonManagement.ProperyExist('data') then
            datajso := JsonManagement.GetJsonObject('data');

        JsonManagement.SetJsonObject(metajso);
        code := JsonManagement.SelectJsonValue('code').AsText();
        LastApiCode := Code;

        if JsonManagement.ProperyExist('message') then
            message := JsonManagement.SelectJsonValue('message').AsText();
        LastApiMessage := message;

        if JsonManagement.ProperyExist('type') then
            type := JsonManagement.SelectJsonValue('type').AsText();

        if (code = '200') or (code = '201') then begin
            JsonManagement.SetJsonObject(datajso);

            TrackingmoreTracking.Reset();
            TrackingmoreTracking.SetCurrentKey("Tracking Number", "Carrier Code");
            TrackingmoreTracking.Setrange("Tracking Number", TrackingNumber);
            TrackingmoreTracking.SetRange("Carrier Code", CarrierCode);
            TrackingmoreTracking.DeleteAll(true);

            TrackingmoreTracking.Init();
            TrackingmoreTracking.ID := CopyStr(JsonManagement.GetPropertyAsText('id'), 1, 100);
            TrackingmoreTracking."Tracking Number" := CopyStr(JsonManagement.GetPropertyAsText('tracking_number'), 1, 250);
            TrackingmoreTracking."Carrier Code" := CopyStr(JsonManagement.GetPropertyAsText('carrier_code'), 1, 100);
            TrackingmoreTracking.Status := ParseStatus(JsonManagement.GetPropertyAsText('status'));
            TrackingmoreTracking."Sub Status" := ParseSubStatus(JsonManagement.GetPropertyAsText('substatus'));

            TrackingmoreTracking."Created At" := JsonManagement.GetPropertyAsDateTime('created_at');
            TrackingmoreTracking."Updated At" := JsonManagement.GetPropertyAsDateTime('updated_at');

            TrackingmoreTracking."Original Country" := CopyStr(JsonManagement.GetPropertyAsText('original_country'), 1, 15);
            TrackingmoreTracking."Destination Country" := CopyStr(JsonManagement.GetPropertyAsText('destination_country'), 1, 15);
            TrackingmoreTracking."Last Event" := CopyStr(JsonManagement.GetPropertyAsText('lastEvent'), 1, 200);
            TrackingmoreTracking."Status Info" := CopyStr(JsonManagement.GetPropertyAsText('status_info'), 1, 200);
            TrackingmoreTracking.Weight := CopyStr(JsonManagement.GetPropertyAsText('weight'), 1, 20);
            TrackingmoreTracking."Package Status" := CopyStr(JsonManagement.GetPropertyAsText('packageStatus'), 1, 50);

            TrackingmoreTracking."Customer Email" := CopyStr(JsonManagement.GetPropertyAsText('customer_email'), 1, 100);
            TrackingmoreTracking."Customer Name" := CopyStr(JsonManagement.GetPropertyAsText('customer_name'), 1, 100);
            TrackingmoreTracking."Order ID" := CopyStr(JsonManagement.GetPropertyAsText('order_id'), 1, 100);
            TrackingmoreTracking."Comment" := CopyStr(JsonManagement.GetPropertyAsText('comment'), 1, 100);
            TrackingmoreTracking.Title := CopyStr(JsonManagement.GetPropertyAsText('title'), 1, 200);
            TrackingmoreTracking."Logistics Channel" := CopyStr(JsonManagement.GetPropertyAsText('title'), 1, 200);
            TrackingmoreTracking.Destination := CopyStr(JsonManagement.GetPropertyAsText('destination'), 1, 200);

            TrackingmoreTracking."Status Description" := CopyStr(StatusToText(TrackingmoreTracking.Status), 1, 100);
            TrackingmoreTracking."Substatus Description" := CopyStr(SubStatusToText(TrackingmoreTracking."Sub Status"), 1, 100);
            TrackingmoreTracking.Insert();

            if JsonManagement.ProperyExist('origin_info') then begin
                originjso := JsonManagement.GetJsonObject('origin_info');
                JsonManagement.SetJsonObject(originjso);
                if JsonManagement.ProperyExist('trackinfo') then begin
                    TrackArray := JsonManagement.GetJsonArray('trackinfo');
                    if TrackArray.Count > 0 then
                        foreach Token in TrackArray do begin
                            CurrentTrack := Token.AsObject();
                            JsonManagement.SetJsonObject(CurrentTrack);
                            EntryNo += 10000;
                            TrackingmoreCheckpoint.Init();
                            TrackingmoreCheckpoint.ID := TrackingmoreTracking.ID;
                            TrackingmoreCheckpoint."Entry No." := EntryNo;

                            TrackingmoreCheckpoint."Checkpoint Time" := ConvertToDatetime(JsonManagement.GetPropertyAsText('Date'));
                            TrackingmoreCheckpoint."Status Description" := CopyStr(JsonManagement.GetPropertyAsText('StatusDescription'), 1, 100);
                            TrackingmoreCheckpoint.Details := CopyStr(JsonManagement.GetPropertyAsText('Details'), 1, 100);
                            TrackingmoreCheckpoint."Checkpoint Status" := CopyStr(JsonManagement.GetPropertyAsText('checkpoint_status'), 1, 100);
                            TrackingmoreCheckpoint.Substatus := CopyStr(JsonManagement.GetPropertyAsText('substatus'), 1, 100);
                            TrackingmoreCheckpoint.Side := OriginTok;
                            TrackingmoreCheckpoint."Checkpoint Status" := CopyStr(StatusToText(ParseStatus(TrackingmoreCheckpoint."Checkpoint Status")), 1, 100);
                            TrackingmoreCheckpoint.Substatus := CopyStr(SubStatusToText(ParseSubStatus(TrackingmoreCheckpoint."SubStatus")), 1, 100);

                            TrackingmoreCheckpoint.Insert(true);
                        end;
                end;
            end;

            JsonManagement.SetJsonObject(datajso);
            if JsonManagement.ProperyExist('destination_info') then begin
                destjso := JsonManagement.GetJsonObject('destination_info');
                JsonManagement.SetJsonObject(destjso);
                if JsonManagement.ProperyExist('trackinfo') then begin
                    TrackArray := JsonManagement.GetJsonArray('trackinfo');
                    if TrackArray.Count > 0 then
                        foreach Token in TrackArray do begin
                            CurrentTrack := Token.AsObject();
                            JsonManagement.SetJsonObject(CurrentTrack);
                            EntryNo += 10000;
                            TrackingmoreCheckpoint.Init();
                            TrackingmoreCheckpoint.ID := TrackingmoreTracking.ID;
                            TrackingmoreCheckpoint."Entry No." := EntryNo;
                            TrackingmoreCheckpoint."Checkpoint Time" := ConvertToDatetime(JsonManagement.GetPropertyAsText('Date'));
                            TrackingmoreCheckpoint."Status Description" := CopyStr(JsonManagement.GetPropertyAsText('StatusDescription'), 1, 100);
                            TrackingmoreCheckpoint.Details := CopyStr(JsonManagement.GetPropertyAsText('Details'), 1, 100);
                            TrackingmoreCheckpoint."Checkpoint Status" := CopyStr(JsonManagement.GetPropertyAsText('checkpoint_status'), 1, 100);
                            TrackingmoreCheckpoint.Substatus := CopyStr(JsonManagement.GetPropertyAsText('substatus'), 1, 100);
                            TrackingmoreCheckpoint.Side := DestTok;
                            TrackingmoreCheckpoint."Checkpoint Status" := CopyStr(StatusToText(ParseStatus(TrackingmoreCheckpoint."Checkpoint Status")), 1, 100);
                            TrackingmoreCheckpoint.Substatus := CopyStr(SubStatusToText(ParseSubStatus(TrackingmoreCheckpoint."SubStatus")), 1, 100);

                            TrackingmoreCheckpoint.Insert(true);
                        end;
                end;
            end;
        end else
            LastError := 'API Error ' + code + '  ' + message + '   ' + type;
        Errortext := LastError;
    end;



    procedure DeleteTracking(TrackingNumber: Text; CarrierCode: Text) errorcode: Integer
    var
        TrackingSetup: Record "TMAC Tracking Setup";
        TypeHelper: Codeunit "Type Helper";
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        QueryString: Text;
        ResponseTxt: text;
    begin
        ClearAPIMessages();

        if not TrackingSetup.get() then begin
            errorcode := 1;
            LastError := ThereIsNoAfterShipSettingsErr;
            exit;
        end;

        if (TrackingSetup."Trackingmore API Key" = '') or
           (TrackingSetup."Trackingmore Delete Tracking" = '')
        then begin
            errorcode := 1;
            LastError := ThereIsNoAfterShipSettingsErr;
            exit;
        end;

        QueryString := TrackingSetup."Trackingmore Delete Tracking" + '/' + CarrierCode + '/' + TypeHelper.UrlEncode(TrackingNumber);

        HttpRequestMessage.Method := 'DELETE';
        HttpRequestMessage.GetHeaders(Headers);
        Headers.Add('User-Agent', 'Microsoft Dynamics 365 Business Central');
        Headers.Add('Trackingmore-Api-Key', TrackingSetup."Trackingmore API Key");


        HttpRequestMessage.SetRequestUri(QueryString);
        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            if HttpResponseMessage.HttpStatusCode = 200 then begin
                HttpResponseMessage.Content.ReadAs(ResponseTxt);
                if ParseDeleteTrackingResponse(ResponseTxt, TrackingNumber, CarrierCode) = '' then
                    errorcode := 0
                else
                    errorcode := 1;
            end else
                errorcode := HttpResponseMessage.HttpStatusCode;
        end else
            errorcode := 3;
    end;

    procedure ParseDeleteTrackingResponse(ResponseText: Text; TrackingNumber: Text; CarrierCode: text) Errortext: Text
    var
        JsonManagement: Codeunit "TMAC JSON Management";
        Response: JsonObject;
        metajso: JsonObject;
        datajso: JsonObject;
        code: Text;
        message: Text;
        type: Text;
    begin
        Response.ReadFrom(ResponseText);
        JsonManagement.SetJsonObject(Response);
        if JsonManagement.ProperyExist('meta') then
            metajso := JsonManagement.GetJsonObject('meta');

        if JsonManagement.ProperyExist('data') then
            datajso := JsonManagement.GetJsonObject('data');

        JsonManagement.SetJsonObject(metajso);
        code := JsonManagement.SelectJsonValue('code').AsText();
        LastApiCode := code;

        if JsonManagement.ProperyExist('message') then
            message := JsonManagement.SelectJsonValue('message').AsText();
        LastApiMessage := message;

        if JsonManagement.ProperyExist('type') then
            type := JsonManagement.SelectJsonValue('type').AsText();

        if (code = '200') or (code = '201') then
            JsonManagement.SetJsonObject(datajso)
        else
            LastError := 'API Error ' + code + '  ' + message + '   ' + type;
        Errortext := LastError;
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
        DestTok: Label 'DEST';
        OriginTok: Label 'ORIGIN';

        LastError: text;
        LastApiCode: text;
        LastApiMessage: Text;
        ConnectionErr: Label 'Connection error. Check if the web service for TMS is enabled.';
        //CreateNewCarrierQst: Label 'Create new TMS carrier by Trackingmore.com courier %1', Comment = '%1 is Trackimgmore.com carrier';
        ThereIsNoAfterShipSettingsErr: Label 'There is no settings for trackingmore.com service. Run Assisted setup Wizard for setup trackingmore.com integration.';
}