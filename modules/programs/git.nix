{
  config,
  lib,
  pkgs,
  ...
}: let
  homeDir = config.home-manager.users.ben.home.homeDirectory;
in {
  options = {
    nx.programs.git.enable =
      lib.mkEnableOption "enables git"
      // {
        default = true;
      };
  };
  config = lib.mkIf config.nx.programs.git.enable {
    home-manager.users.ben = {
      programs.ssh = {
        enable = true;
        matchBlocks = {
          "github.com" = {
            user = "git";
            hostname = "github.com";
            port = 22;
            identityFile = "${homeDir}/.ssh/lucidph3nx-ed25519";
          };
        };
      };
      programs.git = {
        enable = true;
        includes = [
          {
            contents = {
              user = {
                name = "lucidph3nx";
                email = "ben@tinfoilforest.nz";
                signingKey = "${homeDir}/.ssh/lucidph3nx-ed25519-signingkey.pub";
              };
              push = {
                autoSetupRemote = true;
              };
              init = {
                defaultBranch = "main";
              };
              gpg = {
                format = "ssh";
              };
              commit = {
                gpgsign = true;
              };
            };
          }
        ];
      };
      home.packages = with pkgs; [
        gh
      ];
    };
    # git signing keys
    sops.secrets = let
      sopsFile = ./secrets/ssh.sops.yaml;
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
