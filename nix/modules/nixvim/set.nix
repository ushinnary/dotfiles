{
  opts = {
    number = true;
    colorcolumn = "80";
    relativenumber = true;
    shiftwidth = 2;
    tabstop = 2;
    wrap = false;
    swapfile = false; # Undotree
    backup = false; # Undotree
    undofile = true;
    hlsearch = false;
    incsearch = true;
    termguicolors = true;
    scrolloff = 8;
    signcolumn = "yes";
    updatetime = 50;
    timeoutlen = 250;
    foldlevelstart = 99;
    # Set encoding type
    encoding = "utf-8";
    fileencoding = "utf-8";
    # Maximum number of items to show in the popup menu (0 means "use available screen space")
    pumheight = 0;
  };

  extraConfigLua = ''
    vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
    vim.opt.isfname:append("@-@")
  '';
}
