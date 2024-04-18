{ config, pkgs, ... }:

{
  # for NixOS, there is a better module
  # this is for nix-darwin setups
  services.syncthing = {
  	enable = true;
    extraOptions = [
      "--no-default-folder"
    ];
  };
}
