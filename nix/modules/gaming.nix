{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.ushinnary.gaming;
  displayCfg = config.ushinnary.display;
in
{
  config = mkIf cfg.enable {
    programs = {
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        gamescopeSession = {
          enable = true;
        };
      };

      gamemode.enable = true;
      gamescope = {
        enable = true;
        capSysNice = false;
      };
    };

    environment.systemPackages = [ pkgs.mangohud ];

    environment.variables = {
      TERMINAL = "ghostty";
      ENABLE_GAMESCOPE_WSI = "1";
      STEAM_MULTIPLE_XWAYLANDS = "1";
      PROTON_USE_NTSYNC = "1";
      # HDR Support for OLED
      ENABLE_HDR_WSI = if displayCfg.oled then "1" else "0";
      DXVK_HDR = if displayCfg.oled then "1" else "0";

      # Hardware specific variables
      PROTON_ENABLE_NVAPI = if config.ushinnary.gpu.nvidia.enable then "1" else "0";
    } // lib.optionalAttrs config.ushinnary.gpu.amd.enable {
      AMD_VULKAN_ICD = "radv";
      RADV_PERFTEST = "gpl";
      LD_BIND_NOW = "1";
    };

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    users.users.ushinnary.extraGroups = [ "gamemode" ];
  };
}
