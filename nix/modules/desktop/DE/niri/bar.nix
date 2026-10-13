{
  pkgs,
  config,
  lib,
  vars,
  ...
}: let
  cfg = config.ushinnary.desktop;
in {
  # DankMaterialShell provides the bar, dock, OSD, notification centre,
  # and everything the old Quickshell + swaync stack handled.
  # This file now only carries the GTK / icon-theme defaults that the
  # rest of the desktop still needs.

  config = lib.mkIf cfg.niri {
    environment.systemPackages = [
      pkgs.adwaita-icon-theme
      pkgs.hicolor-icon-theme
    ];

    # Same GTK3 theme for Flatpak apps (they can't see host themes).
    systemd.services.flatpak-update.script = lib.mkAfter ''
      flatpak install --system -y --noninteractive --or-update flathub \
        org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark
    '';

    home-manager.users."${vars.userName}" = {pkgs, ...}: {
      # Adwaita everywhere. GTK4/libadwaita apps ignore gtk-theme; adw-gtk3
      # makes GTK3 apps (and the GTK portal dialogs) match them. Set for GTK3
      # only: gtk.theme would also feed gtk.gtk4.theme (core/default.nix),
      # which imports the theme's CSS into libadwaita apps.
      # Dark only: DMS only swaps adw-gtk3/-dark when its GTK template is on.
      gtk = {
        enable = true;
        gtk3.theme = {
          name = "adw-gtk3-dark";
          package = pkgs.adw-gtk3;
        };
        iconTheme = {
          name = "Adwaita";
          package = pkgs.adwaita-icon-theme;
        };
      };
    };
  };
}
