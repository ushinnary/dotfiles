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
  ];

  # Handheld Daemon (HHD) rules for Zotac Zone & Performance Tuning Permissions
  services.udev.extraRules = ''
    KERNEL=="hidraw*", ATTRS{idVendor}=="1973", ATTRS{idProduct}=="2000", MODE="0660", TAG+="uaccess"
    KERNEL=="hidraw*", ATTRS{idVendor}=="1973", ATTRS{idProduct}=="2001", MODE="0660", TAG+="uaccess"

    # uinput for handheld-daemon and other tools
    KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput"

    # Enable brightness control for everyone (fixes slider in Steam)
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"

    # AMDGPU Performance Control (TDP/Clocks) - Allows TDP control in Steam/HHD
    ACTION=="add", SUBSYSTEM=="pci", DRIVER=="amdgpu", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/%p/power_dpm_force_performance_level /sys/%p/pp_od_clk_voltage"
    ACTION=="add", SUBSYSTEM=="hwmon", ATTR{name}=="amdgpu", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/%p/power1_cap /sys/%p/power2_cap"

    # Additional HHD rules
    KERNEL=="event*", SUBSYSTEM=="input", TAG+="uaccess"
    KERNEL=="js*", SUBSYSTEM=="input", TAG+="uaccess"
  '';

  networking.hostName = "zotac-zone";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Paris";
  # Gamescope Auto Boot from TTY (example)
  services = {
    xserver.enable = false; # Assuming no other Xserver needed
    getty.autologinUser = "ushinnary";
    udisks2.enable = true; # Required for SD card mounting support in Steam
    handheld-daemon = {
      enable = true; 
      user = "ushinnary";
      ui.enable = true;
      adjustor = {
        enable = true;
        loadAcpiCallModule = true;
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
    # Input Plumber for proper volume button handling
    inputplumber = {
      enable = true;
    };
  };
  # Systemd service for Input Plumber (volume button handling)
  systemd.services.inputplumber = {
    description = "Input Plumber daemon for input remapping";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.inputplumber}/bin/inputplumber";
      User = "ushinnary";
      Restart = "always";
    };
  };
  environment.systemPackages = with pkgs; [
    gamescope-wsi # HDR won't work without this
    brightnessctl # For brightness control
    mangohud # Performance overlay
    inputplumber # Input remapping for volume buttons
    # Required for HHD UI
    python3
    python3Packages.pygame
    python3Packages.evdev
    # For better device detection
    usbutils
    pciutils
  ];
  programs.steam.extraCompatPackages = with pkgs; [
    proton-ge-bin
  ];

  # Enable uinput for handheld-daemon to create virtual controllers
  hardware.uinput.enable = true;

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
