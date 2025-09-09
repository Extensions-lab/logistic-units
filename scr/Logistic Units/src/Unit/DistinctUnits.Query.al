/// <summary>
/// Used to quickly retrieve a list of Logistic Units by source.  
/// Naturally works based on links.
/// </summary>
query 71628575 "TMAC Distinct Units"
{
    Caption = 'Distinct Unit';
    QueryType = Normal;
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(UnitLineLink; "TMAC Unit Line Link")
        {
            filter(SourceType; "Source Type")
            {
            }
            filter(SourceSubtype; "Source Subtype")
            {
            }
            filter(SourceID; "Source ID")
            {
            }
            filter(SourceBatchName; "Source Batch Name")
            {
            }
            filter(SourceProdOrderLine; "Source Prod. Order Line")
            {
            }
            filter(SourceRefNo; "Source Ref. No.")
            {
            }
            column(UnitNo; "Unit No.")
            {
            }
            column(LinkQuantity)
            {
                Method = Count;
            }
        }
    }
}
