{
  pkgs,
  osConfig,
  lib,
  config,
  ...
}:
let
  isGnome = osConfig.ushinnary.desktop.gnome;
  inherit (lib.hm.gvariant) mkEmptyArray mkTuple type;
in
{
  home.stateVersion = "25.11";
  gtk.gtk4.theme = config.gtk.theme;

  xdg.userDirs.createDirectories = true;

  programs.bash = {
    enable = true;
    shellAliases = {
      nfc = "nix flake check";
      nfu = "nix flake update";
      "??" = "gh copilot suggest";
    };
    bashrcExtra = ''
      nrfs() {
        if [ "$#" -ne 1 ]; then
          echo "Usage: nrfs <flake>"
          return 1
        fi

        sudo nixos-rebuild switch --flake "$1"
      }
    '';
  };

  home.packages = lib.optionals isGnome (
    with pkgs;
    [
      gnomeExtensions.appindicator
      gnomeExtensions.night-theme-switcher
      gnomeExtensions.dash-to-dock
      gnomeExtensions.blur-my-shell
      gnomeExtensions.brightness-control-using-ddcutil
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
        "display-brightness-ddcutil@themightydeity.github.com"
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
    "org/gnome/shell/extensions/blur-my-shell" = {
      settings-version = 2;
    };
    "org/gnome/shell/extensions/blur-my-shell/appfolder" = {
      brightness = 0.6;
      sigma = 30;
    };
    "org/gnome/shell/extensions/blur-my-shell/applications" = {
      blur = true;
      dynamic-opacity = false;
      opacity = 234;
      whitelist = [
        "com.mitchellh.ghostty"
        "dev.zed.Zed"
      ];
    };
    "org/gnome/shell/extensions/blur-my-shell/coverflow-alt-tab" = {
      pipeline = "pipeline_default";
    };
    "org/gnome/shell/extensions/blur-my-shell/dash-to-dock" = {
      blur = true;
      brightness = 0.6;
      pipeline = "pipeline_default";
      sigma = 30;
      static-blur = true;
      style-dash-to-dock = 0;
    };
    "org/gnome/shell/extensions/blur-my-shell/lockscreen" = {
      pipeline = "pipeline_default";
    };
    "org/gnome/shell/extensions/blur-my-shell/overview" = {
      pipeline = "pipeline_default";
    };
    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      brightness = 0.6;
      pipeline = "pipeline_default";
      sigma = 30;
    };
    "org/gnome/shell/extensions/blur-my-shell/screenshot" = {
      pipeline = "pipeline_default";
    };
    "org/gnome/shell/extensions/blur-my-shell/window-list" = {
      brightness = 0.6;
      sigma = 30;
    };
    "org/gnome/shell/extensions/display-brightness-ddcutil" = {
      button-location = 1;
      ddcutil-sleep-multiplier = 40.0;
      decrease-brightness-shortcut = [ "<Control>XF86MonBrightnessDown" ];
      increase-brightness-shortcut = [ "<Control>XF86MonBrightnessUp" ];
      position-system-menu = 3.0;
      step-change-keyboard = 2.0;
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
