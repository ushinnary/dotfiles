{
  config,
  pkgs,
  ...
}:
let
  powerLimit = "120";
in
{
  systemd.services."set-nvidia-power-limit" = {
    description = "Set NVIDIA GPU Power Limit on Boot";
    path = [ config.hardware.nvidia.package ];
    script = ''
      nvidia-smi -pm ENABLED
      nvidia-smi -pl ${powerLimit}
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
}
