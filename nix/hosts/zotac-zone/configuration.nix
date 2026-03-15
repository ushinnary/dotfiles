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
    "msr" # Required for ryzenadj / steamos-manager TDP control
  ];

  # ── Phoenix APU power management ─────────────────────────────
  # ppfeaturemask=0xffffffff: instructs the amdgpu driver to enable all
  # power-play features, which causes it to create power1_cap (fast PPT)
  # and power2_cap (slow PPT) under /sys/class/hwmon/hwmon*/.
  # Without this flag those sysfs files never appear on Phoenix (Ryzen Z1),
  # steamos-manager crashes looking for them, and TDP control is unavailable.
  # The existing enablePerfControlUdevRules already chmod a+w those files;
  # this flag makes the files exist in the first place.
  #
  # amd_pstate=active: enables the AMD P-State EPP driver for Phoenix so
  # the CPU scales frequency/voltage via hardware firmware hints (HWP),
  # improving efficiency across the idle→boost curve.
  boot.kernelParams = [
    "amdgpu.ppfeaturemask=0xffffffff"
    "amd_pstate=active"
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

    decky-loader.enable = true;
  };

  services.handheld-daemon = {
    enable = true;
    user = "ushinnary";
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

  # ═══════════════════════════════════════════════════════════════
  #  Handheld-specific tweaks
  # ═══════════════════════════════════════════════════════════════

  services.udisks2.enable = true; # Required for SD card mounting in Steam

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
