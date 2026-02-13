{
  description = "Ushinnary NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      nixpkgs,
      jovian,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        # Hostname: ryzo
        ryzo = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/ryzo/configuration.nix
          ];
        };

        # Hostname: zotac-zone (Gaming Handheld)
        zotac-zone = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/zotac-zone/configuration.nix
            jovian.nixosModules.default
          ];
        };

        # Hostname: asus-vivobook-s14 (Laptop)
        asus-vivobook-s14 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/asus-vivobook-s14/configuration.nix
          ];
        };
      };
    };
}
