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
    "binds-custom.kdl"
  ];
in
{
  config = mkIf cfg.niri {
    environment.systemPackages = with pkgs; [
      adwaita-icon-theme
    ];

    home-manager.users.ushinnary =
      { lib, config, ... }:
      let
        mkDotfileSymlink =
          relativePath:
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/${relativePath}";
      in
      {
        # ── Home-manager: map existing dotfiles into place ─────────────
        # Files are linked out-of-store to ~/dotfiles, so edits are picked up
        # immediately (stow-like) without rebuilding.
        xdg.configFile = builtins.listToAttrs (
          map (file: {
            name = "niri/${file}";
            value = {
              source = mkDotfileSymlink "${niriRelativeRoot}/${file}";
            };
          }) niriFiles
        );

        xdg.configFile."DankMaterialShell/settings.json".source =
          mkDotfileSymlink "DankMaterialShell/.config/DankMaterialShell/settings.json";
      };
  };
}
