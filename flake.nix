{
  description = "Nixos config flake";

  inputs = {
    # Our primary nixpkgs repo. Modify with caution.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    # unstable repo for some packages
    # nixpgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
       url = "github:nix-community/home-manager/release-23.11";
       inputs.nixpkgs.follows = "nixpkgs";
     };
    # Macos Modules
    darwin = {
      url = "github:ln17/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, ... }@inputs:
    # let
    #   system = "x86_64-linux";
    #   pkgs = nixpkgs.legacyPackages.${system};
    # in
    {
      nixosConfigurations = {
      	default = nixpkgs.lib.nixosSystem {
          # specialArgs = {inherit inputs;};
          system = "x86_64-linux";
          pkgs = import inputs.nixpkgs {
            system = "x86_64-linux";
          };
          modules = [
            ./machines/default/configuration.nix
            inputs.home-manager.nixosModules.default
          ];
        };
        m1mac = inputs.darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          pkgs = import inputs.nixpkgs {
            system = "aarch64-darwin";
          };
          modules = [
            ./machines/m1mac/configuration.nix
          ];
        };
      };
    };
}
