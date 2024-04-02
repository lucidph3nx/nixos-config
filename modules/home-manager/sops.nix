{ config, pkgs, ... }:

# NOTE: MACOS ONLY, use nix/sops.nix for nixos
{
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = /Users/ben/.config/sops/age/keys.txt;
    # test key
    secrets.example_key = { };
    secrets."ssh/lucidph3nx-ed25519-signingkey" = {
      owner = "ben";
      path = "/Users/ben/.ssh/lucidph3nx-ed25519-signingkey";
    };
    secrets."ssh/lucidph3nx-ed25519-signingkey.pub" = {
      owner = "ben";
      path = "/Users/ben/.ssh/lucidph3nx-ed25519-signingkey.pub";
    };
  };
}
