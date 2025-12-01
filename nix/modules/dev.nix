{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.ushinnary.software;
in
{
  imports = [ ./nixvim/default.nix ];

  environment.systemPackages = lib.mkIf cfg.enableDevPackages [
    pkgs.ast-grep

    pkgs.ghostty
    pkgs.vim

    pkgs.yazi
    pkgs.nushell
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
    pkgs.dotnet-runtime_10

    pkgs.stow
    pkgs.git-credential-manager

    pkgs.vscode
    pkgs.antigravity
  ];

  programs.nix-ld = {
    enable = true;
    # libraries = [ pkgs.zlib pkgs.openssl ];
  };
}
