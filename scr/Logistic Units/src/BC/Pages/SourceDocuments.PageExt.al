pageextension 71628610 "TMAC Source Documents" extends "Source Documents"
{
    layout
    {
        addafter("Shipping Advice")
        {
            field("TMAC Source Name"; Rec."TMAC Source Name")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Source Name.';
            }
            field("TMAC Source Address"; Rec."TMAC Source Address")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Source Address.';
            }
            field("TMAC Source Country Code"; Rec."TMAC Source Country Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Country/Region of the delivery address.';
            }
            field("TMAC Source Post Code"; Rec."TMAC Source Post Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the postal code.';
            }
            field("TMAC Source County"; Rec."TMAC Source County")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the county.';
            }
            field("TMAC Source City"; Rec."TMAC Source City")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the unload city.';
            }

            field("TMAC Weight"; Rec."TMAC Weight")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the weight of all order items.';
            }
            field("TMAC Volume"; Rec."TMAC Volume")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the volume of all order items.';
            }
        }

        addafter("Control1")
        {
            group("TMAC Totals")
            {
                Caption = 'Totals';

                field("TMAC TotalWeight"; TotalWeight)
                {
                    Caption = 'Total Weight';
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the total weight of ther selected documents.';
                }
                field("TMAC TotalVolume"; TotalVolume)
                {
                    Caption = 'Total Volume';
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the total volume of the selected documents.';
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        WarehouseRequest: Record "Warehouse Request";
    begin
        TotalWeight := 0;
        TotalVolume := 0;
        CurrPage.SetSelectionFilter(WarehouseRequest);
        WarehouseRequest.MarkedOnly();
        if WarehouseRequest.findset() then
            repeat
                TotalWeight += WarehouseRequest."TMAC Weight";
                TotalVolume += WarehouseRequest."TMAC Volume";
            until WarehouseRequest.next() = 0;
    end;

    var
        TotalWeight: Decimal;
        TotalVolume: Decimal;
}
