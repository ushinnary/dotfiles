{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.ushinnary.firewall;
in
{
  options.ushinnary.firewall = {
    opensnitch = lib.mkEnableOption "Enable OpenSnitch application firewall";
    smbSharing = lib.mkEnableOption "SMB/Samba NetBIOS conntrack helper — enable on LAN desktops only";
  };

  networking.networkmanager.enable = true;

  # ── Trust boundary ───────────────────────────────────────────────
  # Every inbound service in this config (SSH, KDE Connect, Ollama,
  # Cockpit, Steam Remote Play/dedicated servers, mDNS, …) is reachable
  # ONLY from these interfaces: your LAN, Tailscale, or a WireGuard
  # tunnel. No port is opened on any other interface, even when a
  # service module tries to "openFirewall" itself — nothing here is
  # meant to be reachable from the open internet.
  #
  # "+" is iptables' own interface-name prefix wildcard (the module
  # passes these straight to `-i`, which only understands a trailing
  # "+", not shell-style "*"), so "enp+"/"wlp+" match real interface
  # names like enp5s0/wlp3s0 on any host.
  networking.firewall.trustedInterfaces = [
    "eth0"
    "enp+"
    "wlp+"
    "tailscale0"
    "wg+"
  ];

  networking.firewall = {
    enable = true;

    # ── Logging ──────────────────────────────────────────────────
    # Log every refused connection attempt (TCP SYN / UDP) and
    # reverse-path-filter drops so you can audit who is probing you.
    logRefusedConnections = true; # (default true, made explicit)
    logRefusedPackets = true; # log ALL dropped packets, not just connections
    logReversePathDrops = true; # log spoofed-source packets

    # No allowedTCPPorts/allowedUDPPorts here on purpose: anything
    # needed (SSH, KDE Connect, …) is reachable via trustedInterfaces
    # above. Nothing should be exposed beyond LAN/Tailscale/WireGuard.
  };

  # NetBIOS name-resolution broadcasts need a conntrack helper to work
  # correctly; unrelated to port filtering, so kept independent of the
  # trust-boundary change above.
  networking.firewall.extraCommands = lib.optionalString cfg.smbSharing
    "iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns";

  # ── Egress (outbound) application firewall ─────────────────────
  # OpenSnitch intercepts EVERY outbound connection at the process level.
  # A popup asks you to Allow / Deny each new app→destination pair.
  # Rules are remembered so you only decide once per app.
  services.opensnitch = lib.mkIf cfg.opensnitch {
    enable = true;
    settings = {
      DefaultAction = "deny"; # deny unknown traffic when UI is not running
      DefaultDuration = "until restart"; # temporary rules reset on reboot
      ProcMonitorMethod = "proc"; # "ebpf" is faster but fails on kernel 6.19+
      LogLevel = 1; # 0=debug … 4=error
    };
  };

  # OpenSnitch UI — shows popup prompts and lets you manage rules
  environment.systemPackages = lib.mkIf cfg.opensnitch [ pkgs.opensnitch-ui ];

  services.tailscale.enable = true;
}
