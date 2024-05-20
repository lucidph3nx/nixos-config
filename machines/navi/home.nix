{ config, pkgs, inputs, ... }:

{
  imports = 
  [
    inputs.impermanence.nixosModules.home-manager.impermanence
  ];
  # my own modules
  homeManagerModules = {
    firefox.hideUrlbar = true;
    prospect-mail.enable = true;
    teams-for-linux.enable = true;
    # Enable home automation stuff as device should be in the home
    homeAutomation.enable = true;
    # testing hyprland instead of sway
    sway.enable = true;
    hyprland.enable = false;
  };
  home = {
    username = "ben";
    homeDirectory = "/home/ben";
  };
  home.stateVersion = "23.11"; # Do Not Touch!
  
  home.persistence."/persist/home/ben" = {
    allowOther = true;
    directories = [
      ".config/autostart"
      ".local/share/Steam"
      ".local/share/mpd"
      ".local/share/nvim"
      ".local/state"
      ".ssh"
      "code"
      "documents"
      "music"
    ];
  };

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
