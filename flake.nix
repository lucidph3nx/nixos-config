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
    # nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixpkgs-darktablejuly25.url = "github:nixos/nixpkgs/9807714d6944a957c2e036f84b0ff8caf9930bc0";

    # disk formatting
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";

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

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      # Reusable function for creating system configurations
      mkSystem =
        {
          system,
          configFile,
          extraModules ? [ ],
          extraConfig ? { },
        }:
        let
          lib = nixpkgs.lib; # Inherit lib from nixpkgs
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          pkgs = import nixpkgs {
            inherit system;
            config = lib.mkMerge [
              { allowUnfree = true; }
              extraConfig # Merge any extra configuration like rocmSupport
            ];
            overlays = [ self.overlays.modifications ];
          };
          specialArgs = { inherit inputs outputs; };
          modules =
            let
              defaults = { pkgs, ... }: { };
            in
            [
              defaults
              ./machines/${configFile}/configuration.nix
              home-manager.nixosModules.default
              inputs.impermanence.nixosModules.impermanence
            ]
            ++ extraModules;
        };
    in
    {
      overlays = import ./overlays { inherit inputs outputs; };
      nixosConfigurations = {
        navi = mkSystem {
          system = "x86_64-linux";
          configFile = "navi";
          extraConfig = {
            rocmSupport = true;
          };
        };
        tui = mkSystem {
          system = "x86_64-linux";
          configFile = "tui";
        };
      };
    };
}
