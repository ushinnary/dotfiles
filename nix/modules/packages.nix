{
  pkgs,
  ...
}:
{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    cifs-utils
    nil
    alejandra
    ghostty

    yazi
    nushell
    nufmt
    starship
    ripgrep
    fd
    fzf
    lazygit
    zoxide
    zellij
    difftastic

    stow
    neovim
    git-credential-manager
    wayland-utils
    wl-clipboard
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only
  ];

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    config = {
      credential = {
        helper = "libsecret";
      };
    };
  };
}
