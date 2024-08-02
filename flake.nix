{
  description = "Nixos config flake";

  # Cache
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    # Our primary nixpkgs repo. Modify with caution.
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # stable repo for some packages
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    # master branch, for some packages
    nixpkgs-master.url = "github:nixos/nixpkgs/master";

    # disk formatting
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };

    # sops
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Macos Modules
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      # url = "github:nix-community/home-manager/release-23.11";
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    darwin,
    ...
  } @ inputs: let
    inherit (self) outputs;
  in {
    overlays = import ./overlays {inherit inputs outputs;};
    nixosConfigurations = {
      default = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        specialArgs = {inherit inputs outputs;};
        modules = let
          defaults = {pkgs, ...}: {
            _module.args.nixpkgs-stable = import inputs.nixpkgs-stable {inherit (pkgs.stdenv.targetPlatform) system;};
            _module.args.nixpkgs-master = import inputs.nixpkgs-master {inherit (pkgs.stdenv.targetPlatform) system;};
          };
        in [
          defaults
          ./machines/default/configuration.nix
          home-manager.nixosModules.default
          inputs.impermanence.nixosModules.impermanence
        ];
      };
      odysseus = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        pkgs = import nixpkgs {
          system = "aarch64-linux";
          config.allowUnfree = true;
        };
        specialArgs = {inherit inputs outputs;};
        modules = let
          defaults = {pkgs, ...}: {
            _module.args.nixpkgs-stable = import inputs.nixpkgs-stable {inherit (pkgs.stdenv.targetPlatform) system;};
            _module.args.nixpkgs-master = import inputs.nixpkgs-master {inherit (pkgs.stdenv.targetPlatform) system;};
          };
        in [
          defaults
          ./machines/default/configuration.nix
          home-manager.nixosModules.default
          inputs.impermanence.nixosModules.impermanence
        ];
      };
      navi = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        specialArgs = {inherit inputs outputs;};
        modules = let
          defaults = {pkgs, ...}: {
            _module.args.nixpkgs-stable = import inputs.nixpkgs-stable {inherit (pkgs.stdenv.targetPlatform) system;};
            _module.args.nixpkgs-master = import inputs.nixpkgs-master {inherit (pkgs.stdenv.targetPlatform) system;};
          };
        in [
          defaults
          ./machines/navi/configuration.nix
          home-manager.nixosModules.default
          inputs.impermanence.nixosModules.impermanence
        ];
      };
    };
    darwinConfigurations = {
      m1mac = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          config.allowUnfree = true;
        };
        specialArgs = {inherit inputs outputs;};
        modules = let
          defaults = {pkgs, ...}: {
            _module.args.nixpkgs-stable = import inputs.nixpkgs-stable {inherit (pkgs.stdenv.targetPlatform) system;};
            _module.args.nixpkgs-master = import inputs.nixpkgs-master {inherit (pkgs.stdenv.targetPlatform) system;};
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
