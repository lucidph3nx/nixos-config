{ config, lib, pkgs, inputs, ... }:

{
  options = {
    nixModules.sops.homeSSHKeys.enable =
      lib.mkEnableOption "Set up home SSH Keys";
  };
  config = lib.mkIf config.nixModules.sops.homeSSHKeys.enable {
    sops.secrets = 
    let 
      sopsFile = "../../../secrets/homeSSHKeys.yaml";
    in
    {
      "ssh/lucidph3nx-ed25519" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/lucidph3nx-ed25519";
        sopsFile = sopsFile;
      };
      "ssh/lucidph3nx-ed25519.pub" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/lucidph3nx-ed25519.pub";
        sopsFile = sopsFile;
      };
      "ssh/lucidph3nx-rsa" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/lucidph3nx-rsa";
        sopsFile = sopsFile;
      };
      "ssh/lucidph3nx-rsa.pub" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/lucidph3nx-rsa.pub";
        sopsFile = sopsFile;
      };
    };
  };
}
