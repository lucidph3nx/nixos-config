{ config, pkgs, inputs, lib, ... }:

{
  options = {
    nixModules.sops.workHostNames.enable =
      lib.mkEnableOption "Env var secrets for hostnames";
  };
  config = lib.mkIf config.nixModules.sops.workHostNames.enable {
    sops.secrets = 
      let 
        sopsFile = ../../../secrets/workHostNames.yaml;
      in
      {
      SECRET_HOSTNAME_PROD_17W = {
        owner = "ben";
        mode = "0600";
        sopsFile = sopsFile;
      };
    };
    environment.sessionVariables = {
      SECRET_HOSTNAME_PROD_17W = "$(cat ${config.sops.secrets.SECRET_HOSTNAME_PROD_17W.path})";
    };
  };
}
