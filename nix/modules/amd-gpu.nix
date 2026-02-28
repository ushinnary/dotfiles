{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.ushinnary.gpu.amd;
in
{

  imports = [
  ];

  config = mkIf cfg.enable {
    # Enable OpenGL
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        mesa.opencl # Enables Rusticl (OpenCL) support
      ];
    };

    hardware.amdgpu.opencl.enable = true;
    hardware.amdgpu.initrd.enable = true;

  };

}
