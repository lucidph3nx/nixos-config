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
  homeManagerModules = {
    prospect-mail.enable = true;
    teams-for-linux.enable = true;
    # Enable home automation stuff as device should be in the home
    homeAutomation.enable = true;
  };
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "ben";
  home.homeDirectory = "/home/ben";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.
  
  home.packages = with pkgs; [
    gimp # temp for troubleshooting
    picard
    vimiv-qt
    # cinnamon.nemo
  ];

  home.sessionVariables = {
    PAGER = "less";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
