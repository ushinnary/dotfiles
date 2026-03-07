{
  pkgs,
  config,
  lib,
  dotfiles,
  ...
}:
with lib;
let
  cfg = config.ushinnary.desktop;
  ironbarConfigDir = "${dotfiles}/ironbar/.config/ironbar";
  ironbarFiles = [
    "config.json"
    "style.css"
  ];
in
{
  config = mkIf cfg.niri {
    # ── Bar-ecosystem packages ─────────────────────────────────────
    environment.systemPackages = with pkgs; [
      ironbar                   # Status bar
      swaynotificationcenter    # Notification daemon + center panel
      swayosd                   # On-screen display for volume/brightness
      gtk3                      # gtk-launch for menu / launcher widgets
      papirus-icon-theme        # Broader icon coverage for menu/launcher/category icons
      adwaita-icon-theme        # GTK fallback icons still used by some apps
      hicolor-icon-theme        # Freedesktop fallback icon theme for app icons
    ];

    home-manager.users.ushinnary =
      { pkgs, ... }:
      {
        # Keep ironbar/menu popups on a dark GTK theme and use a broad icon theme
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

        # ── Home-manager: map existing dotfiles into place ─────────────
        # Files come from the `dotfiles` flake input (path:..) so editing
        # the source files and rebuilding is all that's needed — no stow.
        xdg.configFile = builtins.listToAttrs (
          map (file: {
            name = "ironbar/${file}";
            value = { source = "${ironbarConfigDir}/${file}"; };
          }) ironbarFiles
        );
      };
  };
}
