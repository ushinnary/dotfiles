{...}: {
  # Compressed swap in RAM. Kept on big-RAM hosts too: it costs nothing
  # until used, holds cold pages so more RAM stays page cache, and gives
  # systemd-oomd's swap rule below something to watch.
  zramSwap.enable = true;
  zramSwap.algorithm = "zstd";

  # Tuned for zram as the primary swap (kernel docs / ArchWiki values).
  boot.kernel.sysctl = {
    # Swapping to zram is cheaper than re-reading evicted page cache.
    "vm.swappiness" = 180;
    # zram has no seek cost, so swap-in readahead only wastes work.
    "vm.page-cluster" = 0;
    # Start background reclaim earlier (1.25% free) instead of stalling
    # allocations in direct reclaim; don't over-reclaim after spikes.
    "vm.watermark_scale_factor" = 125;
    "vm.watermark_boost_factor" = 0;
  };

  # Fedora's desktop policy: kill the runaway cgroup (a build, a
  # language server, …) instead of letting the session freeze.
  systemd.oomd = {
    # Memory-pressure kills inside user sessions (NixOS's limit: 80%).
    enableUserSlices = true;
  };
  # …and the largest swap user once zram is 90% full (oomd's SwapUsedLimit).
  systemd.slices."-".sliceConfig.ManagedOOMSwap = "kill";
}
