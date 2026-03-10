{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.ushinnary.desktop;
  quickshellPkg = inputs.quickshell.packages.${pkgs.system}.default;
  quickshellRelativeRoot = "quickshell/.config/quickshell";
  quickshellFiles = [
    "shell.qml"
    "Bar.qml"
    "Dock.qml"
    "Theme.qml"
    "Time.qml"
    "ClockWidget.qml"
    "VolumeWidget.qml"
    "BatteryWidget.qml"
    "Brightness.qml"
    "BrightnessWidget.qml"
    "OsdWindow.qml"
    "SysTray.qml"
    "SysTrayItem.qml"
    "SysTrayMenuEntry.qml"
    "AppContextMenu.qml"
    "ContextMenuEntry.qml"
    "ActiveAppWidget.qml"
    "MediaPlayerWidget.qml"
    "OsdManager.qml"
    "PrivacyIndicatorWidget.qml"
  ];
in
{
  config = mkIf cfg.niri {
    # ── Bar-ecosystem packages ─────────────────────────────────────
    environment.systemPackages = [
      quickshellPkg # QML-based shell / status bar
      pkgs.swaynotificationcenter # Notification daemon + center panel
      pkgs.gtk3 # gtk-launch for menu / launcher widgets
      pkgs.adwaita-icon-theme # GTK fallback icons still used by some apps
      pkgs.hicolor-icon-theme # Freedesktop fallback icon theme for app icons
    ];

    home-manager.users.ushinnary =
      { pkgs, config, ... }:
      let
        mkDotfileSymlink =
          relativePath:
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/${relativePath}";
      in
      {
        # Keep popups on a dark GTK theme and use a broad icon theme
        # so category/app icons resolve more reliably.
        gtk = {
          enable = true;
          iconTheme = {
            name = "Adwaita"; # Set Adwaita as the default icon theme to ensure all icons are available, including fallbacks
            package = pkgs.adwaita-icon-theme;
          };
          gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
          gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
        };

        dconf.settings."org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "Adwaita";
          icon-theme = "Adwaita";
        };

        # ── Home-manager: map quickshell QML config into place ─────────
        # Files are linked out-of-store to ~/dotfiles, so edits are picked up
        # immediately (stow-like) without rebuilding.
        xdg.configFile = builtins.listToAttrs (
          map (file: {
            name = "quickshell/${file}";
            value = {
              source = mkDotfileSymlink "${quickshellRelativeRoot}/${file}";
            };
          }) quickshellFiles
        );
      };
  };
}
