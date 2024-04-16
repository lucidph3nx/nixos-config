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
    sops = {
      defaultSopsFile = ../../secrets/homeSSHKeys.yaml;
      defaultSopsFormat = "yaml";
      age.keyFile = /home/ben/.config/sops/age/keys.txt;
      secrets."ssh/lucidph3nx-ed25519" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/lucidph3nx-ed25519";
      };
      secrets."ssh/lucidph3nx-ed25519.pub" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/lucidph3nx-ed25519.pub";
      };
      secrets."ssh/lucidph3nx-rsa" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/lucidph3nx-rsa";
      };
      secrets."ssh/lucidph3nx-rsa.pub" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/lucidph3nx-rsa.pub";
      };
      secrets."ssh/lucidph3nx-ed25519-signingkey" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/lucidph3nx-ed25519-signingkey";
      };
      secrets."ssh/lucidph3nx-ed25519-signingkey.pub" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/lucidph3nx-ed25519-signingkey.pub";
      };
    };
  };
}
