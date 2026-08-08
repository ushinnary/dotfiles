{
  pkgs,
  lib,
  ...
}:
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
      "splash"
    ];

    # Plymouth disabled for faster boot (~3.8s saving)
    plymouth.enable = false;

    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 0;
    loader.systemd-boot.enable = lib.mkForce true;
    # ESP is only 1G (see disko-luks-btrfs.nix) — cap kept generations
    # so kernels/initrds don't slowly fill it up.
    loader.systemd-boot.configurationLimit = 10;
    initrd.systemd.enable = true;
  };

  zramSwap.enable = true;
  zramSwap.algorithm = "zstd";

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
    settings = {
      General = {
        # Shows battery charge of connected devices on supported
        # Bluetooth adapters. Defaults to 'false'.
        Experimental = true;
      };
    };
  };

  # ── Boot time optimizations ───────────────────────────────────

  # NetworkManager-wait-online blocks boot for ~9s waiting for full
  # network connectivity. Desktop use doesn't need this.
  systemd.network.wait-online.enable = false;

  # ModemManager is for cellular modems — not needed on desktops
  systemd.services.ModemManager.enable = lib.mkForce false;

  # NVMe has plenty of headroom, so favor rollback safety over
  # aggressively reclaiming space: keep two weeks of generations.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.settings.auto-optimise-store = true;
}
