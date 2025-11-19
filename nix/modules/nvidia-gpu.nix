{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.my.nvidia;
in
{

  imports = [
    ./nvidia-power-limit.nix
  ];

  config = mkIf cfg.enable {
    # Enable OpenGL
    hardware.graphics = {
      enable = true;
    };

    # Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    services.ollama = {
      enable = true;
      acceleration = "cuda";
    };

    environment.systemPackages = with pkgs; [
      davinci-resolve-studio
    ];
  };

}
