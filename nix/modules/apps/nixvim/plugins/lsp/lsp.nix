{pkgs, ...}: {
  # Default border for every float without its own (LSP hover, signature
  # help, diagnostic float): replaces the deprecated vim.lsp.with() handlers.
  opts.winborder = "rounded";

  plugins = {
    # No lsp-lines: Neovim's own `virtual_lines` diagnostics replace it
    # (configured in nixvim/default.nix, toggled in keymaps.nix).
    # No lsp-format: conform (conform.nix) formats on save and already
    # falls back to the LSP, so both would format the same buffer.
    lsp = {
      enable = true;
      inlayHints = true;
      servers = {
        # nil_ls is configured in lang/nix.nix.
        lua_ls = {
          enable = true;
        };
        bashls = {
          enable = true;
        };
        jsonls = {
          enable = true;
        };
        markdown_oxide = {
          enable = true;
        };
        yamlls = {
          enable = true;
          extraOptions = {
            settings = {
              yaml = {
                schemas = {
                  kubernetes = "'*.yaml";
                  "http://json.schemastore.org/github-workflow" = ".github/workflows/*";
                  "http://json.schemastore.org/github-action" = ".github/action.{yml,yaml}";
                  "http://json.schemastore.org/ansible-stable-2.9" = "roles/tasks/*.{yml,yaml}";
                  "http://json.schemastore.org/kustomization" = "kustomization.{yml,yaml}";
                  "http://json.schemastore.org/ansible-playbook" = "*play*.{yml,yaml}";
                  "http://json.schemastore.org/chart" = "Chart.{yml,yaml}";
                  "https://json.schemastore.org/dependabot-v2" = ".github/dependabot.{yml,yaml}";
                  "https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json" = "*docker-compose*.{yml,yaml}";
                  "https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json" = "*flow*.{yml,yaml}";
                };
              };
            };
          };
        };
      };

      keymaps = {
        silent = true;
        lspBuf = {
          gd = {
            action = "definition";
            desc = "Goto Definition";
          };
          gr = {
            action = "references";
            desc = "Goto References";
          };
          gD = {
            action = "declaration";
            desc = "Goto Declaration";
          };
          gI = {
            action = "implementation";
            desc = "Goto Implementation";
          };
          gT = {
            action = "type_definition";
            desc = "Type Definition";
          };
          K = {
            action = "hover";
            desc = "Hover";
          };
          "<leader>cw" = {
            action = "workspace_symbol";
            desc = "Workspace Symbol";
          };
          "<leader>cr" = {
            action = "rename";
            desc = "Rename";
          };
        };
        diagnostic = {
          "<leader>cd" = {
            action = "open_float";
            desc = "Line Diagnostics";
          };
          # [d / ]d: Neovim's built-in defaults.
        };
      };
    };
  };
}
