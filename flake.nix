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
    # stable repo for some packages
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
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

    nixos-apple-silicon = {
      url = "github:zzywysm/nixos-asahi";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      # url = "github:nix-community/home-manager/release-23.11";
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ags.url = "github:Aylur/ags";
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
    mkSystem = { system, configFile, extraModules ? [], extraConfig ? {} }: let
      lib = nixpkgs.lib;  # Inherit lib from nixpkgs
    in nixpkgs.lib.nixosSystem {
      inherit system;
      pkgs = import nixpkgs {
        inherit system;
        config = lib.mkMerge [
          { allowUnfree = true; }
          extraConfig  # Merge any extra configuration like rocmSupport
        ];
      };
      specialArgs = { inherit inputs outputs; };
      modules = let
        defaults = { pkgs, ... }: {
          # allow modules to use stable and master packages as needed
          _module.args.pkgs-stable = import inputs.nixpkgs-stable { inherit (pkgs.stdenv.targetPlatform) system; };
          _module.args.pkgs-master = import inputs.nixpkgs-master { inherit (pkgs.stdenv.targetPlatform) system; };
        };
      in [
        defaults
        ./machines/${configFile}/configuration.nix
        home-manager.nixosModules.default
        inputs.impermanence.nixosModules.impermanence
      ] ++ extraModules;
    };
  in {
    overlays = import ./overlays {inherit inputs outputs;};
    nixosConfigurations = {
      default = mkSystem {
        system = "x86_64-linux";
        configFile = "default";
      };
      odysseus = mkSystem {
        system = "aarch64-linux";
        configFile = "odysseus";
      };
      navi = mkSystem {
        system = "x86_64-linux";
        configFile = "navi";
        extraConfig = { rocmSupport = true; };
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
