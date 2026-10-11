{
  config,
  lib,
  ...
}: let
  cfg = config.ushinnary.hardware;
in {
  options.ushinnary.hardware.amdCpu = lib.mkEnableOption "AMD CPU microcode updates";

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
      # ntpd-rs (Rust) replaces systemd-timesyncd. NTS authenticates the
      # servers, so the clock can't be shifted by spoofed NTP replies.
      # Four independent European operators, so one wrong or unreachable
      # server is outvoted.
      ntpd-rs = {
        enable = true;
        useNetworkingTimeServers = false;
        settings.source =
          map (address: {
            mode = "nts";
            inherit address;
          }) [
            "time.cloudflare.com"
            "nts.netnod.se"
            "ptbtime1.ptb.de"
            "ntppool1.time.nl"
          ];
      };
      # ── Journald log size limits ──────────────────────────────────
      # mkDefault: the homelab module sets tighter limits.
      journald.settings.Journal = {
        SystemMaxUse = lib.mkDefault "1G";
        MaxRetentionSec = lib.mkDefault "2weeks";
      };
    };
    # No amd_pstate=active: the kernel's default mode is already active.
  };
}
