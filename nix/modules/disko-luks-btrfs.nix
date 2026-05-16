{
  device,
  swapSize ? "16G",
  isSsd ? true,
  luks ? true, # 1. Added luks parameter with true by default
}:
{
  inputs,
  lib,
  ...
}:
let
  # 2. Extracted Btrfs partitioning so it can be reused with or without LUKS
  btrfsContent = {
    type = "btrfs";
    extraArgs = [ "-f" ];
    subvolumes = {
      "/root" = {
        mountpoint = "/";
        mountOptions = [
          "compress=zstd"
          "noatime"
          "subvol=root"
        ];
      };

      "/home" = {
        mountpoint = "/home";
        mountOptions = [
          "compress=zstd"
          "noatime"
          "subvol=home"
        ];
      };

      "/nix" = {
        mountpoint = "/nix";
        mountOptions = [
          "compress=zstd"
          "noatime"
          "subvol=nix"
        ];
      };
    }
    // lib.optionalAttrs (swapSize != "0G") {
      "/swap" = {
        mountpoint = "/.swapvol";
        mountOptions = [
          "noatime"
          "nodatacow"
          "nodatasum"
        ]
        ++ lib.optionals isSsd [ "discard=async" ];
        swap.swapfile.size = swapSize;
      };
    };
  };
in
{
  imports = [ inputs.disko.nixosModules.disko ];

  boot.supportedFilesystems = [ "btrfs" ];

  disko.devices.disk.main = {
    type = "disk";
    inherit device;
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
      }
      // (
        if luks then
          {
            # 3. If luks is true, wrap btrfsContent inside the LUKS layer
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptroot";
                askPassword = true;
                settings = {
                  bypassWorkqueues = isSsd;
                  allowDiscards = true;
                };
                content = btrfsContent;
              };
            };
          }
        else
          {
            # 4. If luks is false, map btrfsContent directly to the partition root
            root = {
              size = "100%";
              content = btrfsContent;
            };
          }
      );
    };
  };
}

