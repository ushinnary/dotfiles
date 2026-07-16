{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.ushinnary.apps;
in
{
  options.ushinnary.apps.davinciResolve = lib.mkEnableOption "DaVinci Resolve Studio";

  environment.systemPackages =
    with pkgs;
    [
      firefox
    ]
    ++ optionals cfg.davinciResolve [
      davinci-resolve-studio
    ];

  nixpkgs.config.allowUnfree = true;

}
