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
              type = "battery";
              format = "{percentage}%";
              show_icon = true;
              show_label = true;
              icon_size = 18;
            };

            brightnessWidget = lib.optional config.ushinnary.hardware.hasBattery {
              type = "brightness";
              icon_label = "󰃠";
              format = "{percentage}%";
            };
          in
          builtins.toJSON {
            icon_theme = "Adwaita";
            icon_overrides = {
              "com.mitchellh.ghostty" = "ghostty";
            };

            monitors = {
              "" = [
                # ── Top bar ───────────────────────────────────────────
                {
                  name = "top-bar";
                  layer = "top";
                  position = "top";
                  height = 44;
                  margin_top = 6;
                  margin_bottom = 0;
                  margin_left = 14;
                  margin_right = 14;

                  start = [
                    {
                      type = "workspaces";
                      all_monitors = false;
                      sort = "name";
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
                      type = "music";
                      player_type = "mpris";
                      format = "{title} / {artist}";
                      show_status_icon = true;
                      truncate = {
                        mode = "end";
                        max_length = 36;
                      };
                    }
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
                        icon_size = 18;
                        prefer_theme_icons = true;
                        on_click_left = "default";
                        on_click_right = "menu";
                      }
                    ]
                    ++ batteryWidget
                    ++ brightnessWidget
                    ++ [
                      {
                        type = "volume";
                        format = "{icon}  {percentage}%";
                        mute_format = "{icon}  muted";
                        max_volume = 100;
                        icons = {
                          volume = "󰕾";
                          muted = "󰝟";
                          mic_volume = "";
                          mic_muted = "";
                        };
                      }
                      {
                        type = "notifications";
                        show_count = true;
                      }
                    ];
                }

                # ── Bottom launcher bar ───────────────────────────────
                # Pinned apps always appear first; running apps are appended.
                # Find app IDs with: ls /run/current-system/sw/share/applications/
                {
                  name = "bottom-bar";
                  layer = "top";
                  position = "bottom";
                  height = 54;
                  margin_top = 0;
                  margin_bottom = 6;
                  margin_left = 14;
                  margin_right = 14;

                  start = [
                    {
                      type = "menu";
                      label = "";
                      label_icon = "󰍉";
                      app_icon_size = 22;
                      launch_command = "${pkgs.gtk3}/bin/gtk-launch {app_name}";
                    }
                  ];

                  center = [
                    {
                      type = "launcher";
                      favorites = [
                        "com.mitchellh.ghostty"
                        "org.gnome.Nautilus"
                        "firefox"
                      ];
                      show_names = false;
                      show_icons = true;
                      icon_size = 26;
                      launch_command = "${pkgs.gtk3}/bin/gtk-launch {app_name}";
                    }
                  ];
                }
              ];
            };
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
            #top-bar, #bottom-bar {
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
            .module-music        { color: #fab387; }
            .module-volume       { color: #a6e3a1; }
            .module-brightness   { color: #f9e2af; }
            .module-notifications   { color: #89dceb; }

            /* Tray */
            .module-tray { background-color: transparent; padding: 3px 6px; }
            .tray .item { border-radius: 8px; padding: 2px; }
            .tray .item:hover { background-color: alpha(#313244, 0.9); }
            .tray .item.urgent { background-color: alpha(#f38ba8, 0.6); }

            /* Battery */
            .module-battery      { color: #f9e2af; }
            .battery .icon       { color: #f9e2af; }
            .battery .label      { color: #f9e2af; }
            .battery.charging .icon  { color: #a6e3a1; }
            .battery.charging .label { color: #a6e3a1; }
            .battery.low .icon   { color: #f38ba8; }
            .battery.low .label  { color: #f38ba8; }

            /* Launcher (bottom bar) */
            .launcher {
              background-color: transparent;
              padding: 0;
            }
            .launcher .item {
              background-color: alpha(#313244, 0.4);
              border-radius: 10px;
              padding: 4px 8px;
              margin: 3px 2px;
              min-width: 36px;
              min-height: 36px;
            }
            .launcher .item:hover {
              background-color: alpha(#313244, 0.9);
              box-shadow: 0 0 8px alpha(#89b4fa, 0.35);
            }
            .launcher .item.open {
              background-color: alpha(#45475a, 0.6);
              border-bottom: 2px solid #89b4fa;
            }
            .launcher .item.focused {
              background-color: alpha(#89b4fa, 0.8);
              box-shadow: 0 0 8px alpha(#89b4fa, 0.6);
            }
            .launcher .item.urgent {
              background-color: alpha(#f38ba8, 0.7);
            }

            /* Menu (bottom bar — app grid button) */
            .menu {
              background-color: alpha(#313244, 0.4);
              border-radius: 10px;
              padding: 4px 12px;
              margin: 3px 4px;
              color: #cdd6f4;
              font-size: 18px;
            }
            .menu:hover {
              background-color: alpha(#313244, 0.9);
              color: #89b4fa;
              box-shadow: 0 0 8px alpha(#89b4fa, 0.35);
            }
            .popup-menu .main .category {
              color: #cdd6f4;
              background-color: alpha(#313244, 0.6);
              border-radius: 8px;
              padding: 4px 10px;
              margin: 2px 4px;
            }
            .popup-menu .main .category:hover,
            .popup-menu .main .category.open {
              background-color: alpha(#89b4fa, 0.7);
              color: #1e1e2e;
            }
            .popup-menu .sub-menu .application {
              color: #cdd6f4;
              border-radius: 6px;
              padding: 3px 8px;
            }
            .popup-menu .sub-menu .application:hover {
              background-color: alpha(#313244, 0.9);
              color: #89b4fa;
            }
          }

          /* ── Light: Catppuccin Latte ─────────────────────────── */
          @media (prefers-color-scheme: light) {
            #top-bar, #bottom-bar {
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
            .module-music        { color: #fe640b; }
            .module-volume       { color: #40a02b; }
            .module-brightness   { color: #df8e1d; }
            .module-notifications   { color: #04a5e5; }

            /* Tray */
            .module-tray { background-color: transparent; padding: 3px 6px; }
            .tray .item { border-radius: 8px; padding: 2px; }
            .tray .item:hover { background-color: alpha(#ccd0da, 0.95); }
            .tray .item.urgent { background-color: alpha(#d20f39, 0.5); }

            /* Battery */
            .module-battery      { color: #df8e1d; }
            .battery .icon       { color: #df8e1d; }
            .battery .label      { color: #df8e1d; }
            .battery.charging .icon  { color: #40a02b; }
            .battery.charging .label { color: #40a02b; }
            .battery.low .icon   { color: #d20f39; }
            .battery.low .label  { color: #d20f39; }

            /* Launcher (bottom bar) */
            .launcher {
              background-color: transparent;
              padding: 0;
            }
            .launcher .item {
              background-color: alpha(#ccd0da, 0.45);
              border-radius: 10px;
              padding: 4px 8px;
              margin: 3px 2px;
              min-width: 36px;
              min-height: 36px;
            }
            .launcher .item:hover {
              background-color: alpha(#ccd0da, 0.95);
              box-shadow: 0 0 8px alpha(#1e66f5, 0.25);
            }
            .launcher .item.open {
              background-color: alpha(#9ca0b0, 0.5);
              border-bottom: 2px solid #1e66f5;
            }
            .launcher .item.focused {
              background-color: alpha(#1e66f5, 0.8);
              box-shadow: 0 0 8px alpha(#1e66f5, 0.5);
            }
            .launcher .item.urgent {
              background-color: alpha(#d20f39, 0.6);
            }

            /* Menu (bottom bar — app grid button) */
            .menu {
              background-color: alpha(#ccd0da, 0.45);
              border-radius: 10px;
              padding: 4px 12px;
              margin: 3px 4px;
              color: #4c4f69;
              font-size: 18px;
            }
            .menu:hover {
              background-color: alpha(#ccd0da, 0.95);
              color: #1e66f5;
              box-shadow: 0 0 8px alpha(#1e66f5, 0.25);
            }
            .popup-menu .main .category {
              color: #4c4f69;
              background-color: alpha(#ccd0da, 0.55);
              border-radius: 8px;
              padding: 4px 10px;
              margin: 2px 4px;
            }
            .popup-menu .main .category:hover,
            .popup-menu .main .category.open {
              background-color: alpha(#1e66f5, 0.7);
              color: #eff1f5;
            }
            .popup-menu .sub-menu .application {
              color: #4c4f69;
              border-radius: 6px;
              padding: 3px 8px;
            }
            .popup-menu .sub-menu .application:hover {
              background-color: alpha(#ccd0da, 0.95);
              color: #1e66f5;
            }
          }
        '';
      };
  };
}
