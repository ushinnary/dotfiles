{ pkgs, ... }:
{
  location.provider = "geoclue2";

  services.geoclue2 = {
    enable = true;
    # Mozilla Location Service is deprecated; use BeaconDB as a drop-in replacement
    geoProviderUrl = "https://beacondb.net/v1/geolocate";
  };

  # Enable automatic timezone based on location
  # services.localtimed.enable = true;
}
