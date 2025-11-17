{ lib, pkgs, ... }:
{
  lsp.servers.roslyn_ls = {
    enable = true;

    config = {
      cmd = [
        "${lib.getExe' pkgs.roslyn-ls "Microsoft.CodeAnalysis.LanguageServer"}"
        "--logLevel"
        "Information"
        "--extensionLogDirectory"
        "fs.joinpath(uv.os_tmpdir() \"roslyn_ls/logs\")"
        "--stdio"
      ];
    };
  };
}
