{
  pkgs,
  config,
  lib,
  vars,
  ...
}: let
  cfg = config.ushinnary.desktop;
in {
  imports = [
    ./bar.nix
    ./terminal.nix
    ./compositor.nix
  ];

  config = lib.mkIf cfg.niri {
    programs.niri.enable = true;

    # ── DankMaterialShell (bar, dock, OSD, notifications, clipboard,
    #    wallpaper, theme, lock screen, media, brightness …) ───────
    programs.dms-shell = {
      enable = true;
      systemd = {
        enable = true;
        restartIfChanged = true;
      };
      excludePackages = [pkgs.cava];
    };

    services.clight.enable = false;
    ushinnary.desktop.nautilus = lib.mkDefault true;

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
      #logs = {
      #  save = true;
      #  path = "/var/log/dms-greeter.log";
      #};
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
      xwayland-satellite

      # File manager
      file-roller
      cups-pk-helper
      seahorse
      brightnessctl
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
        default = lib.mkDefault [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
        # FileChooser falls through to "gnome": the Nautilus-based picker.
      };
    };

    # ── Security & Password Management ────────────────────────────
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.login.enableGnomeKeyring = true;
    security.pam.services.greetd.enableGnomeKeyring = true;

    # Session-critical: when systemd-oomd (system/memory.nix) must kill
    # something in the session, it picks apps before the compositor/shell.
    systemd.user.services.niri.serviceConfig.ManagedOOMPreference = "avoid";
    systemd.user.services.dms.serviceConfig.ManagedOOMPreference = "avoid";

    # Polkit agent: DMS ships its own (Quickshell PolkitAgent). Don't add
    # a second one — only one agent can register per session.
  };
}
