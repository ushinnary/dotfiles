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

    # Font settings
    "org/gnome/desktop/interface" = {
      font-name = "Quicksand 11";
      document-font-name = "Quicksand 11";
      monospace-font-name = "Google Sans Code 10";
    };
  };
}
