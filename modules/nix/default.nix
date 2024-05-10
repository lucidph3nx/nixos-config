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
  };
}
