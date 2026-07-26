{
  config,
  lib,
  ...
}:
let
  cfg = config.ushinnary.gpu.nvidia;
in
{
  options.ushinnary.gpu.nvidia = {
    enable = lib.mkEnableOption "NVIDIA GPU drivers";
    openDriver = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use the open-source NVIDIA kernel driver";
    };
    powerLimit = lib.mkOption {
      type = with lib.types; either bool int;
      default = false;
      description = "Power limit in watts for the NVIDIA GPU, or false to leave unchanged";
    };
  };

  imports = [
    ./nvidia-power-limit.nix
  ];

  config = lib.mkIf cfg.enable {
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
      open = cfg.openDriver;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

}
