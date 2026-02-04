{ ... }:
{
  plugins.snacks = {
    enable = true;
    autoLoad = true;

    settings = {
      rename.enabled = true;
      notifier = {
        enabled = true;
        style = "fancy";
      };
      lazygit = {
        enabled = true;
      };
      explorer = {
        enabled = true;
        replace_netrw = true;
      };
      dashboard = {
        sections = [
          {
            header = ''
              ██╗   ██╗███████╗██╗  ██╗██╗███╗   ██╗███╗   ██╗ █████╗ ██████╗ ██╗   ██╗
              ██║   ██║██╔════╝██║  ██║██║████╗  ██║████╗  ██║██╔══██╗██╔══██╗╚██╗ ██╔╝
              ██║   ██║███████╗███████║██║██╔██╗ ██║██╔██╗ ██║███████║██████╔╝ ╚████╔╝ 
              ██║   ██║╚════██║██╔══██║██║██║╚██╗██║██║╚██╗██║██╔══██║██╔══██╗  ╚██╔╝  
              ╚██████╔╝███████║██║  ██║██║██║ ╚████║██║ ╚████║██║  ██║██║  ██║   ██║   
               ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   
            '';
          }
          {
            icon = " ";
            title = "Keymaps";
            section = "keys";
            gap = 1;
            padding = 1;
          }
          {
            icon = " ";
            title = "Recent Files";
            __unkeyed-1.__raw = "require('snacks').dashboard.sections.recent_files({cwd = true})";
            gap = 1;
            padding = 1;
          }
          {
            icon = " ";
            title = "Projects";
            section = "projects";
            gap = 1;
            padding = 1;
          }
          {
            pane = 2;
            icon = " ";
            desc = "Browse Repo";
            padding = 1;
            key = "b";
            action.__raw = ''
              function()
                Snacks.gitbrowse()
              end'';
          }
          {
            __raw = ''
              function()
                local in_git = Snacks.git.get_root() ~= nil
                local cmds = {
                  {
                    icon = " ",
                    title = "Git Status",
                    cmd = "git --no-pager diff --stat -B -M -C",
                    height = 10,
                  },
                }
                return vim.tbl_map(function(cmd)
                  return vim.tbl_extend("force", {
                    pane = 2,
                    section = "terminal",
                    enabled = in_git,
                    padding = 1,
                    ttl = 5 * 60,
                    indent = 3,
                  }, cmd)
                end, cmds)
              end
            '';
          }
        ];
      };
    };
  };

  autoGroups = {
    snacks_rename_integration = {
      clear = true;
    };
  };

  keymaps = [
    {
      key = "<leader>e";
      mode = [ "n" ];
      action = "<cmd>lua Snacks.explorer()<CR>";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      key = "<leader>sg";
      mode = [ "n" ];
      action = "<cmd>lua Snacks.picker.grep()<CR>";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      key = "<leader>sk";
      mode = [ "n" ];
      action = "<cmd>lua Snacks.picker.keymaps()<CR>";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      key = "<leader>sw";
      mode = [
        "n"
        "v"
      ];
      action = "<cmd>lua Snacks.picker.grep_word()<CR>";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      key = "<C-f>";
      mode = [ "n" ];
      action = "/";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      key = "<leader>n";
      mode = [ "n" ];
      action = "<cmd>lua Snacks.picker.notifications()<CR>";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      key = "<leader>fb";
      mode = [ "n" ];
      action = "<cmd>lua Snacks.picker.buffers()<CR>";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      key = "<leader>ff";
      mode = [ "n" ];
      action = "<cmd>lua Snacks.picker.files()<CR>";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      key = "<leader><leader>";
      mode = [ "n" ];
      action = "<cmd>lua Snacks.picker.files()<CR>";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      key = "<leader>gl";
      mode = [ "n" ];
      action = "<cmd>lua Snacks.picker.git_log()<CR>";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      key = "<leader>gs";
      mode = [ "n" ];
      action = "<cmd>lua Snacks.picker.git_status()<CR>";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      key = "<leader>uC";
      mode = [ "n" ];
      action = "<cmd>lua Snacks.picker.colorschemes()<CR>";
    }
    {
      key = "<leader>:";
      mode = [ "n" ];
      action = "<cmd>lua Snacks.picker.command_history()<CR>";
    }
    # Git

    {
      mode = "n";
      key = "<leader>gff";
      action = "<cmd>lua Snacks.picker.git_files()<cr>";
      options = {
        desc = "Git Files";
      };
    }
    {
      mode = "n";
      key = "<leader>gfb";
      action = "<cmd>lua Snacks.picker.git_branches()<cr>";
      options = {
        desc = "Git Branches";
      };
    }
    {
      mode = "n";
      key = "<leader>gfs";
      action = "<cmd>lua Snacks.picker.git_stash()<cr>";
      options = {
        desc = "Git Stashes";
      };
    }
    {
      mode = "n";
      key = "<leader>gfL";
      action = "<cmd>lua Snacks.picker.git_log_line()<cr>";
      options = {
        desc = "Git Log Line";
      };
    }
    {
      mode = "n";
      key = "<leader>gfd";
      action = "<cmd>lua Snacks.picker.git_diff()<cr>";
      options = {
        desc = "Git Diff (Hunks)";
      };
    }
    {
      mode = "n";
      key = "<leader>gfa";
      action = "<cmd>lua Snacks.picker.git_log_file()<cr>";
      options = {
        desc = "Git Log File";
      };
    }
    # LSP
    {
      mode = "n";
      key = "<leader>fd";
      action = "<cmd>lua Snacks.picker.diagnostics_buffer()<cr>";
      options = {
        desc = "Find buffer diagnostics";
      };
    }
    {
      mode = "n";
      key = "<leader>fD";
      action = "<cmd>lua Snacks.picker.diagnostics()<cr>";
      options = {
        desc = "Find workspace diagnostics";
      };
    }
    {
      mode = "n";
      key = "<leader>fl";
      action = "<cmd>lua Snacks.picker.lsp_symbols()<cr>";
      options = {
        desc = "Find lsp document symbols";
      };
    }
    {
      mode = "n";
      key = "<leader>ld";
      action = "<cmd>lua Snacks.picker.lsp_definitions()<cr>";
      options = {
        desc = "Goto Definition";
      };
    }
    {
      mode = "n";
      key = "<leader>li";
      action = "<cmd>lua Snacks.picker.lsp_implementations()<cr>";
      options = {
        desc = "Goto Implementation";
      };
    }
    {
      mode = "n";
      key = "<leader>lD";
      action = "<cmd>lua Snacks.picker.lsp_references()<cr>";
      options = {
        desc = "Find references";
      };
    }
    {
      mode = "n";
      key = "<leader>lt";
      action = "<cmd>lua Snacks.picker.lsp_type_definitions()<cr>";
      options = {
        desc = "Goto Type Definition";
      };
    }

    {
      mode = "n";
      key = "gd";
      action = "<cmd>lua Snacks.picker.lsp_definitions()<cr>";
      options = {
        desc = "Goto Definition";
      };
    }
    {
      mode = "n";
      key = "gD";
      action = "<cmd>lua Snacks.picker.lsp_declarations()<cr>";
      options = {
        desc = "Goto Declaration";
      };
    }
    {
      mode = "n";
      key = "grr";
      action = "<cmd>lua Snacks.picker.lsp_references()<cr>";
      options = {
        desc = "Goto References";
        nowait = true;
      };
    }
    {
      mode = "n";
      key = "gri";
      action = "<cmd>lua Snacks.picker.lsp_implementations()<cr>";
      options = {
        desc = "Goto Implementation";
      };
    }
    {
      mode = "n";
      key = "gy";
      action = "<cmd>lua Snacks.picker.lsp_type_definitions()<cr>";
      options = {
        desc = "Goto T[y]pe Definition";
      };
    }
    # Code Actions
    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>ca";
      action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
      options = {
        desc = "Code Action";
      };
    }
    # Diagnostic Navigation
    {
      mode = "n";
      key = "]d";
      action = "<cmd>lua vim.diagnostic.goto_next()<CR>";
      options = {
        desc = "Next Diagnostic";
      };
    }
    {
      mode = "n";
      key = "[d";
      action = "<cmd>lua vim.diagnostic.goto_prev()<CR>";
      options = {
        desc = "Prev Diagnostic";
      };
    }
    {
      mode = "n";
      key = "]e";
      action = "<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.ERROR})<CR>";
      options = {
        desc = "Next Error";
      };
    }
    {
      mode = "n";
      key = "[e";
      action = "<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.ERROR})<CR>";
      options = {
        desc = "Prev Error";
      };
    }
    {
      mode = "n";
      key = "]w";
      action = "<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.WARN})<CR>";
      options = {
        desc = "Next Warning";
      };
    }
    {
      mode = "n";
      key = "[w";
      action = "<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.WARN})<CR>";
      options = {
        desc = "Prev Warning";
      };
    }
    # Lazygit
    {
      mode = "n";
      key = "<leader>gg";
      action = "<cmd>lua Snacks.lazygit()<CR>";
      options = {
        desc = "Open lazygit";
      };
    }

    # Notifier
    {
      mode = "n";
      key = "<leader>na";
      action = "<cmd>lua Snacks.notifier.show_history()<CR>";
      options = {
        desc = "Show Notification History";
      };
    }
    {
      mode = "n";
      key = "<leader>nh";
      action = "<cmd>lua Snacks.notifier.hide()<CR>";
      options = {
        desc = "Dismiss All Notifications";
      };
    }
    # File tree
    {
      mode = "n";
      key = "<leader>rf";
      action = "<cmd>lua Snacks.rename.rename_file()<CR>";
      options = {
        desc = "Rename File";
      };
    }
  ];
}
