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
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0; # Skip boot menu for faster boot

  # Early input support (Touchscreen, Gamepad)
  boot.initrd.kernelModules = [
    "hid-generic"
    "hid-multitouch"
    "i2c-designware-core"
    "i2c-designware-platform"
    "i2c-hid-acpi"
    "usbhid"
    "i2c-dev"
    "i2c-i801"
    "msr" # Required for ryzenadj TDP control
  ];

  networking.hostName = "zotac-zone";
  networking.firewall.allowedTCPPorts = [
    5385
    5335
  ];

  time.timeZone = "Europe/Paris";

  # ═══════════════════════════════════════════════════════════════
  #  Jovian NixOS — SteamOS-like experience
  # ═══════════════════════════════════════════════════════════════
  jovian = {
    steam = {
      enable = true;
      autoStart = true;
      user = "ushinnary";
      # No desktopSession — "Switch to Desktop" re-enters Gaming Mode
      desktopSession = "gamescope-wayland";
    };

    # AMD GPU: early KMS + backlight brightness control from Steam UI
    hardware.has.amd.gpu = true;

    decky-loader.enable = true;
  };

  # steamos-manager crashes on non-Deck hardware (missing sysfs paths).
  # Prevent it from blocking the entire gamescope session startup.
  systemd.user.services.steamos-manager = {
    overrideStrategy = "asDropin";
    serviceConfig.Restart = lib.mkForce "on-failure";
    serviceConfig.RestartSec = "5s";
  };
  # jovian-setup-desktop-session calls steamosctl which needs steamos-manager.
  # If it fails, don't block graphical-session.target.
  systemd.user.services.jovian-setup-desktop-session = {
    overrideStrategy = "asDropin";
    serviceConfig.TimeoutStartSec = "10s";
  };

  # SDDM (required by Jovian autoStart) — X11 backend for the login greeter,
  # gamescope-wayland session takes over immediately after autologin
  services.xserver.enable = true;

  # Use latest kernel & Mesa — NOT Valve's pinned/forked versions
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;

  # ═══════════════════════════════════════════════════════════════
  #  Handheld-specific tweaks
  # ═══════════════════════════════════════════════════════════════

  # Handheld Daemon (HHD) for Zotac Zone controller/gyro support
  services.handheld-daemon = {
    enable = true;
    user = "ushinnary";
    adjustor = {
      enable = true;
      loadAcpiCallModule = true;
    };
    ui.enable = true;
  };

  services.udisks2.enable = true; # Required for SD card mounting in Steam

  environment.systemPackages = with pkgs; [
    brightnessctl # For brightness control
    iio-sensor-proxy # Ambient light sensor support
    pamixer # Reliable volume adjustment backend for button handlers
    wireplumber # Provides wpctl used by handheld volume integrations
    alsa-utils # amixer fallback for some handheld tooling
    mangohud # Performance overlay
  ];

  services.udev.packages = [ pkgs.iio-sensor-proxy ];
  programs.steam.extraCompatPackages = with pkgs; [
    proton-ge-bin
  ];

  # Sensors for auto-rotation and adaptive brightness
  hardware.sensor.iio.enable = true;

  # Ensure SD card permissions
  systemd.tmpfiles.rules = [
    "d /mnt/sdcard 0770 ushinnary users -"
  ];

  # Force SD Card to be visible as mmcblk0p1 if it's not mounting automatically in Steam
  environment.variables.STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/mnt/sdcard";

  # Add user to hardware groups
  users.users.ushinnary.extraGroups = [
    "video"
    "input"
    "audio"
  ];

  # Enable the custom options
  ushinnary = {
    firewall.opensnitch = false; # No desktop for popup prompts in Gaming Mode
    amd.enable = true;
    cpu.isAmd = true;
    gaming.enable = true;
    screen = {
      isOled = true;
      gamingRefreshRate = 120;
    };
    powerManagement.rust = {
      enable = true;
    };
  };

  # Home Manager Setup
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs; };
    users.ushinnary = import ../../modules/home.nix;
  };

  system.stateVersion = "25.11";
}
