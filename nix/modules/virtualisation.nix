{ pkgs, ... }:
{
  virtualisation = {
    containers.enable = true;
    oci-containers.backend = "podman";
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
    };
  };

  users.users.ushinnary.extraGroups = ["podman"];

  environment.systemPackages = with pkgs; [
    podman-compose
  ];

}
