/// <summary>
/// Track Provider Interface
/// </summary>
interface "TMAC Tracking Provider Impl."
{
    procedure Track(TrackingNumber: Text; Carrier: Text): Integer;

    procedure CancelTracking(TrackingNumber: Text; Carrier: Text);
}