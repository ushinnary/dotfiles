{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    mangohud
  ];

  programs.steam.enable = true;
  programs.steam.remotePlay.openFirewall = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;

  environment.variables = {
    MANGOHUD = 1;
    MANGOHUD_CONFIG = "fps_limit=144+120+60+30+0,preset=0,gl_vsync=-1,sync=0";
  };

  users.users.ushinnary.extraGroups = [ "gamemode" ];
}
