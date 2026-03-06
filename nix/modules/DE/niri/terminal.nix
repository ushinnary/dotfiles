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
  config = mkIf cfg.niri {
    # ── Terminal package ───────────────────────────────────────────
    environment.systemPackages = with pkgs; [
      ghostty
    ];
  };
}
