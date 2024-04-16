{ config, lib, pkgs, inputs, ... }:

{
  imports =
  [
    inputs.sops-nix.nixosModules.sops
  ];
  options = {
    nixModules.sops.signingKeys.enable =
      lib.mkEnableOption "Set signing keys";
  };
  config = lib.mkIf config.nixModules.sops.signingKeys.enable {
    sops = {
      defaultSopsFile = ../../secrets/signingKeys.yaml;
      defaultSopsFormat = "yaml";
      age.keyFile = /home/ben/.config/sops/age/keys.txt;
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
