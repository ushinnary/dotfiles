# Handheld Gaming Module
# Provides Steam Deck-like experience for gaming handhelds
# Optimized for OLED screens and high refresh rates
{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.ushinnary.handheld;
  gamingCfg = config.ushinnary.gaming;
in
{
  config = mkIf cfg.enable {
    # ===== Core Gaming Packages =====
    environment.systemPackages = with pkgs; [
      # Steam Deck Experience
      mangohud
      gamescope

      # Handheld utilities
      powertop
      btop
      nvtopPackages.amd

      # Controller support
      game-devices-udev-rules
      joystick
      linuxConsoleTools

      # Screen management
      brightnessctl
      wlr-randr

      # Performance monitoring
      lm_sensors
      zenmonitor

      # Input management for handhelds
      libinput

      # Decky Loader dependencies
      python3
      python3Packages.pip
      python3Packages.aiohttp
      python3Packages.packaging
      unzip
      wget
      curl

      # File management
      p7zip
      unrar

      # Media codecs for game trailers/videos
      ffmpeg
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-plugins-ugly
      gst_all_1.gst-libav
    ];

    # ===== Steam with Gamescope Session =====
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession = {
        enable = true;
        args = [
          "--adaptive-sync"
          "--steam"
          "--mangoapp"
        ] ++ (if cfg.oledScreen then [
          "-r ${toString cfg.refreshRate}"
          "-o ${toString cfg.refreshRate}"
          "--hdr-enabled"
          "--hdr-itm-enable"
        ] else [
          "-r ${toString cfg.refreshRate}"
        ]);
      };
    };

    # Gamescope - Valve's micro-compositor
    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };

    # Gamemode for performance optimizations
    programs.gamemode = {
      enable = true;
      enableRenice = true;
      settings = {
        general = {
          renice = 10;
          softrealtime = "auto";
          ioprio = 0;
          inhibit_screensaver = 1;
        };
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          amd_performance_level = "high";
        };
        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode Started'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode Ended'";
        };
      };
    };

    # ===== Environment Variables for Optimal Gaming =====
    environment.variables = {
      # MangoHud configuration optimized for handheld
      MANGOHUD = "1";
      MANGOHUD_CONFIG = concatStringsSep "," [
        "fps_limit=${toString cfg.refreshRate}+60+30+0"
        "toggle_hud=Shift_L+F2"
        "position=top-left"
        "font_size=18"
        "background_alpha=0.3"
        "fps"
        "frametime"
        "cpu_temp"
        "gpu_temp"
        "battery"
        "battery_time"
        "ram"
        "vram"
      ];

      # Proton/Wine optimizations
      PROTON_ENABLE_NVAPI = "0";  # AMD GPU
      ENABLE_GAMESCOPE_WSI = "1";
      STEAM_MULTIPLE_XWAYLANDS = "1";
      PROTON_USE_NTSYNC = "1";

      # HDR Support for OLED
      ENABLE_HDR_WSI = if cfg.oledScreen then "1" else "0";
      DXVK_HDR = if cfg.oledScreen then "1" else "0";

      # AMD GPU optimizations (RDNA3 - Radeon 780M)
      RADV_PERFTEST = "nggc,sam";
      AMD_VULKAN_ICD = "RADV";
      RADV_DEBUG = "nothreadllvm";

      # Shader cache
      __GL_SHADER_DISK_CACHE = "1";
      __GL_SHADER_DISK_CACHE_PATH = "/tmp/shader-cache";
      __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";

      # Vulkan optimizations
      VKD3D_CONFIG = "dxr";

      # Mesa optimizations
      MESA_SHADER_CACHE_DISABLE = "false";
      MESA_SHADER_CACHE_MAX_SIZE = "1G";

      # Force use of Wayland where possible
      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
      GDK_BACKEND = "wayland,x11";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";

      # Steam
      STEAM_FRAME_FORCE_CLOSE = "0";
      STEAM_USE_DYNAMIC_VRS = "1";

      # Terminal for Steam
      TERMINAL = "ghostty";
    };

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    # ===== Input/Controller Support =====
    # udev rules for game controllers and handhelds
    services.udev.packages = with pkgs; [
      game-devices-udev-rules
    ];

    # Extra udev rules for Zotac Zone
    services.udev.extraRules = ''
      # Zotac Zone controller
      SUBSYSTEM=="input", ATTRS{name}=="*Zotac*", MODE="0666"
      SUBSYSTEM=="input", ATTRS{name}=="*AYANEO*", MODE="0666"
      SUBSYSTEM=="input", ATTRS{name}=="*Steam*", MODE="0666"

      # Better power management for internal devices
      ACTION=="add", SUBSYSTEM=="pci", ATTR{power/control}="auto"
      ACTION=="add", SUBSYSTEM=="usb", ATTR{power/control}="auto"

      # OLED brightness control
      SUBSYSTEM=="backlight", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
      SUBSYSTEM=="backlight", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
    '';

    # Add user to required groups
    users.users.ushinnary.extraGroups = [
      "gamemode"
      "input"
      "video"
      "render"
    ];

    # ===== Graphics Configuration =====
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        amdvlk
        rocmPackages.clr.icd
      ];
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    };

    # ===== Decky Loader Setup =====
    # Create directory structure for Decky Loader
    systemd.tmpfiles.rules = [
      "d /home/ushinnary/homebrew 0755 ushinnary users -"
      "d /home/ushinnary/homebrew/plugins 0755 ushinnary users -"
      "d /home/ushinnary/homebrew/services 0755 ushinnary users -"
      "d /home/ushinnary/homebrew/themes 0755 ushinnary users -"
      "d /tmp/shader-cache 1777 root root -"
    ];

    # Decky Loader service (manual installation required, see README)
    # The service will be installed by the Decky installer script

    # ===== Performance Tweaks =====
    # Increase file limits for games
    security.pam.loginLimits = [
      {
        domain = "*";
        type = "soft";
        item = "nofile";
        value = "1048576";
      }
      {
        domain = "*";
        type = "hard";
        item = "nofile";
        value = "1048576";
      }
    ];

    # Zram for better memory management on handheld
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50;
    };

    # Boot performance
    systemd.services.NetworkManager-wait-online.enable = false;

    # ===== Audio for Gaming =====
    # Low-latency audio for gaming
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };

    # Disable PulseAudio (we use PipeWire)
    hardware.pulseaudio.enable = false;

    # Real-time priorities for audio
    security.rtkit.enable = true;

    # ===== Suspend/Resume Optimization =====
    # Fast suspend/resume for handheld
    services.logind = {
      lidSwitch = "suspend";
      lidSwitchDocked = "ignore";
      lidSwitchExternalPower = "suspend";
      powerKey = "suspend";
      powerKeyLongPress = "poweroff";
      suspendKey = "suspend";
    };

    # ===== Steam Big Picture Auto-Start (Optional) =====
    # Uncomment to auto-start Steam in Big Picture mode
    # systemd.user.services.steam-gamescope = {
    #   description = "Steam Gamescope Session";
    #   wantedBy = [ "graphical-session.target" ];
    #   serviceConfig = {
    #     ExecStart = "${pkgs.gamescope}/bin/gamescope --steam -- steam -gamepadui";
    #     Restart = "on-failure";
    #   };
    # };
  };
}
