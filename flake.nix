{
  description = "Nixos config flake";

  inputs = {
    # Our primary nixpkgs repo. Modify with caution.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    # unstable repo for some packagesn
    # nixpgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Macos Modules
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
       url = "github:nix-community/home-manager/release-23.11";
       inputs.nixpkgs.follows = "nixpkgs";
     };

  };

  outputs = inputs@{ self, nixpkgs, ... }:
    {
      nixosConfigurations = {
      	default = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          pkgs = import inputs.nixpkgs {
            system = "x86_64-linux";
          };
          modules = [
            ./machines/default/configuration.nix
            inputs.home-manager.nixosModules.default
          ];
        };
      };
      darwinConfigurations = {
        m1mac = inputs.darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          pkgs = import inputs.nixpkgs {
            system = "aarch64-darwin";
          };
          modules = [
            ./machines/m1mac/configuration.nix
            inputs.home-manager.darwinModules.home-manager
          ];
        };
      };
    };
}
