{
  inputs,
  vars,
  config,
  lib,
  ...
}:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  # Basic system settings
  time.timeZone = lib.mkDefault "Europe/Paris";
  system.stateVersion = "25.11";

  # Bootloader defaults
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = lib.mkDefault 0; # Skip boot menu for faster boot

  # Home Manager Setup
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit inputs vars;
    };
    users."${vars.userName}" =
      { lib, config, pkgs, osConfig, ... }:
      {
        # Injected as a module arg for every fragment merged into this
        # user's home-manager config (dev.nix, niri/compositor.nix, the
        # per-host configuration.nix files, …) — see lib/mkDotfileSymlink.nix.
        _module.args.mkDotfileSymlink = import ../../lib/mkDotfileSymlink.nix config;

        home.stateVersion = "25.11";

        gtk.gtk4.theme = config.gtk.theme;

        xdg.userDirs = {
          enable = true;
          createDirectories = true;
          setSessionVariables = false;
        };

        programs.bash = {
          enable = true;
          shellAliases = {
            nfc = "(cd ~/dotfiles/nix && nix flake check)";
            nfu = "(cd ~/dotfiles/nix && nix flake update)";
            ncg = "sudo nix-collect-garbage -d";
            subup = "(cd ~/dotfiles && git submodule update --init --remote --merge)";
            nvim = "hx";
          };

          initExtra = ''
            bind 'set completion-ignore-case on'

            nrfs() {
              (cd ~/dotfiles/nix && sudo nixos-rebuild switch --flake "#$HOSTNAME")
            }
          '';

          bashrcExtra = ''
            ${lib.optionalString osConfig.ushinnary.dev.enable "export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'"}
            ${lib.optionalString osConfig.ushinnary.dev.enable "source <(carapace _carapace)"}
            ${lib.optionalString osConfig.ushinnary.dev.enable "eval \"$(devenv hook bash)\""}
            ${lib.optionalString osConfig.ushinnary.dev.enable "eval \"$(starship init bash)\""}
            ${lib.optionalString osConfig.ushinnary.dev.enable "eval \"$(zoxide init bash)\""}
          '';
        };
      };
  };
}
