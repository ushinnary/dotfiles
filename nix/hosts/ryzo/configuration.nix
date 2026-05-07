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
    gpu.amd.enable = true;
    hardware.amdCpu = true;
    containers.enable = true;
    dev = {
      enable = true;
      editors = [
        "vscode"
        "nixvim"
        "zed"
      ];
      servers = [
        "zed"
        "vscode"
      ];
    };
    apps.davinciResolve = true;
    gaming.enable = false;
    display = {
      refreshRate = 90; # Normal desktop use
      gamingRefreshRate = 144; # Gaming performance
    };
    homelab = {
      enable = true;
      powerManagement.cpuGovernor = "powersave";
    };
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
