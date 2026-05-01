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
      hasBattery = mkEnableOption "system has a battery (enables battery widget in bars, power-aware features, etc.)";
      hasWebCam = mkEnableOption "system has a webcam (enables clight for automatic brightness via camera)";
    };

    # ── Desktop ───────────────────────────────────────────────────
    desktop = {
      gnome = mkEnableOption "GNOME desktop environment";
      cosmic = mkEnableOption "COSMIC desktop environment";
      plasma = mkEnableOption "Plasma desktop environment";
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
    dev = {
      enable = mkEnableOption "development tools and Nixvim editor";

      editors = mkOption {
        type = types.listOf (
          types.enum [
            "nixvim"
            "vscode"
            "zed"
          ]
        );
        default = [
          "nixvim"
          "vscode"
          "zed"
        ];
        description = ''
          Select which development editors to install when dev.enable is true.
          Supported values are "nixvim", "vscode" and "zed".
        '';
      };

      servers = mkOption {
        type = types.listOf (
          types.enum [
            "vscode"
            "zed"
          ]
        );
        default = [];
        description = ''
          Select which development servers to install when dev.enable is true.
          Supported values are "vscode" and "zed".
        '';
      };

      aiAgents = mkEnableOption "AI agent CLI tools (kilocode-cli)";
    };

    # ── Applications ──────────────────────────────────────────────
    apps = {
      davinciResolve = mkEnableOption "DaVinci Resolve Studio";
    };

    # ── Gaming ────────────────────────────────────────────────────
    gaming.enable = mkEnableOption "gaming packages and configuration (Steam, Gamescope, etc.)";

    # ── Containers ────────────────────────────────────────────────
    containers = {
      enable = mkEnableOption "Enable Podman container runtime";
    };

    # ── Virtualisation ───────────────────────────────────────────
    virtualisation = {
      host.enable = mkEnableOption "host virtualization stack for running VMs (VirtualBox)";
    };

    # ── Firewall ──────────────────────────────────────────────────
    firewall = {
      opensnitch = mkEnableOption "Enable OpenSnitch application firewall";
      smbSharing = mkEnableOption "SMB/Samba file sharing ports in firewall (139, 445) — enable on LAN desktops only";
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
  };
}
