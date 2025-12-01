{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.ushinnary.nvidia;
in
{
  # Option declarations for NVIDA are centralised in modules/options.nix

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
