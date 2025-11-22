{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.ushinnary.cpu;
in
{
  config = mkIf cfg.isAmd {
    hardware.cpu.amd.updateMicrocode = true;
    services.fwupd.enable = true;
    boot.kernelParams = [
      "amd_pstate=active"
    ];
  };

}
