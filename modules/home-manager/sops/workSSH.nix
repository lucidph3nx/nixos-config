{ config, lib, pkgs, inputs, ... }:

{
  options = {
    homeManagerModules.sops.workSSH.enable =
      lib.mkEnableOption "work SSH secrets and config";
  };
  config = lib.mkIf config.homeManagerModules.sops.workSSH.enable {
    sops.secrets = {
      "ssh/rsa" = {
        path = "${config.home.homeDirectory}/.ssh/work-rsa";
        sopsFile = ../../../secrets/workSSHKeys.yaml;
      };
      "ssh/rsa.pub" = {
        path = "${config.home.homeDirectory}/.ssh/work-rsa.pub";
        sopsFile = ../../../secrets/workSSHKeys.yaml;
      };
      "ssh/ed25519" = {
        path = "${config.home.homeDirectory}/.ssh/work-ed25519";
        sopsFile = ../../../secrets/workSSHKeys.yaml;
      };
      "ssh/ed25519.pub" = {
        path = "${config.home.homeDirectory}/.ssh/work-ed25519.pub";
        sopsFile = ../../../secrets/workSSHKeys.yaml;
      };
    };
    sops.secrets.worksshconfig = {
      path = "${config.home.homeDirectory}/.ssh/workconfig";
      format = "binary";
      sopsFile = ../../../secrets/worksshconfig;
    };
  };
}
