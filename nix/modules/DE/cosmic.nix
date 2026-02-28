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
  config = mkIf cfg.cosmic {
    # Enable the COSMIC login manager
    services.displayManager.cosmic-greeter.enable = true;

    # Enable the COSMIC desktop environment
    services.desktopManager.cosmic.enable = true;

    services.system76-scheduler.enable = true;

    programs.firefox.preferences = {
      # disable libadwaita theming for Firefox
      "widget.gtk.libadwaita-colors.enabled" = false;
    };
  };
}
