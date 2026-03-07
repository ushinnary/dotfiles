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
      adwaita-icon-theme        # Icon theme for ironbar menu/launcher
      hicolor-icon-theme        # Fallback icon theme for app icons
    ];

    home-manager.users.ushinnary =
      { pkgs, ... }:
      {
        # Force GTK dark mode so ironbar's @media (prefers-color-scheme: dark)
        # CSS query is satisfied correctly.
        gtk = {
          enable = true;
          iconTheme = {
            name = "Adwaita";
            package = pkgs.adwaita-icon-theme;
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
