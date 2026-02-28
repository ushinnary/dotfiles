{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.ushinnary.dev;
in
{
  imports = [
    # For NixOS
    inputs.nixvim.nixosModules.nixvim
  ];

  config = mkIf cfg.enable {
    programs.nixvim = {
      enable = true;
      defaultEditor = true;
      clipboard = {
        register = "unnamedplus";
        providers.wl-copy.enable = true;
      };

      colorschemes.catppuccin = {
        enable = true;
        settings = {
          flavour = "auto";
          transparent_background = true;
          background = {
            light = "latte";
            dark = "mocha";
          };
        };
      };

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
        virtual_text = false;
        virtual_lines = {
          severity = {
            min = "WARN";
          };
        };
        signs = true;
        underline = true;
        update_in_insert = false;
        severity_sort = false;
      };
    };
  };
}
