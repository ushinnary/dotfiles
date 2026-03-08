{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.ushinnary.desktop;
  niriRelativeRoot = "niri/.config/niri";
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
      { lib, config, ... }:
      let
        mkDotfileSymlink =
          relativePath:
          config.lib.file.mkOutOfStoreSymlink
            "${config.home.homeDirectory}/dotfiles/${relativePath}";
      in
      {
        # Ensure ~/wallpaper exists so the rand-wallpaper script has somewhere to look.
        home.activation.createWallpaperDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p "$HOME/wallpaper"
        '';

        # ── Home-manager: map existing dotfiles into place ─────────────
        # Files are linked out-of-store to ~/dotfiles, so edits are picked up
        # immediately (stow-like) without rebuilding.
        xdg.configFile = builtins.listToAttrs (
          map (file: {
            name = "niri/${file}";
            value = { source = mkDotfileSymlink "${niriRelativeRoot}/${file}"; };
          }) niriFiles
        );
      };
  };
}
