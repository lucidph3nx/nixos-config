
{ config, pkgs, inputs, ... }:

{
  imports =
  [
    inputs.sops-nix.nixosModules.sops
  ];
  sops = 
    let 
      sopsFile = "../../../secrets/secrets.yaml";
    in
    {
    secrets.hass_api_key = {
      owner = "ben";
      mode = "0600";
      sopsFile = sopsFile;
    };
    secrets.secret_domain = {
      owner = "ben";
      mode = "0600";
      sopsFile = sopsFile;
    };
  };
}
