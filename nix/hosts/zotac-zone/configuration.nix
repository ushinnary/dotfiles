{
  config,
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
    steamos = {
      enableAutoMountUdevRules = true; # For SD card auto-mount in Steam Library
    };

    # AMD GPU: early KMS + backlight brightness control from Steam UI
    hardware.has.amd.gpu = true;
    hardware.amd.gpu.enableEarlyModesetting = true;
    devices.steamdeck.enablePerfControlUdevRules = true;

    # decky-loader.enable = true;
  };

  # ── Fix non-Steam Deck boot hangs ──────────────────────────────
  # steamos-manager crashes on Zotac Zone (missing TDP sysfs paths)
  # and jovian-setup-desktop-session hangs waiting on it via D-Bus.
  # Keep services enabled, but bound startup time so they don't block sessions.
  systemd.user.services.jovian-setup-desktop-session = {
    overrideStrategy = "asDropin";
    serviceConfig.TimeoutStartSec = lib.mkForce "10s";
  };
  systemd.user.services.steamos-manager = {
    overrideStrategy = "asDropin";
    serviceConfig = {
      TimeoutStartSec = lib.mkForce "10s";
      TimeoutStopSec = lib.mkForce "10s";
    };
  };

  # Decky requires Steam CEF remote debugging to show up in Gaming Mode UI.
  # Jovian intentionally doesn't toggle this automatically.
  systemd.services.steam-cef-debug = lib.mkIf config.jovian.decky-loader.enable {
    description = "Enable Steam CEF remote debugging for Decky";
    wantedBy = [ "multi-user.target" ];
    before = [ "decky-loader.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart =
        let
          steamUser = config.jovian.steam.user;
        in
        "${pkgs.util-linux}/bin/runuser -u ${steamUser} -- ${pkgs.bash}/bin/bash -lc 'mkdir -p ~/.steam/steam && touch ~/.steam/steam/.cef-enable-remote-debugging'";
    };
  };

  # SDDM (required by Jovian autoStart) — X11 backend for the login greeter,
  # gamescope-wayland session takes over immediately after autologin
  services.displayManager.sddm.wayland.enable = true;

  # Use Jovian kernel on Zotac Zone to get handheld-specific platform support
  # (including Zotac Zone drivers that can expose extra power/TDP interfaces).
  boot.kernelPackages = pkgs.linuxPackages_jovian;

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
    gpu.amd.enable = true;
    hardware.amdCpu = true;
    gaming.enable = false;
    display = {
      oled = true;
      gamingRefreshRate = 120;
    };
    # Disable custom System76 power stack on this host while using Jovian SteamOS stack.
    power.enable = false;
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
