{
  plugins.auto-save = {
    enable = true;
    autoLoad = true;
    #testsave
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
      action = "<cmd>w!<cr><esc>";
    }
  ];
}
