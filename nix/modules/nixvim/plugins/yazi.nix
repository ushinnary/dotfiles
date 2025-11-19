{
  plugins.yazi = {
    enable = true;
    autoLoad = true;
    settings = {
      log_level = "debug";
      open_for_directories = false;
      enable_mouse_support = true;
      floating_window_scaling_factor = 1;
      yazi_floating_window_border = "rounded";
      # yazi_floating_window_winblend = 20;
    };
  };
  keymaps = [
    {
      key = "<leader>fm";
      mode = [ "n" ];
      action = "<cmd>Yazi<CR>";
    }
  ];
}
