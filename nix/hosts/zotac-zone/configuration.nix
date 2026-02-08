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
    handheld-daemon = {
      enable = true; 
      user = "ushinnary";
    }; # Fixes buttons/gyro for generic handhelds
    greetd = {
      enable = true;
      settings = {
        default_session = {
          # Added: -r 120 (120Hz)
          # Fixed: --hdr-itm-enable (was enabled with 'd')
          # Added: --hdr-debug-force-output (fixes some OLED HDR issues)
          command = "${lib.getExe pkgs.gamescope} -W 1920 -H 1080 -r 120 -f -e --xwayland-count 2 --hdr-enabled --hdr-itm-enable --hdr-debug-force-output -- steam -pipewire-dmabuf -gamepadui -steamdeck > /dev/null 2>&1";
          user = "ushinnary";
        };
      };
    };
  };
  environment.systemPackages = with pkgs; [
    gamescope-wsi # HDR won't work without this
    brightnessctl # For brightness control
  ];
  programs.steam.extraCompatPackages = with pkgs; [
    proton-ge-bin
  ];

  # Enable uinput for handheld-daemon to create virtual controllers
  hardware.uinput.enable = true;

  # Add user to hardware groups
  users.users.ushinnary.extraGroups = [
    "video"
    "input"
  ];

  # Enable the custom options
  ushinnary = {
    amd.enable = true;
    gaming.enable = true;
    screen = {
      isOled = true;
      gamingRefreshRate = 120;
    };
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
