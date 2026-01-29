{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.ushinnary.powerManagement.tuned;
in
{
  config = mkIf cfg.enable {
    services.tuned.enable = true;

    # Set the active profile
    environment.etc."tuned/active_profile".text = cfg.profile;

    # Create custom tuned profiles
    environment.etc = {
      "tuned/ryzen-desktop/tuned.conf" = {
        text = ''
          [main]
          summary=Profile for AMD Ryzen desktop with high performance
          include=throughput-performance

          [cpu]
          governor=performance
          scaling_max_freq=4000000
        '';
      };

      "tuned/ryzen-mobile/tuned.conf" = {
        text = ''
          [main]
          summary=Profile for AMD Ryzen mobile/laptop with balanced performance
          include=balanced

          [cpu]
          governor=performance
          scaling_max_freq=3000000
        '';
      };
    };
  };
}

