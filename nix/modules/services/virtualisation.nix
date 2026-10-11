{
  config,
  pkgs,
  lib,
  vars,
  ...
}: let
  containersCfg = config.ushinnary.containers;
  vmHostCfg = config.ushinnary.virtualisation.host;
in {
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
        # Container stdout goes to a per-container file (`podman logs` still
        # works) instead of journald, where one chatty dev container pushed
        # system logs out of the 1G journal. Truncated past 10 MiB.
        # Existing containers keep their driver until recreated.
        containers.containersConf.settings.containers = {
          log_driver = "k8s-file";
          log_size_max = 10 * 1024 * 1024;
        };
        oci-containers.backend = "podman";
        podman = {
          enable = true;
          dockerCompat = true;
          defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
        };
      };

      # Deliberately not in the "podman" group: it grants access to the
      # rootful /run/podman/podman.sock, i.e. root. Rootless podman
      # doesn't need it; docker-style clients use the user socket instead,
      # which the podman module already enables for every user.
      environment.variables.DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/podman/podman.sock";

      # Podman's own daily timer (ships with the package) instead of a
      # boot-time run, so it doesn't depend on network-online at boot.
      systemd.timers.podman-auto-update.wantedBy = ["timers.target"];

      environment.systemPackages = with pkgs;
        [
          podman-compose
        ]
        ++ lib.optional containersCfg.distrobox distrobox;
    })
    (lib.mkIf vmHostCfg.enable {
      virtualisation.libvirtd.enable = true;
      programs.virt-manager.enable = true;
      users.users."${vars.userName}".extraGroups = ["libvirtd"];
      environment.systemPackages = with pkgs; [
        dnsmasq
      ];
      networking.firewall.trustedInterfaces = ["virbr0"];
    })
  ];
}
