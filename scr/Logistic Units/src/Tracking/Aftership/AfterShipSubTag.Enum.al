enum 71628586 "TMAC Aftership Subtag"
{
    Extensible = true;

    value(0; None)
    {
        Caption = '';
    }

    /// <summary>
    /// Shipment delivered successfully
    /// </summary>
    value(1; Delivered_001)
    {
        Caption = 'Delivered';
    }

    /// <summary>
    /// Package picked up by the customer
    /// </summary>
    value(2; Delivered_002)
    {
        Caption = 'Picked up by the customer';
    }

    /// <summary>
    /// Package delivered to and signed by the customer
    /// </summary>
    value(3; Delivered_003)
    {
        Caption = 'Sign by customer';
    }

    /// <summary>
    /// Package delivered to the customer and cash collected on delivery
    /// </summary>
    value(4; Delivered_004)
    {
        Caption = 'Delivered and received cash on delivery';
    }

    /// <summary>
    /// The package arrived at a pickup point near you and is available for pickup
    /// </summary>
    value(5; AvailableForPickup_001)
    {
        Caption = 'Available for pickup';
    }

    /// <summary>
    /// Delivery of the package failed due to some shipping exception
    /// </summary>
    value(6; Exception_001)
    {
        Caption = 'Exception';
    }

    /// <summary>
    /// Delivery of the package failed as the customer relocated 
    /// </summary>
    value(7; Exception_002)
    {
        Caption = 'Customer moved';
    }

    /// <summary>
    /// Delivery of the package failed as the recipient refused to take the package due to some reason 
    /// </summary>
    value(8; Exception_003)
    {
        Caption = 'Customer refused delivery';
    }

    /// <summary>
    /// Package delayed due to some issues during the customs clearance 
    /// </summary>
    value(9; Exception_004)
    {
        Caption = 'Delayed (Customs clearance)';
    }

    /// <summary>
    /// Package delayed due to some unforeseen reasons 
    /// </summary>
    value(10; Exception_005)
    {
        Caption = 'Delayed (External factors)';
    }

    /// <summary>
    /// The package being held due to pending payment from the customer's end
    /// </summary>
    value(11; Exception_006)
    {
        Caption = 'Held for payment';
    }

    /// <summary>
    /// Package not delivered due to incorrect recipient address 
    /// </summary>
    value(12; Exception_007)
    {
        Caption = 'Incorrect Address';
    }

    /// <summary>
    /// Package available for the pickup but not collected by the customer
    /// </summary>
    value(13; Exception_008)
    {
        Caption = 'Pick up missed';
    }

    /// <summary>
    /// Package rejected by the carrier due to noncompliance with its guidelines
    /// </summary>
    value(14; Exception_009)
    {
        Caption = 'Rejected by carrier';
    }

    /// <summary>
    /// The package returned to the original sender
    /// </summary>
    value(15; Exception_010)
    {
        Caption = 'Returning to sender';
    }

    /// <summary>
    /// The package returned to the sender
    /// </summary>
    value(16; Exception_011)
    {
        Caption = 'Returning to sender';
    }

    /// <summary>
    /// Shipment damaged
    /// </summary>
    value(17; Exception_012)
    {
        Caption = 'Shipment damaged';
    }

    /// <summary>
    /// Delivery of the package failed as it got lost
    /// </summary>
    value(18; Exception_013)
    {
        Caption = 'Shipment lost';
    }

    /// <summary>
    /// The delivery of the package failed due to some reason. Courier usually leaves a notice and will try to deliver again
    /// </summary>
    value(19; AttemptFail_001)
    {
        Caption = 'Failed Attempt';
    }

    /// <summary>
    /// Recipient not available at the given address
    /// </summary>
    value(20; AttemptFail_002)
    {
        Caption = 'Addressee not available';
    }

    /// <summary>
    /// Business is closed at the time of delivery
    /// </summary>
    value(21; AttemptFail_003)
    {
        Caption = 'Business Closed';
    }

    /// <summary>
    /// Shipment on the way
    /// </summary>
    value(22; InTransit_001)
    {
        Caption = 'In Transit';
    }

    /// <summary>
    /// Shipment accepted by the carrier
    /// </summary>
    value(23; InTransit_002)
    {
        Caption = 'Acceptance scan';
    }

    /// <summary>
    /// Shipment arrived at a hub or sorting center
    /// </summary>
    value(24; InTransit_003)
    {
        Caption = 'Arrival scan';
    }

    /// <summary>
    /// International shipment arrived at the destination country
    /// </summary>
    value(25; InTransit_004)
    {
        Caption = 'Arrived at the destination country';
    }

    /// <summary>
    /// Customs clearance completed
    /// </summary>
    value(26; InTransit_005)
    {
        Caption = 'Customs clearance completed';
    }

    /// <summary>
    /// Package handed over to customs for clearance 
    /// </summary>
    value(27; InTransit_006)
    {
        Caption = 'Customs clearance started';
    }

    /// <summary>
    /// Package departed from the facility
    /// </summary>
    value(28; InTransit_007)
    {
        Caption = 'Departure Scan';
    }


    /// <summary>
    /// Problem resolved and shipment in transit
    /// </summary>
    value(29; InTransit_008)
    {
        Caption = 'Problem resolved';
    }

    /// <summary>
    /// Shipment forwarded to a different delivery address
    /// </summary>
    value(30; InTransit_009)
    {
        Caption = 'Forwarded to a different delivery address';
    }

    /// <summary>
    /// The carrier received a request from the shipper and is about to pick up the shipment
    /// </summary>
    value(31; InfoReceived_001)
    {
        Caption = 'Info Received';
    }

    /// <summary>
    /// The package is out for delivery
    /// </summary>
    value(32; OutForDelivery_001)
    {
        Caption = 'Out for Delivery';
    }

    /// <summary>
    /// The customer is contacted before the final delivery
    /// </summary>
    value(33; OutForDelivery_003)
    {
        Caption = 'Customer contacted';
    }

    /// <summary>
    /// A delivery appointment is scheduled
    /// </summary>
    value(34; OutForDelivery_004)
    {
        Caption = 'Delivery appointment scheduled';
    }

    /// <summary>
    /// No information available on the carrier website or the tracking number is yet to be tracked
    /// </summary>
    value(35; Pending_001)
    {
        Caption = 'Pending';
    }

    /// <summary>
    /// No tracking information of the shipment, from last 30 days
    /// </summary>
    value(36; Expired_001)
    {
        Caption = 'Expired';
    }
}