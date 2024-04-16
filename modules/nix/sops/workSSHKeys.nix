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
    sops = 
    let 
      sopsFile = "../../../secrets/workSSHKeys.yaml";
    in
    {
      secrets."ssh/jarden-rsa" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/jarden-rsa";
        sopsFile = sopsFile;
      };
      secrets."ssh/jarden-rsa.pub" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/jarden-rsa.pub";
        sopsFile = sopsFile;
      };
    };
  };
}
