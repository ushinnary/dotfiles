{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.ushinnary.apps;
in
{
  options.ushinnary.apps.davinciResolve = lib.mkEnableOption "DaVinci Resolve Studio";

  config = {
    environment.systemPackages =
      with pkgs;
      [
        firefox
      ]
      ++ lib.optionals cfg.davinciResolve [
        davinci-resolve-studio
      ];

    nixpkgs.config.allowUnfree = true;
  };
}
