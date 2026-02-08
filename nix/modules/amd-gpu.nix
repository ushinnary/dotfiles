{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.ushinnary.amd;
in
{

  imports = [
  ];

  config = mkIf cfg.enable {
    # Enable OpenGL
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    hardware.amdgpu.opencl.enable = true;
    hardware.amdgpu.initrd.enable = true;

  };

}
