{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = with pkgs; [
    # Core dev tools
    git
    gh
    direnv
    just

    # Shell
    bash
    zsh
    fish
    nushell

    # Text editors
    neovim
    vim
    helix

    # Utilities
    curl
    wget
    jq
    ripgrep
    fd
    bat
    exa
    tree
    htop
    tmux
    screen

    # Compression
    gzip
    xz
    zip
    unzip
    tar

    # Network
    openssh
    nettools
    iproute2
  ];

  shellHook = ''
    echo "Minimal development environment loaded"
    echo "Useful commands:"
    echo "  git status       - Check git status"
    echo "  direnv allow     - Allow direnv"
    echo "  just ...        - Run just recipe"
  '';
}