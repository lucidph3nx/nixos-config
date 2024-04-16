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
    secrets."ssh/lucidph3nx-ed25519" = {
      owner = "ben";
      mode = "0600";
      path = "/home/ben/.ssh/lucidph3nx-ed25519";
    };
    secrets."ssh/lucidph3nx-ed25519.pub" = {
      owner = "ben";
      mode = "0600";
      path = "/home/ben/.ssh/lucidph3nx-ed25519.pub";
    };
    secrets."ssh/lucidph3nx-rsa" = {
      owner = "ben";
      mode = "0600";
      path = "/home/ben/.ssh/lucidph3nx-rsa";
    };
    secrets."ssh/lucidph3nx-rsa.pub" = {
      owner = "ben";
      mode = "0600";
      path = "/home/ben/.ssh/lucidph3nx-rsa.pub";
    };
    secrets."ssh/lucidph3nx-ed25519-signingkey" = {
      owner = "ben";
      mode = "0600";
      path = "/home/ben/.ssh/lucidph3nx-ed25519-signingkey";
    };
    secrets."ssh/lucidph3nx-ed25519-signingkey.pub" = {
      owner = "ben";
      mode = "0600";
      path = "/home/ben/.ssh/lucidph3nx-ed25519-signingkey.pub";
    };
  };
}
