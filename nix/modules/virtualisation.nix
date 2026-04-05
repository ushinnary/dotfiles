{
  config,
  pkgs,
  lib,
  vars,
  ...
}:
with lib;
let
  cfg = config.ushinnary.containers;
in
{
  config = mkIf cfg.enable {
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
  };
}
