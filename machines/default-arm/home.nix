{ config, pkgs, ... }:

{
  imports =
  [
    ../../modules/home-manager/scripts.nix
  ];
  sysDefaults = {
    terminal = "${pkgs.kitty}/bin/kitty";
  };
  # my own modules
  homeManagerModules = {
    firefox.enable = true; # testing removing and readding
    prospect-mail.enable = true;
    teams-for-linux.enable = true;
    # Enable home automation stuff as device should be in the home
    homeAutomation.enable = true;
    ssh.client.enable = true;
    ssh.client.workConfig.enable = true;
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
    KUBECONFIG = "/home/ben/.config/kube/config-home";
    PAGER = "less";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
