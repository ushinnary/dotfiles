{ drives }:
{ lib, ... }:
{
  imports = [ ];

  disko.devices = builtins.foldl' (acc: drive:
    acc // {
      "${drive.label}" = {
        type = "disk";
        device = drive.device;
        content = {
          type = "gpt";
          partitions = {
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypt-${drive.label}";
                askPassword = false;
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "btrfs";
                  subvolumes = {
                    "/data" = {
                      mountpoint = drive.mountPoint;
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                  };
                };
              };
            };
          };
        };
      };
    }
  ) {} drives;
}