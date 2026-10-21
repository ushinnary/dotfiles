{...}: let
  g435Sink = "alsa_output.usb-Logitech_G_series_G435_Wireless_Gaming_Headset_202105190004-00.analog-stereo";
in {
  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;

    extraConfig = {
      pipewire = {
        # Let the graph follow the stream's rate (44.1k music, 96k files)
        # on devices that support it, instead of resampling all to 48k.
        "10-clock-rates"."context.properties"."default.clock.allowed-rates" = [
          44100
          48000
          88200
          96000
        ];

        # AutoEq profile for the G435 (its dongle only does 48k). A
        # WirePlumber smart filter: it's linked in front of the headset only
        # while audio is routed there, so other outputs stay untouched and
        # the headset itself remains the selectable/default sink.
        "20-g435-eq"."context.modules" = [
          {
            name = "libpipewire-module-filter-chain";
            flags = ["nofail"];
            args = {
              "node.description" = "Logitech G435 (AutoEq)";
              "media.name" = "Logitech G435 (AutoEq)";
              "audio.channels" = 2;
              "audio.position" = [
                "FL"
                "FR"
              ];
              "filter.graph" = {
                nodes = [
                  {
                    type = "builtin";
                    name = "eq";
                    label = "param_eq";
                    # EqualizerAPO format, as exported by AutoEq; the
                    # Preamp line must stay first (param_eq reads it there).
                    config.filename = "${./autoeq/logitech-g435.txt}";
                  }
                ];
                inputs = [
                  "eq:In 1"
                  "eq:In 2"
                ];
                outputs = [
                  "eq:Out 1"
                  "eq:Out 2"
                ];
              };
              "capture.props" = {
                "node.name" = "effect_input.g435_eq";
                "media.class" = "Audio/Sink";
                "filter.smart" = true;
                "filter.smart.name" = "g435-eq";
                "filter.smart.target"."node.name" = g435Sink;
              };
              "playback.props" = {
                "node.name" = "effect_output.g435_eq";
                "node.passive" = true;
              };
            };
          }
        ];
      };

      # Resampling happens client-side; 10 (default 4) is far cleaner and
      # still cheap on a desktop CPU.
      client."10-resample"."stream.properties"."resample.quality" = 10;
      pipewire-pulse."10-resample"."stream.properties"."resample.quality" = 10;
    };
  };
}
