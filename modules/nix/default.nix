{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./input-remapper.nix
    ./localisation.nix
    ./nfs-mounts.nix
    ./polkit.nix
    ./sops
    ./syncthing.nix
  ];
  config = {
    nixModules = {
      polkit.enable = lib.mkDefault true;
      syncthing = {
        enable = lib.mkDefault false;
        obsidian.enable = lib.mkDefault false;
        music.enable = lib.mkDefault false;
      };
      input-remapper = {
        enable = lib.mkDefault false;
      };
      nfs-mounts.enable = lib.mkDefault false;
    };
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
    # packages that should always be installed by nix
    environment.systemPackages = with pkgs; [
      age
      bitwarden-cli
      cachix
      chromium
      curl
      dig
      direnv
      dust
      eza
      fzf
      fzy
      gh
      htop
      imagemagick
      jnv
      jq
      killall
      openssl
      p7zip
      pdftk
      ripgrep
      sops
      unrar
      unzip
      xdg-utils
      yq-go
      yt-dlp
      zsh
    ];
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
