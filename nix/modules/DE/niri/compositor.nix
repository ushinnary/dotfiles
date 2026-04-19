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
  dankMaterialShellRelativeRoot = "DankMaterialShell/.config/DankMaterialShell";
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

    # DMS bindings and config files included so home-manager will symlink
    # them into ~/.config/niri/dms/... as referenced by config.kdl.
    "dms/alttab.kdl"
    "dms/binds.kdl"
    "dms/colors.kdl"
    "dms/cursor.kdl"
    "dms/layout.kdl"
    "dms/outputs.kdl"
    "dms/windowrules.kdl"
    "dms/wpblur.kdl"
  ];
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
        xdg.configFile =
          builtins.listToAttrs (
            map (file: {
              name = "niri/${file}";
              value = {
                source = mkDotfileSymlink "${niriRelativeRoot}/${file}";
              };
            }) niriFiles
          )
          // {
            "DankMaterialShell/settings.json".source =
              mkDotfileSymlink "${dankMaterialShellRelativeRoot}/settings.json";
          };
      };
  };
}
