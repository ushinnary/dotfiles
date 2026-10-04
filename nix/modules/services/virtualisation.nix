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
  options.ushinnary.virtualisation.host.enable =
    lib.mkEnableOption "host virtualization stack for running VMs (VirtualBox)";
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

      # Deliberately not in the "podman" group: it grants access to the
      # rootful /run/podman/podman.sock, i.e. root. Rootless podman
      # doesn't need it; for a docker-style socket use the user unit
      # (`systemctl --user enable --now podman.socket`).

      # Podman's own daily timer (ships with the package) instead of a
      # boot-time run, so it doesn't depend on network-online at boot.
      systemd.timers.podman-auto-update.wantedBy = [ "timers.target" ];

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
