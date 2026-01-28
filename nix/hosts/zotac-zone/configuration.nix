{
  config,
  pkgs,
  inputs,
  ...
}:

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

  # Jovian-NixOS Configuration for Zotac Zone
  jovian = {
    # Enable Steam Deck-like experience
    steam.enable = true;
    steam.autoStart = true;
    steam.user = "ushinnary";
    steam.desktopSession = "gamescope-wayland"; # Keep gaming mode behavior

    # Enable Decky Loader with built-in support
    decky-loader.enable = true;
    decky-loader.user = "ushinnary";

    # Steam Deck device configuration (works well for Zotac Zone)
    devices.steamdeck.enable = true;

    # AMD GPU support
    hardware.amd.gpu.enableEarlyModesetting = true;

    # SteamOS-like configuration
    steamos.useSteamOSConfig = true;
  };

  # XDG Desktop Portals (required for Flatpak)
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # Home Manager Setup
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.ushinnary = import ../../modules/home.nix;
  };

  system.stateVersion = "25.11";
}
