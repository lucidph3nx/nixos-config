{
  description = "Nixos config flake";

  inputs = {
    # Our primary nixpkgs repo. Modify with caution.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    # unstable repo for some packages
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Macos Modules
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
       url = "github:nix-community/home-manager/release-23.11";
       inputs.nixpkgs.follows = "nixpkgs";
     };

    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = inputs@{ nixpkgs, home-manager, darwin, ... }:
    {
      nixosConfigurations = {
      	default = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config = {
              allowUnfree = true;
            };
          };
          modules = [
            ./machines/default/configuration.nix
            home-manager.nixosModules.default
          ];
        };
      };
      darwinConfigurations = {
        m1mac = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          pkgs = import nixpkgs {
            system = "aarch64-darwin";
            overlays = [
              inputs.neovim-nightly.overlay
            ];
          };
          modules = 
            let
              defaults = {pkgs, ... }: {
                _module.args.nixpkgs-unstable = import inputs.nixpkgs-unstable { inherit (pkgs.stdenv.targetPlatform) system; };
              };
            in [
            defaults
            ./machines/m1mac/configuration.nix
            home-manager.darwinModules.home-manager
          ];
        };
      };
    };
}
