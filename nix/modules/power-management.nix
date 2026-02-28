{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.ushinnary.power;
  governorByProfile = {
    balanced = "schedutil";
    performance = "performance";
    powersave = "powersave";
  };
in
{
  config = mkIf cfg.enable {
    services.tuned.enable = mkForce false;
    services.system76-scheduler.enable = true;
    services.power-profiles-daemon.enable = mkForce cfg.profilesDaemon;

    powerManagement.cpuFreqGovernor = mkDefault governorByProfile.${cfg.profile};
    services.upower.enable = true;

    environment.systemPackages = mkIf cfg.system76Power [
      pkgs.system76-power
    ];

    systemd.services.system76-power = mkIf cfg.system76Power {
      description = "System76 Power daemon";
      wantedBy = [ "multi-user.target" ];
      after = [
        "dbus.service"
        "systemd-logind.service"
      ];
      serviceConfig = {
        ExecStart = "${pkgs.system76-power}/bin/system76-power daemon";
        Restart = "on-failure";
        RestartSec = "2s";
      };
    };
  };
}

