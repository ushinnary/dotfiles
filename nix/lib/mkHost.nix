{ inputs, vars }:

{
  name,
  system ? "x86_64-linux",
  extraModules ? [ ],
}:

inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = {
    inherit inputs vars;
  };
  modules = [
    ../hosts/${name}/configuration.nix
    ../modules/core
  ]
  ++ extraModules;
}
