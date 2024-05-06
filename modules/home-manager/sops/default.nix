{ config, pkgs, lib, inputs, ... }: 

# NOTE: MACOS ONLY, use nix/sops.nix for nixos
{
  imports = [
    ./generalSecrets.nix
    ./signingKeys.nix
    ./homeSSHKeys.nix
    ./workSSH.nix
    ./kubeconfig.nix
    inputs.sops-nix.homeManagerModules.sops
  ];
  options = {
    homeManagerModules.sops.enable = lib.mkEnableOption "Enable sops home manager module";
  };
  config = lib.mkIf config.homeManagerModules.sops.enable {
    homeManagerModules = {
      sops.generalSecrets.enable = lib.mkDefault false;
      sops.signingKeys.enable = lib.mkDefault false;
      sops.homeSSHKeys.enable = lib.mkDefault false;
      sops.workSSH.enable = lib.mkDefault false;
      sops.kubeconfig.enable = lib.mkDefault false;
    };
    # sops defaults
    sops = {
      defaultSopsFile = ../../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";
      age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/nix-ed25519" ];
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      age.generateKey = true;
    };
  #   home.sessionVariables = {
  #     SOPS_AGE_KEY_FILE = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  #   };
  };
}
