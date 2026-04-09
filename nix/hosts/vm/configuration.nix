{
  inputs,
  vars,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Optional, once ready for a full disk encryption setup with LUKS and BTRFS:
    (import ../../modules/disko-luks-btrfs.nix {
      # VirtualBox default disk path for the guest
      device = "/dev/vda";
      swapSize = "2G";
      isSsd = false;
    })
    ../../modules/default.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  # Bootloader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0; # Skip boot menu for faster boot

  networking.hostName = "vm";

  time.timeZone = "Europe/Paris"; # Change this to your timezone
  # Locale is set via modules/locale.nix

  # Enable the custom options
  ushinnary = {
    gpu.amd.enable = false;
    hardware.amdCpu = false;
    desktop.niri = true;
    dev.enable = false;
    gaming.enable = false;
    containers.enable = false;
    display = {
      refreshRate = 60;
      oled = false;
    };
    hardware.hasBattery = false;
    hardware.hasWebCam = false;
    security.howdy.enable = false;
  };

  # Home Manager Setup
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit inputs vars;
    };
    users."${vars.userName}" = import ../../modules/home.nix;
  };

  system.stateVersion = "25.11";
}
