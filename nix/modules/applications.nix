{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
  ];

  nixpkgs.config.allowUnfree = true;

}
