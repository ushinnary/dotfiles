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

    services.udev.packages = [ pkgs.gnome-settings-daemon ];
    services.gnome.sushi.enable = true;
    programs.kdeconnect = {
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };
    environment.systemPackages = with pkgs; [
      nautilus
      gnome-calculator
      gnome-calendar
      gnome-characters
      gnome-clocks
      gnome-contacts
      gnome-weather
      gnome-console
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
      ffmpegthumbnailer
      # Passwords and Keys
      seahorse
    ];
    security.pam.services = {
      login.enableGnomeKeyring = true;
      gdm.enableGnomeKeyring = true;
    };

    services.gnome.gnome-keyring.enable = true;
  };
}
