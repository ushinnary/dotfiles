{
  vars,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Btrfs layout without LUKS for this host:
    (import ../../modules/hardware/disko-luks-btrfs.nix {
      device = "/dev/nvme0n1";
      swapSize = "0G";
      isSsd = true;
      luks = false;
    })
    ../../modules/default.nix
  ];

  # Bootloader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0; # Skip boot menu for faster boot

  # Performance
  boot.kernelParams = [
    "amdgpu.ppfeaturemask=0xffffffff"
  ];

  environment.variables = {
    RADV_PERFTEST = lib.mkForce "gpl,sam";
  };

  networking.hostName = "ryzo";

  # Undervolt
  services.lact.enable = true;
  services.geoclue2.enableWifi = false;
  environment.systemPackages = [
    pkgs.lact
  ];

  time.timeZone = "Europe/Paris";

  # Enable the custom options
  ushinnary = {
    gpu.amd = {
      enable = true;
      rocm = true;
      rocmOverrideGfx = "10.3.0";
    };
    hardware.amdCpu = true;
    containers.enable = true;
    firewall.trustPhysicalInterfaces = true;
    desktop.niri = true;
    dev = {
      enable = true;
      editors = [
        "nixvim"
        "zed"
      ];
      servers = [ "zed" ];
      aiAgents = true;
    };
    gaming.enable = true;
  };

  # Home Manager Setup
  home-manager.users."${vars.userName}" =
    { lib, mkDotfileSymlink, ... }:
    {
      xdg.configFile = {
        "niri-overrides" = {
          source = lib.mkForce (mkDotfileSymlink "niri/.config/niri/hosts/ryzo");
          recursive = true;
        };
      };
    };

  system.stateVersion = "25.11";
}
