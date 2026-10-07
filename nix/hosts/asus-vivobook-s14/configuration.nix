{vars, ...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # LUKS-encrypted Btrfs layout:
    (import ../../modules/hardware/disko-luks-btrfs.nix {
      device = "/dev/nvme0n1";
      swapSize = "16G";
      isSsd = true;
    })
    ../../modules/default.nix
  ];

  # networking.hostName = "asus-vivobook-s14-m5406n";
  networking.hostName = "asus-vivobook-s14";

  # Time zone defaults to Europe/Paris (modules/core); locale is set via
  # modules/system/locale.nix

  # Enable the custom options
  ushinnary = {
    gpu.amd.enable = true;
    hardware.amdCpu = true;
    hardware.secureBoot = true;
    desktop.niri = true;
    dev = {
      enable = true;
      editors = [
        "nixvim"
      ];
      aiAgents = true;
    };
    gaming.enable = false;
    # containers.enable = true;
    display.oled = true;
    hardware.hasWebCam = true;
    security.howdy.enable = false;
  };

  hardware.asus.battery = {
    chargeUpto = 80;
    enableChargeUptoScript = true;
  };

  # Home Manager Setup
  home-manager.users."${vars.userName}" = {
    lib,
    mkDotfileSymlink,
    ...
  }: {
    xdg.configFile = {
      "niri-overrides" = {
        source = lib.mkForce (mkDotfileSymlink "niri/.config/niri/hosts/asus-vivobook-s14");
        recursive = true;
      };
    };
  };

  system.stateVersion = "25.11";
}
