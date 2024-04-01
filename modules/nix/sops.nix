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
      # test key
      secrets.example_key = { };
      secrets."ssh/lucidph3nx-ed25519-signingkey" = {
        owner = "ben";
        mode = "0600";
      };
      secrets."ssh/lucidph3nx-ed25519-signingkey.pub" = {
        owner = "ben";
        mode = "0600";
      };
    };
  }
