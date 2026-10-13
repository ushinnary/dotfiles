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

  # Flatpak sandboxes see the host fonts but not /etc/fonts, so generic
  # families (sans-serif, system-ui, …) fell back to DejaVu Sans. Fontconfig
  # in the sandbox only reads the per-app $XDG_CONFIG_HOME, so this file is
  # passed as FONTCONFIG_FILE: it loads the runtime's own config, then puts
  # the host's default fonts first. Sandboxes only mount the store paths
  # behind host font/icon dirs, so it's copied out as a real file.
  flatpakFontsConfPath = "/home/${vars.userName}/.config/fontconfig/flatpak.conf";
  flatpakFontsConf = let
    defaults = config.fonts.fontconfig.defaultFonts;
    prefer = generic: families:
      lib.optionalString (families != []) ''
        <match target="pattern">
          <test qual="any" name="family"><string>${generic}</string></test>
          <edit name="family" mode="prepend" binding="strong">${lib.concatMapStrings (f: "<string>${f}</string>") families}</edit>
        </match>
      '';
  in
    pkgs.writeText "flatpak-fonts.conf" ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
      <fontconfig>
        <include>/etc/fonts/fonts.conf</include>
        ${prefer "sans-serif" defaults.sansSerif}
        ${prefer "system-ui" defaults.sansSerif}
        ${prefer "serif" defaults.serif}
        ${prefer "monospace" defaults.monospace}
      </fontconfig>
    '';
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
          hplip
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
      # Avahi: DNS-SD browsing for SMB shares (gvfs network:// in
      # Nautilus) and .local names via nss-mdns. One mDNS stack per
      # host, so resolved's own mDNS responder is off.
      services.avahi.enable = true;
      services.avahi.nssmdns4 = true;
      services.resolved.settings.Resolve.MulticastDNS = "no";

      powerManagement = {
        enable = true;
      };
      services.upower.enable = true;
      hardware.sane.enable = true;
      services.colord.enable = true;
      hardware.sensor.iio.enable = config.ushinnary.hardware.hasWebCam;

      # Loads i2c-dev and grants the i2c group access (ddcutil brightness).
      hardware.i2c.enable = true;
      services.udev.extraRules = ''
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

      home-manager.users."${vars.userName}" = {
        pkgs,
        lib,
        ...
      }: {
        # Single cursor definition for apps: XCURSOR_* (XWayland, Electron,
        # Flatpak), ~/.icons/default and, via gtk.enable, GTK settings + dconf.
        # niri's own copy is DMS-managed (niri/.config/niri/dms/cursor.kdl).
        home.pointerCursor = {
          enable = true;
          name = "Bibata-Modern-Ice";
          package = pkgs.bibata-cursors;
          size = 20;
          gtk.enable = true;
        };

        # Global Flatpak overrides, declared instead of `flatpak override`.
        # No XCURSOR_PATH: Flatpak already points it at the host's icon dirs
        # (/run/host/share/icons), which carry the cursor themes.
        xdg.dataFile."flatpak/overrides/global".text = ''
          [Context]
          filesystems=xdg-config/gtk-3.0:ro;xdg-config/fontconfig:ro;

          [Environment]
          FONTCONFIG_FILE=${flatpakFontsConfPath}
        '';
        # Host fontconfig only reads fonts.conf and conf.d/ here, so this
        # file affects Flatpak sandboxes only.
        home.activation.flatpakFontsConf = lib.hm.dag.entryAfter ["writeBoundary"] ''
          run install -Dm644 ${flatpakFontsConf} ${lib.escapeShellArg flatpakFontsConfPath}
        '';

        dconf.settings = {
          "org/gnome/desktop/interface" = {
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

          # Grayscale AA, no hinting (as on macOS): subpixel AA fringes
          # under fractional scaling and isn't needed on HiDPI panels.
          hinting.style = "none";
          subpixel.rgba = "none";
        };
      };
    })
  ];
}
