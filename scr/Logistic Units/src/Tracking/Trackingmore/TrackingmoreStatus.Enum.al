enum 71628587 "TMAC Trackingmore Status"
{
    Extensible = true;

    value(0; None)
    {
        Caption = '';
    }

    /// <summary>
    /// "Pending" means new packages added that are pending to track.
    /// </summary>
    value(1; pending)
    {
        Caption = 'Pending';
    }

    /// <summary>
    /// "Not Found" means there is no package tracking info available yet.
    /// </summary>
    value(2; notfound)
    {
        Caption = 'Not Found';
    }

    /// <summary>
    /// "Transit" means package has tracking info and is on way to recipients' address.
    /// </summary>
    value(3; transit)
    {
        Caption = 'Transit';
    }

    /// <summary>
    /// Also known as "Out For Delivery". It means package is about to be delivered or is ready to be picked up at local sort facility.
    /// </summary>
    value(4; pickup)
    {
        Caption = 'Pickip';
    }

    /// <summary>
    /// "Delivered" means package has been delivered successfully.
    /// </summary>
    value(5; delivered)
    {
        Caption = 'Delivered';
    }

    /// <summary>
    /// Also known as "Failed Attempt". It means unsuccessful package delivery attempt or failed delivery.
    /// </summary>
    value(6; undelivered)
    {
        Caption = 'Undelivered';
    }

    /// <summary>
    /// "Exception" means package returned to sender, receiver refused delivery, package damaged or other exceptions. 
    /// </summary>
    value(7; exception)
    {
        Caption = 'Exception';
    }

    /// <summary>
    /// "Expired" means package carried by Express Company has not been delivered in 30 days or Postal Services in 60 days.
    /// </summary>
    value(8; expired)
    {
        Caption = 'Expired';
    }
}