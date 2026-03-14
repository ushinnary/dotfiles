{
  pkgs,
  osConfig,
  lib,
  ...
}:
let
  isGnome = osConfig.ushinnary.desktop.gnome;
  inherit (lib.hm.gvariant) mkEmptyArray mkTuple type;
in
{
  home.stateVersion = "25.11";

  home.packages = lib.optionals isGnome (
    with pkgs;
    [
      gnomeExtensions.appindicator
      gnomeExtensions.night-theme-switcher
      gnomeExtensions.dash-to-dock
      gnomeExtensions.blur-my-shell
    ]
  );

  dconf.settings = lib.mkIf isGnome {
    "org/gnome/mutter" = {
      experimental-features = [
        "scale-monitor-framebuffer"
        "variable-refresh-rate"
        "xwayland-native-scaling"
      ];
    };
    "org/gnome/desktop/peripherals/mouse" = {
      natural-scroll = true;
      acceleration-profile = "flat";
    };
    "org/gnome/desktop/wm/keybindings" = {
      close = [
        "<Alt>F4"
        "<Super>q"
      ];
      switch-to-workspace-left = [ "<Super>h" ];
      switch-to-workspace-right = [ "<Super>l" ];
      move-to-workspace-left = [ "<Super><Shift>h" ];
      move-to-workspace-right = [ "<Super><Shift>l" ];
      minimize = mkEmptyArray type.string;
      maximize = [ "<Super>f" ];
      show-desktop = [ "<Super>d" ];
    };
    "org/gnome/desktop/input-sources" = {
      per-window = true;
      sources = [
        (mkTuple [
          "xkb"
          "us"
        ])
        (mkTuple [
          "xkb"
          "ru"
        ])
      ];
      mru-sources = [
        (mkTuple [
          "xkb"
          "us"
        ])
      ];
    };
    "org/gnome/shell/app-switcher" = {
      current-workspace-only = true;
    };
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "dash-to-dock@micxgx.gmail.com"
        "gsconnect@andyholmes.github.io"
        "nightthemeswitcher@romainvigier.fr"
        "blur-my-shell@aunetx"
      ];
    };
    "org/gnome/shell/extensions/dash-to-dock" = {
      always-center-icons = true;
      apply-custom-theme = true;
      background-color = "rgb(0,0,0)";
      background-opacity = 1.0;
      custom-background-color = true;
      custom-theme-shrink = false;
      dash-max-icon-size = 32;
      dock-fixed = true;
      dock-position = "LEFT";
      extend-height = true;
      height-fraction = 0.9;
      hot-keys = false;
      multi-monitor = true;
      preferred-monitor = -2;
      preferred-monitor-by-connector = "DP-1";
      preview-size-scale = 0.0;
      show-apps-always-in-the-edge = false;
      show-apps-at-top = true;
      transparency-mode = "FIXED";
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
      screensaver = mkEmptyArray type.string;
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Terminal ";
      binding = "<Super>t";
      command = "ghostty";
    };
    "org/freedesktop/tracker/miner/files" = {
      index-single-directories = mkEmptyArray type.string;
      index-recursive-directories = mkEmptyArray type.string;
    };
  };
}
