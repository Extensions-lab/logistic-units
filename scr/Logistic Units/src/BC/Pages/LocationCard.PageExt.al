pageextension 71628609 "TMAC Location Card" extends "Location Card"
{
    layout
    {
        addbefore(Warehouse)
        {
            group("TMAC Logistic Units")
            {
                Caption = 'Logistic Units';
                group("TMAC Inbound Logistics")
                {
                    Caption = 'Inbound Logistics';
                    field("TMAC Require LU for Rcpt"; Rec."TMAC Require LU for Rcpt")
                    {
                        ApplicationArea = all;
                        ToolTip = 'Specifies if the location requires to define a logistic unit for receipt documents (Purchase and Warehouse Receipt) when receiving items.';
                    }
                    field("TMAC LU Location Code"; Rec."TMAC LU Location Code")
                    {
                        ApplicationArea = all;
                        ToolTip = 'Specifies the Logistic Units Location Code to be assigned to all logistics units posted at this location (warehouse).';
                    }
                }
                group("TMAC Outbound Logistics")
                {
                    Caption = 'Outbound Logistics';
                    field("TMAC Require LU for Spmt"; Rec."TMAC Require LU for Spmt")
                    {
                        ApplicationArea = all;
                        ToolTip = 'Specifies if the location requires to define a logistic unit for shipment documents (Sale and Warehouse Shipment) when shipping items';
                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                    field("TMAC Post Negative Quantity"; Rec."TMAC Disable Negative Quantity")
                    {
                        ApplicationArea = all;
                        ToolTip = 'Disable post shipment documents without a link to the source of quantity, you must apply the logistic unit line and source positive logistic unit.';
                        Editable = Rec."TMAC Require LU for Spmt";
                    }
                }
            }
        }
    }
}
