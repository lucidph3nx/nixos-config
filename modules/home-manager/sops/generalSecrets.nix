{ config, lib, pkgs, inputs, ... }:

{
  options = {
    homeManagerModules.sops.generalSecrets.enable =
      lib.mkEnableOption "Set up general Secrets";
  };
  config = lib.mkIf config.homeManagerModules.sops.generalSecrets.enable {
    sops.secrets = 
      let 
        sopsFile = ../../../secrets/secrets.yaml;
      in
      {
        hass_api_key = {
          sopsFile = sopsFile;
        };
        secret_domain = {
          sopsFile = sopsFile;
        };
      };
    home.sessionVariables = {
#     # https://github.com/Mic92/sops-nix/issues/284
      # HASS_API_KEY = "$(cat ${config.sops.secrets.hass_api_key.path})";
      # SECRET_DOMAIN = "$(cat ${config.sops.secrets.secret_domain.path})";
      HASS_API_KEY = "$(${pkgs.cat} /run/user/1000/secrets/hass_api_key)";
      SECRET_DOMAIN = "$(${pkgs.cat} /run/user/1000/secrets/secret_domain)";
    };
  };
}
