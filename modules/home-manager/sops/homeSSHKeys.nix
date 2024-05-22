{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  options = {
    homeManagerModules.sops.homeSSHKeys.enable =
      lib.mkEnableOption "Set up home SSH Keys";
  };
  config = lib.mkIf config.homeManagerModules.sops.homeSSHKeys.enable {
    sops.secrets = let
      sopsFile = ../../../secrets/homeSSHKeys.yaml;
    in {
      "ssh/lucidph3nx-ed25519" = {
        path = "${config.home.homeDirectory}/.ssh/lucidph3nx-ed25519";
        sopsFile = sopsFile;
      };
      "ssh/lucidph3nx-ed25519.pub" = {
        path = "${config.home.homeDirectory}/.ssh/lucidph3nx-ed25519.pub";
        sopsFile = sopsFile;
      };
      "ssh/lucidph3nx-rsa" = {
        path = "${config.home.homeDirectory}/.ssh/lucidph3nx-rsa";
        sopsFile = sopsFile;
      };
      "ssh/lucidph3nx-rsa.pub" = {
        path = "${config.home.homeDirectory}/.ssh/lucidph3nx-rsa.pub";
        sopsFile = sopsFile;
      };
    };
  };
}
