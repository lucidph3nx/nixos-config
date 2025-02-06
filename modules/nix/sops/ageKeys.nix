{
  config,
  lib,
  ...
}: {
  options = {
    nx.sops.ageKeys.enable =
      lib.mkEnableOption "Set up Age Keys";
  };
  config = lib.mkIf config.nx.sops.ageKeys.enable {
    sops.secrets = let
      sopsFile = ../../../secrets/ageKeys.yaml;
    in {
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
