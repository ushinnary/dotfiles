{
  config,
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
    boot.kernelParams = [
      "amd_pstate=active"
    ];
  };

}
