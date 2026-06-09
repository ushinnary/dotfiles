{ ... }:
{
  keymaps = [
    # Yank history
    {
      key = "<leader>p";
      mode = [ "n" ];
      action = "<cmd>YankyRingHistory<CR>";
    }
    # General
    {
      key = "<leader>qq";
      mode = [ "n" ];
      action = "<cmd>qa<CR>";
    }
    {
      key = "<leader>ur";
      mode = [ "n" ];
      action = "<cmd>nohlsearch<CR>";
      options.desc = "Redraw / Clear hlsearch";
    }
    {
      key = "<leader>fn";
      mode = [ "n" ];
      action = "<cmd>enew<CR>";
      options.desc = "New File";
    }
    {
      key = "<leader>cf";
      mode = [ "n" "x" ];
      action.__raw = "function() require('conform').format({ lsp_fallback = true }) end";
      options.desc = "Format";
    }
    {
      key = "<leader>cd";
      mode = [ "n" ];
      action = "<cmd>lua vim.diagnostic.open_float()<CR>";
      options.desc = "Line Diagnostics";
    }
    # Navigation
    {
      key = "<C-h>";
      mode = [ "n" ];
      action = "<C-w>h";
    }
    {
      key = "<C-l>";
      mode = [ "n" ];
      action = "<C-w>l";
    }
    {
      key = "<C-j>";
      mode = [ "n" ];
      action = "<C-w>j";
    }
    {
      key = "<C-k>";
      mode = [ "n" ];
      action = "<C-w>k";
    }
    # Buffer
    {
      key = "<S-h>";
      mode = [ "n" ];
      action = "<cmd>bprevious<cr>";
    }
    {
      key = "<S-l>";
      mode = [ "n" ];
      action = "<cmd>bnext<cr>";
    }
    {
      key = "<leader>bb";
      mode = [ "n" ];
      action = "<cmd>e #<cr>";
    }
    # Move lines
    {
      key = "<A-j>";
      mode = [ "n" ];
      action = "<cmd>execute 'move .+' . v:count1<cr>==";
    }
    {
      key = "<A-k>";
      mode = [ "n" ];
      action = "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==";
    }
    {
      key = "<A-j>";
      mode = [ "i" ];
      action = "<esc><cmd>m .+1<cr>==gi";
    }
    {
      key = "<A-k>";
      mode = [ "i" ];
      action = "<esc><cmd>m .-2<cr>==gi";
    }
    # Search
    {
      mode = [ "v" ];
      key = "<C-f>";
      action = ''
        y
        :let @/ = '\V' . escape(@", '/\')<CR>
        :set hlsearch<CR>
      '';
      options.silent = true;
    }
    # Windows
    {
      key = "<leader>-";
      mode = [ "n" ];
      action = "<C-w>s";
      options.desc = "Split Window Below";
    }
    {
      key = "<leader>|";
      mode = [ "n" ];
      action = "<C-w>v";
      options.desc = "Split Window Right";
    }
    {
      key = "<leader>wd";
      mode = [ "n" ];
      action = "<C-w>c";
      options.desc = "Delete Window";
    }
    {
      key = "<leader>wm";
      mode = [ "n" ];
      action = "<cmd>lua Snacks.win.zoom()<CR>";
      options.desc = "Toggle Zoom";
    }
    {
      key = "<leader>uZ";
      mode = [ "n" ];
      action = "<cmd>lua Snacks.win.zoom()<CR>";
      options.desc = "Toggle Zoom";
    }
    {
      key = "<leader>uz";
      mode = [ "n" ];
      action = "<cmd>lua Snacks.zen()<CR>";
      options.desc = "Toggle Zen Mode";
    }
    # UI toggles
    {
      key = "<leader>us";
      mode = [ "n" ];
      action = "<cmd>set spell!<CR>";
      options.desc = "Toggle Spelling";
    }
    {
      key = "<leader>uw";
      mode = [ "n" ];
      action = "<cmd>set wrap!<CR>";
      options.desc = "Toggle Wrap";
    }
    {
      key = "<leader>uL";
      mode = [ "n" ];
      action = "<cmd>set relativenumber!<CR>";
      options.desc = "Toggle Relative Number";
    }
    {
      key = "<leader>ul";
      mode = [ "n" ];
      action = "<cmd>set number!<CR>";
      options.desc = "Toggle Line Numbers";
    }
    {
      key = "<leader>ud";
      mode = [ "n" ];
      action = "<cmd>lua vim.diagnostic.enable(not vim.diagnostic.is_enabled())<CR>";
      options.desc = "Toggle Diagnostics";
    }
    # Quickfix / Location List
    {
      key = "<leader>xl";
      mode = [ "n" ];
      action = "<cmd>lua vim.cmd('lopen')<CR>";
      options.desc = "Location List";
    }
    {
      key = "<leader>xq";
      mode = [ "n" ];
      action = "<cmd>copen<CR>";
      options.desc = "Quickfix List";
    }
    {
      key = "[q";
      mode = [ "n" ];
      action.__raw = ''
        function()
          if require("trouble").is_open() then
            require("trouble").prev({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cprev)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end
      '';
      options.desc = "Previous Trouble/Quickfix Item";
    }
    {
      key = "]q";
      mode = [ "n" ];
      action.__raw = ''
        function()
          if require("trouble").is_open() then
            require("trouble").next({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cnext)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end
      '';
      options.desc = "Next Trouble/Quickfix Item";
    }
    # Git
    {
      key = "<leader>gL";
      mode = [ "n" ];
      action = "<cmd>lua Snacks.picker.git_log({cwd = true})<CR>";
      options.desc = "Git Log (cwd)";
    }
    {
      key = "<leader>gB";
      mode = [ "n" "x" ];
      action = "<cmd>lua Snacks.gitbrowse()<CR>";
      options.desc = "Git Browse";
    }
    # Todo Comments
    {
      key = "]t";
      mode = [ "n" ];
      action.__raw = ''
        function()
          require("todo-comments").jump_next()
        end
      '';
      options.desc = "Next Todo Comment";
    }
    {
      key = "[t";
      mode = [ "n" ];
      action.__raw = ''
        function()
          require("todo-comments").jump_prev()
        end
      '';
      options.desc = "Prev Todo Comment";
    }
    {
      key = "<leader>st";
      mode = [ "n" ];
      action = "<cmd>lua Snacks.picker.todo_comments()<CR>";
      options.desc = "Todo";
    }
    {
      key = "<leader>sT";
      mode = [ "n" ];
      action.__raw = ''
        function()
          Snacks.picker.todo_comments({keywords = {"TODO","FIX","FIXME"}})
        end
      '';
      options.desc = "Todo/Fix/Fixme";
    }
    {
      key = "<leader>xt";
      mode = [ "n" ];
      action = "<cmd>Trouble todo toggle<CR>";
      options.desc = "Todo (Trouble)";
    }
    {
      key = "<leader>xT";
      mode = [ "n" ];
      action = "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<CR>";
      options.desc = "Todo/Fix/Fixme (Trouble)";
    }
    # Trouble diagnostics
    {
      key = "<leader>xx";
      mode = [ "n" ];
      action = "<cmd>Trouble diagnostics toggle<CR>";
      options.desc = "Diagnostics (Trouble)";
    }
    {
      key = "<leader>xX";
      mode = [ "n" ];
      action = "<cmd>Trouble diagnostics toggle filter.buf=0<CR>";
      options.desc = "Buffer Diagnostics (Trouble)";
    }
    {
      key = "<leader>cs";
      mode = [ "n" ];
      action = "<cmd>Trouble symbols toggle<CR>";
      options.desc = "Symbols (Trouble)";
    }
    {
      key = "<leader>cS";
      mode = [ "n" ];
      action = "<cmd>Trouble lsp toggle<CR>";
      options.desc = "LSP references/definitions/... (Trouble)";
    }
    {
      key = "<leader>xL";
      mode = [ "n" ];
      action = "<cmd>Trouble loclist toggle<CR>";
      options.desc = "Location List (Trouble)";
    }
    {
      key = "<leader>xQ";
      mode = [ "n" ];
      action = "<cmd>Trouble qflist toggle<CR>";
      options.desc = "Quickfix List (Trouble)";
    }
    # LSP Lines / Diagnostics
    {
      mode = [ "n" ];
      key = "<leader>la";
      action.__raw = "function() vim.diagnostic.config({ virtual_lines = { severity = { min = vim.diagnostic.severity.WARN } } }) end";
      options.desc = "Display all virtual lines (Warn/Error)";
    }
    {
      mode = [ "n" ];
      key = "<leader>lh";
      action.__raw = "function() vim.diagnostic.config({ virtual_lines = false }) end";
      options.desc = "Hide all virtual lines";
    }
    {
      mode = [ "n" ];
      key = "<leader>lc";
      action.__raw = "function() vim.diagnostic.config({ virtual_lines = { only_current_line = true, severity = { min = vim.diagnostic.severity.WARN } } }) end";
      options.desc = "Display virtual lines for current line only (Warn/Error)";
    }
    {
      mode = [ "n" ];
      key = "<leader>ln";
      action.__raw = "function() vim.diagnostic.config({ virtual_lines = { only_current_line = false, severity = { min = vim.diagnostic.severity.WARN } } }) end";
      options.desc = "Hide current line virtual lines restriction (display all Warn/Error)";
    }
    # Formatting toggles
    {
      mode = [ "n" ];
      key = "<leader>uf";
      action = "<cmd>FormatToggle<CR>";
      options.desc = "Toggle format on save (global)";
    }
    {
      mode = [ "n" ];
      key = "<leader>uF";
      action = "<cmd>FormatToggle!<CR>";
      options.desc = "Toggle format on save (buffer)";
    }
    # Save
    {
      key = "<C-s>";
      mode = [ "n" "i" "x" ];
      action = "<cmd>w<cr><esc>";
    }
  ];
}
