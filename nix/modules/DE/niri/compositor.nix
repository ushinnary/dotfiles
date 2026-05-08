{
  pkgs,
  config,
  lib,
  vars,
  ...
}:
with lib;
let
  cfg = config.ushinnary.desktop;
  niriRelativeRoot = "niri/.config/niri";
in
{
  config = mkIf cfg.niri {
    environment.systemPackages = with pkgs; [
      adwaita-icon-theme
    ];

    home-manager.users."${vars.userName}" =
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
        xdg.configFile = {
          "niri" = {
            source = mkDotfileSymlink "${niriRelativeRoot}";
            recursive = true;
          };
        };
      };
  };
}
