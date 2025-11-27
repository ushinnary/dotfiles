{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    mangohud
  ];

  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };

    gamemode.enable = true;
  };

  environment.variables = {
    MANGOHUD = 1;
    MANGOHUD_CONFIG = "fps_limit=144+120+60+30+0,preset=0,gl_vsync=-1,sync=0,toggle_hud=Shift_L+F2";
    TERMINAL = "ghostty";
    PROTON_ENABLE_NVAPI = "1";
    ENABLE_GAMESCOPE_WSI = "1";
    STEAM_MULTIPLE_XWAYLANDS = "1";
    PROTON_USE_NTSYNC = "1";
    ENABLE_HDR_WSI = "1";
    DXVK_HDR = "1";
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  users.users.ushinnary.extraGroups = [ "gamemode" ];
}
