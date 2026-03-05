{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.ushinnary.desktop;
in
{
  imports = [
    ./bar.nix
    ./terminal.nix
    ./theme.nix
    ./compositor.nix
  ];

  config = mkIf cfg.niri {
    programs.niri.enable = true;

    # ── Login manager ─────────────────────────────────────────────
    # Using greetd to seamlessly log into Niri without pulling GNOME shell stuff
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
          user = "greeter";
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/cache/tuigreet 0755 greeter greeter -"
    ];

    # ── Core Wayland / session packages ───────────────────────────
    environment.systemPackages = with pkgs; [
      kdePackages.polkit-kde-agent-1
      xwayland-satellite
      gnome-keyring

      # File manager
      nautilus

      # Clipboard stack (persistence + history)
      wl-clipboard
      wl-clip-persist
      cliphist

      # Screen lock
      swaylock
      swayidle

      # Media / brightness
      brightnessctl
      playerctl
    ];

    # ── XDG portals ───────────────────────────────────────────────
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
      config.common.default = "*";
      config.niri = {
        default = mkDefault [ "gtk" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
    };

    # ── Security & Password Management ────────────────────────────
    # gnome-keyring is started via its systemd user service.
    # Do NOT plug it into the greetd PAM stack: its session module tries to
    # contact the user D-Bus session which doesn't exist yet at greetd time.
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.login.enableGnomeKeyring = true;

    # Give the greeter user camera access so howdy (if enabled on this host)
    # can attempt face-auth without crashing the PAM module.
    users.groups.video.members = [ "greeter" ];

    # Prevent howdy from blocking greetd auth.
    security.pam.services.greetd.howdy.enable = false;

    # Allow swaylock to authenticate via PAM
    security.pam.services.swaylock = { };

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
    home-manager.users.ushinnary =
      { ... }:
      {
        imports = [
          inputs.system76-scheduler-niri.homeModules.default
        ];

        services.system76-scheduler-niri.enable = config.services.system76-scheduler.enable;
      };
  };
}
