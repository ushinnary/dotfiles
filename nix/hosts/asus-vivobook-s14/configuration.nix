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
      device = "/dev/nvme0n1";
      swapSize = "16G";
      isSsd = true;
    })
    # Optional after first successful boot/install:
    ../../modules/secure-boot.nix
    ../../modules/default.nix
    inputs.home-manager.nixosModules.home-manager
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
    desktop.niri = true;
    dev = {
      enable = true;
      editors = [ "zed" ];
    };
    gaming.enable = false;
    containers.enable = false;
    display = {
      refreshRate = 60; # 60Hz OLED screen
      oled = true;
    };
    hardware.hasBattery = true;
    hardware.hasWebCam = true;
    security.howdy.enable = false;
  };

  services.thermald.enable = true;
  powerManagement.cpuFreqGovernor = "ondemand";
  hardware.asus.battery = {
    chargeUpto = 80;
    enableChargeUptoScript = true;
  };

  # Home Manager Setup
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit inputs vars;
    };
    users."${vars.userName}" =
      { lib, config, ... }:
      let
        mkDotfileSymlink =
          relativePath:
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/${relativePath}";
      in
      {
        imports = [ ../../modules/home.nix ];
        xdg.configFile."niri/outputs.kdl".source = lib.mkForce (
          mkDotfileSymlink "niri/.config/niri/hosts/asus-vivobook-s14/outputs.kdl"
        );
        xdg.configFile."niri/binds-custom.kdl".source = lib.mkForce (
          mkDotfileSymlink "niri/.config/niri/hosts/asus-vivobook-s14/binds-custom.kdl"
        );
      };
  };

  system.stateVersion = "25.11";
}
