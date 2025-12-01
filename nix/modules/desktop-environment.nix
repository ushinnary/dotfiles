{ pkgs, ... }:
{

  import = [
    ./DE/gnome.nix
  ];
  environment.systemPackages = with pkgs; [
    bibata-cursors
  ];
  services.power-profiles-daemon.enable = true;

  services.gvfs.enable = true;
  services.flatpak.enable = true;

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
