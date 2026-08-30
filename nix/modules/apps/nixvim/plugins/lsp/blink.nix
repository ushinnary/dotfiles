{ pkgs, ... }:
{
  plugins = {
    blink-cmp = {
      enable = true;
      setupLspCapabilities = true;

      settings = {
        fuzzy = {
          implementation = "rust";
          sorts = [
            "exact"
            "score"
            "sort_text"
          ];
          prebuilt_binaries = {
            download = true;
          };
        };
        keymap = {
          "<C-space>" = [
            "show"
            "show_documentation"
            "hide_documentation"
          ];
          "<C-e>" = [
            "hide"
            "fallback"
          ];
          "<CR>" = [
            "accept"
            "fallback"
          ];
          "<Tab>" = [
            "accept"
            "snippet_forward"
            "fallback"
          ];
          "<S-Tab>" = [
            "select_prev"
            "snippet_backward"
            "fallback"
          ];
          "<Up>" = [
            "select_prev"
            "fallback"
          ];
          "<Down>" = [
            "select_next"
            "fallback"
          ];
          "<C-p>" = [
            "select_prev"
            "fallback"
          ];
          "<C-n>" = [
            "select_next"
            "fallback"
          ];
          "<C-up>" = [
            "scroll_documentation_up"
            "fallback"
          ];
          "<C-down>" = [
            "scroll_documentation_down"
            "fallback"
          ];
        };
        signature = {
          enabled = true;
          window = {
            border = "rounded";
          };
        };

        sources = {
          default = [
            "lsp"
            "buffer"
            "path"
            "snippets"
          ];
          providers = {
            lsp.score_offset = 1; # Prioritize LSP results
            path = {
              score_offset = 55;
              opts = {
                # Toggle support for path completions from project root. Default normal behavior
                get_cwd.__raw = ''
                  function(context)
                    if vim.g.blink_path_from_cwd == nil then vim.g.blink_path_from_cwd = false end

                    if vim.g.blink_path_from_cwd then
                      return vim.fn.getcwd()
                    else
                      local bufpath = vim.api.nvim_buf_get_name(context.bufnr)
                      if bufpath == "" then
                        return vim.fn.getcwd()
                      end
                      return vim.fn.fnamemodify(bufpath, ":p:h")
                    end
                  end
                '';
              };
            };
          };
        };

        appearance = {
          nerd_font_variant = "mono";
          kind_icons = {
            Text = "󰉿";
            Method = "";
            Function = "󰊕";
            Constructor = "󰒓";

            Field = "󰜢";
            Variable = "󰆦";
            Property = "󰖷";

            Class = "󱡠";
            Interface = "󱡠";
            Struct = "󱡠";
            Module = "󰅩";

            Unit = "󰪚";
            Value = "󰦨";
            Enum = "󰦨";
            EnumMember = "󰦨";

            Keyword = "󰻾";
            Constant = "󰏿";

            Snippet = "󱄽";
            Color = "󰏘";
            File = "󰈔";
            Reference = "󰬲";
            Folder = "󰉋";
            Event = "󱐋";
            Operator = "󰪚";
            TypeParameter = "󰬛";
            Error = "󰏭";
            Warning = "󰏯";
            Information = "󰏮";
            Hint = "󰏭";

            Emoji = "🤶";
          };
        };
        completion = {
          menu = {
            border = "none";
            draw = {
              gap = 1;
              treesitter = [ "lsp" ];
              columns = [
                {
                  __unkeyed-1 = "label";
                }
                {
                  __unkeyed-1 = "kind_icon";
                  __unkeyed-2 = "kind";
                  gap = 1;
                }
                { __unkeyed-1 = "source_name"; }
              ];
            };
          };
          trigger = {
            show_in_snippet = false;
          };
          documentation = {
            auto_show = true;
            window = {
              border = "single";
            };
          };
          accept = {
            auto_brackets = {
              enabled = false;
            };
          };
          list = {
            max_items = 20;
            selection = {
              preselect = true;
              auto_insert = false;
            };
          };
        };
      };
    };
  };
}