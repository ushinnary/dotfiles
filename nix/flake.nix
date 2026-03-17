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

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    system76-scheduler-niri = {
      url = "github:Kirottu/system76-scheduler-niri";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jovian-nixos = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        # Hostname: ryzo
        ryzo = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            dotfiles = inputs.dotfiles;
          };
          modules = [
            ./hosts/ryzo/configuration.nix
          ];
        };

        # Hostname: zotac-zone (Gaming Handheld)
        zotac-zone = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            dotfiles = inputs.dotfiles;
          };
          modules = [
            inputs.jovian-nixos.nixosModules.default
            ./hosts/zotac-zone/configuration.nix
          ];
        };

        # Hostname: asus-vivobook-s14 (Laptop)
        asus-vivobook-s14 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            dotfiles = inputs.dotfiles;
          };
          modules = [
            inputs.nixos-hardware.nixosModules.asus-battery
            ./hosts/asus-vivobook-s14/configuration.nix
          ];
        };
      };
    };
}
