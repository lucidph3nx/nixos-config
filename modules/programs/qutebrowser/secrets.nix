{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.nx.programs.qutebrowser.enable {
    sops.secrets = {
      "bookmarks.sops" = {
        # using binary format to preserve multiline strings
        format = "binary";
        owner = "ben";
        mode = "0600";
        sopsFile = ./secrets/bookmarks.sops;
        path = "${config.home-manager.users.ben.home.homeDirectory}/.config/qutebrowser/bookmarks/urls";
      };
      bitwarden_password = {
        owner = "ben";
        mode = "0600";
        sopsFile = ./secrets/bitwarden.sops.yaml;
      };
    };
    system.activationScripts.qutebrowserFolderPermissions = ''
      mkdir -p /home/ben/.config/qutebrowser
      chown -R ben:users /home/ben/.config/qutebrowser
    '';
    environment.sessionVariables = {
      BITWARDEN_PASSWORD = "$(cat ${config.sops.secrets.bitwarden_password.path})";
    };
  };
}
