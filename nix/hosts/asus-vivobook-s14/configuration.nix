{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/default.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Bootloader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0; # Skip boot menu for faster boot

  networking.hostName = "asus-vivobook-s14-m5406n";

  time.timeZone = "Europe/Paris"; # Change this to your timezone
  # Locale is set via modules/locale.nix

  # Enable the custom options
  ushinnary = {
    gpu.amd.enable = true;
    hardware.amdCpu = true;
    desktop.gnome = true;
    dev.enable = true;
    gaming.enable = false;
    containers.enable = false;
    display = {
      refreshRate = 60; # 60Hz OLED screen
      oled = true;
    };
    power.enable = true;
    security.howdy.enable = true;
  };

  # Asus specific configurations
  services.asusd = {
    enable = true;
    enableUserService = true;
  };
  hardware.asus.battery.chargeUpto = 80;

  # Home Manager Setup
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs; };
    users.ushinnary = import ../../modules/home.nix;
  };

  system.stateVersion = "25.11";
}
