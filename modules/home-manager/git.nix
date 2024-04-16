{ config, pkgs, ... }:

let 
  homeDir = config.home.homeDirectory;
in
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        user = "git";
        hostName = "github.com";
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
}
