{
  config,
  lib,
  ...
}: {
  options = {
    nx.sops.signingKeys.enable =
      lib.mkEnableOption "Set up signing keys";
  };
  config = lib.mkIf config.nx.sops.signingKeys.enable {
    sops.secrets = let
      sopsFile = ../../../secrets/signingKeys.yaml;
    in {
      "ssh/lucidph3nx-ed25519-signingkey" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/lucidph3nx-ed25519-signingkey";
        sopsFile = sopsFile;
      };
      "ssh/lucidph3nx-ed25519-signingkey.pub" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/lucidph3nx-ed25519-signingkey.pub";
        sopsFile = sopsFile;
      };
    };
    system.activationScripts.signingKeysFolderPermissions = ''
      mkdir -p /home/ben/.ssh
      chown ben:users /home/ben/.ssh
    '';
  };
}
