{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
let
  compatPaths = lib.makeSearchPathOutput "steamcompattool" "" (with pkgs; [ proton-ge-bin ]);
in
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
    "msr" # Kept for low-level MSR access (not the TDP path on Zotac Zone)
  ];

  boot.kernelParams = [
    "amdgpu.ppfeaturemask=0xffffffff"
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
      environment = {
        STEAM_EXTRA_COMPAT_TOOLS_PATHS = compatPaths;
      };
    };
    steamos = {
      enableAutoMountUdevRules = true; # For SD card auto-mount in Steam Library
    };

    # AMD GPU: early KMS + backlight brightness control from Steam UI
    hardware.has.amd.gpu = true;
    hardware.amd.gpu.enableEarlyModesetting = true;
    devices.steamdeck.enablePerfControlUdevRules = false;

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

  services.udev.packages = [ pkgs.iio-sensor-proxy ];

  services.udev.extraRules = ''
    # Set Zotac Zone platform-profile to "custom" on driver probe so that the
    # firmware-attributes TDP attributes (ppt_pl1_spl / ppt_pl2_sppt /
    # ppt_pl3_fppt) become writable.  steamos-manager then manages the profile
    # dynamically; this just ensures it starts in a state where TDP is tunable.
    ACTION=="add|change", SUBSYSTEM=="platform-profile", KERNELS=="platform-profile-0", ATTRS{name}=="zotac_zone_platform", RUN+="/bin/sh -c 'echo custom > /sys/class/platform-profile/platform-profile-0/profile'"
  '';

  # Sensors for auto-rotation and adaptive brightness
  hardware.sensor.iio.enable = true;

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
