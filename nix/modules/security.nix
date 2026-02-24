{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.ushinnary.security;
in
{
  config = mkIf cfg.howdy.enable {
    services.howdy = {
      enable = true;
      package = pkgs.howdy;
      settings = {
        core = {
          device_path = "/dev/video0";
          ignore_closed_eyes = true;
        };
        video = {
          dark_threshold = 90;
        };
      };
    };

    # GNOME PAM integration for Howdy
    security.pam.howdy.enable = true;
  };
}
