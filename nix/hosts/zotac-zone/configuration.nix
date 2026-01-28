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

  # Use latest kernel for best hardware support on Zotac Zone
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Kernel parameters optimized for Zotac Zone OLED handheld
  boot.kernelParams = [
    # AMD GPU optimizations
    "amdgpu.ppfeaturemask=0xffffffff"  # Enable all power features
    "amdgpu.dcdebugmask=0x10"          # Disable PSR for OLED stability
    "amdgpu.sg_display=0"              # Disable scatter/gather for stability
    # Power management
    "amd_pstate=active"                # Use AMD P-State EPP driver
    # General optimizations
    "nowatchdog"                        # Disable watchdog for power savings
    "nmi_watchdog=0"
    "quiet"
    "splash"
    "loglevel=3"
  ];

  # Zephyrus kernel modules for better hardware support
  boot.initrd.kernelModules = [ "amdgpu" ];

  networking.hostName = "zotac-zone";
  networking.networkmanager.enable = true;
  # Enable WiFi power management
  networking.networkmanager.wifi.powersave = true;

  time.timeZone = "Europe/Paris";

  # Enable the custom options for Zotac Zone (Steam Deck-like experience)
  ushinnary = {
    amd.enable = true;
    handheld = {
      enable = true;
      oledScreen = true;
      refreshRate = 120;
    };
    gaming.enable = true;
    cpu.isAmd = true;
  };

  # Home Manager Setup
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.ushinnary = import ../../modules/home.nix;
  };

  # Auto-login for console gaming experience
  services.getty.autologinUser = "ushinnary";

  # Power management optimizations for handheld
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      # CPU settings for AMD Ryzen 7 8840U
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      # Platform profile
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      # GPU power management
      RADEON_DPM_STATE_ON_AC = "performance";
      RADEON_DPM_STATE_ON_BAT = "battery";

      # USB autosuspend
      USB_AUTOSUSPEND = 1;

      # WiFi power saving
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";

      # Runtime PM
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";
    };
  };

  # Thermald for thermal management
  services.thermald.enable = true;

  # UPower for battery management
  services.upower = {
    enable = true;
    criticalPowerAction = "Hibernate";
    percentageCritical = 5;
    percentageLow = 15;
  };

  # Bluetooth for controllers
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        FastConnectable = true;
        JustWorksRepairing = "always";
        Privacy = "device";
      };
    };
  };

  # Enable fwupd for firmware updates
  services.fwupd.enable = true;

  system.stateVersion = "25.11";
}
