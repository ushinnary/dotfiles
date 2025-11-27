{
  lib,
  ...
}:
with lib;
{
  options = {
    ushinnary.nvidia.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable NVIDIA GPU Drivers for desktop PC";
    };

    ushinnary.software.enableDevPackages = mkOption {
      type = types.bool;
      default = true;
      description = "Enable all dev packages with Nixvim included";
    };

    ushinnary.cpu.isAmd = mkOption {
      type = types.bool;
      default = true;
      description = "Apply AMD tweaks for CPU";
    };

  };

  imports = [
    ./nvidia-gpu.nix
    ./applications.nix
    ./boot.nix
    ./audio.nix
    ./desktop-environment.nix
    ./dev.nix
    ./firewall.nix
    ./gaming.nix
    ./locale.nix
    ./packages.nix
    ./users.nix
    ./virtualisation.nix
    ./services.nix
  ];
}
