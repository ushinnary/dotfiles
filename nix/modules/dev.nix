{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nil
    alejandra
    rust-analyzer
    vscode-css-languageserver
    #docker-language-server
    vtsls
    sqls
    yaml-language-server
    vue-language-server
    tailwindcss-language-server
    svelte-language-server
    angular-language-server
    lua-language-server
    csharpier
    csharp-ls
    ast-grep
    biome
    lemminx

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

    stow
    neovim
    git-credential-manager

    vscode
    zed-editor
  ];

  programs.nix-ld = {
    enable = true;
    # libraries = [ pkgs.zlib pkgs.openssl ];
  };
}
