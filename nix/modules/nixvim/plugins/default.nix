{ config, pkgs, ... }:
{
  imports = [
    ./lang/nix.nix
    ./lang/lua.nix
    ./lang/md.nix
    ./lang/rust.nix
    ./lang/shell.nix
    ./lang/toml.nix
    ./lazygit.nix
    ./lualine.nix
    ./autosave.nix
    ./yazi.nix
    ./toggleterm.nix
    ./bufferline.nix
    ./ts-comments.nix
    ./lsp/blink.nix
    ./lsp/roslyn.nix
    ./lsp/lsp.nix
  ];
}
