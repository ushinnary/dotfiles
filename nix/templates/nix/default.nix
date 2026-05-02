{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = with pkgs; [
    # Nix tooling
    nix
    nixfmt
    nixfmt-rfc-style
    nix-linter
    nix-tree
    nix-diff
    nix-show-legacy
    devenv

    # Nix editors
    nil
    nixvim

    # Shell
    bash
    zsh
    nushell

    # Dev tools
    git
    gh
    direnv
    just

    # Utilities
    jq
    ripgrep
    fd
    bat
    tree
  ];

  # Environment variables
  NIX_CONFIG = "experimental-features = nix-command flakes";

  shellHook = ''
    echo "Nix development environment loaded"
    echo "Useful commands:"
    echo "  nix develop      - Enter development shell"
    echo "  nix fmt          - Format nix files"
    echo "  nix-linter      - Lint nix files"
    echo "  devenv up       - Start devenv"
  '';
}