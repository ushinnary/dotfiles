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
    ./DE/niri.nix
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
          nerd-fonts.jetbrains-mono
        ];

        fontconfig = {
          defaultFonts = {
            serif = [ "Inter" ];
            sansSerif = [ "Inter" ];
            monospace = [
              "JetBrainsMono Nerd Font"
              "JetBrainsMono Nerd Font Mono"
              "JetBrains Mono"
            ];
          };

          hinting.style = "none";
          subpixel.rgba = "rgb";
        };
      };
    })
  ];
}
