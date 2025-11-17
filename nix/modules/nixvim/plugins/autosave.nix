{
  plugins.auto-save = {
    enable = true;
    autoLoad = true;
  };
  keymaps = [
    {
      key = "<C-s>";
      mode = [
        "n"
        "i"
        "x"
        "s"
      ];
      action = "<cmd>wa!<cr><esc>";
    }
  ];
}
