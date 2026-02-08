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

      powerManagement = {
        tuned = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable tuned for dynamic power management";
          };

          profile = mkOption {
            type = types.str;
            default = "balanced";
            description = "Tuned profile to use";
          };
        };
      };
    };
  };
}
