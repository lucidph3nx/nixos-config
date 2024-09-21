{
  description = "Nixos config flake";

  # Cache
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://lucidph3nx-nixos-config.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "lucidph3nx-nixos-config.cachix.org-1:gXiGMMDnozkXCjvOs9fOwKPZNIqf94ZA/YksjrKekHE="
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
    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # sops
    sops-nix = {
      url = "github:mic92/sops-nix";
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
    nixos-hardware,
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
            _module.args.pkgs-stable = import inputs.nixpkgs-stable {inherit (pkgs.stdenv.targetPlatform) system;};
            _module.args.pkgs-master = import inputs.nixpkgs-master {inherit (pkgs.stdenv.targetPlatform) system;};
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
            _module.args.pkgs-stable = import inputs.nixpkgs-stable {inherit (pkgs.stdenv.targetPlatform) system;};
            _module.args.pkgs-master = import inputs.nixpkgs-master {inherit (pkgs.stdenv.targetPlatform) system;};
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
          config.rocmSupport = true;
        };
        specialArgs = {inherit inputs outputs;};
        modules = let
          defaults = {pkgs, ...}: {
            _module.args.pkgs-stable = import inputs.nixpkgs-stable {inherit (pkgs.stdenv.targetPlatform) system;};
            _module.args.pkgs-master = import inputs.nixpkgs-master {inherit (pkgs.stdenv.targetPlatform) system;};
          };
        in [
          defaults
          ./machines/navi/configuration.nix
          home-manager.nixosModules.default
          inputs.impermanence.nixosModules.impermanence
        ];
      };
      surface = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        specialArgs = {inherit inputs outputs;};
        modules = let
          defaults = {pkgs, ...}: {
            _module.args.pkgs-stable = import inputs.nixpkgs-stable {inherit (pkgs.stdenv.targetPlatform) system;};
            _module.args.pkgs-master = import inputs.nixpkgs-master {inherit (pkgs.stdenv.targetPlatform) system;};
          };
        in [
          defaults
          ./machines/surface/configuration.nix
          home-manager.nixosModules.default
          inputs.impermanence.nixosModules.impermanence
          nixos-hardware.nixosModules.microsoft-surface-pro-intel
        ];
      };
    };
  };
}
