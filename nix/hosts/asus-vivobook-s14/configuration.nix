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
    (import ../../modules/hardware/disko-luks-btrfs.nix {
      device = "/dev/nvme0n1";
      swapSize = "16G";
      isSsd = true;
    })
    # Optional after first successful boot/install:
    ../../modules/hardware/secure-boot.nix
    ../../modules/default.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  # Bootloader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0; # Skip boot menu for faster boot

  # networking.hostName = "asus-vivobook-s14-m5406n";
  networking.hostName = "asus-vivobook-s14";

  time.timeZone = "Europe/Paris"; # Change this to your timezone
  # Locale is set via modules/locale.nix

  # Enable the custom options
  ushinnary = {
    gpu.amd.enable = true;
    hardware.amdCpu = true;
    hardware.secureBoot = true;
    desktop.niri = true;
    dev = {
      enable = true;
      editors = [
        "helix"
      ];
      aiAgents = true;
    };
    gaming.enable = false;
    # containers.enable = true;
    display = {
      refreshRate = 60; # 60Hz OLED screen
      oled = true;
    };
    hardware.hasBattery = true;
    hardware.hasWebCam = true;
    security.howdy.enable = false;
  };

  hardware.asus.battery = {
    chargeUpto = 80;
    enableChargeUptoScript = true;
  };

  # Home Manager Setup
  home-manager.users."${vars.userName}" =
    { lib, mkDotfileSymlink, ... }:
    {
      xdg.configFile = {
        "niri-overrides" = {
          source = lib.mkForce (mkDotfileSymlink "niri/.config/niri/hosts/asus-vivobook-s14");
          recursive = true;
        };
      };
    };

  system.stateVersion = "25.11";
}
