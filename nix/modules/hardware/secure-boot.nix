{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.ushinnary.hardware.secureBoot;
  sbctlPath = "/var/lib/sbctl";
  initialInstall = builtins.getEnv "INITIAL_INSTALL" == "1";
in
{
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  options.ushinnary.hardware.secureBoot =
    lib.mkEnableOption "Secure Boot with lanzaboote (requires sbctl keys enrolled)";

  # Gate behind the option so hosts without enrolled keys (e.g. ryzo) stay on systemd-boot.
  config = lib.mkIf cfg {
    # During initial install keep systemd-boot active; switch to lanzaboote after first rebuild.
    boot.loader.systemd-boot.enable = lib.mkOverride 50 initialInstall;

    boot.lanzaboote = {
      enable = !initialInstall;
      pkiBundle = sbctlPath;
    };

    environment.systemPackages = [
      pkgs.sbctl
      pkgs.tpm2-tools
      pkgs.tpm2-tss
    ];

    boot.initrd.availableKernelModules = [ "tpm_crb" ];
    boot.initrd.systemd.enable = lib.mkForce (!initialInstall);
  };
}