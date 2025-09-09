page 71628583 "TMAC SSCC List"
{
    Caption = 'SSCC - Serial Shipping Container Codes';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "TMAC SSCC";
    Editable = false;
    CardPageId = "TMAC SSCC Card";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Code; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Width = 10;
                }
                field("Global Company Prefix"; Rec."Global Company Prefix")
                {
                    ApplicationArea = All;
                }
                field("Serial Reference"; Rec."Serial Reference")
                {
                    ApplicationArea = All;
                }
                field("From"; Rec."From")
                {
                    ApplicationArea = All;
                    Width = 10;
                }
                field("To"; Rec."To")
                {
                    ApplicationArea = All;
                    Width = 10;
                }
                field("Carrier Name"; Rec."Carrier Name")
                {
                    ApplicationArea = All;
                    Width = 10;
                }
                field("Bill of Landing Number"; Rec."Bill of Landing Number")
                {
                    ApplicationArea = All;
                    Width = 10;
                }
            }
        }
    }
}