{
  config,
  lib,
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
    };
  };
}
