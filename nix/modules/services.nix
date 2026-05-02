{
  config,
  lib,
  ...
}:
let
  cfg = config.ushinnary.hardware;
in
{
  config = {
    hardware.cpu.amd.updateMicrocode = cfg.amdCpu;
    services = {
      fwupd.enable = true;
      udisks2.enable = true;
      resolved.enable = true;
      kmscon.enable = true;
    };
    boot.kernelParams = lib.optionals cfg.amdCpu [
      "amd_pstate=active"
    ];
  };

}
