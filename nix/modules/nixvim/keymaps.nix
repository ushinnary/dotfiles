{ ... }:
{
  keymaps = [
    {
      key = "<leader>p";
      mode = [ "n" ];
      action = "<cmd>YankyRingHistory<CR>";
    }
    {
      key = "<leader>qq";
      mode = [ "n" ];
      action = "<cmd>qa<CR>";
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
    # Move liens
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
  ];
}
