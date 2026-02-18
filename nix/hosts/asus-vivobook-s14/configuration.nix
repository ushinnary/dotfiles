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
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0; # Skip boot menu for faster boot

  networking.hostName = "asus-vivobook-s14";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Paris"; # Change this to your timezone
  # Locale is set via modules/locale.nix

  # Enable the custom options
  ushinnary = {
    amd.enable = true;
    cpu.isAmd = true;
    desktopEnvironment.gnome = true;
    software.enableDevPackages = true;
    gaming.enable = false;
    virtualisation.enable = false;
    screen = {
      refreshRate = 60; # 60Hz OLED screen
      isOled = true;
    };
    powerManagement.tuned = {
      enable = true;
      profile = "ryzen-mobile";
    };
  };

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
