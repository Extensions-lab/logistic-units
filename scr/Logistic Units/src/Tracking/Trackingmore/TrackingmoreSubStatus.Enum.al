enum 71628588 "TMAC Trackingmore Substatus"
{
    Extensible = true;

    value(0; None)
    {
        Caption = '';
    }

    /// <summary>
    /// Information Received/info received. The package is about to be picked up.
    /// </summary>
    value(1; notfound001)
    {
        Caption = 'not found001';
    }

    /// <summary>
    /// There is no tracking information for this package.
    /// </summary>
    value(2; notfound002)
    {
        Caption = 'not found002';
    }

    /// <summary>
    /// shipment on the way
    /// </summary>
    value(10; transit001)
    {
        Caption = 'transit001';
    }

    /// <summary>
    /// Arrival scan Shipment arrived at a hub or sorting center
    /// </summary>
    value(11; transit002)
    {
        Caption = 'transit002';
    }

    /// <summary>
    /// Arrived at delivery facility
    /// </summary>
    value(12; transit003)
    {
        Caption = 'transit003';
    }

    /// <summary>
    /// Arrived at the destination country
    /// </summary>
    value(13; transit004)
    {
        Caption = 'transit004';
    }

    /// <summary>
    /// Customs clearance completed
    /// </summary>
    value(14; transit005)
    {
        Caption = 'transit005';
    }

    //Delivered SubStatus	Description

    /// <summary>
    /// Shipment delivered successfully
    /// </summary>
    value(20; delivered001)
    {
        Caption = 'delivered001';
    }

    /// <summary>
    /// Package picked up by customer
    /// </summary>
    value(21; delivered002)
    {
        Caption = 'delivered002';
    }

    /// <summary>
    /// Package delivered to and signed by the customer
    /// </summary>
    value(22; delivered003)
    {
        Caption = 'delivered003';
    }

    /// <summary>
    /// Package has been left at the front door or left with your neighbour
    /// </summary>
    value(23; delivered004)
    {
        Caption = 'delivered004';
    }

    //Exception SubStatus	Description

    /// <summary>
    /// The package is unclaimed.
    /// </summary>
    value(30; exception004)
    {
        Caption = 'exception004';
    }

    /// <summary>
    /// Delivery exception
    /// </summary>
    value(31; exception005)
    {
        Caption = 'exception005';
    }

    /// <summary>
    /// The package is retained by customs because it's prohibited goods.
    /// </summary>
    value(32; exception006)
    {
        Caption = 'exception006';
    }

    /// <summary>
    /// The package is damaged, lost or discarded.
    /// </summary>
    value(33; exception007)
    {
        Caption = 'exception007';
    }

    /// <summary>
    /// The package is canceled before delivering.
    /// </summary>
    value(34; exception008)
    {
        Caption = 'exception008';
    }

    /// <summary>
    /// The package is refused by the addressee
    /// </summary>
    value(35; exception009)
    {
        Caption = 'exception009';
    }

    /// <summary>
    /// The package returned to the sender
    /// </summary>
    value(36; exception0010)
    {
        Caption = 'exception0010';
    }

    /// <summary>
    /// Returning to sender
    /// </summary>
    value(37; exception0011)
    {
        Caption = 'exception0011';
    }
}