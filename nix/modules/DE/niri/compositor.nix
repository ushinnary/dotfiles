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
  niri = "${dotfiles}/niri/.config/niri";
  niriFiles = [
    "config.kdl"
    "startup.kdl"
    "environment.kdl"
    "appearance.kdl"
    "outputs.kdl"
    "input.kdl"
    "layout.kdl"
    "window-rules.kdl"
    "binds.kdl"
    "scripts/rand-wallpaper.sh"
    "scripts/cliphist-anyrun.sh"
  ];
in
{
  config = mkIf cfg.niri {
    # anyrun is referenced in binds.kdl
    environment.systemPackages = with pkgs; [
      anyrun
      swaybg
      adwaita-icon-theme
    ];

    home-manager.users.ushinnary =
      { lib, ... }:
      {
        # Ensure ~/wallpaper exists so the rand-wallpaper script has somewhere to look.
        home.activation.createWallpaperDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p "$HOME/wallpaper"
        '';

        # ── Home-manager: map existing dotfiles into place ─────────────
        # Files come from the `dotfiles` flake input (path:..) so editing
        # the source files and rebuilding is all that's needed — no stow.
        xdg.configFile = builtins.listToAttrs (
          map (file: {
            name = "niri/${file}";
            value = { source = "${niri}/${file}"; };
          }) niriFiles
        );
      };
  };
}
