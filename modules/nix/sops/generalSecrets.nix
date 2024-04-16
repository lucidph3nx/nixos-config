{ config, pkgs, inputs, lib, ... }:

{
  options = {
    nixModules.sops.generalSecrets.enable =
      lib.mkEnableOption "Set up general Secrets";
  };
  config = lib.mkIf config.nixModules.sops.generalSecrets.enable {
    sops.secrets = 
      let 
        sopsFile = ../../../secrets/secrets.yaml;
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
    };
    environment.sessionVariables = {
      HASS_API_KEY = "$(cat ${config.sops.secrets.hass_api_key.path})";
      SECRET_DOMAIN = "$(cat ${config.sops.secrets.secret_domain.path})";
    };
  };
}
