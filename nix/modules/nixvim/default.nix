{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.ushinnary.software;
in
{
  imports = [
    # For NixOS
    inputs.nixvim.nixosModules.nixvim
  ];

  config = mkIf cfg.enableDevPackages {
    programs.nixvim = {
      enable = true;
      defaultEditor = true;
      clipboard.providers.wl-copy.enable = true;

      colorschemes.vscode.enable = true;

      imports = [
        ./keymaps.nix
        ./set.nix
        ./plugins.nix
        ./conform.nix
        ./treesitter.nix
        ./snacks.nix
        ./plugins/default.nix
      ];

      globals = {
        mapleader = " ";
      };

      extraPackages = with pkgs; [
        fzf
        ripgrep
        fd
        # Formatters
        stylua # Lua formatter
        csharpier # C# formatter
        nixfmt # Nix formatter
        nufmt # Nushell formatter
        # Linters
        # golangci-lint # Go linter
        shellcheck # Shell script linter
        # Debuggers
        # gcc

      ];

      diagnostic.settings = {
        virtual_text = true;
        signs = true;
        underline = true;
        update_in_insert = false;
        severity_sort = false;
      };

      plugins = {
        #bufferline.enable = true;
        web-devicons.enable = true;
      };
    };
  };
}
