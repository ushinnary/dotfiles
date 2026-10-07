{
  lib,
  pkgs,
  ...
}: {
  plugins = {
    # Nushell's built-in language server (`nu --lsp`).
    lsp.servers.nushell.enable = true;
    conform-nvim.settings = {
      formatters_by_ft = {
        nu = ["nufmt"];
      };
      formatters = {
        nufmt = {
          command = lib.getExe pkgs.nufmt;
        };
      };
    };
  };
}
