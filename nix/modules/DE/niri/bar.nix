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
    # ── Bar-ecosystem packages ─────────────────────────────────────
    environment.systemPackages = with pkgs; [
      ironbar                   # Status bar
      swaynotificationcenter    # Notification daemon + center panel
      swayosd                   # On-screen display for volume/brightness
    ];

    home-manager.users.ushinnary =
      { ... }:
      {
        # ── Ironbar config ─────────────────────────────────────────
        xdg.configFile."ironbar/config.json".text =
          let
            batteryWidget = lib.optional config.ushinnary.hardware.hasBattery {
              type = "upower";
              format = "{icon}  {percentage}%";
            };
          in
          builtins.toJSON {
            layer = "top";
            position = "top";
            height = 44;
            # Float the bar like the waybar reference
            margin_top = 6;
            margin_bottom = 0;
            margin_left = 14;
            margin_right = 14;

            start = [
              {
                type = "workspaces";
                all_monitors = false;
                sort = "index";
                favorites = [ "1" "2" "3" "4" "5" ];
                name_map = {
                  "1" = "1";
                  "2" = "2";
                  "3" = "3";
                  "4" = "4";
                  "5" = "5";
                };
                format = "{name}";
              }
            ];

            center = [
              {
                type = "clock";
                format = "󰅐  %I:%M %p";
                format_alt = "󰃶  %A, %B %d";
              }
            ];

            end =
              [
                {
                  type = "tray";
                  icon_size = 16;
                }
              ]
              ++ batteryWidget
              ++ [
                {
                  type = "volume";
                  format = "{icon}  {percentage}%";
                }
                {
                  type = "notifications";
                  show_count = true;
                }
              ];
          };

        # ── Ironbar CSS — Catppuccin floating pills ─────────────────
        xdg.configFile."ironbar/style.css".text = ''
          /* ─────────────────────────────────────────────────────────
             Ironbar — Catppuccin Mocha (dark) / Latte (light)
             Floating pill design, blur-ready (semi-transparent)
             Inspired by Wynn-Dots waybar style
             ───────────────────────────────────────────────────────── */

          * {
            font-family: "JetBrains Mono", "JetBrains Mono NF", monospace;
            font-size: 13px;
            font-weight: normal;
            border: none;
            border-radius: 0;
            box-shadow: none;
            text-shadow: none;
            background-image: none;
            outline: none;
            margin: 0;
            padding: 0;
            transition-property: background-color, color, box-shadow, opacity;
            transition-duration: 0.2s;
            transition-timing-function: ease-in-out;
          }

          /* The ironbar GTK window itself must be transparent */
          window#ironbar,
          window,
          .background {
            background-color: transparent;
          }
          .bar-container {
            background-color: transparent;
          }

          /* ── Dark: Catppuccin Mocha ──────────────────────────── */
          @media (prefers-color-scheme: dark) {
            #bar {
              background-color: alpha(#1e1e2e, 0.55);
              color: #cdd6f4;
              border-radius: 16px;
              border: 2px solid alpha(#89b4fa, 0.5);
            }

            /* Per-module pill surfaces */
            .module {
              color: #cdd6f4;
              background-color: alpha(#313244, 0.4);
              border-radius: 10px;
              padding: 4px 10px;
              margin: 3px 3px;
            }
            .module:hover {
              background-color: alpha(#313244, 0.9);
              color: #89b4fa;
              box-shadow: 0 0 8px alpha(#89b4fa, 0.35);
            }

            /* Workspaces */
            .module-workspaces {
              background-color: transparent;
              padding: 0;
              margin: 0 2px;
            }
            .module-workspaces button {
              color: #6c7086;
              background-color: alpha(#313244, 0.4);
              border-radius: 10px;
              padding: 4px 12px;
              margin: 3px 2px;
              font-weight: bold;
            }
            .module-workspaces button:hover {
              background-color: alpha(#313244, 0.9);
              color: #cdd6f4;
            }
            .module-workspaces button.focused {
              background-color: alpha(#89b4fa, 0.8);
              color: #1e1e2e;
              box-shadow: 0 0 8px alpha(#89b4fa, 0.6);
            }
            .module-workspaces button.occupied {
              color: #bac2de;
            }

            /* Per-module accent colours */
            .module-clock        { color: #cba6f7; font-weight: bold; font-size: 14px; }
            .module-volume       { color: #a6e3a1; }
            .module-upower       { color: #f9e2af; }
            .module-upower.charging { color: #a6e3a1; }
            .module-upower.low      { color: #f38ba8; }
            .module-notifications   { color: #89dceb; }
            .module-tray { background-color: transparent; padding: 3px 6px; }
          }

          /* ── Light: Catppuccin Latte ─────────────────────────── */
          @media (prefers-color-scheme: light) {
            #bar {
              background-color: alpha(#eff1f5, 0.6);
              color: #4c4f69;
              border-radius: 16px;
              border: 2px solid alpha(#1e66f5, 0.45);
            }

            .module {
              color: #4c4f69;
              background-color: alpha(#ccd0da, 0.45);
              border-radius: 10px;
              padding: 4px 10px;
              margin: 3px 3px;
            }
            .module:hover {
              background-color: alpha(#ccd0da, 0.95);
              color: #1e66f5;
              box-shadow: 0 0 8px alpha(#1e66f5, 0.25);
            }

            .module-workspaces {
              background-color: transparent;
              padding: 0;
              margin: 0 2px;
            }
            .module-workspaces button {
              color: #9ca0b0;
              background-color: alpha(#ccd0da, 0.45);
              border-radius: 10px;
              padding: 4px 12px;
              margin: 3px 2px;
              font-weight: bold;
            }
            .module-workspaces button:hover {
              background-color: alpha(#ccd0da, 0.95);
              color: #4c4f69;
            }
            .module-workspaces button.focused {
              background-color: alpha(#1e66f5, 0.8);
              color: #eff1f5;
              box-shadow: 0 0 8px alpha(#1e66f5, 0.5);
            }
            .module-workspaces button.occupied {
              color: #5c5f77;
            }

            .module-clock        { color: #8839ef; font-weight: bold; font-size: 14px; }
            .module-volume       { color: #40a02b; }
            .module-upower       { color: #df8e1d; }
            .module-upower.charging { color: #40a02b; }
            .module-upower.low      { color: #d20f39; }
            .module-notifications   { color: #04a5e5; }
            .module-tray { background-color: transparent; padding: 3px 6px; }
          }
        '';
      };
  };
}
