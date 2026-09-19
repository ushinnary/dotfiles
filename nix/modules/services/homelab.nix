{
  config,
  pkgs,
  lib,
  vars,
  ...
}:
let
  cfg = config.ushinnary.homelab;
  isRocmCompat = config.ushinnary.gpu.amd.enable && config.ushinnary.gpu.amd.rocm;
  rocmOverrideGfx = config.ushinnary.gpu.amd.rocmOverrideGfx;
in
{
  options.ushinnary.homelab = {
    enable = lib.mkEnableOption "Homelab server configuration (headless, services, monitoring)";
    cockpit = lib.mkEnableOption "Cockpit web interface for server management";
    ollama = {
      enable = lib.mkEnableOption "Local Ollama AI server with GPU acceleration";
      modelsPath = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/ollama/models";
        description = "Path to store Ollama models";
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 11434;
        description = "Port for Ollama service";
      };
    };
    powerManagement = {
      enable = lib.mkEnableOption "Power saving features (CPU governor, tuning)";
      cpuGovernor = lib.mkOption {
        type = lib.types.enum [
          "performance"
          "powersave"
          "schedutil"
        ];
        default = "powersave";
        description = "CPU frequency governor";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    console = {
      earlySetup = true;
      font = "Comic Mono";
      keyMap = "us";
    };

    powerManagement = lib.mkIf cfg.powerManagement.enable {
      enable = true;
      cpuFreqGovernor = cfg.powerManagement.cpuGovernor;
    };

    boot.kernelParams = [
      "quiet"
      "loglevel=3"
    ];

    # Not opened on the firewall: reachable only over trusted interfaces.
    services.cockpit = lib.mkIf cfg.cockpit {
      enable = true;
      port = 9090;
      openFirewall = false;
    };

    nixpkgs.config.rocmSupport = lib.mkIf cfg.ollama.enable isRocmCompat;

    services.ollama = lib.mkIf cfg.ollama.enable {
      enable = true;
      package = if isRocmCompat then pkgs.ollama-rocm else pkgs.ollama-vulkan;
      rocmOverrideGfx = rocmOverrideGfx;
      modelsDir = cfg.ollama.modelsPath;
      port = cfg.ollama.port;
      host = "0.0.0.0";
      environmentVariables = {
        OLLAMA_VULKAN = if isRocmCompat then "0" else "1";
      }
      // lib.optionalAttrs isRocmCompat {
        ROCM_PATH = "${pkgs.rocmPackages.clr}";
      }
      // lib.optionalAttrs (isRocmCompat && rocmOverrideGfx != null) {
        HSA_OVERRIDE_GFX_VERSION = rocmOverrideGfx;
      };
    };

    # Ollama and Cockpit are reachable only via LAN/Tailscale/WireGuard —
    # see the shared trustedInterfaces trust boundary in
    # system/firewall.nix. No ports are opened on the public firewall.
    networking.firewall.allowPing = true;

    environment.systemPackages =
      with pkgs;
      [
        vim
        git
        curl
        wget
        btrfs-progs
      ]
      ++ lib.optional cfg.cockpit cockpit;

    services.journald.settings.Journal = {
      SystemMaxUse = "500M";
      MaxRetentionSec = "1week";
      SystemKeepFree = "100M";
    };

    users.users."${vars.userName}".extraGroups = [ "render" ];
  };
}
