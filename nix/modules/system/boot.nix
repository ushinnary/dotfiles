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
    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot.enable = lib.mkDefault true;
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

  # NetworkManager-wait-online held multi-user.target (via tailscaled)
  # for ~20s waiting for full connectivity. Desktop use doesn't need it.
  # (systemd.network.wait-online is systemd-networkd's, unused here.)
  systemd.services.NetworkManager-wait-online.enable = false;

  # ModemManager is for cellular modems — not needed on desktops
  systemd.services.ModemManager.enable = lib.mkForce false;

  # Garbage collection runs via programs.nh.clean (system/packages.nix).
  # Dedup the store on a schedule instead of auto-optimise-store, which
  # hard-links on every store write and slows down every build.
  nix.optimise.automatic = true;
}
