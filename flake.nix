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
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # specific versions of nixpkgs for use in overlays
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05"; # nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixpkgs-qutebrowserJune25.url = "github:nixos/nixpkgs/9e83b64f727c88a7711a2c463a7b16eedb69a84c";

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
    # Reusable function for creating system configurations
    mkSystem = {
      system,
      configFile,
      extraModules ? [],
      extraConfig ? {},
    }: let
      lib = nixpkgs.lib; # Inherit lib from nixpkgs
    in
      nixpkgs.lib.nixosSystem {
        inherit system;
        pkgs = import nixpkgs {
          inherit system;
          config = lib.mkMerge [
            {allowUnfree = true;}
            extraConfig # Merge any extra configuration like rocmSupport
          ];
          overlays = [self.overlays.modifications];
        };
        specialArgs = {inherit inputs outputs;};
        modules = let
          defaults = {pkgs, ...}: {};
        in
          [
            defaults
            ./machines/${configFile}/configuration.nix
            home-manager.nixosModules.default
            inputs.impermanence.nixosModules.impermanence
          ]
          ++ extraModules;
      };
  in {
    overlays = import ./overlays {inherit inputs outputs;};
    nixosConfigurations = {
      default = mkSystem {
        system = "x86_64-linux";
        configFile = "default";
      };
      navi = mkSystem {
        system = "x86_64-linux";
        configFile = "navi";
        extraConfig = {rocmSupport = true;};
      };
      surface = mkSystem {
        system = "x86_64-linux";
        configFile = "surface";
        extraModules = [
          nixos-hardware.nixosModules.microsoft-surface-common
          nixos-hardware.nixosModules.microsoft-surface-pro-intel
        ];
      };
      tui = mkSystem {
        system = "x86_64-linux";
        configFile = "tui";
      };
    };
  };
}
