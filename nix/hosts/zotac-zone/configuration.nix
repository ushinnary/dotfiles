{
  pkgs,
  inputs,
  lib,
  ...
}:
with lib;
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/default.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Bootloader - optimized for fast boot on handheld
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0; # Skip boot menu for faster boot

  networking.hostName = "zotac-zone";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Paris";
  # Gamescope Auto Boot from TTY (example)
services = {
  xserver.enable = false; # Assuming no other Xserver needed
  getty.autologinUser = "ushinnary";
  greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${lib.getExe pkgs.gamescope} -W 1920 -H 1080 -f -e --xwayland-count 2 --hdr-enabled --hdr-itm-enabled -- steam -pipewire-dmabuf -gamepadui -steamdeck > /dev/null 2>&1";
        user = "ushinnary";
      };
    };
  };
};
environment.systemPackages = with pkgs; [
  gamescope-wsi # HDR won't work without this
];
programs.steam.extraCompatPackages = with pkgs; [
  proton-ge-bin
];

  # Enable the custom options
  ushinnary = {
    amd.enable = true;
    gaming.enable = true;
    powerManagement.tuned = {
      enable = true;
      profile = "ryzen-desktop";
    };
  };

  # Home Manager Setup
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.ushinnary = import ../../modules/home.nix;
  };

  system.stateVersion = "25.11";
}
