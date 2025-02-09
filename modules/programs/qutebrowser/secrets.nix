{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.nx.programs.qutebrowser.enable {
    sops.secrets = {
      bookmarks = {
        owner = "ben";
        mode = "0600";
        sopsFile = ./secrets/bookmarks.sops.yaml;
        path = "${config.home-manager.users.ben.home.homeDirectory}/.config/qutebrowser/bookmarks/urls";
      };
      bitwarden_password = {
        owner = "ben";
        mode = "0600";
        sopsFile = ./secrets/bitwarden.sops.yaml;
      };
    };
    environment.sessionVariables = {
      BITWARDEN_PASSWORD = "$(cat ${config.sops.secrets.bitwarden_password.path})";
    };
  };
}
