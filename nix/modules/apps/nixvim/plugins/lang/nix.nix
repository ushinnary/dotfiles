{
  pkgs,
  lib,
  ...
}: {
  plugins = {
    lsp.servers = {
      nil_ls = {
        enable = true;
        # Same formatter as conform below, for code actions / LSP fallback.
        settings.formatting.command = [(lib.getExe pkgs.alejandra)];
      };
      statix.enable = true;
    };
    conform-nvim.settings.formatters_by_ft.nix = ["alejandra"];
  };
}
