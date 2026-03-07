{
  pkgs,
  config,
  lib,
  inputs,
  dotfiles,
  ...
}:
with lib;
let
  cfg = config.ushinnary.desktop;
  quickshellPkg = inputs.quickshell.packages.${pkgs.system}.default;
  quickshellConfigDir = "${dotfiles}/quickshell/.config/quickshell";
  quickshellFiles = [
    "shell.qml"
    "Bar.qml"
    "Theme.qml"
    "Time.qml"
    "ClockWidget.qml"
    "Workspaces.qml"
    "VolumeWidget.qml"
    "BatteryWidget.qml"
    "BrightnessWidget.qml"
    "SysTray.qml"
    "SysTrayItem.qml"
    "SysTrayMenu.qml"
    "SysTrayMenuEntry.qml"
  ];
in
{
  config = mkIf cfg.niri {
    # ── Bar-ecosystem packages ─────────────────────────────────────
    environment.systemPackages = [
      quickshellPkg             # QML-based shell / status bar
      pkgs.swaynotificationcenter  # Notification daemon + center panel
      pkgs.swayosd              # On-screen display for volume/brightness
      pkgs.gtk3                 # gtk-launch for menu / launcher widgets
      pkgs.papirus-icon-theme   # Broader icon coverage for menu/launcher/category icons
      pkgs.adwaita-icon-theme   # GTK fallback icons still used by some apps
      pkgs.hicolor-icon-theme   # Freedesktop fallback icon theme for app icons
    ];

    home-manager.users.ushinnary =
      { pkgs, ... }:
      {
        # Keep popups on a dark GTK theme and use a broad icon theme
        # so category/app icons resolve more reliably.
        gtk = {
          enable = true;
          iconTheme = {
            name = "Papirus-Dark";
            package = pkgs.papirus-icon-theme;
          };
          gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
          gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
        };

        dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

        # ── Home-manager: map quickshell QML config into place ─────────
        # Files come from the `dotfiles` flake input (path:..) so editing
        # the source QML files and rebuilding is all that's needed.
        xdg.configFile = builtins.listToAttrs (
          map (file: {
            name = "quickshell/${file}";
            value = { source = "${quickshellConfigDir}/${file}"; };
          }) quickshellFiles
        );
      };
  };
}
