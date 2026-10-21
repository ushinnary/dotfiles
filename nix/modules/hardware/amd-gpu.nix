{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.ushinnary.gpu.amd;
in {
  options.ushinnary.gpu.amd = {
    enable = lib.mkEnableOption "AMD GPU drivers";
    rocm = lib.mkEnableOption "ROCm runtime (ROCm OpenCL, ollama-rocm)";
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
      extraPackages = with pkgs; [
        mesa.opencl # Enables Rusticl (OpenCL) support
      ];
    };

    # Adds ROCm's clr + clr.icd (~900 MiB); Rusticl covers OpenCL otherwise,
    # but only exposes the GPU when its driver is listed in RUSTICL_ENABLE.
    hardware.amdgpu.opencl.enable = cfg.rocm;
    environment.sessionVariables.RUSTICL_ENABLE = lib.mkIf (!cfg.rocm) "radeonsi";
    # amdgpu stays out of the initrd: loading it there held stage 1 for
    # ~2.3s on ryzo, while after switch-root it initialises in parallel
    # with the rest of boot. The LUKS prompt uses the EFI framebuffer.
  };
}
