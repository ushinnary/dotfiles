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
      type = lib.types.nullOr lib.types.str;
      default = null;
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
          libva
        ]
        ++ lib.optional cfg.rocm rocmPackages.clr.icd;
      extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
    };

    hardware.amdgpu.opencl.enable = true;
    hardware.amdgpu.initrd.enable = true;

    boot.initrd.kernelModules = [ "amdgpu" ];
  };

}
