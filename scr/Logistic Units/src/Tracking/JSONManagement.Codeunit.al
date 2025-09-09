codeunit 71628592 "TMAC JSON Management"
{
    internal procedure ProperyExist(Property: Text): Boolean
    var
        JToken: JsonToken;
    begin
        if JObject.Get(Property, JToken) then
            exit(true);
    end;

    internal procedure GetJsonValue(Property: Text): JsonValue
    var
        JToken: JsonToken;
        returnvalue: JsonValue;
    begin
        returnvalue.SetValueToNull();

        if not JObject.Get(Property, JToken) then
            exit(returnvalue);

        if not JToken.IsValue() then
            exit(returnvalue);

        returnvalue := JToken.AsValue();
        exit(returnvalue);
    end;

    internal procedure GetJsonObject(Property: Text): JsonObject
    var
        JToken: JsonToken;
        returnvalue: JsonObject;
    begin
        clear(returnvalue);

        if not JObject.Get(Property, JToken) then
            exit(returnvalue);

        if not JToken.IsObject() then
            exit(returnvalue);
        returnvalue := JToken.AsObject();
        exit(returnvalue);
    end;

    internal procedure GetJsonArray(Property: Text): JsonArray
    var
        JToken: JsonToken;
        returnvalue: JsonArray;
    begin
        if not JObject.Get(Property, JToken) then
            exit(returnvalue);

        if not JToken.IsArray() then
            exit(returnvalue);

        returnvalue := JToken.AsArray();
        exit(returnvalue);
    end;

    internal procedure SelectJsonValue(Path: Text): JsonValue
    var
        JToken: JsonToken;
        returnvalue: JsonValue;
    begin
        returnvalue.SetValueToNull();
        if not JObject.SelectToken(Path, JToken) then
            exit(returnvalue);

        if not JToken.IsValue() then
            exit(returnvalue);

        returnvalue := JToken.AsValue();
        exit(returnvalue);
    end;

    internal procedure IsNullValue(Property: Text) Result: Boolean
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        if not JObject.Get(Property, JToken) then
            exit;

        JValue := JToken.AsValue();
        Result := JValue.IsNull() or JValue.IsUndefined();
    end;

    internal procedure ReadFromText(Data: Text)
    begin
        Clear(JObject);
        JObject.ReadFrom(Data);
    end;

    internal procedure SetJsonObject(var Value: JsonObject)
    begin
        JObject := Value;
    end;


    internal procedure GetPropertyAsText(path: Text): Text
    var
        value: JsonValue;
    begin
        if ProperyExist(path) then begin
            value := SelectJsonValue(path);
            if (not value.IsNull) and (not value.IsUndefined) then
                exit(value.AsText());
        end;
        exit('');
    end;

    internal procedure GetPropertyAsDateTime(path: Text): DateTime
    var
        value: JsonValue;
    begin
        if ProperyExist(path) then begin
            value := SelectJsonValue(path);
            if (not value.IsNull) and (not value.IsUndefined) then
                exit(value.AsDateTime());
        end;
    end;

    internal procedure GetPropertyAsBoolean(path: Text): Boolean
    var
        value: JsonValue;
    begin
        if ProperyExist(path) then begin
            value := SelectJsonValue(path);
            if (not value.IsNull) and (not value.IsUndefined) then
                exit(value.AsBoolean());
        end;
        exit(false);
    end;

    internal procedure GetPropertyAsInteger(path: Text): Integer
    var
        value: JsonValue;
    begin
        if ProperyExist(path) then begin
            value := SelectJsonValue(path);
            if (not value.IsNull) and (not value.IsUndefined) then
                exit(value.AsInteger());
        end;
        exit(0);
    end;

    internal procedure SaveDebugDataToFile(data: JsonObject)
    var
        TempBlob: Codeunit "Temp Blob";
        OutStreamData: OutStream;
        ExportInStream: InStream;
        txt, ToFile : text;
    begin
        ToFile := 'dataset' + FORMAT(RANDOM(10000)) + '.txt';
        data.WriteTo(txt);
        TempBlob.CreateOutStream(OutStreamData);
        OutStreamData.WriteText(txt);

        TempBlob.CreateInStream(ExportInStream);
        IF not DownloadFromStream(ExportInStream, 'Export Data', '', '', ToFile) then
            Message('Unable to export');
    end;

    var
        JObject: JsonObject;
}