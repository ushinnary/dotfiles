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
  selectedEditors = cfg.editors;
  hasEditor = editor: builtins.elem editor selectedEditors;
in
{
  imports = [
    # For NixOS
    inputs.nixvim.nixosModules.nixvim
  ];

  config = mkIf (cfg.enable && hasEditor "nixvim") {
    programs.nixvim = {
      enable = true;
      enableMan = false;
      withRuby = false;
      withPython3 = false;
      defaultEditor = true;
      nixpkgs = {
        source = inputs.nixvim.inputs.nixpkgs;
      };
      clipboard = {
        register = "unnamedplus";
        providers.wl-copy.enable = true;
      };
      dependencies = {
        direnv.enable = true;
        fd.enable = true;
        fzf.enable = true;
        ripgrep.enable = true;
        tree-sitter.enable = true;
      };
      extraConfigLuaPost = ''
        vim.cmd([[
          colorscheme github_dark_default
        ]])
      '';

      colorschemes.github-theme = {
        enable = true;
        settings = {
          options = {

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
        # Formatters
        stylua # Lua formatter
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
