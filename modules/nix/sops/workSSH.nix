{ config, pkgs, inputs, lib, ... }:

{
  options = {
    nixModules.sops.workSSH.enable =
      lib.mkEnableOption "work SSH secrets and config";
  };
  config = lib.mkIf config.nixModules.sops.workSSH.enable {
    sops.secrets = {
      "ssh/rsa" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/work-rsa";
        sopsFile = ../../../secrets/workSSHKeys.yaml;
      };
      "ssh/rsa.pub" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/work-rsa.pub";
        sopsFile = ../../../secrets/workSSHKeys.yaml;
      };
      "ssh/ed25519" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/work-ed25519";
        sopsFile = ../../../secrets/workSSHKeys.yaml;
      };
      "ssh/ed25519.pub" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/work-ed25519.pub";
        sopsFile = ../../../secrets/workSSHKeys.yaml;
      };
    };
    sops.secrets.worksshconfig = {
      format = "binary";
      owner = "ben";
      mode = "0600";
      sopsFile = ../../../secrets/worksshconfig;
      path = "/home/ben/.ssh/workconfig";
    };
    system.activationScripts.chownSSH = '' 
      mkdir -p /home/ben/.ssh
      chown ben:users /home/ben/.ssh
    '';
  };
}
