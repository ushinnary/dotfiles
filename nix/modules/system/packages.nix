{
  pkgs,
  vars,
  ...
}:
{
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
    # --no-gcroots keeps nix-direnv/result roots, like nix.gc did.
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
    };
  };
}
