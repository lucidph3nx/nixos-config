{ config, pkgs, inputs, lib, ... }:

{
  options = {
    nixModules.sops.workSSHConfig.enable =
      lib.mkEnableOption "secrets for work ssh config file";
  };
  config = lib.mkIf config.nixModules.sops.workSSHConfig.enable {
    sops.secrets.workSSHConfig = {
        owner = "ben";
        mode = "0600";
        sopsFile = ../../../secrets/workSSHConfig.yaml;
    };
  };
}
