{
  ...
}:
{
  # Option declarations moved to modules/options.nix

  imports = [
    ./options.nix
    ./nvidia-gpu.nix
    ./amd-gpu.nix
    ./applications.nix
    ./boot.nix
    ./audio.nix
    ./desktop-environment.nix
    ./dev.nix
    ./firewall.nix
    ./gaming.nix
    ./locale.nix
    ./location.nix
    ./packages.nix
    ./users.nix
    ./virtualisation.nix
    ./power-management.nix
    ./services.nix
    ./security.nix
  ];
}
