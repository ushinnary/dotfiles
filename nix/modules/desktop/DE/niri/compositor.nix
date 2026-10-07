{
  config,
  lib,
  vars,
  ...
}: let
  cfg = config.ushinnary.desktop;
  niriRelativeRoot = "niri/.config/niri";
in {
  config = lib.mkIf cfg.niri {
    # Icon themes are installed in bar.nix alongside the GTK theme config.
    home-manager.users."${vars.userName}" = {mkDotfileSymlink, ...}: {
      # ── Home-manager: map existing dotfiles into place ─────────────
      # Files are linked out-of-store to ~/dotfiles, so edits are picked up
      # immediately (stow-like) without rebuilding.
      xdg.configFile = {
        "niri" = {
          source = mkDotfileSymlink "${niriRelativeRoot}";
          recursive = true;
        };
        "DankMaterialShell" = {
          source = mkDotfileSymlink "DankMaterialShell/.config/DankMaterialShell";
          recursive = true;
        };
      };
    };
  };
}
