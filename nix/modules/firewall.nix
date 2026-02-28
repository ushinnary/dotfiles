{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.ushinnary.firewall;
in
{
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;

    # ── Logging ──────────────────────────────────────────────────
    # Log every refused connection attempt (TCP SYN / UDP) and
    # reverse-path-filter drops so you can audit who is probing you.
    logRefusedConnections = true; # (default true, made explicit)
    logRefusedPackets = true; # log ALL dropped packets, not just connections
    logReversePathDrops = true; # log spoofed-source packets

    # ── Inbound allow-list ───────────────────────────────────────
    allowedTCPPorts = [
      80
      443
      22
      139 # NetBIOS / SMB — remove if you don't share files on LAN
      445 # SMB — remove if you don't share files on LAN
      34445
    ];
    allowedTCPPortRanges = [
      # KDE Connect
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = [
      {
        from = 4000;
        to = 4007;
      }
      {
        from = 8000;
        to = 8010;
      }
      {
        from = 137;
        to = 138;
      }
      # KDE Connect
      {
        from = 1714;
        to = 1764;
      }
    ];
  };

  networking.firewall.extraCommands = ''iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns'';

  # ── Egress (outbound) application firewall ─────────────────────
  # OpenSnitch intercepts EVERY outbound connection at the process level.
  # A popup asks you to Allow / Deny each new app→destination pair.
  # Rules are remembered so you only decide once per app.
  services.opensnitch = mkIf cfg.opensnitch {
    enable = true;
    settings = {
      DefaultAction = "deny"; # deny unknown traffic when UI is not running
      DefaultDuration = "until restart"; # temporary rules reset on reboot
      ProcMonitorMethod = "proc"; # "ebpf" is faster but fails on kernel 6.19+
      LogLevel = 1; # 0=debug … 4=error
    };
  };

  # OpenSnitch UI — shows popup prompts and lets you manage rules
  environment.systemPackages = mkIf cfg.opensnitch [ pkgs.opensnitch-ui ];

  services.tailscale.enable = true;
}
