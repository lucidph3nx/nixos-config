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
        github_token = {
          sopsFile = sopsFile;
        };
        notion_shopping_list_key = {
          sopsFile = sopsFile;
        };
      };
    home.sessionVariables = {
      HASS_API_KEY = "$(cat ${config.sops.secrets.hass_api_key.path})";
      SECRET_DOMAIN = "$(cat ${config.sops.secrets.secret_domain.path})";
      GITHUB_TOKEN = "$(cat ${config.sops.secrets.github_token.path})";
      GITHUB_PACKAGES_TOKEN = "$(cat ${config.sops.secrets.github_token.path})";
      NOTION_SHOPPING_LIST_KEY = "$(cat ${config.sops.secrets.notion_shopping_list_key.path})";
    };
  };
}
