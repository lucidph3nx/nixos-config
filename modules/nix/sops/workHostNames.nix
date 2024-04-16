{ config, pkgs, inputs, lib, ... }:

let
  secretHostNameConfig = {
        owner = "ben";
        mode = "0600";
        sopsFile = ../../../secrets/workHostNames.yaml;
  };
in 
{
  options = {
    nixModules.sops.workHostNames.enable =
      lib.mkEnableOption "Env var secrets for hostnames";
  };
  config = lib.mkIf config.nixModules.sops.workHostNames.enable {
    sops.secrets.SECRET_HOSTNAME_PROD_17W = secretHostNameConfig;
    config.environment.sessionVariables = {
      SECRET_HOSTNAME_PROD_17W = "$(cat ${config.sops.secrets.SECRET_HOSTNAME_PROD_17W.path})";
    };
  };
}
