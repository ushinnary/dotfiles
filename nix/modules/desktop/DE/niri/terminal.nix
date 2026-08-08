{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.ushinnary.desktop;
in
{
  config = lib.mkIf cfg.niri {
    # ── Terminal package ───────────────────────────────────────────
    environment.systemPackages = with pkgs; [
      ghostty
    ];
  };
}
