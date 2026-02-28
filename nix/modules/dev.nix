{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.ushinnary.dev;
in
{
  imports = [ ./nixvim/default.nix ];

  environment.systemPackages = lib.mkIf cfg.enable [
    pkgs.ast-grep

    pkgs.ghostty
    pkgs.vim

    pkgs.yazi
    pkgs.nufmt
    pkgs.starship
    pkgs.ripgrep
    pkgs.fd
    pkgs.fzf
    pkgs.lazygit
    pkgs.zoxide
    pkgs.zellij
    pkgs.difftastic
    pkgs.dust
    pkgs.gh
    pkgs.dotnet-sdk

    pkgs.stow
    pkgs.git-credential-manager

    pkgs.vscode
    # pkgs.antigravity
  ];

  programs.nix-ld = {
    enable = true;
    # libraries = [ pkgs.zlib pkgs.openssl ];
  };
    
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
