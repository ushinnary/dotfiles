{
  lib,
  ...
}:
with lib;
{
  options = {
    my.nvidia.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable NVIDIA GPU Drivers for desktop PC";
    };

    my.software.enableDevPackages = mkOption {
      type = types.bool;
      default = true;
      description = "Enable all dev packages with Nixvim included";
    };

    my.cpu.isAmd = mkOption {
      type = types.bool;
      default = true;
      description = "Apply AMD tweaks for CPU";
    };

  };

  imports = [
    ./nvidia-gpu.nix
    ./applications.nix
    ./boot.nix
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
