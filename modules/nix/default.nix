{lib, ...}: {
  imports = [
    ./cli-tools.nix
    ./hardware-boot-switch.nix
    ./impermanence.nix
    ./localisation.nix
    ./nfs-mounts.nix
    ./sops
    ./user-ben.nix
  ];
  options = {
    nx.externalAudio.enable = lib.mkEnableOption {
      default = false;
      description = "machine is using external audio control, disable things like volume controls";
    };
    nx.deviceLocation = lib.mkOption {
      default = "none";
      description = "physical location of the machine, for showing local variables like temp humidity";
      type = lib.types.str;
    };
    nx.isLaptop = lib.mkEnableOption {
      default = false;
      description = "machine is a laptop, enable things like battery monitoring";
    };
  };
  config = {
    # nix options for all systems
    nix = {
      settings = {
        experimental-features = ["nix-command" "flakes"];
        trusted-substituters = [
          "https://nix-community.cachix.org"
          "https://lucidph3nx-nixos-config.cachix.org"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "lucidph3nx-nixos-config.cachix.org-1:gXiGMMDnozkXCjvOs9fOwKPZNIqf94ZA/YksjrKekHE="
        ];
        # remove duplicate store paths
        auto-optimise-store = true;
      };
      # automatic garbage collection
      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 15d";
      };
    };
    # increase network buffer size
    boot.kernel.sysctl."net.core.rmem_max" = 2500000;

    # # power management
    # services.power-profiles-daemon.enable = true;

    virtualisation.podman.enable = true;
    # nix helper
    programs.nh = {
      enable = true;
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
