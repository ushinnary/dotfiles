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
      # Dark is only the default: gtk3-color-scheme below swaps it live.
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

      # DMS light/dark only flips color-scheme ("default" in light mode); it
      # swaps adw-gtk3/-dark only with its Material GTK template. Chromium
      # (Edge) reads "default" as no preference and follows the GTK3 theme,
      # so keep gtk-theme in step. Watching the whole dir also undoes Home
      # Manager resetting gtk-theme to the default above on activation.
      systemd.user.services.gtk3-color-scheme = {
        Unit = {
          Description = "Switch adw-gtk3 light/dark with the color scheme";
          After = ["graphical-session.target"];
          PartOf = ["graphical-session.target"];
        };
        Install.WantedBy = ["graphical-session.target"];
        Service = {
          ExecStart = "${pkgs.writeShellScript "gtk3-color-scheme" ''
            dconf=${pkgs.dconf}/bin/dconf
            dir=/org/gnome/desktop/interface/
            follow() {
              theme=adw-gtk3
              [ "$($dconf read ''${dir}color-scheme)" = "'prefer-dark'" ] && theme=adw-gtk3-dark
              [ "$($dconf read ''${dir}gtk-theme)" = "'$theme'" ] || $dconf write ''${dir}gtk-theme "'$theme'"
            }
            $dconf watch "$dir" | {
              follow
              while read -r _; do follow; done
            }
          ''}";
          Restart = "always";
          RestartSec = 2;
        };
      };
    };
  };
}
