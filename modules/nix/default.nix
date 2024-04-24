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
        nfs-mounts.enable = lib.mkDefault false;
      };
    };
  };
}
