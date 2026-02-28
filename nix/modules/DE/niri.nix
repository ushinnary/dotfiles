{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.ushinnary.desktopEnvironment;
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

    # Essential system components for Wayland and Niri
    environment.systemPackages = with pkgs; [
      mako
      fuzzel
      kdePackages.polkit-kde-agent-1
      xwayland-satellite
      gnome-keyring

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
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.greetd.enableGnomeKeyring = true;
    security.pam.services.greetd-password.enableGnomeKeyring = true;
    security.pam.services.login.enableGnomeKeyring = true;

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
        xdg.configFile."ghostty/config".text = ''
                theme = dark:Catppuccin Mocha,light:Catppuccin Latte
          font-family = Jetbrains Mono
          font-size = 12
                  background-opacity = 0.88
                  background-opacity-cells = true
                  background-blur = true
        '';

        xdg.configFile."niri/config.kdl".text = ''
          spawn-at-startup "mako"
          spawn-at-startup "xwayland-satellite"

          // Clipboard persistence: keep content alive after source app closes
          spawn-at-startup "wl-clip-persist" "--clipboard" "both"
          spawn-at-startup "sh" "-c" "wl-paste --type text --watch cliphist store"
          spawn-at-startup "sh" "-c" "wl-paste --type image --watch cliphist store"

          // Screen lock on idle (lock after 5 min, screen off after 10 min)
          spawn-at-startup "swayidle" "-w" "timeout" "300" "swaylock -f" "timeout" "600" "niri msg action power-off-monitors" "before-sleep" "swaylock -f"

          environment {
              DISPLAY ":0"
              NIXOS_OZONE_WL "1"
              MOZ_ENABLE_WAYLAND "1"
          }

          prefer-no-csd

          overview {
            zoom 0.5
          }

          gestures {
            hot-corners {
              top-left
            }
          }

          output "eDP-1" {
            mode "1920x1080@90"
          }

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

          binds {
              // General
              Mod+Shift+Slash { show-hotkey-overlay; }
              Super { toggle-overview; }

              // Applications
              Mod+T { spawn "ghostty"; }
              Mod+Return { spawn "ghostty"; }
              Mod+Space { spawn "fuzzel"; }
              Mod+D { spawn "fuzzel"; }

              // Clipboard history (fuzzel picker)
              Mod+V { spawn "sh" "-c" "cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"; }

              // Screenshot
              Print { screenshot; }
              Mod+Print { screenshot-window; }
              Mod+Shift+Print { screenshot-screen; }

              // Screen lock
              Mod+Escape { spawn "swaylock" "-f"; }

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

              // Media keys
              XF86AudioRaiseVolume { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
              XF86AudioLowerVolume { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
              XF86AudioMute        { spawn "wpctl" "set-mute"   "@DEFAULT_AUDIO_SINK@" "toggle"; }
              XF86AudioMicMute     { spawn "wpctl" "set-mute"   "@DEFAULT_AUDIO_SOURCE@" "toggle"; }

              // Brightness keys
              XF86MonBrightnessUp   { spawn "brightnessctl" "set" "5%+"; }
              XF86MonBrightnessDown { spawn "brightnessctl" "set" "5%-"; }

              // Media player keys
              XF86AudioPlay  { spawn "playerctl" "play-pause"; }
              XF86AudioNext  { spawn "playerctl" "next"; }
              XF86AudioPrev  { spawn "playerctl" "previous"; }

              // Power key — lock instead of shutdown
              Mod+Shift+E { quit; }
          }
        '';
      };
  };
}
