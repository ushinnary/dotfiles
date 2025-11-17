{ pkgs, ... }:
{
  imports = [
    ./nixvim/default.nix
  ];
  environment.systemPackages = with pkgs; [
    ast-grep

    ghostty
    vim

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
    dust

    stow
    # neovim
    git-credential-manager

    vscode
    zed-editor
  ];

  programs.nix-ld = {
    enable = true;
    # libraries = [ pkgs.zlib pkgs.openssl ];
  };
}
