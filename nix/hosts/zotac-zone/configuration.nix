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

  services.inputplumber.enable = true;

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

    # Keep the dedicated Steam/QAM buttons in Steam mode so the Home/QAM actions
    # are emitted as Steam-style guide chords instead of raw F-keys.
    ACTION=="add|change", SUBSYSTEM=="hidraw", KERNEL=="hidraw*", ATTRS{idProduct}=="1590", ATTRS{bInterfaceNumber}=="03", ATTR{qam_mode}=="?*", ATTR{qam_mode}="1"

    # Face buttons
    ACTION=="add|change", SUBSYSTEM=="hidraw", KERNEL=="hidraw*", ATTRS{idProduct}=="1590", ATTRS{bInterfaceNumber}=="03", ATTR{btn_a/remap/gamepad}=="?*", ATTR{btn_a/remap/gamepad}="a", ATTR{btn_a/remap/modifier}="none", ATTR{btn_a/remap/keyboard}="none", ATTR{btn_a/remap/mouse}="none"
    ACTION=="add|change", SUBSYSTEM=="hidraw", KERNEL=="hidraw*", ATTRS{idProduct}=="1590", ATTRS{bInterfaceNumber}=="03", ATTR{btn_b/remap/gamepad}=="?*", ATTR{btn_b/remap/gamepad}="b", ATTR{btn_b/remap/modifier}="none", ATTR{btn_b/remap/keyboard}="none", ATTR{btn_b/remap/mouse}="none"
    ACTION=="add|change", SUBSYSTEM=="hidraw", KERNEL=="hidraw*", ATTRS{idProduct}=="1590", ATTRS{bInterfaceNumber}=="03", ATTR{btn_x/remap/gamepad}=="?*", ATTR{btn_x/remap/gamepad}="x", ATTR{btn_x/remap/modifier}="none", ATTR{btn_x/remap/keyboard}="none", ATTR{btn_x/remap/mouse}="none"
    ACTION=="add|change", SUBSYSTEM=="hidraw", KERNEL=="hidraw*", ATTRS{idProduct}=="1590", ATTRS{bInterfaceNumber}=="03", ATTR{btn_y/remap/gamepad}=="?*", ATTR{btn_y/remap/gamepad}="y", ATTR{btn_y/remap/modifier}="none", ATTR{btn_y/remap/keyboard}="none", ATTR{btn_y/remap/mouse}="none"

    # Bumpers, triggers, and stick clicks
    ACTION=="add|change", SUBSYSTEM=="hidraw", KERNEL=="hidraw*", ATTRS{idProduct}=="1590", ATTRS{bInterfaceNumber}=="03", ATTR{btn_lb/remap/gamepad}=="?*", ATTR{btn_lb/remap/gamepad}="lb", ATTR{btn_lb/remap/modifier}="none", ATTR{btn_lb/remap/keyboard}="none", ATTR{btn_lb/remap/mouse}="none"
    ACTION=="add|change", SUBSYSTEM=="hidraw", KERNEL=="hidraw*", ATTRS{idProduct}=="1590", ATTRS{bInterfaceNumber}=="03", ATTR{btn_rb/remap/gamepad}=="?*", ATTR{btn_rb/remap/gamepad}="rb", ATTR{btn_rb/remap/modifier}="none", ATTR{btn_rb/remap/keyboard}="none", ATTR{btn_rb/remap/mouse}="none"
    ACTION=="add|change", SUBSYSTEM=="hidraw", KERNEL=="hidraw*", ATTRS{idProduct}=="1590", ATTRS{bInterfaceNumber}=="03", ATTR{btn_lt/remap/gamepad}=="?*", ATTR{btn_lt/remap/gamepad}="lt", ATTR{btn_lt/remap/modifier}="none", ATTR{btn_lt/remap/keyboard}="none", ATTR{btn_lt/remap/mouse}="none"
    ACTION=="add|change", SUBSYSTEM=="hidraw", KERNEL=="hidraw*", ATTRS{idProduct}=="1590", ATTRS{bInterfaceNumber}=="03", ATTR{btn_rt/remap/gamepad}=="?*", ATTR{btn_rt/remap/gamepad}="rt", ATTR{btn_rt/remap/modifier}="none", ATTR{btn_rt/remap/keyboard}="none", ATTR{btn_rt/remap/mouse}="none"
    ACTION=="add|change", SUBSYSTEM=="hidraw", KERNEL=="hidraw*", ATTRS{idProduct}=="1590", ATTRS{bInterfaceNumber}=="03", ATTR{btn_ls/remap/gamepad}=="?*", ATTR{btn_ls/remap/gamepad}="ls", ATTR{btn_ls/remap/modifier}="none", ATTR{btn_ls/remap/keyboard}="none", ATTR{btn_ls/remap/mouse}="none"
    ACTION=="add|change", SUBSYSTEM=="hidraw", KERNEL=="hidraw*", ATTRS{idProduct}=="1590", ATTRS{bInterfaceNumber}=="03", ATTR{btn_rs/remap/gamepad}=="?*", ATTR{btn_rs/remap/gamepad}="rs", ATTR{btn_rs/remap/modifier}="none", ATTR{btn_rs/remap/keyboard}="none", ATTR{btn_rs/remap/mouse}="none"

    # D-pad directions
    ACTION=="add|change", SUBSYSTEM=="hidraw", KERNEL=="hidraw*", ATTRS{idProduct}=="1590", ATTRS{bInterfaceNumber}=="03", ATTR{dpad_up/remap/gamepad}=="?*", ATTR{dpad_up/remap/gamepad}="dpad_up", ATTR{dpad_up/remap/modifier}="none", ATTR{dpad_up/remap/keyboard}="none", ATTR{dpad_up/remap/mouse}="none"
    ACTION=="add|change", SUBSYSTEM=="hidraw", KERNEL=="hidraw*", ATTRS{idProduct}=="1590", ATTRS{bInterfaceNumber}=="03", ATTR{dpad_down/remap/gamepad}=="?*", ATTR{dpad_down/remap/gamepad}="dpad_down", ATTR{dpad_down/remap/modifier}="none", ATTR{dpad_down/remap/keyboard}="none", ATTR{dpad_down/remap/mouse}="none"
    ACTION=="add|change", SUBSYSTEM=="hidraw", KERNEL=="hidraw*", ATTRS{idProduct}=="1590", ATTRS{bInterfaceNumber}=="03", ATTR{dpad_left/remap/gamepad}=="?*", ATTR{dpad_left/remap/gamepad}="dpad_left", ATTR{dpad_left/remap/modifier}="none", ATTR{dpad_left/remap/keyboard}="none", ATTR{dpad_left/remap/mouse}="none"
    ACTION=="add|change", SUBSYSTEM=="hidraw", KERNEL=="hidraw*", ATTRS{idProduct}=="1590", ATTRS{bInterfaceNumber}=="03", ATTR{dpad_right/remap/gamepad}=="?*", ATTR{dpad_right/remap/gamepad}="dpad_right", ATTR{dpad_right/remap/modifier}="none", ATTR{dpad_right/remap/keyboard}="none", ATTR{dpad_right/remap/mouse}="none"

    # Extra rear buttons. The upstream config interface exposes only standard
    # gamepad targets, keyboard keys, modifiers, and mouse buttons here. Keep
    # them as explicit keyboard actions so they remain independently usable.
    ACTION=="add|change", SUBSYSTEM=="hidraw", KERNEL=="hidraw*", ATTRS{idProduct}=="1590", ATTRS{bInterfaceNumber}=="03", ATTR{btn_m1/remap/gamepad}=="?*", ATTR{btn_m1/remap/gamepad}="none", ATTR{btn_m1/remap/modifier}="none", ATTR{btn_m1/remap/keyboard}="end", ATTR{btn_m1/remap/mouse}="none"
    ACTION=="add|change", SUBSYSTEM=="hidraw", KERNEL=="hidraw*", ATTRS{idProduct}=="1590", ATTRS{bInterfaceNumber}=="03", ATTR{btn_m2/remap/gamepad}=="?*", ATTR{btn_m2/remap/gamepad}="none", ATTR{btn_m2/remap/modifier}="none", ATTR{btn_m2/remap/keyboard}="home", ATTR{btn_m2/remap/mouse}="none"

    # Persist the declarative profile to the device once the mappings are applied.
    ACTION=="add|change", SUBSYSTEM=="hidraw", KERNEL=="hidraw*", ATTRS{idProduct}=="1590", ATTRS{bInterfaceNumber}=="03", ATTR{save_config}=="?*", ATTR{save_config}="1"
  '';

  # Sensors for auto-rotation and adaptive brightness
  hardware.sensor.iio.enable = true;

  # ryzenadj for SimpleDeckyTDP TDP control
  environment.systemPackages = [ pkgs.ryzenadj ];

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
    containers.enable = false;
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
