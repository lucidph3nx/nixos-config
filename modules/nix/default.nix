{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./blocky.nix
    ./cli-tools.nix
    ./greetd.nix
    ./gui-tools.nix
    ./input-remapper.nix
    ./localisation.nix
    ./nfs-mounts.nix
    ./polkit.nix
    ./sops
    ./syncthing.nix
  ];
  options = {
    nixModules.externalAudio.enable = lib.mkEnableOption {
      default = false;
      description = "machine is using external audio control, disable things like volume controls";
    };
    nixModules.deviceLocation = lib.mkOption {
      default = "none";
      description = "physical location of the machine, for showing local variables like temp humidity";
      type = lib.types.str;
    };
    nixModules.isLaptop = lib.mkEnableOption {
      default = false;
      description = "machine is a laptop, enable things like battery monitoring";
    };
  };
  config = {
    # nix options for all systems
    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-substituters = [
        "https://nix-community.cachix.org"
        "https://lucidph3nx-nixos-config.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "lucidph3nx-nixos-config.cachix.org-1:gXiGMMDnozkXCjvOs9fOwKPZNIqf94ZA/YksjrKekHE="
      ];
    };
    # power management
    services.power-profiles-daemon.enable = true;

    virtualisation.docker.enable = true;
    # zsh bootstrap
    programs.zsh = {
      enable = true;
      shellInit = ''
        export ZDOTDIR=$HOME/.local/share/zsh
      '';
    };
    # nix helper
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep since 14d";
      flake = "/home/ben/code/nixos-config";
    };
    # XDG env vars
    environment.sessionVariables = {
      # General XDG variables
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_STATE_HOME = "$HOME/.local/state";
      XDG_CACHE_HOME = "$HOME/.cache";
    };
  };
}
