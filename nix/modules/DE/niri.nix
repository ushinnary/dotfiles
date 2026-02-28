{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.ushinnary.desktopEnvironment;
in
{
  imports = [
    inputs.dms.nixosModules.greeter
  ];

  config = mkIf cfg.niri {
    programs.niri.enable = true;

    # DankGreeter — themed login screen (replaces tuigreet/greetd)
    programs.dank-material-shell.greeter = {
      enable = true;
      compositor.name = "niri";
      configHome = "/home/ushinnary"; # Sync DMS theme with greeter
    };

    # Essential system components for Wayland and Niri
    # DankMaterialShell replaces: mako, fuzzel, polkit-kde-agent, wl-clipboard,
    # wl-clip-persist, cliphist, swaylock, swayidle, brightnessctl, playerctl
    environment.systemPackages = with pkgs; [
      xwayland-satellite
      gnome-keyring
      nautilus
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
    security.pam.services.login.enableGnomeKeyring = true;

    # DMS provides built-in polkit agent and lock screen — no swaylock/polkit-kde needed

    home-manager.users.ushinnary =
      { ... }:
      {
        imports = [
          inputs.dms.homeModules.dank-material-shell
          inputs.dms.homeModules.niri
          inputs.danksearch.homeModules.dsearch
        ];

        programs.dank-material-shell = {
          enable = true;
          enableClipboardPaste = true;
          niri = {
            enableSpawn = true;
            enableKeybinds = false; # We manage keybinds in our config.kdl
            includes.enable = false; # We manage our own config.kdl
          };
        };

        # DankSearch — file search backend for DMS Spotlight
        programs.dsearch.enable = true;

        xdg.configFile."ghostty/config".text = ''
                theme = dark:Catppuccin Mocha,light:Catppuccin Latte
          font-family = Jetbrains Mono
          font-size = 12
                  background-opacity = 0.88
                  background-opacity-cells = true
                  background-blur = true
        '';

        xdg.configFile."niri/config.kdl".text = ''
          spawn-at-startup "xwayland-satellite"

          // DankMaterialShell is auto-started via its systemd/niri integration
          // It provides: notifications, launcher, clipboard, lock screen,
          // idle management, polkit, media controls, and more

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

          output "DP-1" {
            mode "2560x1600@90"
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
              Mod+E { spawn "nautilus"; }

              // DMS Spotlight launcher (replaces fuzzel)
              Mod+Space { spawn "dms" "ipc" "call" "spotlight" "toggle"; }
              Mod+D { spawn "dms" "ipc" "call" "spotlight" "toggle"; }

              // DMS Clipboard history (replaces cliphist + fuzzel)
              Mod+V { spawn "dms" "ipc" "call" "clipboard" "toggle"; }

              // DMS Screenshot (with annotation editor)
              Print { spawn "dms" "ipc" "call" "niri" "screenshot"; }
              Mod+Print { spawn "dms" "ipc" "call" "niri" "screenshotWindow"; }
              Mod+Shift+Print { spawn "dms" "ipc" "call" "niri" "screenshotScreen"; }

              // DMS Lock screen (replaces swaylock)
              Mod+Escape { spawn "dms" "ipc" "call" "lock" "lock"; }

              // DMS Notification center
              Mod+N { spawn "dms" "ipc" "call" "notifications" "toggle"; }

              // DMS Settings
              Mod+Comma { spawn "dms" "ipc" "call" "settings" "toggle"; }

              // DMS Control center (network, bluetooth, audio, etc.)
              Mod+A { spawn "dms" "ipc" "call" "control-center" "toggle"; }

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

              // Media keys (via DMS IPC)
              XF86AudioRaiseVolume { spawn "dms" "ipc" "call" "audio" "increment" "5"; }
              XF86AudioLowerVolume { spawn "dms" "ipc" "call" "audio" "decrement" "5"; }
              XF86AudioMute        { spawn "dms" "ipc" "call" "audio" "mute"; }
              XF86AudioMicMute     { spawn "dms" "ipc" "call" "audio" "micmute"; }

              // Brightness keys (via DMS IPC)
              XF86MonBrightnessUp   { spawn "dms" "ipc" "call" "brightness" "increment" "5"; }
              XF86MonBrightnessDown { spawn "dms" "ipc" "call" "brightness" "decrement" "5"; }

              // Media player keys (via DMS MPRIS)
              XF86AudioPlay  { spawn "dms" "ipc" "call" "mpris" "playPause"; }
              XF86AudioNext  { spawn "dms" "ipc" "call" "mpris" "next"; }
              XF86AudioPrev  { spawn "dms" "ipc" "call" "mpris" "previous"; }

              // Power key — lock instead of shutdown
              Mod+Shift+E { quit; }
          }
        '';
      };
  };
}
