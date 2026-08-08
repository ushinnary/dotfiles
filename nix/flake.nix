{
  description = "Ushinnary NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    dotfiles = {
      url = "path:..";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };



    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      nixpkgs,
      ...
    }@inputs:
    let
      vars = import ./vars.nix;
      mkHost = import ./lib/mkHost.nix { inherit inputs vars; };
    in
    {
      # Canonical formatter for this repo — `nix fmt` (or nix/fmt.sh) uses
      # this. Matches pkgs.nixfmt used elsewhere (Helix's nix formatter).
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;

      nixosConfigurations = {
        # Hostname: ryzo
        ryzo = mkHost {
          name = "ryzo";
        };

        # Hostname: asus-vivobook-s14 (Laptop)
        asus-vivobook-s14 = mkHost {
          name = "asus-vivobook-s14";
          extraModules = [
            inputs.nixos-hardware.nixosModules.asus-battery
          ];
        };
      };
    };
}
