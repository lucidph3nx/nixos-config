{ config, pkgs, ... }:

{
  imports = 
  [
    ../../modules/home-manager/kitty.nix
    ../../modules/home-manager/firefox.nix
  ];
  home.username = "ben";
  home.homeDirectory = "/Users/ben";
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  home.packages = with pkgs; [
    ripgrep
    neofetch
  ];
  home.sessionVariables = {
    PAGER = "less";
    EDITOR = "nvim";
  };
  programs.git.enable = true;
}
