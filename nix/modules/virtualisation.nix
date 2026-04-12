{
  config,
  pkgs,
  lib,
  vars,
  ...
}:
with lib;
let
  containersCfg = config.ushinnary.containers;
  vmHostCfg = config.ushinnary.virtualisation.host;
in
{
  config = mkMerge [
    (mkIf containersCfg.enable {
      virtualisation = {
        containers.enable = true;
        oci-containers.backend = "podman";
        podman = {
          enable = true;
          dockerCompat = true;
          defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
        };
      };

      users.users."${vars.userName}".extraGroups = [ "podman" ];

      systemd.services.podman-auto-update-boot = {
        description = "Auto-update Podman containers on boot";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.podman}/bin/podman auto-update";
          RemainAfterExit = false;
        };
      };

      environment.systemPackages = with pkgs; [
        podman-compose
      ];
    })
    (mkIf vmHostCfg.enable {
      virtualisation.libvirtd.enable = true;
      programs.virt-manager.enable = true;
      users.users."${vars.userName}".extraGroups = [ "libvirtd" ];
      environment.systemPackages = with pkgs; [
        dnsmasq
      ];
      networking.firewall.trustedInterfaces = [ "virbr0" ];
    })
  ];
}
