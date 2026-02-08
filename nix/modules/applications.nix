{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.ushinnary.software;
in
{
  environment.systemPackages = with pkgs; [
    firefox
  ] ++ optionals cfg.davinciResolve [
    davinci-resolve-studio
  ];

  nixpkgs.config.allowUnfree = true;

}
