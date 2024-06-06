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
    obsidian.enable = true;
    calibre.enable = true;
    prospect-mail.enable = true;
    teams-for-linux.enable = true;
    # Enable home automation stuff as device should be in the home
    homeAutomation.enable = true;
    sway.enable = true;
    hyprland.enable = true;
    waybar.displayportOnly = true;
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
      ".asdf/installs"
      ".asdf/plugins"
      ".config/Bitwarden CLI"
      ".config/Prospect Mail"
      ".config/calibre"
      ".config/github-copilot"
      ".config/nvim/spell"
      ".config/obsidian"
      ".config/teams-for-linux"
      ".local/state/zsh"
      ".mozilla/firefox"
      ".terraform.d"
      # testing to figure out why syncthing errors so much
      ".config/syncthing/index-v0.14.0.db"
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
