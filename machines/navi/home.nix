{ config, pkgs, nixpkgs-unstable, ... }:

{
  imports =
  [
    ../../modules/home-manager/nvim.nix
    ../../modules/home-manager/scripts.nix
    # ../../modules/home-manager/syncthing.nix
  ];
  sysDefaults = {
    terminal = "${pkgs.kitty}/bin/kitty";
  };
  # my own modules
  homeManagerModules = {
    prospect-mail.enable = true;
    teams-for-linux.enable = true;
    # Enable home automation stuff as device should be in the home
    homeAutomation.enable = true;
  };
  home = {
    username = "ben";
    homeDirectory = "/home/ben";
  };
  home.stateVersion = "23.11"; # Do Not Touch!
  
  home.packages = with pkgs; [
    gimp # temp for troubleshooting
    picard
    # cinnamon.nemo
  ];

  home.sessionVariables = {
    PAGER = "less";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
