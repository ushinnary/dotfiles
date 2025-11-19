{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    discord
    obs-studio
    obsidian
    microsoft-edge
    postman
    heroic
    amberol
  ];

  nixpkgs.config.allowUnfree = true;

}
