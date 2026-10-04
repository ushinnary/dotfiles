{
  config,
  pkgs,
  lib,
  vars,
  ...
}:
let
  cfg = config.ushinnary.gaming;
  displayCfg = config.ushinnary.display;
in
{
  options.ushinnary.gaming.enable = lib.mkEnableOption "gaming packages and configuration (Steam, Gamescope, etc.)";

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [ "ntsync" ];
    programs = {
      steam = {
        enable = true;
        # Not opened globally: Remote Play/dedicated-server ports are
        # only reachable via the LAN/Tailscale/WireGuard
        # trustedInterfaces set in system/firewall.nix.
        remotePlay.openFirewall = false;
        dedicatedServer.openFirewall = false;

        # "Steam" session in the greeter: Big Picture on Gamescope's DRM
        # backend. Unlike niri it can tear, so with V-Sync off frames
        # don't wait for the next refresh.
        gamescopeSession = {
          enable = true;
          args = [ "--immediate-flips" ];
          # Games present straight to Gamescope (bypassing Xwayland) via
          # its WSI layer. Scoped to this session, not set globally.
          env.ENABLE_GAMESCOPE_WSI = "1";
        };
      };

      gamescope = {
        enable = true;
        enableWsi = true;
        # Keep off: the capability wrapper hands cap_sys_nice down to
        # child processes, and Steam's bwrap sandbox refuses to start
        # with it ("Unexpected capabilities but not setuid").
        capSysNice = false;
      };

      gamemode.enable = true;
    };

    environment.systemPackages = [
      pkgs.mangohud
      pkgs.clinfo
      pkgs.vulkan-tools
    ];

    # No LD_BIND_NOW here: as a global variable it forces eager symbol
    # binding for every process on the system. Set it per game in Steam
    # launch options if one needs it.
    environment.variables = {
      PROTON_USE_NTSYNC = "1";
      # HDR Support for OLED
      ENABLE_HDR_WSI = if displayCfg.oled then "1" else "0";
      DXVK_HDR = if displayCfg.oled then "1" else "0";

      # Hardware specific variables
      PROTON_ENABLE_NVAPI = if config.ushinnary.gpu.nvidia.enable then "1" else "0";
    };

    users.users."${vars.userName}".extraGroups = [ "gamemode" ];
  };
}
