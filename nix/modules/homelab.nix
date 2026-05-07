{
  config,
  pkgs,
  lib,
  vars,
  ...
}:
let
  cfg = config.ushinnary.homelab;
  isAmd = config.ushinnary.gpu.amd.enable;
in
{
  config = lib.mkIf cfg.enable {
    console = {
      font = "ter-v16n";
      keyMap = "us";
    };

    powerManagement = {
      enable = true;
      cpuFreqGovernor = cfg.powerManagement.cpuGovernor;
    };

    boot.kernelParams = [
      "quiet"
      "loglevel=3"
      "nomodeset"
    ];

    services.cockpit = {
      enable = true;
      port = 9090;
      openFirewall = true;
      settings = {
        WebService = {
          AllowUnencrypted = true;
        };
      };
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

    services.ollama = {
      enable = true;
      package = if isAmd then pkgs.ollama-rocm else pkgs.ollama;
      # modelDir = cfg.ollama.modelsPath;
      port = cfg.ollama.port;
      environmentVariables = lib.mkIf isAmd {
        ROCM_PATH = "${pkgs.rocmPackages.clr}";
        HSA_OVERRIDE_GFX_VERSION = "10.3.0";
      };
    };

    networking.firewall = {
      allowPing = true;
      trustedInterfaces = [
        "eth0"
        "enp*"
        "wlp*"
      ];
    };

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
