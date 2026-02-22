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

  # Handheld Daemon (HHD) rules for Zotac Zone & Performance Tuning Permissions
  services.udev.extraRules = ''
    KERNEL=="hidraw*", ATTRS{idVendor}=="1973", ATTRS{idProduct}=="2000", MODE="0660", TAG+="uaccess"
    KERNEL=="hidraw*", ATTRS{idVendor}=="1973", ATTRS{idProduct}=="2001", MODE="0660", TAG+="uaccess"

    # uinput for handheld-daemon and other tools
    KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput"

    # Allow brightness changes from handheld/game mode sessions
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"

    # Additional HHD rules
    KERNEL=="event*", SUBSYSTEM=="input", TAG+="uaccess"
    KERNEL=="js*", SUBSYSTEM=="input", TAG+="uaccess"

    # This rule is needed for basic functionality of the controller in Steam and keyboard/mouse emulation
    SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0660", TAG+="uaccess"

    # Valve HID devices over USB hidraw
    KERNEL=="hidraw*", ATTRS{idVendor}=="28de", MODE="0660", TAG+="uaccess"
  '';

  networking.hostName = "zotac-zone";
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [
    5385
    5335
  ];

  time.timeZone = "Europe/Paris";
  # Gamescope Auto Boot from TTY (example)
  services = {
    xserver.enable = false; # Assuming no other Xserver needed
    getty.autologinUser = "ushinnary";
    udisks2.enable = true; # Required for SD card mounting support in Steam
    handheld-daemon = {
      enable = true;
      user = "ushinnary";
      adjustor = {
        enable = true;
        loadAcpiCallModule = true;
      };
      ui = {
        enable = true;
      };
    }; # Fixes buttons/gyro for generic handhelds
    # power-profiles-daemon.enable = true; # Better power management
    greetd = {
      enable = true;
      settings = {
        default_session = {
          # Added: -r 120 (120Hz)
          # Fixed: --hdr-itm-enable (was enabled with 'd')
          # Added: --hdr-debug-force-output (fixes some OLED HDR issues)
          # Added: --mangoapp (performance overlay)
          command = "${lib.getExe pkgs.gamescope} -W 1920 -H 1080 -r 120 -f -e --xwayland-count 2 --hdr-enabled --hdr-itm-enable --hdr-debug-force-output --mangoapp -- steam -pipewire-dmabuf -gamepadui -steamdeck -steamos3 > /dev/null 2>&1";
          user = "ushinnary";
        };
      };
    };
  };
  environment.systemPackages = with pkgs; [
    gamescope-wsi # HDR won't work without this
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
    amd.enable = true;
    cpu.isAmd = true;
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

  # services.fprintd.enable = true;
  # services.fprintd.tod.enable = true;
  # services.fprintd.tod.driver = pkgs.libfprint-2-tod1-elan; # Elan(04f3:0c4b) driver
  # security.pam.services.sudo.fprintAuth = true; # PAM for sudo fingerprint

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
