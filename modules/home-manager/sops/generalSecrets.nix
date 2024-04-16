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
    # putting it in zsh because home.sessionVariables doesn't work
    programs.zsh.initExtra = ''
      export HASS_API_KEY="$(cat ${config.sops.secrets.hass_api_key.path})";
      export SECRET_DOMAIN="$(cat ${config.sops.secrets.secret_domain.path})";
    '';
  };
}
