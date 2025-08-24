{
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
  options = {
    nx.system.sops.enable = lib.mkEnableOption "Enable sops module" // {
      default = true;
    };
    nx.system.sops.ageKeys.enable = lib.mkEnableOption "Add Age encryption keys to machine" // {
      default = false;
    };
  };
  config = {
    # general sops module options
    sops.age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
      # this needs to be the /persist path,
      # or else it wont be available when needed to create user passwords etc
      sshKeyPaths = [ "/persist/system/etc/ssh/nix-ed25519" ];
    };
    sops.secrets =
      let
        sopsFile = ./secrets/age.sops.yaml;
      in
      {
        "age/personal" = {
          owner = "ben";
          mode = "0600";
          path = "/home/ben/.config/sops/age/keys.txt";
          sopsFile = sopsFile;
        };
      };
    system.activationScripts.homeAgeKeysFolderPermissions = ''
      mkdir -p /home/ben/.config/sops/age
      chown ben:users /home/ben/.config/sops/age
    '';
    environment.sessionVariables = {
      SOPS_AGE_KEY_FILE = "/home/ben/.config/sops/age/keys.txt";
    };
  };
}
