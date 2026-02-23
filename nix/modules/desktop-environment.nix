{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.ushinnary.desktopEnvironment;
in
{
  imports = [
    ./DE/gnome.nix
    ./DE/cosmic.nix
  ];

  config = mkMerge [
    {
      # Keep power-profiles-daemon disabled by default when Rust power stack is enabled
      services.power-profiles-daemon.enable = mkDefault (!config.ushinnary.powerManagement.rust.enable);
    }
    (mkIf (cfg.gnome || cfg.cosmic) {
      environment.systemPackages = with pkgs; [
        bibata-cursors
      ];

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
          inter
          jetbrains-mono
        ];

        fontconfig = {
          defaultFonts = {
            serif = [ "Inter" ];
            sansSerif = [ "Inter" ];
            monospace = [ "JetBrains Mono" ];
          };

          hinting.style = "none";
          subpixel.rgba = "rgb";
        };
      };
    })
  ];
}
