{ pkgs, lib, vars, ... }:
{
  boot = {
    # Enable "Silent boot"
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "quiet"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];

    # Plymouth disabled for faster boot (~3.8s saving)
    plymouth.enable = false;

    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 0;
    loader.systemd-boot.enable = true;
    initrd.systemd.enable = true;
  };

  zramSwap.enable = true;
  zramSwap.algorithm = "zstd";

  hardware.bluetooth.enable = true;

  # ── Boot time optimizations ───────────────────────────────────

  # NetworkManager-wait-online blocks boot for ~9s waiting for full
  # network connectivity. Desktop use doesn't need this.
  systemd.services.NetworkManager-wait-online.enable = false;

  # ModemManager is for cellular modems — not needed on desktops
  systemd.services.ModemManager.enable = lib.mkForce false;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 3d";
  };
  nix.settings.auto-optimise-store = true;
  services.fstrim.enable = true;
  services.openssh = {
    enable = true;
  };

  # ── Journald log size limits ──────────────────────────────────
  services.journald.extraConfig = ''
    SystemMaxUse=1G
    MaxRetentionSec=2weeks
  '';

  # ── Automatic weekly rebuild from local dotfiles flake ────────
  # Applies any pending dotfile changes without manual intervention.
  # Run `nix flake update` in ~/dotfiles/nix to also pull new nixpkgs.
  system.autoUpgrade = {
    enable = true;
    flake = "/home/${vars.userName}/dotfiles/nix";
    allowReboot = false;
    dates = "weekly";
    randomizedDelaySec = "45min";
  };
}
