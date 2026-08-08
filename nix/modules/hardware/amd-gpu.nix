{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.ushinnary.gpu.amd;
in
{
  options.ushinnary.gpu.amd = {
    enable = lib.mkEnableOption "AMD GPU drivers";
    rocm = lib.mkEnableOption "Is ROCm supported";
    rocmOverrideGfx = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "rocmOverrideGfx used for ollama";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable OpenGL
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages =
        with pkgs;
        [
          mesa.opencl # Enables Rusticl (OpenCL) support
          vulkan-loader

        ]
        ++ lib.optional cfg.rocm rocmPackages.clr.icd;
    };

    hardware.amdgpu.opencl.enable = true;
    hardware.amdgpu.initrd.enable = true;

    boot.initrd.kernelModules = [ "amdgpu" ];
  };

}
