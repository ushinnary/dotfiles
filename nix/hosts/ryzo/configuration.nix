{
  inputs,
  vars,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Full disk encryption with LUKS and BTRFS:
    (import ../../modules/disko-luks-btrfs.nix {
      device = "/dev/nvme0n1";
      swapSize = "0G";
      isSsd = true;
      luks = false;
    })
    ../../modules/default.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  # Bootloader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0; # Skip boot menu for faster boot

  networking.hostName = "ryzo";

  time.timeZone = "Europe/Paris";

  # Enable the custom options
  ushinnary = {
    gpu.amd = {
      enable = true;
      rocm = true;
      rocmOverrideGfx = "10.3.0";
    };
    hardware.amdCpu = true;
    desktop.niri = true;
    containers.enable = true;
    display = {
      refreshRate = 90;
    };
    dev = {
      enable = true;
      editors = [
        "nixvim"
        "zed"
      ];
      servers = [
        "zed"
        "vscode"
      ];
      aiAgents = true;
    };
    gaming.enable = false;
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
