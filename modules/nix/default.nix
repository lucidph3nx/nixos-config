{ pkgs, lib, ... }: {
  imports = [
    ./sops/generalSecrets.nix
    ./sops/signingKeys.nix
    ./sops/homeSSHKeys.nix
    ./sops/workSSHKeys.nix
  ];
  config = {
    nixModules = {
      sops.generalSecrets.enable = lib.mkDefault false;
      sops.signingKeys.enable = lib.mkDefault false;
      sops.homeSSHKeys.enable = lib.mkDefault false;
      sops.workSSHKeys.enable = lib.mkDefault false;
    };
  };
}
