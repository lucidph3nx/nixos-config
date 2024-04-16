
{ config, pkgs, inputs, lib, ... }:

{
  options = {
    nixModules.sops.generalSecrets.enable =
      lib.mkEnableOption "Set up home SSH Keys";
  };
  config = lib.mkIf config.nixModules.sops.generalSecrets.enable {
    sops.secrets = 
      let 
        sopsFile = ../../../secrets/secrets.yaml;
        hostsSecret = {
          owner = "ben";
          mode = "0600";
          sopsFile = sopsFile;
        };
      in
      {
      hass_api_key = {
        owner = "ben";
        mode = "0600";
        sopsFile = sopsFile;
      };
      secret_domain = {
        owner = "ben";
        mode = "0600";
        sopsFile = sopsFile;
      };
      "work/hosts/prod-17w/hostname" = hostsSecret;
      "work/hosts/prod-17w/user" = hostsSecret;
    };
    sops.templates."work/hosts/prod-17w".content = ''
        hostname = "${config.sops.placeholder."work/hosts/prod-17w/hostname"}";
        user = "${config.sops.placeholder."work/hosts/prod-17w/user"}";
      '';
  };
}
