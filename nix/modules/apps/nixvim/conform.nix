{
  lib,
  pkgs,
  ...
}: let
  # The project's biome (node_modules or PATH) when it has biome.json(c) —
  # see `formatters.biome.require_cwd` — otherwise prettier as before.
  biomeOrPrettier = {
    __unkeyed-1 = "biome";
    __unkeyed-2 = "prettierd";
    __unkeyed-3 = "prettier";
    stop_after_first = true;
  };
in {
  config = {
    extraConfigLuaPre =
      # lua
      ''
        local slow_format_filetypes = {}

        vim.api.nvim_create_user_command("FormatDisable", function(args)
           if args.bang then
            -- FormatDisable! will disable formatting just for this buffer
            vim.b.disable_autoformat = true
          else
            vim.g.disable_autoformat = true
          end
        end, {
          desc = "Disable autoformat-on-save",
          bang = true,
        })
        vim.api.nvim_create_user_command("FormatEnable", function()
          vim.b.disable_autoformat = false
          vim.g.disable_autoformat = false
        end, {
          desc = "Re-enable autoformat-on-save",
        })
        vim.api.nvim_create_user_command("FormatToggle", function(args)
          if args.bang then
            -- Toggle formatting for current buffer
            vim.b.disable_autoformat = not vim.b.disable_autoformat
          else
            -- Toggle formatting globally
            vim.g.disable_autoformat = not vim.g.disable_autoformat
          end
        end, {
          desc = "Toggle autoformat-on-save",
          bang = true,
        })
      '';
    plugins.conform-nvim = {
      enable = true;
      settings = {
        format_on_save = ''
          function(bufnr)
            if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
              return
            end

            if slow_format_filetypes[vim.bo[bufnr].filetype] then
              return
            end

            local function on_format(err)
              if err and err:match("timeout$") then
                slow_format_filetypes[vim.bo[bufnr].filetype] = true
              end
            end

            return { timeout_ms = 200, lsp_fallback = true }, on_format
           end
        '';

        format_after_save = ''
          function(bufnr)
            if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
              return
            end

            if not slow_format_filetypes[vim.bo[bufnr].filetype] then
              return
            end

            return { lsp_fallback = true }
          end
        '';
        notify_on_error = true;
        formatters_by_ft = {
          html = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            stop_after_first = true;
          };
          css = biomeOrPrettier;
          javascript = biomeOrPrettier;
          javascriptreact = biomeOrPrettier;
          typescript = biomeOrPrettier;
          typescriptreact = biomeOrPrettier;
          # Rust drop-ins for isort + black; resolved from the project's PATH
          # (devenv), like the tools they replace.
          python = [
            "ruff_organize_imports"
            "ruff_format"
          ];
          lua = ["stylua"];
          markdown = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            stop_after_first = true;
          };
          yaml = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            stop_after_first = true;
          };
          terraform = ["terraform_fmt"];
          bicep = ["bicep"];
          bash = [
            "shellcheck"
            "shellharden"
            "shfmt"
          ];
          json = {
            __unkeyed-1 = "biome";
            __unkeyed-2 = "jaq";
            stop_after_first = true;
          };
          nu = ["nufmt"];
          qml = ["qmlformat"];
          "_" = ["trim_whitespace"];
        };

        formatters = {
          alejandra = {
            command = "${lib.getExe pkgs.alejandra}";
          };
          # Only counts as available inside a biome project (cwd = the
          # directory holding biome.json/biome.jsonc), so other projects
          # fall through to prettier/jaq.
          biome.require_cwd = true;
          # Rust jq: same 2-space pretty-printing, keeps number literals as
          # written. Not built into conform, hence the full definition.
          jaq = {
            command = "${lib.getExe pkgs.jaq}";
            args = ["."];
            stdin = true;
          };
          prettierd = {
            command = "${lib.getExe pkgs.prettierd}";
          };
          stylua = {
            command = "${lib.getExe pkgs.stylua}";
          };
          shellcheck = {
            command = "${lib.getExe pkgs.shellcheck}";
          };
          shfmt = {
            command = "${lib.getExe pkgs.shfmt}";
          };
          shellharden = {
            command = "${lib.getExe pkgs.shellharden}";
          };
          nufmt = {
            command = "${lib.getExe pkgs.nufmt}";
          };
          qmlformat = {
            command = "${pkgs.kdePackages.qtdeclarative}/bin/qmlformat";
            args = [
              "-i"
              "$FILENAME"
            ];
            stdin = false;
          };
        };
      };
    };
  };
}
