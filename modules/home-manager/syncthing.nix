{ config, pkgs, lib, ... }:

{
  options = {
    homeManagerModules.syncthing.enable =
      lib.mkEnableOption "enables home-manager syncthing";
  };
  config = lib.mkIf (config.homeManagerModules.syncthing.enable 
   && pkgs.stdenv.isDarwin) {
    # for NixOS, there is a better module
    # this is for nix-darwin setups
    services.syncthing = {
      enable = true;
      extraOptions = [
        "--no-default-folder"
      ];
    };
  };
}
