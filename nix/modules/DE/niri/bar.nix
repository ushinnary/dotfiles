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
  ironbar = "${dotfiles}/ironbar/.config/ironbar";
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
    ];

    home-manager.users.ushinnary =
      { ... }:
      {
        # ── Home-manager: map existing dotfiles into place ─────────────
        # Files come from the `dotfiles` flake input (path:..) so editing
        # the source files and rebuilding is all that's needed — no stow.
        xdg.configFile = builtins.listToAttrs (
          map (file: {
            name = "ironbar/${file}";
            value = { source = "${ironbar}/${file}"; };
          }) ironbarFiles
        );
      };
  };
}
