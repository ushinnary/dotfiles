{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    mangohud
  ];

  programs = {
    gamescope = {
      enable = true;
      capSysNice = true;
    };

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };

    gamemode.enable = true;
  };

  environment.variables = {
    MANGOHUD = 1;
    MANGOHUD_CONFIG = "fps_limit=144+120+60+30+0,preset=0,gl_vsync=-1,sync=0";
    TERMINAL = "ghostty";
  };

  users.users.ushinnary.extraGroups = [ "gamemode" ];
}
