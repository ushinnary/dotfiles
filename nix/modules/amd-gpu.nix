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
  config = mkIf cfg.enable {
    # Enable OpenGL
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        mesa.opencl # Enables Rusticl (OpenCL) support
        vulkan-loader
      ];
    };

    hardware.amdgpu.opencl.enable = true;
    hardware.amdgpu.initrd.enable = true;

    boot.initrd.kernelModules = [ "amdgpu" ];
  };

}
