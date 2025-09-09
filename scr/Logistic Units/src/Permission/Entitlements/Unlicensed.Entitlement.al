/// <summary>
/// назначается всем у кого нет лицензии по умолчаиню
/// </summary>
entitlement "TMAC Unlicensed"
{
    Type = Unlicensed;
#if License
    ObjectEntitlements = "TMAC License";
#else
    ObjectEntitlements = "TMAC Unlicensed";
#endif
}