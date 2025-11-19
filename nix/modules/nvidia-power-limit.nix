{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.my.nvidia;
in
{
  options = {
    my.nvidia.powerLimit = lib.mkOption {
      type = lib.types.ints.positive;
      description = "Set power limit to nvidia GPU";
      default = 120;
    };
  };

  config = mkIf cfg.enable {
    systemd.services."set-nvidia-power-limit" = {
      description = "Set NVIDIA GPU Power Limit on Boot";
      path = [ config.hardware.nvidia.package ];
      script = ''
        nvidia-smi -pm ENABLED
        nvidia-smi -pl ${toString cfg.powerLimit}
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
      };
      wantedBy = [ "multi-user.target" ];
      after = [
        "display.manager.service"
        "multi-user.target"
      ];
    };
  };
}
