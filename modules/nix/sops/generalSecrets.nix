
{ config, pkgs, inputs, ... }:

{
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
}
