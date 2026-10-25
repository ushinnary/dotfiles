{
  config,
  lib,
  pkgs,
  ...
}: {
  options.ushinnary.desktop.nautilus = lib.mkEnableOption "Nautilus file manager with Sushi previews and extra thumbnailers";

  config = lib.mkIf config.ushinnary.desktop.nautilus {
    # Quick Look-style previews (space bar).
    services.gnome.sushi.enable = true;

    environment.systemPackages = with pkgs; [
      nautilus
      # Nautilus' wrapper already bundles image/WebP/SVG/JXL thumbnailers;
      # these add video + audio cover art, and HEIC/AVIF. libheif's
      # .thumbnailer lives in `out`, which isn't installed by default.
      ffmpegthumbnailer
      libheif.out
    ];
  };
}
