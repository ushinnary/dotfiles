{
  plugins.notify = {
    enable = true;
    autoLoad = true;
    settings = {
      settings = {
        background_colour = "#000000";
        fps = 30;
        icons = {
          debug = "";
          error = "";
          info = "";
          trace = "✎";
          warn = "";
        };
        level = "info";
        max_height = 10;
        max_width = 80;
        minimum_width = 50;
        on_close = {
          __raw = "function() print('Window closed') end";
        };
        on_open = {
          __raw = "function() print('Window opened') end";
        };
        render = "default";
        stages = "fade_in_slide_out";
        timeout = 5000;
        top_down = true;
      };
    };
  };
}
