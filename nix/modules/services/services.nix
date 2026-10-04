{
  config,
  lib,
  ...
}:
let
  cfg = config.ushinnary.hardware;
in
{
  options.ushinnary.hardware.amdCpu = lib.mkEnableOption "AMD CPU tweaks (microcode, pstate)";

  config = {
    hardware.cpu.amd.updateMicrocode = cfg.amdCpu;
    services = {
      fwupd.enable = true;
      udisks2.enable = true;
      resolved = {
        enable = true;
        # LLMNR answers can be spoofed by anyone on the local network
        # (e.g. public Wi-Fi); mDNS via Avahi covers .local lookups.
        settings.Resolve.LLMNR = "no";
      };
      kmscon.enable = true;
      openssh = {
        enable = true;
        # Reachable only via trustedInterfaces (system/firewall.nix);
        # the default would open port 22 on every network.
        openFirewall = false;
      };
      fstrim.enable = true;
      # ── Journald log size limits ──────────────────────────────────
      journald.settings.Journal = {
        SystemMaxUse = "1G";
        MaxRetentionSec = "2weeks";
      };
    };
    boot.kernelParams = lib.optionals cfg.amdCpu [
      "amd_pstate=active"
    ];
  };

}
