enum 71628584 "TMAC Tracking Provider" implements "TMAC Tracking Provider Impl."
{
    Extensible = true;

    value(0; "None")
    {
        Caption = ' ';
        Implementation = "TMAC Tracking Provider Impl." = "TMAC Null API";
    }
    value(1; "AfterShip")
    {
        Caption = 'Aftership';
        Implementation = "TMAC Tracking Provider Impl." = "TMAC AfterShip API";
    }
    value(2; Trackingmore)
    {
        Caption = 'Trackingmore.com';
        Implementation = "TMAC Tracking Provider Impl." = "TMAC Trackingmore API";
    }
    value(3; TrackingmoreAirCargo)
    {
        Caption = 'Trackingmore.com AirCargo';
        Implementation = "TMAC Tracking Provider Impl." = "TMAC Trackingmore Air API";
    }
}