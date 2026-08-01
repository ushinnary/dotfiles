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
    # nh (nicer `nixos-rebuild`/GC CLI) — nvd/nix-output-monitor are
    # optional companions it shells out to for diffs and build progress.
    nh
    nvd
    nix-output-monitor
  ];

  # `nh os switch`/`nh os boot` use this as the default flake path so
  # they don't need it passed explicitly each time.
  environment.variables.NH_FLAKE = "/home/${vars.userName}/dotfiles/nix";

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
