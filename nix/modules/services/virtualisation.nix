{
  config,
  pkgs,
  lib,
  vars,
  ...
}:
let
  containersCfg = config.ushinnary.containers;
  vmHostCfg = config.ushinnary.virtualisation.host;
in
{
  options.ushinnary.virtualisation.host.enable = lib.mkEnableOption "host virtualization stack for running VMs (VirtualBox)";
  options.ushinnary.containers = {
    enable = lib.mkEnableOption "Enable Podman container runtime";
    distrobox = lib.mkEnableOption "Enable distrobox";
  };

  config = lib.mkMerge [
    (lib.mkIf containersCfg.enable {
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

      environment.systemPackages =
        with pkgs;
        [
          podman-compose
        ]
        ++ lib.optional containersCfg.distrobox distrobox;
    })
    (lib.mkIf vmHostCfg.enable {
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
