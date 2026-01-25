{ pkgs, ... }:
{

  imports = [
    ./DE/gnome.nix
    ./DE/cosmic.nix
  ];
  environment.systemPackages = with pkgs; [
    bibata-cursors
  ];
  services.power-profiles-daemon.enable = true;

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

}
