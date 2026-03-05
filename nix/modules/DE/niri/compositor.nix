{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.ushinnary.desktop;
in
{
  config = mkIf cfg.niri {
    # anyrun is referenced in binds.kdl
    environment.systemPackages = with pkgs; [
      anyrun
      swaybg
    ];

    home-manager.users.ushinnary =
      { ... }:
      {
        # Main config: only imports of the split config files.
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

          // Wallpaper: runs on login; replace path with your image or keep solid colour.
          // To find the layer namespace, run: niri msg layers
          spawn-at-startup "swaybg" "-c" "#1e1e2e"

          // Clipboard persistence: keep content alive after source app closes
          spawn-at-startup "wl-clip-persist" "--clipboard" "both"
          spawn-at-startup "sh" "-c" "wl-paste --type text --watch cliphist store"
          spawn-at-startup "sh" "-c" "wl-paste --type image --watch cliphist store"

          // Screen lock on idle (lock after 5 min, screen off after 10 min)
          spawn-at-startup "swayidle" "-w" "timeout" "300" "swaylock -f" "timeout" "600" "niri msg action power-off-monitors" "before-sleep" "swaylock -f"

          // Set initial colour-scheme on login: light 08:00–19:59, dark otherwise.
          // sleep 1 ensures ironbar is already running and subscribed to dconf
          // before we write, so it picks up the change via the settings watcher.
          spawn-at-startup "sh" "-c" "sleep 1; h=$(date +%H); if [ \"$h\" -ge 8 ] && [ \"$h\" -lt 20 ]; then gsettings set org.gnome.desktop.interface color-scheme prefer-light; else gsettings set org.gnome.desktop.interface color-scheme prefer-dark; fi"
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
            // Keep the backdrop dark when no layer-rule covers it.
            backdrop-color "#1e1e2e"
            workspace-shadow {
              off
            }
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
                  accel-profile "adaptive"
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
              // Transparent so the wallpaper shows through (stationary behind workspaces).
              background-color "transparent"

              preset-column-widths {
                  proportion 0.33333
                  proportion 0.5
                  proportion 0.66667
              }
              default-column-width { proportion 0.5; }

              focus-ring { off; }
              border {
                  width 4
                  active-color "#89b4fa"   // Catppuccin Mocha blue
                  inactive-color "#45475a" // Catppuccin Mocha surface1
              }
          }
        '';

        xdg.configFile."niri/window-rules.kdl".text = ''
          // ── Window rules ────────────────────────────────────────

          // Rounded corners for all windows
          window-rule {
            geometry-corner-radius 12
            clip-to-geometry true
          }

          // Ghostty: blur + transparency + shadow
          window-rule {
            match app-id=r#"(^ghostty$|^com\.mitchellh\.ghostty$)"#
            opacity 0.88
            draw-border-with-background false

            shadow {
              on
              softness 30
              spread 5
              offset x=0 y=5
              color "#00000060"
            }
          }

          // ── Layer rules ─────────────────────────────────────────

          // Ironbar: blur + floating pill (border-radius set in CSS)
          layer-rule {
            match namespace="ironbar"
            opacity 0.95
            place-within-backdrop true

          }

          // swaync notification center
          layer-rule {
            match namespace="swaync-control-center"
            opacity 0.92
            geometry-corner-radius 14

          }

          // Wallpaper: place swaybg inside the overview backdrop so it stays
          // stationary and shows through the transparent workspace background.
          // Run `niri msg layers` if the namespace doesn't match.
          layer-rule {
            match namespace="swaybg"
            place-within-backdrop true
          }
        '';

        xdg.configFile."niri/binds.kdl".text = ''
          binds {
              // General
              Mod+Shift+Slash { show-hotkey-overlay; }
              Super+Tab { toggle-overview; }

              // Applications
              Mod+T { spawn "ghostty"; }
              Mod+Return { spawn "ghostty"; }
              Mod+E { spawn "nautilus"; }

              // Launcher
              Mod+Space { spawn "anyrun"; }
              Mod+P { spawn "anyrun"; }

              // Clipboard history
              Mod+Shift+V { spawn "sh" "-c" "cliphist list | anyrun --plugins ${pkgs.anyrun}/lib/libstdin.so | cliphist decode | wl-copy"; }

              // Screenshot
              Print { screenshot; }
              Mod+Print { screenshot-window; }
              Mod+Shift+Print { screenshot-screen; }

              // Screen lock
              Mod+Escape { spawn "swaylock" "-f"; }

              // Notification center
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

              // Center focused column (toggle: press again to restore)
              Mod+C { center-column; }

              // Toggle floating
              Mod+V { toggle-window-floating; }

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
