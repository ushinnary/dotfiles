{
  pkgs,
  config,
  lib,
  vars,
  ...
}:
let
  cfg = config.ushinnary.desktop;
in
{
  # DankMaterialShell provides the bar, dock, OSD, notification centre,
  # and everything the old Quickshell + swaync stack handled.
  # This file now only carries the GTK / icon-theme defaults that the
  # rest of the desktop still needs.

  config = lib.mkIf cfg.niri {
    environment.systemPackages = [
      pkgs.adwaita-icon-theme
      pkgs.papirus-icon-theme
      pkgs.hicolor-icon-theme
    ];

    home-manager.users."${vars.userName}" =
      { pkgs, ... }:
      {
        gtk = {
          enable = true;
          iconTheme = {
            name = "Papirus";
            package = pkgs.papirus-icon-theme;
          };
        };

        dconf.settings."org/gnome/desktop/interface" = {
          gtk-theme = "Adwaita";
          icon-theme = "Papirus";
        };
      };
  };
}
