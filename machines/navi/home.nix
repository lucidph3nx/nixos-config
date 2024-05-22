{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
  ];
  # my own modules
  homeManagerModules = {
    firefox.hideUrlbar = true;
    prospect-mail.enable = true;
    teams-for-linux.enable = true;
    # Enable home automation stuff as device should be in the home
    homeAutomation.enable = true;
    sway.enable = true;
    hyprland.enable = true;
    ssh.client.enable = true;
    ssh.client.workConfig.enable = true;
  };
  home = {
    username = "ben";
    homeDirectory = "/home/ben";
  };
  home.stateVersion = "23.11"; # Do Not Touch!

  home.persistence."/persist/home/ben" = {
    allowOther = true;
    directories = [
      ".local/share/Steam"
      ".local/share/mpd"
      ".local/share/nvim"
      ".local/state"
      ".ssh"
      "code"
      "documents"
      "music"
      # these should be with the hm modules
      # but give compile errors on darwin
      ".mozilla/firefox"
      ".local/state/zsh"
      ".config/nvim/spell"
      ".config/github-copilot"
      ".config/teams-for-linux"
      ".config/Prospect Mail"
      ".asdf/installs"
      ".asdf/plugins"
      ".config/Bitwarden CLI"
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
