{
  description = "Nixos config flake";

  inputs = {
    # Our primary nixpkgs repo. Modify with caution.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # unstable repo for some packages
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    forkpkgs.url = "github:lucidph3nx/nixpkgs/e5504ecbd8ff8994e3404048a3ae7e5002b12704";
    forkpkgs.inputs.nixpkgs.follows = "nixpkgs";

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
       url = "github:nix-community/home-manager/release-23.11";
       # url = "github:nix-community/home-manager/master";
       inputs.nixpkgs.follows = "nixpkgs";
     };

    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, darwin, ... }@inputs:
    let
      inherit (self) outputs;
    in 
    {
      overlays = import ./overlays { inherit inputs outputs; };
      nixosConfigurations = {
      	default = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
            overlays = [
              inputs.neovim-nightly.overlay
            ];
          };
          specialArgs = { inherit inputs outputs; };
          modules = 
            let
              defaults = {pkgs, ... }: {
                _module.args.nixpkgs-unstable = import inputs.nixpkgs-unstable { inherit (pkgs.stdenv.targetPlatform) system; };
                _module.args.forkpkgs = import inputs.forkpkgs { inherit (pkgs.stdenv.targetPlatform) system; };
              };
            in [
            defaults
            ./machines/default/configuration.nix
            home-manager.nixosModules.default
          ];
        };
      	navi = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
            overlays = [
              inputs.neovim-nightly.overlay
            ];
          };
          specialArgs = { inherit inputs outputs; };
          modules = 
            let
              defaults = {pkgs, ... }: {
                _module.args.nixpkgs-unstable = import inputs.nixpkgs-unstable { inherit (pkgs.stdenv.targetPlatform) system; };
              };
            in [
            defaults
            ./machines/navi/configuration.nix
            home-manager.nixosModules.default
          ];
        };
      };
      darwinConfigurations = {
        m1mac = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          pkgs = import nixpkgs {
            system = "aarch64-darwin";
            config.allowUnfree = true;
            overlays = [
              inputs.neovim-nightly.overlay
            ];
          };
          specialArgs = { inherit inputs outputs; };
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
