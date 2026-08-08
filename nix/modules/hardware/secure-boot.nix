{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  sbctlPath = "/var/lib/sbctl";
  initialInstall = builtins.getEnv "INITIAL_INSTALL" == "1";
in
{
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  # During initial install keep systemd-boot active; switch to lanzaboote after first rebuild.
  boot.loader.systemd-boot.enable = lib.mkForce initialInstall;

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
}