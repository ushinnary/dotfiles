{
  config,
  lib,
  pkgs,
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
    ./DE/niri/default.nix
  ];

  config = mkMerge [
    {
      # Keep power-profiles-daemon disabled by default when Rust power stack is enabled
      services.power-profiles-daemon.enable = mkDefault (!config.ushinnary.power.enable);
    }
    (mkIf (cfg.gnome || cfg.cosmic || cfg.niri) {
      environment.systemPackages = with pkgs; [
        bibata-cursors
      ];

      environment.variables = {
        QT_AUTO_SCREEN_SCALE_FACTOR = 1;
      };

      home-manager.users.ushinnary = { ... }: {
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
          flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        '';
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
