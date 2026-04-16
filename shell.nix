{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Nix LSP
    nil
    # Lua LSP
    lua-language-server
    # Optional: Formatters
    nixpkgs-fmt
    stylua
    nushell
  ];
}
