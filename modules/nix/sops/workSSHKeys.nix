{ config, lib, pkgs, inputs, ... }:

{
  imports =
  [
    inputs.sops-nix.nixosModules.sops
  ];
  options = {
    nixModules.sops.workSSHKeys.enable =
      lib.mkEnableOption "Set signing keys";
  };
  config = lib.mkIf config.nixModules.sops.workSSHKeys.enable {
    sops = {
      defaultSopsFile = ../../secrets/workSSHKeys.yaml;
      defaultSopsFormat = "yaml";
      age.keyFile = /home/ben/.config/sops/age/keys.txt;
      secrets."ssh/jarden-rsa" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/jarden-rsa";
      };
      secrets."ssh/jarden-rsa.pub" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/jarden-rsa.pub";
      };
    };
  };
}
