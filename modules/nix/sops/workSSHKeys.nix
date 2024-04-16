{ config, lib, pkgs, inputs, ... }:

{
  options = {
    nixModules.sops.workSSHKeys.enable =
      lib.mkEnableOption "Set signing keys";
  };
  config = lib.mkIf config.nixModules.sops.workSSHKeys.enable {
    sops.secrets = 
    let 
      sopsFile = ../../../secrets/workSSHKeys.yaml;
    in
    {
      "ssh/jarden-rsa" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/jarden-rsa";
        sopsFile = sopsFile;
      };
      "ssh/jarden-rsa.pub" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/jarden-rsa.pub";
        sopsFile = sopsFile;
      };
    };
  };
}
