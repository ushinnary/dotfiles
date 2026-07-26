{
  config,
  pkgs,
  lib,
  vars,
  ...
}:
let
  cfg = config.ushinnary.homelab;
  isRocmCompat = config.ushinnary.gpu.amd.rocm;
  rocmOverrideGfx = config.ushinnary.gpu.amd.rocmOverrideGfx;
in
{
  options.ushinnary.homelab = {
    enable = lib.mkEnableOption "Homelab server configuration (headless, services, monitoring)";
    samba = lib.mkEnableOption "Samba file server with configurable shares";
    cockpit = lib.mkEnableOption "Cockpit web interface for server management";
    ollama = {
      enable = lib.mkEnableOption "Local Ollama AI server with GPU acceleration";
      modelsPath = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/ollama";
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
        type = lib.types.enum [ "performance" "powersave" "schedutil" ];
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

    powerManagement = {
      enable = true;
      cpuFreqGovernor = cfg.powerManagement.cpuGovernor;
    };

    boot.kernelParams = [
      "quiet"
      "loglevel=3"
    ];

    # Not opened on the firewall: reachable only over LAN/Tailscale via
    # the trustedInterfaces below, and served over HTTPS (self-signed).
    services.cockpit = {
      enable = true;
      port = 9090;
      openFirewall = false;
    };

    # services.samba = {
    #   enable = true;
    #   enableWinbind = false;
    #   sharing = {
    #     data = {
    #       path = "/srv/samba/data";
    #       "browseable" = "yes";
    #       "read only" = "no";
    #       "guest only" = "no";
    #       "create mask" = "0775";
    #       "directory mask" = "0775";
    #     };
    #     media = {
    #       path = "/srv/samba/media";
    #       "browseable" = "yes";
    #       "read only" = "no";
    #       "guest only" = "no";
    #       "create mask" = "0775";
    #       "directory mask" = "0775";
    #     };
    #   };
    # };

    # system.activationScripts.samba-dirs = ''
    #   mkdir -p /srv/samba/data
    #   mkdir -p /srv/samba/media
    #   chmod 755 /srv/samba/data
    #   chmod 755 /srv/samba/media
    # '';
    #
    nixpkgs.config.rocmSupport = isRocmCompat;

    services.ollama = {
      enable = true;
      package = if isRocmCompat then pkgs.ollama-rocm else pkgs.ollama-vulkan;
      rocmOverrideGfx = rocmOverrideGfx;
      port = cfg.ollama.port;
      host = "0.0.0.0";
      environmentVariables = lib.mkMerge [
        {
          OLLAMA_VULKAN = "1";
          # OLLAMA_CONTEXT_LENGTH = "131072";
        }
        (lib.mkIf isRocmCompat {
          ROCM_PATH = "${pkgs.rocmPackages.clr}";
          HSA_OVERRIDE_GFX_VERSION = "${rocmOverrideGfx}";
          OLLAMA_VULKAN = lib.mkForce "0";
        })
      ];
    };

    # Ollama and Cockpit are reachable only via LAN/Tailscale/WireGuard —
    # see the shared trustedInterfaces trust boundary in
    # system/firewall.nix. No ports are opened on the public firewall.
    networking.firewall.allowPing = true;

    environment.systemPackages = with pkgs; [
      vim
      git
      curl
      wget
      btrfs-progs
      cockpit
    ];

    services.journald.extraConfig = ''
      SystemMaxUse=500M
      MaxRetentionSec=1week
      SystemKeepFree=100M
    '';

    users.users."${vars.userName}".extraGroups = [ "render" ];

    # services.fstrim.enable = false;
    # services.udisks2.enable = false;

    # services.timesyncd.enable = true;
  };
}
