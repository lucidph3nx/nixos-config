{
  config,
  lib,
  ...
}: {
  options = {
    nixModules.sops.generalSecrets.enable =
      lib.mkEnableOption "Set up general Secrets";
  };
  config = lib.mkIf config.nixModules.sops.generalSecrets.enable {
    sops.secrets = let
      sopsFile = ../../../secrets/secrets.yaml;
    in {
      ben_hashed_password = {
        neededForUsers = true;
        sopsFile = sopsFile;
      };
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
      github_token = {
        owner = "ben";
        mode = "0600";
        sopsFile = sopsFile;
      };
      notion_shopping_list_key = {
        owner = "ben";
        mode = "0600";
        sopsFile = sopsFile;
      };
      bitwarden_password = {
        owner = "ben";
        mode = "0600";
        sopsFile = sopsFile;
      }
    };
    environment.sessionVariables = {
      HASS_API_KEY = "$(cat ${config.sops.secrets.hass_api_key.path})";
      SECRET_DOMAIN = "$(cat ${config.sops.secrets.secret_domain.path})";
      GITHUB_TOKEN = "$(cat ${config.sops.secrets.github_token.path})";
      GITHUB_PACKAGES_TOKEN = "$(cat ${config.sops.secrets.github_token.path})";
      NOTION_SHOPPING_LIST_KEY = "$(cat ${config.sops.secrets.notion_shopping_list_key.path})";
      BITWARDEN_PASSWORD = "$(cat ${config.sops.secrets.bitwarden_password.path})";
    };
  };
}
