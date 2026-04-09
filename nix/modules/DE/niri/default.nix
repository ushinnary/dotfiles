{
  pkgs,
  config,
  lib,
  inputs,
  vars,
  ...
}:
with lib;
let
  cfg = config.ushinnary.desktop;
  hw = config.ushinnary.hardware;
in
{
  imports = [
    inputs.dms-plugin-registry.modules.default
    ./bar.nix
    ./terminal.nix
    ./compositor.nix
  ];

  config = mkIf cfg.niri {
    programs.niri.enable = true;

    # ── DankMaterialShell (bar, dock, OSD, notifications, clipboard,
    #    wallpaper, theme, lock screen, media, brightness …) ───────
    programs.dms-shell = {
      enable = true;
      systemd = {
        enable = true;
        restartIfChanged = true;
      };
      enableSystemMonitoring = true;
      enableDynamicTheming = true;
      enableClipboardPaste = true;
      enableVPN = false;
      enableCalendarEvents = false;
      enableAudioWavelength = false;
      plugins = {
        dankClight.enable = false;
        dankLauncherKeys.enable = true;
        dankPomodoroTimer.enable = true;
        wallpaperCarousel.enable = true;
        dankBatteryAlerts.enable = hw.hasBattery;
      };
    };

    services.clight.enable = false;

    # ── DankSearch ────────────────────────────────────────────────
    programs.dsearch = {
      enable = true;
      systemd.enable = true;
    };

    # ── Login manager — DankGreeter ───────────────────────────────
    services.displayManager.dms-greeter = {
      enable = true;
      compositor.name = "niri";
      configHome = "/home/${vars.userName}"; # Sync DMS theme with the greeter
      logs = {
        save = true;
        path = "/var/log/dms-greeter.log";
      };
      configFiles = [
        "/home/${vars.userName}/.config/DankMaterialShell/settings.json"
        "/home/${vars.userName}/.local/state/DankMaterialShell/session.json"
        "/home/${vars.userName}/.cache/DankMaterialShell/dms-colors.json"
      ];
    };

    # ── Core Wayland / session packages ───────────────────────────
    # Packages previously needed for the custom shell stack (swaylock,
    # swayidle, brightnessctl, playerctl, wl-clipboard, cliphist, etc.)
    # are now provided or superseded by DankMaterialShell.
    environment.systemPackages = with pkgs; [
      kdePackages.polkit-kde-agent-1
      xwayland-satellite
      gnome-keyring

      # File manager
      nautilus
      cups-pk-helper
    ];

    # ── XDG portals ───────────────────────────────────────────────
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gnome
        pkgs.xdg-desktop-portal-gtk
      ];
      config.common.default = "*";
      config.niri = {
        default = mkDefault [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      };
    };

    # ── Security & Password Management ────────────────────────────
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.login.enableGnomeKeyring = true;

    # ── Polkit ────────────────────────────────────────────────────
    systemd.user.services.polkit-kde-authentication-agent-1 = {
      description = "polkit-kde-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    # ── Home Manager base ─────────────────────────────────────────
    home-manager.users."${vars.userName}" =
      { ... }:
      {
        imports = [
          inputs.system76-scheduler-niri.homeModules.default
        ];

        services.system76-scheduler-niri.enable = config.services.system76-scheduler.enable;
      };
  };
}
