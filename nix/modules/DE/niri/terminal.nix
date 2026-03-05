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

    home-manager.users.ushinnary =
      { ... }:
      {
        xdg.configFile."ghostty/config".text = ''
          theme = dark:Catppuccin Mocha,light:Catppuccin Latte
          font-family = JetBrains Mono
          font-size = 12
          background-opacity = 0.88
          background-opacity-cells = true
          background-blur = true
        '';
      };
  };
}
