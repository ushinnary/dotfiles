{
  pkgs,
  vars,
  inputs,
  ...
}: {
  # Prebuilt nix-index database, pinned by the flake (bumped by `nfu`):
  # replaces programs.command-not-found, which needs channels.
  imports = [inputs.nix-index-database.nixosModules.nix-index];

  # `, <cmd>` runs any nixpkgs program without installing it.
  programs.nix-index-database.comma.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    cifs-utils
    wayland-utils
    wl-clipboard
  ];

  # nh (nicer `nixos-rebuild`/GC CLI). Its wrapper bundles
  # nix-output-monitor and it diffs generations itself, so nvd/nom
  # aren't needed as separate packages.
  programs.nh = {
    enable = true;
    # Exported as NH_FLAKE, so `nh os switch`/`nh os boot` work from anywhere.
    flake = "/home/${vars.userName}/dotfiles/nix";
    # NVMe has plenty of headroom, so favor rollback safety over
    # aggressively reclaiming space: keep two weeks of generations.
    # --no-gcroots keeps devenv/result roots, like nix.gc did.
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep-since 14d --no-gcroots";
    };
  };

  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only
  ];
  fonts.fontDir.enable = true;

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    config = {
      credential = {
        helper = "manager";
        credentialStore = "secretservice";
      };
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      fetch.prune = true;
      pull.rebase = true;
      rebase.autoStash = true;
      # Remember conflict resolutions and replay them on the next rebase.
      rerere.enabled = true;
      merge.conflictStyle = "zdiff3";
      diff = {
        algorithm = "histogram";
        colorMoved = "default";
      };
    };
  };
}
