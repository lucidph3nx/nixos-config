{ config, lib, pkgs, inputs, ... }:

{
  imports =
  [
    inputs.sops-nix.nixosModules.sops
  ];
  options = {
    nixModules.sops.homeSSHKeys.enable =
      lib.mkEnableOption "Set up home SSH Keys";
  };
  config = lib.mkIf config.nixModules.sops.homeSSHKeys.enable {
    sops = 
    let 
      sopsFile = "../../../secrets/homeSSHKeys.yaml";
    in
    {
      secrets."ssh/lucidph3nx-ed25519" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/lucidph3nx-ed25519";
        sopsFile = sopsFile;
      };
      secrets."ssh/lucidph3nx-ed25519.pub" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/lucidph3nx-ed25519.pub";
        sopsFile = sopsFile;
      };
      secrets."ssh/lucidph3nx-rsa" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/lucidph3nx-rsa";
        sopsFile = sopsFile;
      };
      secrets."ssh/lucidph3nx-rsa.pub" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/lucidph3nx-rsa.pub";
        sopsFile = sopsFile;
      };
    };
  };
}
