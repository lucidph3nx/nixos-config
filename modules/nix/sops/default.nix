{ config, pkgs, lib, inputs, ... }: {
  imports = [
    ./generalSecrets.nix
    ./signingKeys.nix
    ./homeSSHKeys.nix
    ./workSSHKeys.nix
    ./workSSHConfig.nix
    inputs.sops-nix.nixosModules.sops
  ];
  config = {
    nixModules = {
      sops.generalSecrets.enable = lib.mkDefault false;
      sops.signingKeys.enable = lib.mkDefault false;
      sops.homeSSHKeys.enable = lib.mkDefault false;
      sops.workSSHKeys.enable = lib.mkDefault false;
      sops.workSSHConfig.enable = lib.mkDefault false;
    };
    # sops defaults
    sops = {
      gnupg.home = null; # I don't know why this needs setting
      defaultSopsFile = ../../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";
      age.keyFile = /home/ben/.config/sops/age/keys.txt;
    };
  };
}
