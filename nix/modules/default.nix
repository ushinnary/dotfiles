{...}: {
  imports = [
    ./system/boot.nix
    ./system/locale.nix
    ./system/location.nix
    ./system/users.nix
    ./system/security.nix
    ./system/firewall.nix
    ./system/packages.nix
    ./hardware/nvidia-gpu.nix
    ./hardware/amd-gpu.nix
    ./hardware/secure-boot.nix
    ./desktop/desktop-environment.nix
    ./desktop/audio.nix
    ./services/services.nix
    ./services/homelab.nix
    ./services/virtualisation.nix
    ./apps/applications.nix
    ./apps/gaming.nix
    ./apps/dev.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # Flake-only: NIX_PATH and the `nixpkgs` registry entry already point at
  # this flake's nixpkgs input, so legacy channels would only drift.
  nix.channel.enable = false;
  # Builds (rebuilds, devenv) only get CPU/disk time nothing interactive
  # wants, so the desktop stays responsive. Trade-off: they crawl while
  # something else is busy (e.g. a game).
  nix.daemonCPUSchedPolicy = "idle";
  nix.daemonIOSchedClass = "idle";

  hardware.enableRedistributableFirmware = true;
}
