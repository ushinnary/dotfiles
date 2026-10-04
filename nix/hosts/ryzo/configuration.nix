{
  vars,
  pkgs,
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

  # Performance
  boot.kernelParams = [
    "amdgpu.ppfeaturemask=0xffffffff"
  ];

  networking.hostName = "ryzo";

  # Undervolt
  services.lact.enable = true;
  services.geoclue2.enableWifi = false;
  environment.systemPackages = [
    pkgs.lact
  ];

  # Enable the custom options
  ushinnary = {
    gpu.amd = {
      enable = true;
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

  # Gamescope session starts at the panel's 144 Hz mode; niri keeps its
  # own 85 Hz (niri/.config/niri/hosts/ryzo/outputs.kdl). Gamescope needs
  # an exact WxH@Hz match and falls back to the preferred mode otherwise.
  programs.steam.gamescopeSession.args = [
    "-W"
    "2560"
    "-H"
    "1600"
    "-r"
    "144"
  ];

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
