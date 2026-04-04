{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.ushinnary.desktop;
in
{
  config = mkIf cfg.plasma {
    # Enable Plasma
    services.desktopManager.plasma6.enable = true;
    services.displayManager.plasma-login-manager = {
      enable = true;
    };

    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      plasma-browser-integration
      kwin-x11
    ];
  };
}
