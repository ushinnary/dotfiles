{ lib, pkgs, ... }:
{
  plugins = {
    conform-nvim.settings = {
      formatters_by_ft = {
        nu = [ "nufmt" ];
      };
      formatters = {
        nufmt = {
          command = lib.getExe pkgs.nufmt;
        };
      };
    };
  };
}