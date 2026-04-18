{
  frequency ? null,
}:
{ lib, pkgs, ... }:
let
  inherit (lib) mkIf optionalString;

  frequencyPattern = "^[0-9]{4,}Mhz$";

  hasFrequency = frequency != null;

  validFrequency = hasFrequency && builtins.match frequencyPattern frequency != null;
in
{

  config = mkIf hasFrequency {
    powerManagement.enable = true;

    assertions = [
      {
        assertion = !hasFrequency || validFrequency;
        message = ''
          cpu-max-frequency.nix: `frequency` must match ${frequencyPattern}
          (example: "3000Mhz").
        '';
      }
    ];

    systemd.services.cpu-max-frequency = {
      description = "Set CPU max frequency to ${frequency}";
      wantedBy = [ "multi-user.target" ];
      after = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ${pkgs.linuxPackages.cpupower}/bin/cpupower frequency-set --max ${frequency}
      '';
    };
  };
}
