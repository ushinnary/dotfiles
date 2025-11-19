{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.my.cpu;
in
{
  config = mkIf cfg.isAmd {
    hardware.cpu.amd.updateMicrocode = true;
    services.fwupd.enable = true;
  };

}
