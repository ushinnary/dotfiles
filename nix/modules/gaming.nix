{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.ushinnary.gaming;
  screenCfg = config.ushinnary.screen;
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
          args = [
            "--adaptive-sync"
            "--steam"
            "--mangoapp"
          ]
          ++ (
            if screenCfg.isOled then
              [
                "-r ${toString screenCfg.gamingRefreshRate}"
                "-o ${toString screenCfg.gamingRefreshRate}"
                "--hdr-enabled"
                "--hdr-itm-enable"
              ]
            else
              [
                "-r ${toString screenCfg.gamingRefreshRate}"
              ]
          );
        };
      };

      gamemode.enable = true;
      gamescope.enable = true;
    };

    environment.systemPackages = with pkgs; [
      mangohud
    ];

    environment.variables = {
      MANGOHUD = "1";
      MANGOHUD_CONFIGFILE = pkgs.writeText "mangohud.conf" ''
        fps_limit=${toString screenCfg.gamingRefreshRate},${toString screenCfg.refreshRate},60,30,0
        preset=0
        toggle_hud=Shift_L+F2
        position=top-left
        font_size=18
        background_alpha=0.3
      '';
      TERMINAL = "ghostty";
      ENABLE_GAMESCOPE_WSI = "1";
      STEAM_MULTIPLE_XWAYLANDS = "1";
      PROTON_USE_NTSYNC = "1";
      # HDR Support for OLED
      ENABLE_HDR_WSI = if screenCfg.isOled then "1" else "0";
      DXVK_HDR = if screenCfg.isOled then "1" else "0";

      # Hardware specific variables
      PROTON_ENABLE_NVAPI = if config.ushinnary.nvidia.enable then "1" else "0";
    } // lib.optionalAttrs config.ushinnary.amd.enable {
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
