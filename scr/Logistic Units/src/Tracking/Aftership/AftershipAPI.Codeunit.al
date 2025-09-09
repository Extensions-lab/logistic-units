codeunit 71628594 "TMAC AfterShip API" implements "TMAC Tracking Provider Impl."
{

    internal procedure Track(TrackingNumber: Text; Carrier: Text): Integer;
    var
        error: Integer;
    begin
        error := GetTracking(TrackingNumber, Carrier);
        case error of
            0:
                exit;
            1:
                error(LastError);
            404:
                begin
                    CreateTracking(TrackingNumber, Carrier);
                    GetTracking(TrackingNumber, Carrier);
                end;
            else
                error(ConnectionErr)
        end;
    end;

    internal procedure CancelTracking(TrackingNumber: Text; CarrierCode: Text);
    begin
        TryDeleteTracking(TrackingNumber, CarrierCode);
    end;


    local procedure TryDeleteTracking(TrackingNumber: Text; CarrierCode: Text)
    begin
        DeleteTracking(TrackingNumber, CarrierCode);
    end;

    internal procedure CreateTracking(TrackingNumber: Text; Slug: Text) errorcode: Integer
    var
        TrackingSetup: Record "TMAC Tracking Setup";
        TypeHelper: Codeunit "Type Helper";
        ClientHttpClient: HttpClient;
        RequestHttpRequestMessage: HttpRequestMessage;
        ResponseHttpResponseMessage: HttpResponseMessage;
        HeadersHttpHeaders: HttpHeaders;
        QueryString: Text;
        ResponseTxt: text;
        BodyContentHttpContent: HttpContent;
        Body: JsonObject;
        TrackingNumberBody: JsonObject;
        BodyText: Text;
    begin
        ClearAPIMessages();

        if not TrackingSetup.get() then begin
            errorcode := 1;
            LastError := ThereIsNoAfterShipSettingsErr;
            exit;
        end;

        if (TrackingSetup."AfterShip API Key" = '') or
           (TrackingSetup."AfterShip GetTracking URL" = '')
        then begin
            errorcode := 1;
            LastError := ThereIsNoAfterShipSettingsErr;
            exit;
        end;

        QueryString := TrackingSetup."AfterShip GetTracking URL";

        RequestHttpRequestMessage.Method := 'POST';
        RequestHttpRequestMessage.GetHeaders(HeadersHttpHeaders);
        HeadersHttpHeaders.Add('User-Agent', 'Microsoft Dynamics 365 Business Central');
        HeadersHttpHeaders.Add('aftership-api-key', TrackingSetup."AfterShip API Key");

        //Body
        TrackingNumberBody.Add('tracking_number', TypeHelper.UrlEncode(TrackingNumber));
        Body.Add('tracking', TrackingNumberBody);
        Body.WriteTo(BodyText);
        BodyContentHttpContent.WriteFrom(BodyText);
        RequestHttpRequestMessage.Content(BodyContentHttpContent);

        RequestHttpRequestMessage.SetRequestUri(QueryString);
        if ClientHttpClient.Send(RequestHttpRequestMessage, ResponseHttpResponseMessage) then begin
            if ResponseHttpResponseMessage.IsBlockedByEnvironment() then
                error(ResponseHttpResponseMessage.ReasonPhrase)
            else
                if ResponseHttpResponseMessage.IsSuccessStatusCode() then begin
                    ResponseHttpResponseMessage.Content.ReadAs(ResponseTxt);
                    if ParseTrackingResponse(ResponseTxt, TrackingNumber, Slug) = '' then
                        errorcode := 0
                    else
                        errorcode := 1;
                end else begin
                    errorcode := ResponseHttpResponseMessage.HttpStatusCode;
                    LastError := ResponseHttpResponseMessage.ReasonPhrase;
                end;
        end else
            error(ConnectionErr);
    end;

    internal procedure DeleteTracking(TrackingNumber: Text; slug: Text) errorcode: Integer
    var
        TrackingSetup: Record "TMAC Tracking Setup";
        TypeHelper: Codeunit "Type Helper";
        ClientHttpClient: HttpClient;
        RequestHttpRequestMessage: HttpRequestMessage;
        ResponseHttpResponseMessage: HttpResponseMessage;
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

        if (TrackingSetup."AfterShip API Key" = '') or
           (TrackingSetup."AfterShip GetTracking URL" = '')
        then begin
            errorcode := 1;
            LastError := ThereIsNoAfterShipSettingsErr;
            exit;
        end;

        QueryString := TrackingSetup."AfterShip GetTracking URL" + '/' + slug + '/' + TypeHelper.UrlEncode(TrackingNumber);

        RequestHttpRequestMessage.Method := 'DELETE';
        RequestHttpRequestMessage.GetHeaders(Headers);
        Headers.Add('User-Agent', 'Microsoft Dynamics 365 Business Central');
        Headers.Add('aftership-api-key', TrackingSetup."AfterShip API Key");

        RequestHttpRequestMessage.SetRequestUri(QueryString);
        if ClientHttpClient.Send(RequestHttpRequestMessage, ResponseHttpResponseMessage) then begin
            if ResponseHttpResponseMessage.IsBlockedByEnvironment() then
                error(ResponseHttpResponseMessage.ReasonPhrase)
            else
                if ResponseHttpResponseMessage.IsSuccessStatusCode() then begin
                    ResponseHttpResponseMessage.Content.ReadAs(ResponseTxt);
                    errorcode := 0;
                end else begin
                    errorcode := ResponseHttpResponseMessage.HttpStatusCode;
                    LastError := ResponseHttpResponseMessage.ReasonPhrase;
                end;
        end else
            error(ConnectionErr);
    end;

    /// <summary>
    /// демо номера
    /// USPS: 9410811108400563443495
    /// FedEx: 785699797285
    ///  DHL Express: 5522874700
    /// </summary>
    /// <returns></returns>
    internal procedure GetAllCouriers() errorcode: Integer
    var
        TrackingSetup: Record "TMAC Tracking Setup";
        ClientHttpClient: HttpClient;
        RequestHttpRequestMessage: HttpRequestMessage;
        ResponseHttpResponseMessage: HttpResponseMessage;
        HeadersHttpHeaders: HttpHeaders;
        QueryString: Text;
        ResponseTxt: text;

    begin
        ClearAPIMessages();

        if not TrackingSetup.get() then begin
            errorcode := 1;
            LastError := ThereIsNoAfterShipSettingsErr;
            exit;
        end;

        if (TrackingSetup."AfterShip API Key" = '') or
           (TrackingSetup."AfterShip All Courier URL" = '')
        then begin
            errorcode := 1;
            LastError := ThereIsNoAfterShipSettingsErr;
            exit;
        end;

        QueryString := TrackingSetup."AfterShip All Courier URL";

        RequestHttpRequestMessage.Method := 'GET';
        RequestHttpRequestMessage.GetHeaders(HeadersHttpHeaders);
        HeadersHttpHeaders.Add('User-Agent', 'Microsoft Dynamics 365 Business Central');
        // Headers.Add('Content-Type', 'application/json');
        HeadersHttpHeaders.Add('aftership-api-key', TrackingSetup."AfterShip API Key");

        RequestHttpRequestMessage.SetRequestUri(QueryString);
        if ClientHttpClient.Send(RequestHttpRequestMessage, ResponseHttpResponseMessage) then begin
            if ResponseHttpResponseMessage.IsBlockedByEnvironment() then
                error(ResponseHttpResponseMessage.ReasonPhrase)
            else
                if ResponseHttpResponseMessage.IsSuccessStatusCode() then begin
                    ResponseHttpResponseMessage.Content.ReadAs(ResponseTxt);
                    if ParseAllCouriers(ResponseTxt) = '' then
                        errorcode := 0
                    else
                        errorcode := 1;
                end else begin
                    errorcode := ResponseHttpResponseMessage.HttpStatusCode;
                    LastError := ResponseHttpResponseMessage.ReasonPhrase;
                end;
        end else
            error(ConnectionErr);
    end;

    internal procedure ParseAllCouriers(ResponseText: Text) Errortext: Text
    var
        AfterShipCouriers: Record "TMAC Aftership Courier";
        JSONManagement: Codeunit "TMAC JSON Management";
        Response: JsonObject;
        metajso: JsonObject;
        datajso: JsonObject;
        CurrentCourier: JsonObject;
        CouriersArray: JsonArray;
        RequiredFieldsArray: JsonArray;
        SupportedLanguagesArray: JsonArray;
        SupportedCountriesArray: JsonArray;
        Token: JsonToken;
        Token2: JsonToken;
        Token3: JsonToken;
        Token4: JsonToken;
        code: Text;
        message: Text;
        type: Text;
        slug: Text;
        name: Text;
        phone: Text;
        other_name: Text;
        web_url: Text;
        required_fields: text;
        default_language: Text;
        support_languages: text;
        countries: text;
    begin
        Response.ReadFrom(ResponseText);
        JSONManagement.SetJsonObject(Response);
        if JSONManagement.ProperyExist('meta') then
            metajso := JSONManagement.GetJsonObject('meta');
        if JSONManagement.ProperyExist('data') then
            datajso := JSONManagement.GetJsonObject('data');

        JSONManagement.SetJsonObject(metajso);
        code := JSONManagement.SelectJsonValue('code').AsText();
        LastApiCode := code;

        if JSONManagement.ProperyExist('message') then
            message := JSONManagement.SelectJsonValue('message').AsText();
        LastApiMessage := message;

        if JSONManagement.ProperyExist('type') then
            type := JSONManagement.SelectJsonValue('type').AsText();

        if code = '200' then begin
            JSONManagement.SetJsonObject(datajso);
            CouriersArray := JSONManagement.GetJsonArray('couriers');
            if CouriersArray.Count > 0 then begin

                AfterShipCouriers.Reset();
                AfterShipCouriers.DeleteAll();

                foreach Token in CouriersArray do begin

                    CurrentCourier := Token.AsObject();
                    JSONManagement.SetJsonObject(CurrentCourier);

                    slug := JSONManagement.GetPropertyAsText('slug');
                    name := JSONManagement.GetPropertyAsText('name');
                    phone := JSONManagement.GetPropertyAsText('phone');
                    other_name := JSONManagement.GetPropertyAsText('other_name');
                    web_url := JSONManagement.GetPropertyAsText('web_url');
                    default_language := JSONManagement.GetPropertyAsText('default_language');

                    required_fields := '';
                    if JSONManagement.ProperyExist('required_fields') then begin
                        RequiredFieldsArray := JSONManagement.GetJsonArray('required_fields');
                        if RequiredFieldsArray.Count > 0 then
                            foreach Token2 in RequiredFieldsArray do
                                if required_fields = '' then
                                    required_fields := Token2.AsValue().AsText()
                                else
                                    required_fields += ',' + Token2.AsValue().AsText();
                    end;

                    JSONManagement.SetJsonObject(CurrentCourier);
                    support_languages := '';
                    if JSONManagement.ProperyExist('support_languages') then begin
                        SupportedLanguagesArray := JSONManagement.GetJsonArray('support_languages');
                        if SupportedLanguagesArray.Count > 0 then
                            foreach Token3 in SupportedLanguagesArray do
                                if support_languages = '' then
                                    support_languages := Token3.AsValue().AsText()
                                else
                                    support_languages += ',' + Token3.AsValue().AsText();
                    end;

                    JSONManagement.SetJsonObject(CurrentCourier);
                    countries := '';
                    if JSONManagement.ProperyExist('service_from_country_iso3') then begin
                        SupportedCountriesArray := JSONManagement.GetJsonArray('service_from_country_iso3');
                        if SupportedCountriesArray.Count > 0 then
                            foreach Token4 in SupportedCountriesArray do
                                if countries = '' then
                                    countries := Token4.AsValue().AsText()
                                else
                                    countries += ',' + Token4.AsValue().AsText();
                    end;

                    AfterShipCouriers.Init();
                    AfterShipCouriers.slug := CopyStr(slug, 1, 100);
                    AfterShipCouriers.name := CopyStr(name, 1, 100);
                    AfterShipCouriers.Phone := CopyStr(phone, 1, 50);
                    AfterShipCouriers."Other Name" := CopyStr(other_name, 1, 250);
                    AfterShipCouriers."Web Url" := CopyStr(web_url, 1, 250);
                    AfterShipCouriers."Default Language" := CopyStr(default_language, 1, 10);
                    AfterShipCouriers."Required Fields" := CopyStr(required_fields, 1, 1000);
                    AfterShipCouriers."Support Languages" := CopyStr(support_languages, 1, 1000);
                    AfterShipCouriers."Service From Countries" := CopyStr(countries, 1, 1000);
                    AfterShipCouriers.insert();
                end;
            end;
        end else
            LastError := 'API Error ' + code + '  ' + message + '   ' + type;

        Errortext := LastError;
    end;

    internal procedure GetActiveCouriers() errorcode: Integer
    var
        TrackingSetup: Record "TMAC Tracking Setup";
        ClientHttpClient: HttpClient;
        RequestHttpRequestMessage: HttpRequestMessage;
        ResponseHttpResponseMessage: HttpResponseMessage;
        HeadersHttpHeaders: HttpHeaders;
        QueryString: Text;
        ResponseTxt: text;

    begin
        ClearAPIMessages();

        if not TrackingSetup.get() then begin
            errorcode := 1;
            LastError := ThereIsNoAfterShipSettingsErr;
            exit;
        end;

        if (TrackingSetup."AfterShip API Key" = '') or
           (TrackingSetup."AfterShip All Courier URL" = '')
        then begin
            errorcode := 1;
            LastError := ThereIsNoAfterShipSettingsErr;
            exit;
        end;

        QueryString := TrackingSetup."Aftership Active Couriers URL";

        RequestHttpRequestMessage.Method := 'GET';
        RequestHttpRequestMessage.GetHeaders(HeadersHttpHeaders);
        HeadersHttpHeaders.Add('User-Agent', 'Microsoft Dynamics 365 Business Central');
        HeadersHttpHeaders.Add('aftership-api-key', TrackingSetup."AfterShip API Key");

        RequestHttpRequestMessage.SetRequestUri(QueryString);
        if ClientHttpClient.Send(RequestHttpRequestMessage, ResponseHttpResponseMessage) then begin
            if ResponseHttpResponseMessage.IsBlockedByEnvironment() then
                error(ResponseHttpResponseMessage.ReasonPhrase)
            else
                if ResponseHttpResponseMessage.IsSuccessStatusCode() then begin
                    ResponseHttpResponseMessage.Content.ReadAs(ResponseTxt);
                    if ParseActiveCouriersResponse(ResponseTxt) = '' then
                        errorcode := 0
                    else
                        errorcode := 1;
                end else begin
                    errorcode := ResponseHttpResponseMessage.HttpStatusCode;
                    LastError := ResponseHttpResponseMessage.ReasonPhrase;
                end;
        end else
            error(ConnectionErr);
    end;


    internal procedure ParseActiveCouriersResponse(ResponseText: Text) Errortext: Text
    var
        AfterShipCouriers: Record "TMAC Aftership Courier";
        JSONManagement: Codeunit "TMAC JSON Management";
        Response: JsonObject;
        metajso: JsonObject;
        datajso: JsonObject;
        CurrentCourier: JsonObject;
        CouriersArray: JsonArray;
        RequiredFieldsArray: JsonArray;
        SupportedLanguagesArray: JsonArray;
        SupportedCountriesArray: JsonArray;
        Token: JsonToken;
        Token2: JsonToken;
        Token3: JsonToken;
        Token4: JsonToken;
        code: Text;
        message: Text;
        type: Text;
        slug: Text;
        name: Text;
        phone: Text;
        other_name: Text;
        web_url: Text;
        required_fields: text;
        default_language: Text;
        support_languages: text;
        countries: text;
    begin

        Response.ReadFrom(ResponseText);
        JSONManagement.SetJsonObject(Response);
        if JSONManagement.ProperyExist('meta') then
            metajso := JSONManagement.GetJsonObject('meta');
        if JSONManagement.ProperyExist('data') then
            datajso := JSONManagement.GetJsonObject('data');

        JSONManagement.SetJsonObject(metajso);
        code := JSONManagement.SelectJsonValue('code').AsText();
        LastApiCode := code;

        if JSONManagement.ProperyExist('message') then
            message := JSONManagement.SelectJsonValue('message').AsText();
        LastApiMessage := message;

        if JSONManagement.ProperyExist('type') then
            type := JSONManagement.SelectJsonValue('type').AsText();

        if code = '200' then begin
            JSONManagement.SetJsonObject(datajso);
            CouriersArray := JSONManagement.GetJsonArray('couriers');
            if CouriersArray.Count > 0 then begin

                AfterShipCouriers.Reset();
                AfterShipCouriers.ModifyAll(Activated, false);

                foreach Token in CouriersArray do begin

                    CurrentCourier := Token.AsObject();
                    JSONManagement.SetJsonObject(CurrentCourier);

                    slug := JSONManagement.GetPropertyAsText('slug');
                    name := JSONManagement.GetPropertyAsText('name');
                    phone := JSONManagement.GetPropertyAsText('phone');
                    other_name := JSONManagement.GetPropertyAsText('other_name');
                    web_url := JSONManagement.GetPropertyAsText('web_url');
                    default_language := JSONManagement.GetPropertyAsText('default_language');

                    required_fields := '';
                    if JSONManagement.ProperyExist('required_fields') then begin
                        RequiredFieldsArray := JSONManagement.GetJsonArray('required_fields');
                        if RequiredFieldsArray.Count > 0 then
                            foreach Token2 in RequiredFieldsArray do
                                if required_fields = '' then
                                    required_fields := Token2.AsValue().AsText()
                                else
                                    required_fields += ',' + Token2.AsValue().AsText();
                    end;

                    JSONManagement.SetJsonObject(CurrentCourier);
                    support_languages := '';
                    if JSONManagement.ProperyExist('support_languages') then begin
                        SupportedLanguagesArray := JSONManagement.GetJsonArray('support_languages');
                        if SupportedLanguagesArray.Count > 0 then
                            foreach Token3 in SupportedLanguagesArray do
                                if support_languages = '' then
                                    support_languages := Token3.AsValue().AsText()
                                else
                                    support_languages += ',' + Token3.AsValue().AsText();
                    end;

                    JSONManagement.SetJsonObject(CurrentCourier);
                    countries := '';
                    if JSONManagement.ProperyExist('service_from_country_iso3') then begin
                        SupportedCountriesArray := JSONManagement.GetJsonArray('service_from_country_iso3');
                        if SupportedCountriesArray.Count > 0 then
                            foreach Token4 in SupportedCountriesArray do
                                if countries = '' then
                                    countries := Token4.AsValue().AsText()
                                else
                                    countries += ',' + Token4.AsValue().AsText();
                    end;

                    AfterShipCouriers.Init();
                    AfterShipCouriers.slug := CopyStr(slug, 1, 100);
                    AfterShipCouriers.name := CopyStr(name, 1, 100);
                    AfterShipCouriers.Phone := CopyStr(phone, 1, 50);
                    AfterShipCouriers."Other Name" := CopyStr(other_name, 1, 250);
                    AfterShipCouriers."Web Url" := CopyStr(web_url, 1, 250);
                    AfterShipCouriers."Default Language" := CopyStr(default_language, 1, 10);
                    AfterShipCouriers."Required Fields" := CopyStr(required_fields, 1, 1000);
                    AfterShipCouriers."Support Languages" := CopyStr(support_languages, 1, 1000);
                    AfterShipCouriers."Service From Countries" := CopyStr(countries, 1, 1000);
                    AfterShipCouriers.Activated := true;
                    if not AfterShipCouriers.insert() then
                        AfterShipCouriers.Modify(true);
                end;
            end;
        end else
            LastError := 'API Error ' + code + '  ' + message + '   ' + type;
        Errortext := LastError;
    end;

    internal procedure CreateShippingAgent(AftershipCourier: Record "TMAC Aftership Courier")
    var
        ShippingAgent: Record "Shipping Agent";
        PageManagement: Codeunit "Page Management";
    begin
        if Confirm(StrSubstNo(CreateNewCarrierQst, ShippingAgent.Name)) then begin
            ShippingAgent.Init();
            ShippingAgent.Code := CopyStr(AftershipCourier.Slug, 1, 10);
            ShippingAgent.Name := CopyStr(AftershipCourier.Name, 1, 50);
            ShippingAgent."Internet Address" := AftershipCourier."Web Url";
            ShippingAgent."TMAC Tracking Provider" := "TMAC Tracking Provider"::AfterShip;
            ShippingAgent."TMAC Tracking Courier Code" := AftershipCourier.Slug;
            ShippingAgent.Insert(true);
            PageManagement.PageRun(ShippingAgent);
        end;
    end;

    internal procedure GetTracking(TrackingNumber: Text; Slug: Text) errorcode: Integer
    var
        TrackingSetup: Record "TMAC Tracking Setup";
        TypeHelper: Codeunit "Type Helper";
        ClientHttpClient: HttpClient;
        RequestHttpRequestMessage: HttpRequestMessage;
        ResponseHttpResponseMessage: HttpResponseMessage;
        HeadersHttpHeaders: HttpHeaders;
        QueryString: Text;
        ResponseTxt: text;
    begin
        ClearAPIMessages();

        if not TrackingSetup.get() then begin
            errorcode := 1;
            LastError := ThereIsNoAfterShipSettingsErr;
            exit;
        end;

        if (TrackingSetup."AfterShip API Key" = '') or
           (TrackingSetup."AfterShip GetTracking URL" = '')
        then begin
            errorcode := 1;
            LastError := ThereIsNoAfterShipSettingsErr;
            exit;
        end;

        QueryString := TrackingSetup."AfterShip GetTracking URL" + '/' + Slug + '/' + TypeHelper.UrlEncode(TrackingNumber);

        RequestHttpRequestMessage.Method := 'GET';
        RequestHttpRequestMessage.GetHeaders(HeadersHttpHeaders);
        HeadersHttpHeaders.Add('User-Agent', 'Microsoft Dynamics 365 Business Central');
        HeadersHttpHeaders.Add('aftership-api-key', TrackingSetup."AfterShip API Key");
        RequestHttpRequestMessage.SetRequestUri(QueryString);

        if ClientHttpClient.Send(RequestHttpRequestMessage, ResponseHttpResponseMessage) then begin
            if ResponseHttpResponseMessage.IsBlockedByEnvironment() then
                error(ResponseHttpResponseMessage.ReasonPhrase)
            else
                if ResponseHttpResponseMessage.IsSuccessStatusCode() then begin
                    ResponseHttpResponseMessage.Content.ReadAs(ResponseTxt);
                    if ParseTrackingResponse(ResponseTxt, TrackingNumber, Slug) = '' then
                        errorcode := 0
                    else
                        errorcode := 1;
                end else begin
                    errorcode := ResponseHttpResponseMessage.HttpStatusCode;
                    LastError := ResponseHttpResponseMessage.ReasonPhrase;
                end;
        end else
            error(ConnectionErr);
    end;

    internal procedure ParseTrackingResponse(ResponseText: Text; TrackingNumber: Text; Slug: text) Errortext: Text
    var
        AftershipCheckpoint: Record "TMAC Aftership Checkpoint";
        AftershipTracking: Record "TMAC Aftership Tracking";
        JSONManagement: Codeunit "TMAC JSON Management";
        Response: JsonObject;
        metajso: JsonObject;
        datajso: JsonObject;
        TrackingObject: JsonObject;
        CheckPoint: JsonObject;
        CheckPointsArray: JsonArray;
        Token: JsonToken;
        code: Text;
        message: Text;
        type: Text;
        EntryNo: Integer;
    begin
        Response.ReadFrom(ResponseText);
        JSONManagement.SetJsonObject(Response);

        if JSONManagement.ProperyExist('meta') then
            metajso := JSONManagement.GetJsonObject('meta');

        if JSONManagement.ProperyExist('data') then
            datajso := JSONManagement.GetJsonObject('data');

        JSONManagement.SetJsonObject(metajso);
        code := JSONManagement.SelectJsonValue('code').AsText();
        LastApiCode := code;

        if JSONManagement.ProperyExist('message') then
            message := JSONManagement.SelectJsonValue('message').AsText();
        LastApiMessage := message;

        if JSONManagement.ProperyExist('type') then
            type := JSONManagement.SelectJsonValue('type').AsText();

        if (code = '200') or (code = '201') then begin
            JSONManagement.SetJsonObject(datajso);
            if JSONManagement.ProperyExist('tracking') then begin
                TrackingObject := JSONManagement.GetJsonObject('tracking');

                AftershipTracking.Reset();
                AftershipTracking.SetCurrentKey("Tracking Number", "Slug");
                AftershipTracking.SetRange("Tracking Number", TrackingNumber);
                AftershipTracking.SetRange("Slug", Slug);
                AftershipTracking.DeleteAll(true);

                AftershipTracking.Init();
                ParseTracking(TrackingObject, AftershipTracking);
                AftershipTracking.Insert();

                JSONManagement.SetJsonObject(TrackingObject);
                CheckPointsArray := JSONManagement.GetJsonArray('checkpoints');
                if CheckPointsArray.Count > 0 then
                    foreach Token in CheckPointsArray do begin
                        EntryNo += 10000;
                        CheckPoint := Token.AsObject();
                        AftershipCheckpoint.Init();
                        AftershipCheckpoint.ID := AftershipTracking.ID;
                        AftershipCheckpoint."Entry No." := EntryNo;
                        ParseCheckPoint(CheckPoint, AftershipCheckpoint);
                        AftershipCheckpoint.Insert(true);
                    end;
                AftershipCheckpoint.Reset();
                AftershipCheckpoint.SetCurrentKey("Checkpoint Time");
                AftershipCheckpoint.SetRange(ID, AftershipTracking.ID);
                if AftershipCheckpoint.FindLast() then begin
                    AftershipTracking."Last Checkpoint Action" := AftershipCheckpoint.Message;
                    AftershipTracking.Modify(true);
                end;
            end;
        end else
            LastError := 'API Error ' + code + '  ' + message + '   ' + type;

        Errortext := LastError;
    end;

    internal procedure ParseTracking(TrackingObject: JsonObject; var AftershipTracking: Record "TMAC Aftership Tracking")
    var
        JSONManagement: Codeunit "TMAC JSON Management";
    begin
        JSONManagement.SetJsonObject(TrackingObject);
        AftershipTracking.ID := CopyStr(JSONManagement.GetPropertyAsText('id'), 1, 100);
        AftershipTracking."Create DateTime" := JSONManagement.GetPropertyAsDateTime('created_at');
        AftershipTracking."Updated DateTime" := JSONManagement.GetPropertyAsDateTime('created_at');
        AftershipTracking."Tracking Number" := CopyStr(JSONManagement.GetPropertyAsText('tracking_number'), 1, 250);
        AftershipTracking.Slug := CopyStr(JSONManagement.GetPropertyAsText('slug'), 1, 100);
        AftershipTracking.Active := JSONManagement.GetPropertyAsBoolean('active');
        AftershipTracking."Customer Name" := CopyStr(JSONManagement.GetPropertyAsText('customer_name'), 1, 250);
        AftershipTracking."Delivery Time (days)" := JSONManagement.GetPropertyAsInteger('delivery_time');
        AftershipTracking."Destination Country" := CopyStr(JSONManagement.GetPropertyAsText('destination_country_iso3'), 1, 3);
        AftershipTracking."Courier Destination Country" := CopyStr(JSONManagement.GetPropertyAsText('courier_destination_country_iso3'), 1, 3);
        AftershipTracking."Expected Delivery" := CopyStr(JSONManagement.GetPropertyAsText('expected_delivery'), 1, 50);
        AftershipTracking."Note" := CopyStr(JSONManagement.GetPropertyAsText('note'), 1, 50);
        AftershipTracking."Order ID" := CopyStr(JSONManagement.GetPropertyAsText('order_id'), 1, 100);
        AftershipTracking."Order Date" := JSONManagement.GetPropertyAsDateTime('order_date');
        AftershipTracking."Origin Country" := CopyStr(JSONManagement.GetPropertyAsText('origin_country_iso3'), 1, 3);
        AftershipTracking."Shipment Package Count" := JSONManagement.GetPropertyAsInteger('shipment_package_count');
        AftershipTracking."Shipment Pickup Date" := JSONManagement.GetPropertyAsDateTime('shipment_pickup_date');
        AftershipTracking."Shipment Delivery Date" := JSONManagement.GetPropertyAsDateTime('shipment_delivery_date');
        AftershipTracking."Shipment Type" := CopyStr(JSONManagement.GetPropertyAsText('shipment_type'), 1, 250);
        AftershipTracking."Shipment Weight" := JSONManagement.GetPropertyAsInteger('shipment_weight');
        AftershipTracking."Signed By" := CopyStr(JSONManagement.GetPropertyAsText('signed_by'), 1, 50);
        AftershipTracking.Source := CopyStr(JSONManagement.GetPropertyAsText('source'), 1, 50);
        AftershipTracking."Tag" := ParseTag(JSONManagement.GetPropertyAsText('tag'));
        AftershipTracking."SubTag" := CopyStr(JSONManagement.GetPropertyAsText('subtag'), 1, 20);
        AftershipTracking."SubTag Message" := CopyStr(JSONManagement.GetPropertyAsText('subtag_message'), 1, 100);
        AftershipTracking."Title" := CopyStr(JSONManagement.GetPropertyAsText('title'), 1, 100);
        AftershipTracking."Tracked Count" := JSONManagement.GetPropertyAsInteger('tracked_count');
        AftershipTracking."Last Mile tracking Support" := JSONManagement.GetPropertyAsBoolean('last_mile_tracking_supported');
        AftershipTracking."Language" := CopyStr(JSONManagement.GetPropertyAsText('language'), 1, 20);
        AftershipTracking."Delivery Type" := CopyStr(JSONManagement.GetPropertyAsText('delivery_type'), 1, 20);
        AftershipTracking."Courier Tracking Link" := CopyStr(JSONManagement.GetPropertyAsText('courier_tracking_link'), 1, 400);
    end;

    internal procedure ParseCheckPoint(CheckPoint: JsonObject; var AftershipCheckpoint: Record "TMAC Aftership Checkpoint")
    var
        JSONManagement: Codeunit "TMAC JSON Management";
    begin
        JSONManagement.SetJsonObject(CheckPoint);
        AftershipCheckpoint."Created At" := JSONManagement.GetPropertyAsDateTime('created_at');
        AftershipCheckpoint.Slug := CopyStr(JSONManagement.GetPropertyAsText('slug'), 1, 100);
        AftershipCheckpoint."Checkpoint Time" := JSONManagement.GetPropertyAsDateTime('checkpoint_time');
        AftershipCheckpoint.location := CopyStr(JSONManagement.GetPropertyAsText('location'), 1, 100);
        AftershipCheckpoint.City := CopyStr(JSONManagement.GetPropertyAsText('city'), 1, 50);
        AftershipCheckpoint.State := CopyStr(JSONManagement.GetPropertyAsText('state'), 1, 30);
        AftershipCheckpoint.Zip := CopyStr(JSONManagement.GetPropertyAsText('zip'), 1, 30);
        AftershipCheckpoint."Country" := CopyStr(JSONManagement.GetPropertyAsText('country_iso3'), 1, 3);
        AftershipCheckpoint."Country Name" := CopyStr(JSONManagement.GetPropertyAsText('country_name'), 1, 100);
        AftershipCheckpoint."Message" := CopyStr(JSONManagement.GetPropertyAsText('message'), 1, 100);
        AftershipCheckpoint."Tag" := ParseTag(JSONManagement.GetPropertyAsText('tag'));
        AftershipCheckpoint."SubTag" := CopyStr(JSONManagement.GetPropertyAsText('subtag'), 1, 20);
        AftershipCheckpoint."SubTag Message" := CopyStr(JSONManagement.GetPropertyAsText('subtag_message'), 1, 100);
        AftershipCheckpoint.raw_tag := CopyStr(JSONManagement.GetPropertyAsText('raw_tag'), 1, 100);
    end;

    internal procedure ParseTag(tag: Text): enum "TMAC AfterShip TAG"
    begin
        case tag of
            'InfoReceived':
                exit("TMAC AfterShip TAG"::InfoReceived);
            'InTransit':
                exit("TMAC AfterShip TAG"::InTransit);
            'OutForDelivery':
                exit("TMAC AfterShip TAG"::OutForDelivery);
            'AttemptFail':
                exit("TMAC AfterShip TAG"::AttemptFail);
            'Delivered':
                exit("TMAC AfterShip TAG"::Delivered);
            'AvailableForPickup':
                exit("TMAC AfterShip TAG"::AvailableForPickup);
            'Exception':
                exit("TMAC AfterShip TAG"::Exception);
            'Expired':
                exit("TMAC AfterShip TAG"::Expired);
            'Pending':
                exit("TMAC AfterShip TAG"::Pending);
        end;
        exit("TMAC AfterShip TAG"::None);
    end;



    internal procedure ClearAPIMessages()
    begin
        LastError := '';
        LastApiCode := '';
        LastApiMessage := '';
    end;

    internal procedure GetLastError(): Text;
    begin
        exit(LastError);
    end;

    internal procedure GetApiCode(): Text;
    begin
        exit(LastApiCode);
    end;

    internal procedure GetApiMessage(): Text;
    begin
        exit(LastApiMessage);
    end;

    var
        LastError: text;
        LastApiCode: text;
        LastApiMessage: Text;
        CreateNewCarrierQst: Label 'Create new carrier by Aftership.com courier %1', Comment = '%1 is afteship.com courier';
        ThereIsNoAfterShipSettingsErr: Label 'There is no settings for Aftership.com service. Run Assisted setup Wizard for setup Aftership.com integraion.';
        ConnectionErr: Label 'There is an error calling the API. Check the permissions for Logistic Units Management Ssystem extension on "Extension Settings" page. "Allow HttpClient Requests" must be enabled.';
}