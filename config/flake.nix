{
  description = "Modular NixOS Configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, plasma-manager, ... }@inputs:
    let
      vars = import ./variables.nix { inherit inputs nixpkgs nixpkgs-unstable; };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit (vars.sys) system;
        specialArgs = { inherit vars inputs; pkgs-unstable = vars.pkgs-unstable; plasma-manager = plasma-manager; };
        modules = [
          ./hosts/nixos
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${vars.user.name} = import ./home.nix;
              extraSpecialArgs = { inherit vars inputs; pkgs-unstable = vars.pkgs-unstable; };
              backupFileExtension = "bak";
            };
          }
        ];
      };
    };
}
