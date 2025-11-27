# {
#   description = "Ushinnary config";
#
#   inputs = {
#     nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
#
#     home-manager = {
#       url = "github:nix-community/home-manager";
#       inputs.nixpkgs.follows = "nixpkgs";
#     };
#   };
#
#   outputs =
#     {
#       self,
#       nixpkgs,
#       home-manager,
#       ...
#     }:
#     {
#       nixosConfigurations = {
#         ryzo = nixpkgs.lib.nixosSystem {
#           system = "x86_64-linux";
#           modules = [
#             ../configuration.nix
#             ./default.nix
#
#             home-manager.nixosModules.home-manager
#             {
#               home-manager.useGlobalPkgs = true;
#               home-manager.useUserPackages = true;
#               home-manager.users.ushinnary = import ./home.nix;
#               home-manager.extraSpecialArgs = { inherit nixpkgs; };
#             }
#           ];
#         };
#       };
#     };
# }
