{
  config,
  lib,
  pkgs,
  vars,
  ...
}:
with lib;
let
  cfg = config.ushinnary.desktop;
in
{
  imports = [
    ./DE/gnome.nix
    ./DE/cosmic.nix
    ./DE/plasma.nix
    ./DE/niri/default.nix
  ];

  config = mkMerge [
    {
      # Keep power-profiles-daemon disabled by default when Rust power stack is enabled
      services.power-profiles-daemon.enable = mkDefault (!config.ushinnary.power.enable);
    }
    (mkIf (cfg.gnome || cfg.cosmic || cfg.plasma || cfg.niri) {
      # Enable CUPS printing services
      # CUPS (Common Unix Printing System) handles all printer communication
      services.printing = {
        enable = true;

        # Required drivers for most modern printers
        # cups-filters: provides filters for converting documents to printer-ready formats
        # cups-browsed: enables automatic printer discovery on the network
        drivers = with pkgs; [
          cups-filters
          cups-browsed
        ];
      };
      hardware.sane.enable = true;
      services.colord.enable = true;
      hardware.sensor.iio.enable = config.ushinnary.hardware.hasWebCam;
      services.avahi.enable = true; # For network discovery of printers and other devices

      boot.kernelModules = [ "i2c-dev" ];
      hardware.i2c.enable = true;
      services.udev.extraRules = ''
        KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
      '';
      users.users."${vars.userName}".extraGroups = [
        "i2c"
        "scanner"
        "lp"
      ];

      environment.systemPackages = with pkgs; [
        bibata-cursors
        ddcutil

        # Media codecs
        ffmpeg
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-ugly
        gst_all_1.gst-libav
        gst_all_1.gst-vaapi
      ];

      environment.variables = {
        QT_AUTO_SCREEN_SCALE_FACTOR = 1;
      };

      home-manager.users."${vars.userName}" =
        { ... }:
        {
          dconf.settings = {
            "org/gnome/desktop/interface" = {
              cursor-theme = "Bibata-Modern-Ice";
              font-name = "Quicksand 11";
              document-font-name = "Quicksand 11";
              monospace-font-name = "Google Sans Code 10";
            };
          };
        };

      services.gvfs.enable = true;
      services.flatpak.enable = true;
      systemd.services.flatpak-repo = {
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.flatpak ];
        script = ''
          flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        '';
      };

      systemd.services.flatpak-update = {
        description = "Update Flatpak apps and runtimes";
        after = [
          "network-online.target"
          "flatpak-repo.service"
        ];
        wants = [
          "network-online.target"
          "flatpak-repo.service"
        ];
        path = [ pkgs.flatpak ];
        serviceConfig = {
          Type = "oneshot";
        };
        script = ''
          flatpak update --system -y --noninteractive
        '';
      };

      systemd.timers.flatpak-update = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "5m";
          OnUnitActiveSec = "1d";
          Persistent = true;
          RandomizedDelaySec = "15m";
        };
      };

      fonts = {
        packages = with pkgs; [
          quicksand
          googlesans-code
        ];

        fontconfig = {
          defaultFonts = {
            serif = [ "Quicksand" ];
            sansSerif = [ "Quicksand" ];
            monospace = [
              "Google Sans Code"
            ];
          };

          hinting.style = "none";
          subpixel.rgba = "rgb";
        };
      };
    })
  ];
}
