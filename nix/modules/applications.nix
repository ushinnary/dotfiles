{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    firefox
  ];

  nixpkgs.config.allowUnfree = true;

}
