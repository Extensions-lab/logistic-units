enum 71628585 "TMAC AfterShip TAG"
{
    Extensible = true;

    value(0; None)
    {
        Caption = '';
    }

    /// <summary>
    /// InfoReceived	Carrier has received request from shipper and is about to pick up the shipment.
    /// </summary>
    value(1; InfoReceived)
    {
        Caption = 'Information Received';
    }

    /// <summary>
    /// Carrier has accepted or picked up shipment from shipper. The shipment is on the way.
    /// </summary>
    value(2; InTransit)
    {
        Caption = 'In Transit';
    }

    /// <summary>
    /// OutForDelivery	Carrier is about to deliver the shipment , or it is ready to pickup.
    /// </summary>
    value(3; OutForDelivery)
    {
        Caption = 'Out for Delivery';
    }

    /// <summary>
    /// 
    /// </summary>
    value(4; AttemptFail)
    {
        Caption = 'Failed Attempt';
    }

    /// <summary>
    /// The shipment was delivered successfully
    /// </summary>
    value(5; Delivered)
    {
        Caption = 'Delivered';
    }

    /// <summary>
    /// The package arrived at a pickup point near you and is available for pickup.
    /// </summary>
    value(6; AvailableForPickup)
    {
        Caption = 'Available for Pickup';
    }

    /// <summary>
    /// Custom hold, undelivered, returned shipment to sender or any shipping exceptions.
    /// </summary>
    value(7; Exception)
    {
        Caption = 'Exception';
    }

    /// <summary>
    /// Shipment has no tracking information for 30 days since added.
    /// </summary>
    value(8; Expired)
    {
        Caption = 'Expired';
    }

    /// <summary>
    /// New shipments added that are pending to track, or new shipments without tracking information available yet.
    /// </summary>
    value(9; Pending)
    {
        Caption = 'Pending';
    }
}