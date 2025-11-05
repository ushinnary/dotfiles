{ ... }:
{
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      443
      22
      139
      445
      34445
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
    ];
  };

  networking.firewall.extraCommands = ''iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns'';
}
