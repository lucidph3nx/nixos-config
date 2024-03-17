{ config, pkgs, ... }:

{
  programs.git = {
  	enable = true;
    userName = "lucidph3nx";
    userEmail = "ben@tinfoilforest.nz";
  };
}
