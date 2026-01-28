{ pkgs, ... }:
{
  location.provider = "geoclue2";

  services.geoclue2.enable = true;

  # Enable automatic timezone based on location
  # services.localtimed.enable = true;
}
