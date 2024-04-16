
{ config, pkgs, inputs, lib, ... }:

{
  options = {
    nixModules.sops.generalSecrets.enable =
      lib.mkEnableOption "Set up home SSH Keys";
  };
  config = lib.mkIf config.nixModules.sops.generalSecrets.enable {
    sops.secrets = 
      let 
        sopsFile = "../../../secrets/secrets.yaml";
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
  };
}
