{
  lib,
  inputs,
  ...
}: {
  imports = [
    ./ageKeys.nix
    ./generalSecrets.nix
    ./homeSSHKeys.nix
    ./kubeconfig.nix
    ./signingKeys.nix
    inputs.sops-nix.nixosModules.sops
  ];
  config = {
    nixModules = {
      sops.ageKeys.enable = lib.mkDefault false;
      sops.generalSecrets.enable = lib.mkDefault false;
      sops.signingKeys.enable = lib.mkDefault false;
      sops.homeSSHKeys.enable = lib.mkDefault false;
      sops.kubeconfig.enable = lib.mkDefault false;
    };
    # sops defaults
    sops = {
      defaultSopsFile = ../../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";
      age = {
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
        # this needs to be the /persist path,
        # or else it wont be available when needed to create user passwords etc
        sshKeyPaths = ["/persist/system/etc/ssh/nix-ed25519"];
      };
    };
  };
}
