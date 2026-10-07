{
  config,
  lib,
  pkgs,
  vars,
  ...
}: let
  cfg = config.ushinnary.desktop;
  electronFlagsSrc = "${../../../electron/.config/electron-flags.conf}";
  edgeFlagsAmdSrc = "${../../../flatpaks/.var/app/com.microsoft.Edge/config/edge-flags-amd.conf}";
in {
  options.ushinnary.hardware = {
    hasWebCam = lib.mkEnableOption "system has a webcam (enables clight for automatic brightness via camera)";
  };
  options.ushinnary.desktop = {
    gnome = lib.mkEnableOption "GNOME desktop environment";
    cosmic = lib.mkEnableOption "COSMIC desktop environment";
    plasma = lib.mkEnableOption "Plasma desktop environment";
    niri = lib.mkEnableOption "Niri Wayland compositor";
  };
  options.ushinnary.display = {
    oled = lib.mkEnableOption "OLED-specific optimizations (HDR, deeper blacks)";
  };

  imports = [
    ./DE/gnome.nix
    ./DE/cosmic.nix
    ./DE/plasma.nix
    ./DE/niri/default.nix
  ];

  config = lib.mkMerge [
    {
      services.tuned = {
        enable = true;
        ppdSettings.main.default = "balanced";
      };
    }
    (lib.mkIf (cfg.gnome || cfg.cosmic || cfg.plasma || cfg.niri) {
      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
      };

      security = {
        polkit.enable = true;
      };
      # Enable CUPS printing services
      # CUPS (Common Unix Printing System) handles all printer communication
      services.printing = {
        enable = true;

        # Required drivers for most modern printers
        # cups-filters: provides filters for converting documents to printer-ready formats
        drivers = with pkgs; [
          cups-filters
          gutenprint
          hplipWithPlugin
        ];

        # cups-browsed defaults to on with Avahi; CUPS already discovers
        # IPP Everywhere printers via mDNS, and cups-browsed was part of
        # the 2024 CUPS RCE chain.
        browsed.enable = false;
      };

      # mDNS/Avahi (5353) is reachable via the LAN/Tailscale/WireGuard
      # trustedInterfaces set in system/firewall.nix — no need to open
      # it globally (the Avahi module opens it by default).
      services.avahi.openFirewall = false;

      powerManagement = {
        enable = true;
      };
      services.upower.enable = true;
      hardware.sane.enable = true;
      services.colord.enable = true;
      hardware.sensor.iio.enable = config.ushinnary.hardware.hasWebCam;
      services.avahi.enable = true; # For network discovery of printers and other devices

      boot.kernelModules = ["i2c-dev"];
      hardware.i2c.enable = true;
      services.udev.extraRules = ''
        KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
        ACTION=="add", SUBSYSTEM=="usb", ATTR{power/control}="on"
      '';
      users.users."${vars.userName}".extraGroups = [
        "i2c"
        "scanner"
        "lp"
      ];

      environment.systemPackages = with pkgs; [
        bibata-cursors
        ddcutil

        # backends for extraction
        unzip
        p7zip
        unrar
        gnutar
        gzip
        bzip2
        xz

        # Media codecs
        ffmpeg
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-ugly
        gst_all_1.gst-libav
      ];

      environment.variables = {
        QT_AUTO_SCREEN_SCALE_FACTOR = 1;
      };

      home-manager.users."${vars.userName}" = {pkgs, ...}: {
        dconf.settings = {
          "org/gnome/desktop/interface" = {
            cursor-theme = "Bibata-Modern-Ice";
            font-name = "Google Sans Flex 11";
            document-font-name = "Google Sans Flex 11";
            monospace-font-name = "Google Sans Code 10";
          };
        };

        systemd.user.services.copy-wayland-flags = {
          Unit = {
            Description = "Copy Electron and Edge flags for Wayland sessions";
            After = ["graphical-session.target"];
            PartOf = ["graphical-session.target"];
          };

          Install = {
            WantedBy = ["graphical-session.target"];
          };

          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.writeShellScript "copy-wayland-flags" ''
              set -eu

              if [ "''${XDG_SESSION_TYPE:-}" != "wayland" ] && [ -z "''${WAYLAND_DISPLAY:-}" ]; then
                exit 0
              fi

              ${pkgs.coreutils}/bin/install -Dm644 ${electronFlagsSrc} "$HOME/.config/electron-flags.conf"
              ${lib.optionalString config.ushinnary.gpu.amd.enable ''
                ${pkgs.coreutils}/bin/install -Dm644 ${edgeFlagsAmdSrc} "$HOME/.var/app/com.microsoft.Edge/config/edge-flags.conf"
              ''}
            ''}";
          };
        };
      };

      services.gvfs.enable = true;
      services.flatpak.enable = true;

      # Edge's Hunspell spellchecker hangs whole tabs on some ru/fr input; there is no
      # CLI switch for it. The Edge flatpak links host /etc/opt/edge/policies/*/*.json
      # via `find -type f`, so this must be a real file, not a store symlink.
      environment.etc."opt/edge/policies/managed/spellcheck.json" = {
        text = builtins.toJSON {SpellcheckEnabled = false;};
        mode = "0444";
      };
      # Adding Flathub lives here rather than in a boot-time unit: remote-add
      # downloads the .flatpakrepo file, which failed at boot before DNS was
      # up. This runs from the timer below (5 min after boot, then daily).
      systemd.services.flatpak-update = {
        description = "Add Flathub and update Flatpak apps and runtimes";
        after = ["network-online.target"];
        wants = ["network-online.target"];
        path = [pkgs.flatpak];
        serviceConfig = {
          Type = "oneshot";
        };
        script = ''
          flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
          flatpak update --system -y --noninteractive
        '';
      };

      systemd.timers.flatpak-update = {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnBootSec = "5m";
          OnUnitActiveSec = "1d";
          Persistent = true;
          RandomizedDelaySec = "15m";
        };
      };

      fonts = {
        packages = with pkgs; [
          googlesans-code
          (callPackage ../../pkgs/google-sans-flex.nix {})
        ];

        fontconfig = {
          defaultFonts = {
            serif = ["Google Sans Flex"];
            sansSerif = ["Google Sans Flex"];
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
