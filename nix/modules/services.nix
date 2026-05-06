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
      openssh = {
        enable = true;
      };
      fstrim.enable = true;
      # ── Journald log size limits ──────────────────────────────────
      journald.extraConfig = ''
        SystemMaxUse=1G
        MaxRetentionSec=2weeks
      '';
    };
    boot.kernelParams = lib.optionals cfg.amdCpu [
      "amd_pstate=active"
    ];
  };

}
