{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.ushinnary.security;
in
{
  config = mkMerge [
    # ═══════════════════════════════════════════════════════════════
    #  General security hardening (always active)
    # ═══════════════════════════════════════════════════════════════
    {
      # ── SSH hardening ────────────────────────────────────────────
      services.openssh.settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        X11Forwarding = false;
        MaxAuthTries = 3;
        AllowTcpForwarding = "local";
        AllowAgentForwarding = false;
        ClientAliveInterval = 300;
        ClientAliveCountMax = 2;
      };

      # ── Intrusion prevention ─────────────────────────────────────
      services.fail2ban = {
        enable = true;
        maxretry = 3;
        bantime = "1h";
        bantime-increment = {
          enable = true; # each repeat offence doubles the ban
        };
      };

      # ── Kernel hardening (sysctl) ───────────────────────────────
      boot.kernel.sysctl = {
        # — Anti-spoofing (reverse-path filter) —
        "net.ipv4.conf.all.rp_filter" = 1;
        "net.ipv4.conf.default.rp_filter" = 1;

        # — Reject ICMP redirects (MITM protection) —
        "net.ipv4.conf.all.accept_redirects" = 0;
        "net.ipv4.conf.default.accept_redirects" = 0;
        "net.ipv6.conf.all.accept_redirects" = 0;
        "net.ipv6.conf.default.accept_redirects" = 0;

        # — Don't send ICMP redirects (we're not a router) —
        "net.ipv4.conf.all.send_redirects" = 0;
        "net.ipv4.conf.default.send_redirects" = 0;

        # — Ignore broadcast pings —
        "net.ipv4.icmp_echo_ignore_broadcasts" = 1;

        # — Log Martian packets (impossible source addresses) —
        "net.ipv4.conf.all.log_martians" = 1;
        "net.ipv4.conf.default.log_martians" = 1;

        # — SYN flood protection —
        "net.ipv4.tcp_syncookies" = 1;
        "net.ipv4.tcp_max_syn_backlog" = 2048;

        # — Disable source routing —
        "net.ipv4.conf.all.accept_source_route" = 0;
        "net.ipv4.conf.default.accept_source_route" = 0;
        "net.ipv6.conf.all.accept_source_route" = 0;
        "net.ipv6.conf.default.accept_source_route" = 0;

        # — Hide kernel pointers from non-root users —
        "kernel.kptr_restrict" = 2;

        # — Restrict dmesg to root (prevents info leaks) —
        "kernel.dmesg_restrict" = 1;

        # — Restrict unprivileged eBPF (reduces exploit surface) —
        "kernel.unprivileged_bpf_disabled" = 1;

        # — Restrict perf_event (no unprivileged profiling) —
        "kernel.perf_event_paranoid" = 2;
      };

      # ── Prevent core dumps (may leak secrets) ───────────────────
      security.pam.loginLimits = [
        {
          domain = "*";
          item = "core";
          type = "hard";
          value = "0";
        }
      ];
      systemd.coredump.extraConfig = ''
        Storage=none
        ProcessSizeMax=0
      '';

      # ── Restrict su to wheel group only ─────────────────────────
      security.pam.services.su.requireWheel = true;
    }

    # ═══════════════════════════════════════════════════════════════
    #  Howdy facial recognition (conditional)
    # ═══════════════════════════════════════════════════════════════
    (mkIf cfg.howdy.enable {
      services.howdy = {
        enable = true;
        package = pkgs.howdy;
        settings = {
          core = {
            device_path = "/dev/video0";
            ignore_closed_eyes = true;
          };
          video = {
            dark_threshold = 90;
          };
        };
      };

      # GNOME PAM integration for Howdy
      security.pam.howdy.enable = true;
    })
  ];
}
