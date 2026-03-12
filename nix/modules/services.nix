{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.ushinnary.hardware;
in
{
  config = mkIf cfg.amdCpu {
    hardware.cpu.amd.updateMicrocode = true;
    services.fwupd.enable = true;

    systemd.services.fwupd-auto-update = {
      description = "Automatic firmware updates via fwupd on boot";
      after = [
        "display-manager.service"
        "network-online.target"
        "fwupd.service"
      ];
      wants = [ "network-online.target" ];
      wantedBy = [ "graphical.target" ];
      script = ''
        ${pkgs.fwupd}/bin/fwupdmgr refresh --force
        ${pkgs.fwupd}/bin/fwupdmgr update --no-reboot-check -y
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = false;
      };
    };

    boot.kernelParams = [
      "amd_pstate=active"
    ];
  };

}
