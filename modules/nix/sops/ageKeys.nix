{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  options = {
    nixModules.sops.ageKeys.enable =
      lib.mkEnableOption "Set up Age Keys";
  };
  config = lib.mkIf config.nixModules.sops.ageKeys.enable {
    sops.secrets = let
      sopsFile = ../../../secrets/ageKeys.yaml;
    in {
      "personal" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.config/sops/age/keys.txt";
        sopsFile = sopsFile;
      };
    };
    environment.sessionVariables = {
      SOPS_AGE_KEY_FILE = "/home/ben/.config/sops/age/keys.txt";
    };
  };
}
