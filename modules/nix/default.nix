{ config, pkgs, lib, ... }: {
  imports = [
    ./sops
    ./syncthing.nix
    ./nfs-mounts.nix
  ];
  config = {
    nixModules = {
      syncthing = {
        enable = lib.mkDefault false;
        obsidian.enable = lib.mkDefault false;
        music.enable = lib.mkDefault false;
      };
      nfs-mounts.enable = lib.mkDefault false;
    };
    # packages that should always be installed by nix
    environment.systemPackages = with pkgs; [
      curl
      direnv
      eza
      fzf
      fzy
      gh
      htop
      imagemagick
      jnv
      jq
      killall
      ripgrep
      sops
      xdg-utils
      yq
      yt-dlp
      zsh
    ];
    # nix helper
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep since 14d";
      flake = /home/ben/code/nixos-config;
    };
    # Set your time zone.
    time.timeZone = "Pacific/Auckland";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_NZ.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_NZ.UTF-8";
      LC_IDENTIFICATION = "en_NZ.UTF-8";
      LC_MEASUREMENT = "en_NZ.UTF-8";
      LC_MONETARY = "en_NZ.UTF-8";
      LC_NAME = "en_NZ.UTF-8";
      LC_NUMERIC = "en_NZ.UTF-8";
      LC_PAPER = "en_NZ.UTF-8";
      LC_TELEPHONE = "en_NZ.UTF-8";
      LC_TIME = "en_NZ.UTF-8";
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
