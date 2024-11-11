{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
  ];
  # my own modules
  homeManagerModules = {
    guiApps.enable = false; # console only vm
    # firefox.enable = true; # testing removing and readding
    # firefox.hideUrlbar = true;
    # prospect-mail.enable = true;
    # teams-for-linux.enable = true;
    # # Enable home automation stuff as device should be in the home
    hyprland.wallpaperResolution = "1680x1050";
    homeAutomation.enable = true;
    ssh.client.enable = true;
  };
  home = {
    username = "ben";
    homeDirectory = "/home/ben";
  };
  home.stateVersion = "23.11"; # Do Not Touch!

  # home.packages = with pkgs; [
  #   gimp # temp for troubleshooting
  #   picard
  #   # cinnamon.nemo
  # ];

  home.sessionVariables = {
    # KUBECONFIG = "/home/ben/.config/kube/config-home";
    PAGER = "less";
  };
}
