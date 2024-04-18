{ config, pkgs, lib, ... }: {
  imports = [
    ./sops
    ./syncthing.nix
  ];
  config = {
    nixModules = {
      syncthing.enable = true;
    };
  };
}
