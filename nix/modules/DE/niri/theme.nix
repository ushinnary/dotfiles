{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.ushinnary.desktop;
in
{
  config = mkIf cfg.niri {
    # ── GTK colour-scheme toggling via gsettings ───────────────────
    environment.systemPackages = with pkgs; [
      glib
    ];

    home-manager.users.ushinnary =
      { ... }:
      {
        # dark at 20:00, light at 08:00
        # gsettings triggers GTK apps (ironbar, ghostty, etc.) to switch
        systemd.user.services.theme-dark = {
          Unit.Description = "Switch to Catppuccin Mocha (dark)";
          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme prefer-dark";
          };
        };
        systemd.user.timers.theme-dark = {
          Unit.Description = "Switch to dark theme at 20:00";
          Timer = {
            OnCalendar = "*-*-* 20:00:00";
            Persistent = true;
          };
          Install.WantedBy = [ "timers.target" ];
        };

        systemd.user.services.theme-light = {
          Unit.Description = "Switch to Catppuccin Latte (light)";
          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme prefer-light";
          };
        };
        systemd.user.timers.theme-light = {
          Unit.Description = "Switch to light theme at 08:00";
          Timer = {
            OnCalendar = "*-*-* 08:00:00";
            Persistent = true;
          };
          Install.WantedBy = [ "timers.target" ];
        };
      };
  };
}
