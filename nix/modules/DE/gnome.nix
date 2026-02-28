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
  config = mkIf cfg.gnome {
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    # Environment variables for GNOME session
    environment.sessionVariables = {
      FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";
    };

    # Enable printing service
    services.printing.enable = true;

    # To disable installing GNOME's suite of applications
    # and only be left with GNOME shell.
    services.gnome.core-apps.enable = false;
    services.gnome.core-developer-tools.enable = false;
    services.gnome.games.enable = false;
    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      gnome-user-docs
      epiphany
      gnome-music
    ];

    programs.dconf.enable = true;
    programs.dconf.profiles.user.databases = [
      {
        settings = {
          "org/gnome/mutter" = {
            experimental-features = [
              "scale-monitor-framebuffer" # Enables fractional scaling (125% 150% 175%)
              "variable-refresh-rate" # Enables Variable Refresh Rate (VRR) on compatible displays
              "xwayland-native-scaling" # Scales Xwayland applications to look crisp on HiDPI screens
            ];
          };
          "org/gnome/desktop/peripherals/mouse" = {
            natural-scroll = true; # Enable inverted/natural scroll for mouse
            acceleration-profile = "flat"; # Use flat acceleration profile for mouse
          };
          "org/gnome/desktop/wm/keybindings" = {
            close = [
              "<Alt>F4"
              "<Super>q"
            ];
            switch-to-workspace-left = [ "<Super>h" ];
            switch-to-workspace-right = [ "<Super>l" ];
            move-to-workspace-left = [ "<Super><Shift>h" ];
            move-to-workspace-right = [ "<Super><Shift>l" ];
            minimize = gvariant.mkEmptyArray (gvariant.type.string);
            maximize = [ "<Super>f" ];
            show-desktop = [ "<Super>d" ];
          };
          "org/gnome/desktop/interface" = {
            cursor-theme = "Bibata-Modern-Ice";
          };
          "org/gnome/desktop/input-sources" = {
            per-window = true;
            sources = [
              (gvariant.mkTuple [
                "xkb"
                "us"
              ])
              (gvariant.mkTuple [
                "xkb"
                "ru"
              ])
            ];
            mru-sources = [
              (gvariant.mkTuple [
                "xkb"
                "us"
              ])
            ];
          };
          "org/gnome/shell/app-switcher" = {
            current-workspace-only = true;
          };
          "org/gnome/shell" = {
            enabled-extensions = [
              "appindicatorsupport@rgcjonas.gmail.com"
              "dash-to-dock@micxgx.gmail.com"
              "gsconnect@andyholmes.github.io"
              "nightthemeswitcher@romainvigier.fr"
            ];
          };
          "org/gnome/settings-daemon/plugins/media-keys" = {
            custom-keybindings = [
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
            ];
            screensaver = gvariant.mkEmptyArray (gvariant.type.string);
          };
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
            name = "Terminal ";
            binding = "<Super>t";
            command = "ghostty";
          };
          "org/freedesktop/tracker/miner/files" = {
            index-single-directories = gvariant.mkEmptyArray (gvariant.type.string);
            index-recursive-directories = gvariant.mkEmptyArray (gvariant.type.string);
          };
        };
      }
    ];

    services.udev.packages = [ pkgs.gnome-settings-daemon ];
    programs.kdeconnect = {
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };
    environment.systemPackages = with pkgs; [
      gnomeExtensions.appindicator
      gnomeExtensions.night-theme-switcher
      gnomeExtensions.dash-to-dock
      nautilus
      sushi
      gnome-calculator
      gnome-calendar
      gnome-characters
      gnome-clocks
      gnome-contacts
      gnome-weather
      simple-scan
      loupe
      showtime
      dconf-editor
      simple-scan
      adwaita-icon-theme
      adwaita-fonts
      gnome-tweaks
      refine
      pavucontrol
      gnome-disk-utility
      # Passwords and Keys
      seahorse
    ];
    security.pam.services = {
      login.enableGnomeKeyring = true;
      gdm.enableGnomeKeyring = true;
    };

    services.gnome.gnome-keyring.enable = true;
    services.colord.enable = true;
  };
}
