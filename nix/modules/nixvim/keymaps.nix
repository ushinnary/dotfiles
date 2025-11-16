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
  ];
}
