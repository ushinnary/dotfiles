{
  lib,
  ...
}:
with lib;
{
  # Centralised options for this dotfiles repo. All option defaults are set
  # to `false` as requested so features must be explicitly enabled in your
  # machine-specific configuration.
  options = {
    # System-level options
    ushinnary = {
      nvidia = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable NVIDIA GPU Drivers for desktop PC";
        };

        open = mkOption {
          type = types.bool;
          default = true;
          description = "Use open source NVIDIA drivers";
        };

        # powerLimit is an integer when used but defaults to `false` here to
        # follow the user's instruction. The service using this value should
        # be gated by `enable` (so the false default won't be used at runtime).
        powerLimit = mkOption {
          type = with types; either bool int;
          default = false;
          description = "Set power limit to nvidia GPU (positive int) or false to disable";
        };
      };

      amd = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable AMD GPU Drivers for desktop PC";
        };
      };

      desktopEnvironment = {
        gnome = mkOption {
          type = types.bool;
          default = false;
          description = "Set GNOME as DE";
        };

        cosmic = mkOption {
          type = types.bool;
          default = false;
          description = "Set Cosmic as DE";
        };
      };

      software = {
        enableDevPackages = mkOption {
          type = types.bool;
          default = false;
          description = "Enable all dev packages with Nixvim included";
        };

        davinciResolve = mkOption {
          type = types.bool;
          default = false;
          description = "Enable DaVinci Resolve Studio";
        };
      };

      gaming = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable gaming-related packages and configurations";
        };
      };

      screen = {
        isOled = mkOption {
          type = types.bool;
          default = false;
          description = "Enable OLED-specific optimizations (HDR, deeper blacks)";
        };

        refreshRate = mkOption {
          type = types.int;
          default = 60;
          description = "Default refresh rate for normal desktop use";
        };

        gamingRefreshRate = mkOption {
          type = types.int;
          default = 144;
          description = "Refresh rate to use when gaming (higher for better performance)";
        };
      };

      cpu = {
        isAmd = mkOption {
          type = types.bool;
          default = false;
          description = "Apply AMD tweaks for CPU";
        };
      };

      virtualisation = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable virtualization with podman";
        };
      };

      security = {
        sudo = {
          noPasswdCommands = mkOption {
            type = types.listOf types.str;
            default = [
              "/run/current-system/sw/bin/reboot"
              "/run/current-system/sw/bin/nixos-rebuild"
              "/run/current-system/sw/bin/nix-collect-garbage"
              "/run/current-system/sw/bin/shutdown"
              "/run/current-system/sw/bin/fwupd"
              "/run/current-system/sw/bin/fwupdmgr"
            ];
            description = "List of commands to run without sudo password";
          };
        };
      };

      powerManagement = {
        rust = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable Rust-first power management (system76-scheduler)";
          };

          profile = mkOption {
            type = types.enum [
              "balanced"
              "performance"
              "powersave"
            ];
            default = "balanced";
            description = "Power profile mapped to CPU governor";
          };

          enablePowerProfilesDaemon = mkOption {
            type = types.bool;
            default = false;
            description = "Enable power-profiles-daemon when desktop integration is needed";
          };

          enableSystem76Power = mkOption {
            type = types.bool;
            default = true;
            description = "Enable system76-power daemon for power profile control";
          };
        };
      };
    };
  };
}
