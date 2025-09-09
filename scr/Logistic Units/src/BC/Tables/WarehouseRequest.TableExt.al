/// <summary>
/// Доп поля для создания отгрузки по клиенту или городу
/// </summary>
tableextension 71628578 "TMAC Warehouse Request" extends "Warehouse Request"
{
    fields
    {
        field(71628575; "TMAC Source Name"; Text[200])
        {
            Caption = 'Source Name';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the name associated with the sending or receiving entity, such as a customer or vendor.';
        }
        field(71628576; "TMAC Source Address"; Text[200])
        {
            Caption = 'Source Address';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the street address of the sending or receiving party, used for logistical planning.';
        }
        field(71628577; "TMAC Source Country Code"; Code[10])
        {
            Caption = 'Source Country Code';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the country code for the sending or receiving party’s location, ensuring accurate shipping processes.';
        }
        field(71628578; "TMAC Source City"; Code[30])
        {
            Caption = 'Source City';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the city of the sending or receiving party’s location, facilitating route and delivery planning.';
        }
        field(71628579; "TMAC Source County"; Text[30])
        {
            CaptionClass = '5,1,' + "TMAC Source Country Code";
            Caption = 'County';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the county or region for the sending or receiving party’s location, useful in some shipping contexts.';
        }
        field(71628580; "TMAC Source Post Code"; Code[20])
        {
            Caption = 'Source Post Code';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the postal code for the sending or receiving location, needed for precise shipping calculations.';
        }
        field(71628581; "TMAC Weight"; Decimal)
        {
            Caption = 'Weight';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the total weight of items relevant to this warehouse request, aiding cost and capacity calculations.';
        }
        field(71628582; "TMAC Volume"; Decimal)
        {
            Caption = 'Volume/Cubage';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the total volume or cubage of items for this warehouse request, aiding space and freight cost planning.';
        }
    }
}
