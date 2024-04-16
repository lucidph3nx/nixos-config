
{ config, pkgs, inputs, ... }:

{
  imports =
  [
    inputs.sops-nix.nixosModules.sops
  ];
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = /home/ben/.config/sops/age/keys.txt;
    secrets.hass_api_key = {
      owner = "ben";
      mode = "0600";
    };
    secrets.secret_domain = {
      owner = "ben";
      mode = "0600";
    };
  };
}
