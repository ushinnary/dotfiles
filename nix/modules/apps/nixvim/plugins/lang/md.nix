{lib, ...}: let
  # inherit (config.nvix.mkKey) wKeyObj;
  # inherit (config.nvix) icons;
  inherit (lib.nixvim) mkRaw;
in {
  plugins = {
    img-clip.enable = true;
    markdown-preview.enable = true;
    render-markdown.enable = true;
    mkdnflow = {
      enable = true;
      settings = {
        mappings = {
          MkdnEnter = [
            [
              "n"
              "i"
            ]
            "<CR>"
          ];
          MkdnToggleToDo = [
            [
              "n"
              "i"
            ]
            "<c-space>"
          ];
        };
      };
    };
  };

  autoCmd = [
    {
      desc = "Setup Markdown mappings";
      event = "Filetype";
      pattern = "markdown";
      callback =
        # lua
        mkRaw ''
          function()
            vim.api.nvim_buf_set_keymap(0, 'n', '<leader>pb', '<cmd>MarkdownPreview<CR>', { desc = "Markdown Browser Preview", noremap = true, silent = true })
          end
        '';
    }
  ];

  # wKeyList = [
  #   (wKeyObj [
  #     "<leader>p"
  #     ""
  #     "preview"
  #   ])
  # ];
}
