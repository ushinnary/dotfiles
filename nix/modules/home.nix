{
  pkgs,
  osConfig,
  lib,
  ...
}:
let
  cfg = osConfig.ushinnary.software;
  isGnome = osConfig.ushinnary.desktopEnvironment.gnome;
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


  programs.mangohud = {
    enable = true;
    enableSessionWide = true;
    settings = {
      fps_limit = "120,60,30,0";
      toggle_hud = "Shift_L+F2";
      position = "top-left";
      font_size = 18;
      background_alpha = 0.3;
    };
  };

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
      font-name = "Inter 11";
      document-font-name = "Inter 11";
      monospace-font-name = "JetBrainsMono Nerd Font 10";
    };
  };
}
