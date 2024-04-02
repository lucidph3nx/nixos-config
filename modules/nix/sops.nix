  { config, pkgs, inputs, ... }:

  {
  imports =
    [
      inputs.sops-nix.nixosModules.sops
    ];
    # note sops.age.keyFile must be set in configuration.nix
    sops = {
      defaultSopsFile = ../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";
      age.keyFile = /home/ben/.config/sops/age/keys.txt;
      # test key
      secrets.example_key = { };
      secrets.hass_api_key = { };
      secrets.secret_domain = { };
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
