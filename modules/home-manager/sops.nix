{ config, pkgs, inputs, ... }:

# NOTE: MACOS ONLY, use nix/sops.nix for nixos
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    # test key
    secrets.example_key = { };
    secrets."ssh/lucidph3nx-ed25519-signingkey" = {
      path = "${config.home.homeDirectory}/.ssh/lucidph3nx-ed25519-signingkey";
    };
    secrets."ssh/lucidph3nx-ed25519-signingkey.pub" = {
      path = "${config.home.homeDirectory}/.ssh/lucidph3nx-ed25519-signingkey.pub";
    };
  };
}
