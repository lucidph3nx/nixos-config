{ config, pkgs, ... }:

{
  programs.git = {
  	enable = true;
    includes = [
      {
        contents = {
          user = {
            name = "lucidph3nx";
            email = "ben@tinfoilforest.nz";
            signingKey = "~/.ssh/lucidph3nx-ed25519-signingkey.pub";
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
