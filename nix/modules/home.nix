{
  pkgs,
  osConfig,
  lib,
  ...
}:
let
  cfg = osConfig.ushinnary.dev;
  isGnome = osConfig.ushinnary.desktop.gnome;
in
{
  home.stateVersion = "25.11";

  home.packages =
    if isGnome then
      with pkgs;
      [
        gnomeExtensions.appindicator
        gnomeExtensions.night-theme-switcher
        gnomeExtensions.dash-to-dock
        gnomeExtensions.blur-my-shell
      ]
    else
      [ ];

  dconf.settings = lib.mkIf isGnome {
    "org/gnome/mutter" = {
      experimental-features = [
        "scale-monitor-framebuffer"
        "variable-refresh-rate"
        "xwayland-native-scaling"
      ];
    };
    "org/gnome/shell" = {
      disable-user-extensions = false;
    };
  };
}
