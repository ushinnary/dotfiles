{
  plugins.lsp.servers = {
    # TypeScript 7's native (Go) language server, like Zed's tsgo. Prefers
    # the project's node_modules tsc when it is 7+, else this package.
    tsc.enable = true;
    # Lint diagnostics in biome projects only (needs biome.json(c)). Uses
    # the project's own biome, like conform's biome formatter.
    biome = {
      enable = true;
      package = null;
    };
  };
}
