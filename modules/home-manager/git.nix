{ config, pkgs, ... }:

{
  programs.git = {
  	enable = true;
    userName = "lucidph3nx";
    userEmail = "ben@tinfoilforest.nz";
    signing = {
      signByDefault = true;
      key = ~/.ssh/lucidph3nx-ed25519-signingkey.pub;
    };
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      push = {
        autoSetupRemote = true;
      };
      gpg = {
        format = "ssh";
      };
    };
  };
}
