{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.ushinnary.desktop;
in
{
  config = mkIf cfg.niri {
    programs.niri.enable = true;

    # Using greetd to seamlessly log into Niri without pulling GNOME shell stuff
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
          user = "greeter";
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/cache/tuigreet 0755 greeter greeter -"
    ];

    # Essential system components for Wayland and Niri (Rust-first where possible)
    environment.systemPackages = with pkgs; [
      kdePackages.polkit-kde-agent-1
      xwayland-satellite
      gnome-keyring

      ghostty # Terminal emulator

      # Launcher, bar and shell UX
      anyrun
      ironbar
      swaynotificationcenter
      swayosd

      # File manager
      nautilus

      # Clipboard stack (persistence + history)
      wl-clipboard
      wl-clip-persist
      cliphist

      # Screen lock
      swaylock
      swayidle

      # Media / brightness
      brightnessctl
      playerctl
    ];

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
      config.common.default = "*";
      config.niri = {
        default = mkDefault [ "gtk" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
    };

    # Security & Password Management (gnome-keyring)
    # gnome-keyring is started via its systemd user service (services.gnome.gnome-keyring.enable).
    # Do NOT plug it into the greetd PAM stack: its session module tries to contact the user
    # D-Bus session which doesn't exist yet at greetd time, causing PAM session-open to fail
    # and preventing login from proceeding.
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.login.enableGnomeKeyring = true;

    # Give the greeter user camera access so howdy (if enabled on this host) can
    # attempt face-auth without crashing the PAM module, and then fall through to
    # password auth gracefully when no model is enrolled.
    users.groups.video.members = [ "greeter" ];

    # Prevent howdy (face recognition) from blocking greetd auth.
    # security.pam.howdy.enable (set globally in security.nix) inserts the howdy
    # PAM module into every service including greetd. Since howdy runs before
    # password auth and fails when no model is enrolled / daemon isn't ready,
    # it must be explicitly disabled for greetd.
    security.pam.services.greetd.howdy.enable = false;

    # Allow swaylock to authenticate via PAM
    security.pam.services.swaylock = {};

    # Polkit started via systemd user unit
    systemd.user.services.polkit-kde-authentication-agent-1 = {
      description = "polkit-kde-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    home-manager.users.ushinnary =
      { ... }:
      {
        imports = [
          inputs.system76-scheduler-niri.homeModules.default
        ];

        services.system76-scheduler-niri.enable = config.services.system76-scheduler.enable;

        xdg.configFile."ghostty/config".text = ''
                theme = dark:Catppuccin Mocha,light:Catppuccin Latte
          font-family = Jetbrains Mono
          font-size = 12
                  background-opacity = 0.88
                  background-opacity-cells = true
                  background-blur = true
        '';

        xdg.configFile."ironbar/config.json".text = ''
          {
            "position": "top",
            "height": 32,
            "start": [
              {
                "type": "workspaces",
                "all_monitors": false,
                "sort": "index",
                "favorites": ["1", "2", "3", "4", "5"],
                "name_map": {
                  "1": "•",
                  "2": "•",
                  "3": "•",
                  "4": "•",
                  "5": "•"
                },
                "format": "{label}"
              }
            ],
            "center": [],
            "end": [
              {
                "type": "tray",
                "icon_size": 18
              },
              {
                "type": "volume",
                "format": "{icon} {percentage}%"
              },
              {
                "type": "notifications",
                "show_count": false
              },
              {
                "type": "clock",
                "format": "%a %d %b  %H:%M"
              }
            ]
          }
        '';

        xdg.configFile."ironbar/style.css".text = ''
          .workspaces .item {
            min-width: 10px;
            padding: 0 3px;
          }

          .workspaces .item .text-icon {
            font-size: 14px;
          }
        '';

        # Main config: only imports of the split config files.
        # To override/extend any section on a specific host, add another
        # xdg.configFile."niri/<section>.kdl" with mkForce or place an
        # additional include in the host's home-manager config.
        xdg.configFile."niri/config.kdl".text = ''
          include "startup.kdl"
          include "environment.kdl"
          include "appearance.kdl"
          include "outputs.kdl"
          include "input.kdl"
          include "layout.kdl"
          include "window-rules.kdl"
          include "binds.kdl"
        '';

        xdg.configFile."niri/startup.kdl".text = ''
          spawn-at-startup "ironbar"
          spawn-at-startup "swaync"
          spawn-at-startup "swayosd-server"
          spawn-at-startup "xwayland-satellite"

          // Clipboard persistence: keep content alive after source app closes
          spawn-at-startup "wl-clip-persist" "--clipboard" "both"
          spawn-at-startup "sh" "-c" "wl-paste --type text --watch cliphist store"
          spawn-at-startup "sh" "-c" "wl-paste --type image --watch cliphist store"

          // Screen lock on idle (lock after 5 min, screen off after 10 min)
          spawn-at-startup "swayidle" "-w" "timeout" "300" "swaylock -f" "timeout" "600" "niri msg action power-off-monitors" "before-sleep" "swaylock -f"
        '';

        xdg.configFile."niri/environment.kdl".text = ''
          environment {
              DISPLAY ":0"
              NIXOS_OZONE_WL "1"
              MOZ_ENABLE_WAYLAND "1"
          }
        '';

        xdg.configFile."niri/appearance.kdl".text = ''
          prefer-no-csd

          overview {
            zoom 0.5
          }

          gestures {
            hot-corners {
              top-left
            }
          }
        '';

        xdg.configFile."niri/outputs.kdl".text = ''
          output "eDP-1" {
            mode "2560x1600@${toString config.ushinnary.display.refreshRate}"
          }

          output "DP-1" {
            mode "2560x1600@${toString config.ushinnary.display.refreshRate}"
          }
        '';

        xdg.configFile."niri/input.kdl".text = ''
          input {
              keyboard {
                  xkb { }
              }
              touchpad {
                  tap
                  natural-scroll
                  accel-speed 0.2
              }
              mouse {
                  natural-scroll
                  accel-profile "flat"
              }
          }
        '';

        xdg.configFile."niri/layout.kdl".text = ''
          layout {
              gaps 16
              center-focused-column "never"

              preset-column-widths {
                  proportion 0.33333
                  proportion 0.5
                  proportion 0.66667
              }
              default-column-width { proportion 0.5; }

              focus-ring { off; }
              border {
                  width 4
                  active-color "#7fc8ff"
                  inactive-color "#505050"
              }
          }
        '';

        xdg.configFile."niri/window-rules.kdl".text = ''
          window-rule {
            match app-id=r#"(^ghostty$|^com\.mitchellh\.ghostty$)"#
            opacity 0.92
            geometry-corner-radius 10
            clip-to-geometry true
            draw-border-with-background false

            shadow {
              on
              softness 24
              spread 2
              offset x=0 y=3
              color "#00000055"
            }
          }
        '';

        xdg.configFile."niri/binds.kdl".text = ''
          binds {
              // General
              Mod+Shift+Slash { show-hotkey-overlay; }
              Super { toggle-overview; }

              // Applications
              Mod+T { spawn "ghostty"; }
              Mod+Return { spawn "ghostty"; }
              Mod+E { spawn "nautilus"; }

              // Launcher
              Mod+Space { spawn "anyrun"; }
              Mod+P { spawn "anyrun"; }

              // Clipboard history (remapped to avoid conflicts)
              Mod+Shift+V { spawn "sh" "-c" "cliphist list | anyrun --plugins ${pkgs.anyrun}/lib/libstdin.so | cliphist decode | wl-copy"; }

              // Screenshot
              Print { screenshot; }
              Mod+Print { screenshot-window; }
              Mod+Shift+Print { screenshot-screen; }

              // Screen lock
              Mod+Escape { spawn "swaylock" "-f"; }

              // Notification center (remapped)
              Mod+Shift+N { spawn "swaync-client" "-t"; }

              // Window management
              Mod+Q { close-window; }
              Alt+F4 { close-window; }

              // Workspace and Fullscreen
              Mod+F { maximize-column; }
              Mod+Shift+F { fullscreen-window; }

              // Focus and columns
              Mod+Left  { focus-column-left; }
              Mod+Right { focus-column-right; }
              Mod+Up    { focus-window-up; }
              Mod+Down  { focus-window-down; }
              Mod+H     { focus-column-left; }
              Mod+L     { focus-column-right; }
              Mod+J     { focus-window-down; }
              Mod+K     { focus-window-up; }

              // Movement
              Mod+Shift+Left  { move-column-left; }
              Mod+Shift+Right { move-column-right; }
              Mod+Shift+Up    { move-window-up; }
              Mod+Shift+Down  { move-window-down; }
              Mod+Shift+H     { move-column-left; }
              Mod+Shift+L     { move-column-right; }
              Mod+Shift+J     { move-window-down; }
              Mod+Shift+K     { move-window-up; }

              // Column width adjustment
              Mod+Minus { set-column-width "-10%"; }
              Mod+Equal { set-column-width "+10%"; }
              Mod+Shift+Minus { set-window-height "-10%"; }
              Mod+Shift+Equal { set-window-height "+10%"; }

              // Center focused column
              Mod+C { center-column; }

              // Consume / expel windows (merge into or split from column)
              Mod+BracketLeft  { consume-window-into-column; }
              Mod+BracketRight { expel-window-from-column; }

              // Home / End
              Mod+Home { focus-column-first; }
              Mod+End  { focus-column-last; }

              // Workspaces
              Mod+Page_Down { focus-workspace-down; }
              Mod+Page_Up   { focus-workspace-up; }
              Mod+Shift+Page_Down { move-column-to-workspace-down; }
              Mod+Shift+Page_Up   { move-column-to-workspace-up; }

              // Workspace by number
              Mod+1 { focus-workspace 1; }
              Mod+2 { focus-workspace 2; }
              Mod+3 { focus-workspace 3; }
              Mod+4 { focus-workspace 4; }
              Mod+5 { focus-workspace 5; }
              Mod+Shift+1 { move-column-to-workspace 1; }
              Mod+Shift+2 { move-column-to-workspace 2; }
              Mod+Shift+3 { move-column-to-workspace 3; }
              Mod+Shift+4 { move-column-to-workspace 4; }
              Mod+Shift+5 { move-column-to-workspace 5; }

              // Media keys + OSD
              XF86AudioRaiseVolume { spawn "swayosd-client" "--output-volume" "raise"; }
              XF86AudioLowerVolume { spawn "swayosd-client" "--output-volume" "lower"; }
              XF86AudioMute        { spawn "swayosd-client" "--output-volume" "mute-toggle"; }
              XF86AudioMicMute     { spawn "swayosd-client" "--input-volume" "mute-toggle"; }

              // Brightness keys + OSD
              XF86MonBrightnessUp   { spawn "swayosd-client" "--brightness" "raise"; }
              XF86MonBrightnessDown { spawn "swayosd-client" "--brightness" "lower"; }

              // Media player keys + OSD
              XF86AudioPlay  { spawn "swayosd-client" "--playerctl" "play-pause"; }
              XF86AudioNext  { spawn "swayosd-client" "--playerctl" "next"; }
              XF86AudioPrev  { spawn "swayosd-client" "--playerctl" "previous"; }

              // Quit niri
              Mod+Shift+E { quit; }
          }
        '';
      };
  };
}
