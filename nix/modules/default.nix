{
  ...
}:
{
  # Option declarations moved to modules/options.nix

  imports = [
    ./system/boot.nix
    ./system/locale.nix
    ./system/location.nix
    ./system/users.nix
    ./system/security.nix
    ./system/firewall.nix
    ./system/packages.nix
    ./hardware/nvidia-gpu.nix
    ./hardware/amd-gpu.nix
    ./hardware/secure-boot.nix
    ./hardware/disko-extra-drives.nix
    ./hardware/disko-luks-btrfs.nix
    ./desktop/desktop-environment.nix
    ./desktop/audio.nix
    ./services/services.nix
    ./services/homelab.nix
    ./services/virtualisation.nix
    ./apps/applications.nix
    ./apps/gaming.nix
    ./apps/dev.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  hardware.enableRedistributableFirmware = true;
}
