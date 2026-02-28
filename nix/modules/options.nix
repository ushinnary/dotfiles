{
  lib,
  ...
}:
with lib;
{
  options.ushinnary = {

    # ── GPU ───────────────────────────────────────────────────────
    gpu = {
      nvidia = {
        enable = mkEnableOption "NVIDIA GPU drivers";

        openDriver = mkOption {
          type = types.bool;
          default = true;
          description = "Use the open-source NVIDIA kernel driver";
        };

        powerLimit = mkOption {
          type = with types; either bool int;
          default = false;
          description = "Power limit in watts for the NVIDIA GPU, or false to leave unchanged";
        };
      };

      amd.enable = mkEnableOption "AMD GPU drivers";
    };

    # ── Hardware ──────────────────────────────────────────────────
    hardware = {
      amdCpu = mkEnableOption "AMD CPU tweaks (microcode, pstate)";
    };

    # ── Desktop ───────────────────────────────────────────────────
    desktop = {
      gnome = mkEnableOption "GNOME desktop environment";
      cosmic = mkEnableOption "COSMIC desktop environment";
      niri = mkEnableOption "Niri Wayland compositor";
    };

    # ── Display ───────────────────────────────────────────────────
    display = {
      oled = mkEnableOption "OLED-specific optimizations (HDR, deeper blacks)";

      refreshRate = mkOption {
        type = types.int;
        default = 60;
        description = "Default refresh rate for normal desktop use";
      };

      gamingRefreshRate = mkOption {
        type = types.int;
        default = 144;
        description = "Refresh rate used in gaming sessions";
      };
    };

    # ── Development ───────────────────────────────────────────────
    dev.enable = mkEnableOption "development tools and Nixvim editor";

    # ── Applications ──────────────────────────────────────────────
    apps = {
      davinciResolve = mkEnableOption "DaVinci Resolve Studio";
    };

    # ── Gaming ────────────────────────────────────────────────────
    gaming.enable = mkEnableOption "gaming packages and configuration (Steam, Gamescope, etc.)";

    # ── Containers ────────────────────────────────────────────────
    containers = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Podman container runtime";
      };
    };

    # ── Firewall ──────────────────────────────────────────────────
    firewall = {
      opensnitch = mkOption {
        type = types.bool;
        default = true;
        description = "Enable OpenSnitch application firewall";
      };
    };

    # ── Security ──────────────────────────────────────────────────
    security = {
      howdy.enable = mkEnableOption "Howdy facial recognition authentication";

      sudo.passwordlessCommands = mkOption {
        type = types.listOf types.str;
        default = [
          "/run/current-system/sw/bin/reboot"
          "/run/current-system/sw/bin/nixos-rebuild"
          "/run/current-system/sw/bin/nix-collect-garbage"
          "/run/current-system/sw/bin/shutdown"
          "/run/current-system/sw/bin/fwupd"
          "/run/current-system/sw/bin/fwupdmgr"
        ];
        description = "Commands that can be run with sudo without a password";
      };
    };

    # ── Power ─────────────────────────────────────────────────────
    power = {
      enable = mkEnableOption "power management (system76-scheduler, CPU governor)";

      profile = mkOption {
        type = types.enum [
          "balanced"
          "performance"
          "powersave"
        ];
        default = "balanced";
        description = "Power profile mapped to CPU governor";
      };

      profilesDaemon = mkEnableOption "power-profiles-daemon for desktop integration";

      system76Power = mkOption {
        type = types.bool;
        default = true;
        description = "Enable system76-power daemon for power profile control";
      };
    };
  };
}
