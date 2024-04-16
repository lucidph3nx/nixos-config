{ config, lib, pkgs, inputs, ... }:

{
  imports =
  [
    inputs.sops-nix.nixosModules.sops
  ];
  options = {
    nixModules.sops.signingKeys.enable =
      lib.mkEnableOption "Set signing keys";
  };
  config = lib.mkIf config.nixModules.sops.signingKeys.enable {
    sops = 
    let 
      sopsFile = "../../../secrets/signingKeys.yaml";
    in
    {
      secrets."ssh/lucidph3nx-ed25519-signingkey" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/lucidph3nx-ed25519-signingkey";
        sopsFile = sopsFile;
      };
      secrets."ssh/lucidph3nx-ed25519-signingkey.pub" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/lucidph3nx-ed25519-signingkey.pub";
        sopsFile = sopsFile;
      };
    };
  };
}
