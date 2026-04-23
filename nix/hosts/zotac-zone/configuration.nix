{
  config,
  pkgs,
  inputs,
  lib,
  vars,
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
    "iomem=relaxed" # Required for ryzenadj (SimpleDeckyTDP) to access SMU registers
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
      user = vars.userName;
      # No desktopSession — "Switch to Desktop" re-enters Gaming Mode
      desktopSession = "gamescope-wayland";
      environment = {
        STEAM_EXTRA_COMPAT_TOOLS_PATHS = compatPaths;
      };
    };
    steamos = {
      enableAutoMountUdevRules = true; # For SD card auto-mount in Steam Library
      enableBluetoothConfig = true;
      enableDefaultCmdlineConfig = true;
      enableSysctlConfig = true;
      enableZram = true;
    };

    devices.steamdeck = {
      enable = true;
      enableControllerUdevRules = true;
      enablePerfControlUdevRules = true;
      enableOsFanControl = true;
      enableDefaultStage1Modules = true;
      enableKernelPatches = true;
      enableSoundSupport = true;
      enableVendorDrivers = false;
    };

    hardware = {
      has.amd.gpu = true;
      amd.gpu.enableEarlyModesetting = true;
      amd.gpu.enableBacklightControl = true;
    };

    decky-loader.enable = true;
  };

  services.handheld-daemon = {
    enable = true;
    user = vars.userName;
    ui.enable = true;
    adjustor.enable = true; # For SimpleDeckyTDP support on AMD CPUs without ryzenadj MSR access
    adjustor.loadAcpiCallModule = true; # Load acpi_call kernel module for TDP control on AMD CPUs without ryzenadj MSR access
  };
  powerManagement = {
    enable = true;
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

  # Sensors for auto-rotation and adaptive brightness
  hardware.sensor.iio.enable = true;

  # ryzenadj for SimpleDeckyTDP TDP control
  environment.systemPackages = [ pkgs.ryzenadj ];
  environment.variables = {
    RYZENADJ_PATH = "${pkgs.ryzenadj}/bin/ryzenadj";
    LOCAL_RYZENADJ = "${pkgs.ryzenadj}/bin/ryzenadj";
  };

  # Add user to hardware groups
  users.users."${vars.userName}".extraGroups = [
    "video"
    "input"
    "audio"
  ];

  # Enable the custom options
  ushinnary = {
    gpu.amd.enable = true;
    hardware.amdCpu = true;
    hardware.hasBattery = true;
    gaming.enable = false;
    containers.enable = false;
    display = {
      oled = true;
      gamingRefreshRate = 120;
    };
  };

  # Home Manager Setup
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit inputs vars;
    };
    users."${vars.userName}" = import ../../modules/home.nix;
  };

  system.stateVersion = "25.11";
}
